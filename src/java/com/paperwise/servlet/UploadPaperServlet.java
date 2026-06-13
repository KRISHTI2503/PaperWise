package com.paperwise.servlet;

import com.paperwise.dao.PaperDAO;
import com.paperwise.dao.PaperRequestDAO;
import com.paperwise.model.Paper;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/uploadPaper")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 5,
    maxFileSize = 1024 * 1024 * 200,
    maxRequestSize = 1024 * 1024 * 250
)
public class UploadPaperServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = Logger.getLogger(UploadPaperServlet.class.getName());

    private static final String UPLOAD_DIRECTORY = "uploads";
    private static final String VIEW_UPLOAD = "/WEB-INF/views/uploadPaper.jsp";

    private static final String ATTR_LOGGED_IN_USER = "loggedInUser";

    private static final String ROLE_ADMIN = "admin";

    private static final String[] ALLOWED_EXTENSIONS = {
        ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".txt",
        ".jpg", ".jpeg", ".png", ".mp4", ".mkv"
    };

    private PaperDAO paperDAO;
    private PaperRequestDAO paperRequestDAO;

    @Override
    public void init() throws ServletException {
        try {
            paperDAO = new PaperDAO();
            paperRequestDAO = new PaperRequestDAO();
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
            response.sendRedirect(request.getContextPath() + "/uploadPaper?invalid=true");
            return;
        }

        Part filePart = request.getPart("file");

        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect(request.getContextPath() + "/uploadPaper?invalid=true");
            return;
        }

        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

        if (!isValidFileExtension(fileName)) {
            response.sendRedirect(request.getContextPath() + "/uploadPaper?invalid=true");
            return;
        }

        try {
            String uploadPath = "C:/paperwise_uploads";
            File uploadDir = new File(uploadPath);

            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                if (!created) {
                    LOGGER.log(Level.SEVERE, "Failed to create upload directory: {0}", uploadPath);
                    response.sendRedirect(request.getContextPath() + "/uploadPaper?error=true");
                    return;
                }
                LOGGER.log(Level.INFO, "Created upload directory: {0}", uploadPath);
            }

            String uniqueFileName = generateUniqueFileName(fileName);

            filePart.write(uploadPath + File.separator + uniqueFileName);

            LOGGER.log(Level.INFO, "File saved successfully: {0}", uploadPath + File.separator + uniqueFileName);

            String filePath = uniqueFileName;

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
                    }
                }

                response.sendRedirect(request.getContextPath() + "/uploadPaper?uploaded=true");
                return;
            } else {
                File uploadedFile = new File(uploadPath + File.separator + uniqueFileName);
                if (uploadedFile.exists()) {
                    uploadedFile.delete();
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