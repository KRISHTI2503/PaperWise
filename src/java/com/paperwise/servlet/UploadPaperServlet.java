package com.paperwise.servlet;

import com.paperwise.dao.NotificationDAO;
import com.paperwise.dao.PaperDAO;
import com.paperwise.dao.PaperRequestDAO;
import com.paperwise.model.Paper;
import com.paperwise.model.User;
import com.paperwise.util.SupabaseStorageService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/uploadPaper")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 20,
    maxRequestSize = 1024 * 1024 * 25
)
public class UploadPaperServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = Logger.getLogger(UploadPaperServlet.class.getName());

    private static final String VIEW_UPLOAD = "/WEB-INF/views/uploadPaper.jsp";

    private static final String ATTR_LOGGED_IN_USER = "loggedInUser";

    private static final String ROLE_ADMIN = "admin";

    private static final String UPLOAD_DIRECTORY = "uploads";

    private static final String[] ALLOWED_EXTENSIONS = {
        ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".txt",
        ".jpg", ".jpeg", ".png"
    };

    private PaperDAO paperDAO;
    private PaperRequestDAO paperRequestDAO;
    private boolean useSupabase = false;

    @Override
    public void init() throws ServletException {
        try {
            paperDAO = new PaperDAO();
            paperRequestDAO = new PaperRequestDAO();
            
            // Try to initialize Supabase, but fall back to local storage if it fails
            try {
                SupabaseStorageService.initialize();
                useSupabase = true;
                LOGGER.log(Level.INFO, "Using Supabase Storage for file uploads");
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Supabase not configured, using local file storage. Error: {0}", e.getMessage());
                useSupabase = false;
                
                // Ensure upload directory exists
                String uploadPath = getServletContext().getRealPath("/") + UPLOAD_DIRECTORY;
                java.io.File uploadDir = new java.io.File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise PaperDAO in UploadPaperServlet.", e);
            throw new ServletException("UploadPaperServlet initialisation failed: unable to create PaperDAO.", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Only administrators can upload papers.");
            return;
        }

        forwardUploadForm(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Only administrators can upload papers.");
            return;
        }

        User loggedInUser = getLoggedInUser(request);

        String subjectName = sanitise(request.getParameter("subjectName"));
        String subjectCode = sanitise(request.getParameter("subjectCode"));
        String yearStr     = sanitise(request.getParameter("year"));
        String chapter     = sanitise(request.getParameter("chapter"));
        String examType    = sanitise(request.getParameter("examType"));
        String description = sanitise(request.getParameter("description"));

        String validationError = validateInput(subjectName, subjectCode, yearStr);
        if (validationError != null) {
            response.sendRedirect(request.getContextPath() + "/uploadPaper?invalid=true");
            return;
        }

        int year = Integer.parseInt(yearStr);

        int currentYear = java.time.Year.now().getValue();
        int minYear = currentYear - 20;

        if (year < minYear || year > currentYear) {
            LOGGER.log(Level.WARNING, "File upload rejected: Invalid year: {0}", year);
            response.sendRedirect(request.getContextPath() + "/uploadPaper?msg=" + 
                java.net.URLEncoder.encode("Year must be between " + minYear + " and " + currentYear, "UTF-8") + "&msgType=warning");
            return;
        }

        Part filePart = request.getPart("file");

        if (filePart == null || filePart.getSize() == 0) {
            LOGGER.log(Level.WARNING, "File upload rejected: No file selected");
            response.sendRedirect(request.getContextPath() + "/uploadPaper?msg=" + 
                java.net.URLEncoder.encode("Please select a file to upload", "UTF-8") + "&msgType=warning");
            return;
        }

        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

        if (!isValidFileExtension(fileName)) {
            LOGGER.log(Level.WARNING, "File upload rejected: Invalid file type: {0}", fileName);
            response.sendRedirect(request.getContextPath() + "/uploadPaper?msg=" + 
                java.net.URLEncoder.encode("File type not allowed. Only PDF, DOC, DOCX, PPT, PPTX, TXT, JPG, PNG are allowed", "UTF-8") + "&msgType=warning");
            return;
        }
        
        // Check file size (max 20MB)
        if (filePart.getSize() > 1024 * 1024 * 20) {
            LOGGER.log(Level.WARNING, "File upload rejected: File too large: {0} bytes", filePart.getSize());
            response.sendRedirect(request.getContextPath() + "/uploadPaper?msg=" + 
                java.net.URLEncoder.encode("File too large. Maximum size is 20MB", "UTF-8") + "&msgType=warning");
            return;
        }

        try {
            // Upload file to either Supabase or local storage
            String filePath;
            
            if (useSupabase) {
                // Upload to Supabase Storage
                String contentType = filePart.getContentType();
                try (InputStream fileInputStream = filePart.getInputStream()) {
                    filePath = SupabaseStorageService.uploadFile(fileInputStream, fileName, contentType);
                }

                if (filePath == null) {
                    LOGGER.log(Level.SEVERE, "Failed to upload file to Supabase Storage");
                    response.sendRedirect(request.getContextPath() + "/uploadPaper?msg=" + 
                        java.net.URLEncoder.encode("File storage unavailable, try again later", "UTF-8") + "&msgType=error");
                    return;
                }
                LOGGER.log(Level.INFO, "File uploaded successfully to Supabase: {0}", filePath);
            } else {
                // Check if production mode - fail if Supabase not available
                if (SupabaseStorageService.isProduction()) {
                    LOGGER.log(Level.SEVERE, "Production mode: Supabase not configured, upload rejected");
                    response.sendRedirect(request.getContextPath() + "/uploadPaper?msg=" + 
                        java.net.URLEncoder.encode("File storage unavailable, try again later", "UTF-8") + "&msgType=error");
                    return;
                }
                
                // Local mode - upload to local storage
                String uploadPath = getServletContext().getRealPath("/") + UPLOAD_DIRECTORY;
                java.io.File uploadDir = new java.io.File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                
                // Generate unique filename
                String uniqueFileName = java.util.UUID.randomUUID().toString() + "-" + fileName;
                filePath = UPLOAD_DIRECTORY + "/" + uniqueFileName;
                java.io.File file = new java.io.File(uploadPath, uniqueFileName);
                
                // Save file
                try (InputStream input = filePart.getInputStream();
                     java.io.OutputStream output = new java.io.FileOutputStream(file)) {
                    byte[] buffer = new byte[1024];
                    int bytesRead;
                    while ((bytesRead = input.read(buffer)) != -1) {
                        output.write(buffer, 0, bytesRead);
                    }
                }
                LOGGER.log(Level.INFO, "File uploaded successfully to local storage: {0}", filePath);
            }

            Paper paper = new Paper();
            paper.setSubjectName(subjectName);
            paper.setSubjectCode(subjectCode);
            paper.setYear(year);

            if (chapter != null && !chapter.isEmpty()) {
                paper.setChapter(chapter);
            } else {
                paper.setChapter(null);
            }

            paper.setFileUrl(filePath);
            paper.setUploadedBy(loggedInUser.getUserId());
            paper.setExamType(examType != null && !examType.isEmpty() ? examType : null);
            paper.setDescription(description != null && !description.isEmpty() ? description : null);

            boolean success = paperDAO.savePaper(paper);

            if (success) {
                LOGGER.log(Level.INFO,
                        "Paper ''{0}'' uploaded successfully by user ''{1}''.",
                        new Object[]{subjectName, loggedInUser.getUsername()});

                String requestId = request.getParameter("requestId");
                if (requestId != null && !requestId.trim().isEmpty()) {
                    try {
                        int reqId = Integer.parseInt(requestId.trim());
                        paperRequestDAO.updateStatus(reqId, "completed");
                    } catch (Exception e) {
                        // Ignore request ID processing errors
                    }
                }

                // ── Notify all students about the new paper ───────────────
                try {
                    NotificationDAO notifDAO = new NotificationDAO();
                    String msg = "New paper uploaded: " + subjectName + " (" + year + ")";
                    notifDAO.notifyAllStudents(msg, "/studentDashboard");
                } catch (Exception notifEx) {
                    LOGGER.log(Level.WARNING, "Could not send paper upload notifications.", notifEx);
                }

                response.sendRedirect(request.getContextPath() + "/uploadPaper?uploaded=true");
                return;
            } else {
                // Delete file if database save failed
                if (useSupabase) {
                    SupabaseStorageService.deleteFile(filePath);
                } else {
                    java.io.File fileToDelete = new java.io.File(getServletContext().getRealPath("/"), filePath);
                    if (fileToDelete.exists()) {
                        fileToDelete.delete();
                    }
                }
                response.sendRedirect(request.getContextPath() + "/uploadPaper?error=true");
            }

        } catch (PaperDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "DAO error during paper upload.", e);
            response.sendRedirect(request.getContextPath() + "/uploadPaper?error=true");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error during file upload.", e);
            response.sendRedirect(request.getContextPath() + "/uploadPaper?error=true");
        }
    }

    private void forwardUploadForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("recentPapers", paperDAO.getRecentPapers(3));

        // ── Load notification count and list for admin ──────────────────────────────
        HttpSession session = request.getSession(false);
        if (session != null) {
            User loggedInUser = (User) session.getAttribute("loggedInUser");
            if (loggedInUser != null) {
                try {
                    NotificationDAO notifDAO = new NotificationDAO();
                    request.setAttribute("unreadCount", notifDAO.getUnreadCount(loggedInUser.getUserId()));
                    java.util.List<com.paperwise.model.Notification> notifList = notifDAO.getNotificationsForUser(loggedInUser.getUserId());
                    request.setAttribute("notificationsList", notifList != null ? notifList : new java.util.ArrayList<>());
                } catch (Exception notifEx) {
                    LOGGER.log(Level.WARNING, "Could not load admin notifications.", notifEx);
                    request.setAttribute("unreadCount", 0);
                    request.setAttribute("notificationsList", new java.util.ArrayList<>());
                }
            }
        }

        request.getRequestDispatcher(VIEW_UPLOAD).forward(request, response);
    }

    private boolean isAdmin(HttpServletRequest request) {
        User user = getLoggedInUser(request);
        return user != null && ROLE_ADMIN.equalsIgnoreCase(user.getRole());
    }

    private User getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (User) session.getAttribute(ATTR_LOGGED_IN_USER);
        }
        return null;
    }

    private String validateInput(String subjectName, String subjectCode, String yearStr) {
        if (subjectName.isEmpty() || subjectCode.isEmpty() || yearStr.isEmpty()) {
            return "Subject name, subject code, and year are required.";
        }

        if (subjectName.length() > 150) {
            return "Subject name is too long (maximum 150 characters).";
        }

        if (subjectCode.length() > 50) {
            return "Subject code is too long (maximum 50 characters).";
        }

        try {
            int year = Integer.parseInt(yearStr);
            int currentYear = java.time.Year.now().getValue();
            int minYear = currentYear - 20;

            if (year < minYear || year > currentYear) {
                return "Year must be between " + minYear + " and " + currentYear + ".";
            }
        } catch (NumberFormatException e) {
            return "Year must be a valid number.";
        }

        return null;
    }

    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String content : contentDisposition.split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim()
                        .replace("\"", "");
            }
        }
        return "unknown";
    }

    private boolean isValidFileExtension(String fileName) {
        String lowerFileName = fileName.toLowerCase();
        for (String ext : ALLOWED_EXTENSIONS) {
            if (lowerFileName.endsWith(ext)) {
                return true;
            }
        }
        return false;
    }

    private String generateUniqueFileName(String originalFileName) {
        String timestamp = String.valueOf(System.currentTimeMillis());
        String extension = "";

        int lastDot = originalFileName.lastIndexOf('.');
        if (lastDot > 0) {
            extension = originalFileName.substring(lastDot);
            originalFileName = originalFileName.substring(0, lastDot);
        }

        originalFileName = originalFileName.replaceAll("[^a-zA-Z0-9_-]", "_");

        return timestamp + "_" + originalFileName + extension;
    }

    private String sanitise(String value) {
        return (value == null) ? "" : value.trim();
    }
}