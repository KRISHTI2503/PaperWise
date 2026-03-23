package com.paperwise.servlet;

import com.paperwise.dao.PaperDAO;
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
    private static final String VIEW_UPLOAD = "/upload.jsp";
    private static final String VIEW_ADMIN_DASHBOARD = "/admin-dashboard.jsp";

    private static final String ATTR_ERROR = "errorMessage";
    private static final String ATTR_SUCCESS = "successMessage";
    private static final String ATTR_LOGGED_IN_USER = "loggedInUser";

    private static final String ROLE_ADMIN = "admin";

    private static final String[] ALLOWED_EXTENSIONS = {
        ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".txt",
        ".jpg", ".jpeg", ".png", ".mp4", ".mkv"
    };

    private PaperDAO paperDAO;

    @Override
    public void init() throws ServletException {
        try {
            paperDAO = new PaperDAO();
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

        request.getRequestDispatcher(VIEW_UPLOAD).forward(request, response);
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
        String yearStr = sanitise(request.getParameter("year"));
        String chapter = sanitise(request.getParameter("chapter"));

        String validationError = validateInput(subjectName, subjectCode, yearStr);
        if (validationError != null) {
            request.setAttribute(ATTR_ERROR, validationError);
            request.getRequestDispatcher(VIEW_UPLOAD).forward(request, response);
            return;
        }

        int year = Integer.parseInt(yearStr);

        int currentYear = java.time.Year.now().getValue();
        int minYear = currentYear - 20;

        if (year < minYear || year > currentYear) {
            String errorMsg = "Year must be between " + minYear + " and " + currentYear + ".";
            request.setAttribute(ATTR_ERROR, errorMsg);
            request.getRequestDispatcher(VIEW_UPLOAD).forward(request, response);
            return;
        }

        Part filePart = request.getPart("file");

        if (filePart == null || filePart.getSize() == 0) {
            request.setAttribute(ATTR_ERROR, "Please select a file to upload.");
            request.getRequestDispatcher(VIEW_UPLOAD).forward(request, response);
            return;
        }

        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

        if (!isValidFileExtension(fileName)) {
            request.setAttribute(ATTR_ERROR,
                    "Invalid file type. Allowed types: PDF, DOC, DOCX, PPT, PPTX, TXT, JPG, PNG, MP4, MKV");
            request.getRequestDispatcher(VIEW_UPLOAD).forward(request, response);
            return;
        }

        try {
            String uploadPath = "C:/paperwise_uploads";
            File uploadDir = new File(uploadPath);

            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                if (!created) {
                    LOGGER.log(Level.SEVERE, "Failed to create upload directory: {0}", uploadPath);
                    request.setAttribute(ATTR_ERROR,
                            "Failed to create upload directory. Please contact administrator.");
                    request.getRequestDispatcher(VIEW_UPLOAD).forward(request, response);
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

            boolean success = paperDAO.savePaper(paper);

            if (success) {
                LOGGER.log(Level.INFO,
                        "Paper ''{0}'' uploaded successfully by user ''{1}''.",
                        new Object[]{subjectName, loggedInUser.getUsername()});

                HttpSession session = request.getSession();
                session.setAttribute(ATTR_SUCCESS,
                        "Paper '" + subjectName + "' uploaded successfully!");

                response.sendRedirect(request.getContextPath() + "/adminDashboard");
                return;
            } else {
                File uploadedFile = new File(uploadPath + File.separator + uniqueFileName);
                if (uploadedFile.exists()) {
                    uploadedFile.delete();
                }

                request.setAttribute(ATTR_ERROR,
                        "Failed to save paper information. Please try again.");
                request.getRequestDispatcher(VIEW_UPLOAD).forward(request, response);
            }

        } catch (PaperDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "DAO error during paper upload.", e);
            e.printStackTrace();
            request.setAttribute(ATTR_ERROR,
                    "A server error occurred. Please try again later.");
            request.getRequestDispatcher(VIEW_UPLOAD).forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error during file upload.", e);
            e.printStackTrace();
            request.setAttribute(ATTR_ERROR,
                    "An error occurred while uploading the file: " + e.getMessage());
            request.getRequestDispatcher(VIEW_UPLOAD).forward(request, response);
        }
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