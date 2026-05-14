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

@WebServlet("/editPaper")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 5,
    maxFileSize = 1024 * 1024 * 200,
    maxRequestSize = 1024 * 1024 * 250
)
public class EditPaperServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(EditPaperServlet.class.getName());

    private static final String ATTR_LOGGED_IN_USER = "loggedInUser";
    private static final String ROLE_ADMIN = "admin";
    private static final String VIEW_EDIT_PAPER = "/editPaper.jsp";
    private static final String REDIRECT_ADMIN_DASHBOARD = "/adminDashboard";
    private static final String UPLOAD_DIRECTORY = "C:/paperwise_uploads";

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
            LOGGER.log(Level.SEVERE, "Failed to initialise PaperDAO in EditPaperServlet.", e);
            throw new ServletException("EditPaperServlet initialisation failed.", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User loggedInUser = (User) session.getAttribute(ATTR_LOGGED_IN_USER);
        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!ROLE_ADMIN.equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Administrator privileges required.");
            return;
        }

        String paperIdParam = request.getParameter("paperId");
        if (paperIdParam == null || paperIdParam.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Invalid paper ID.");
            response.sendRedirect(request.getContextPath() + REDIRECT_ADMIN_DASHBOARD);
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam);
            Paper paper = paperDAO.getPaperById(paperId);

            if (paper == null) {
                session.setAttribute("errorMessage", "Paper not found.");
                response.sendRedirect(request.getContextPath() + REDIRECT_ADMIN_DASHBOARD);
                return;
            }

            request.setAttribute("paper", paper);
            request.getRequestDispatcher(VIEW_EDIT_PAPER).forward(request, response);

        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid paper ID format.");
            LOGGER.log(Level.WARNING, "Invalid paper ID format: {0}", paperIdParam);
            response.sendRedirect(request.getContextPath() + REDIRECT_ADMIN_DASHBOARD);
        } catch (PaperDAO.DAOException e) {
            session.setAttribute("errorMessage", "Database error occurred while loading paper.");
            LOGGER.log(Level.SEVERE, "Error loading paper for edit.", e);
            response.sendRedirect(request.getContextPath() + REDIRECT_ADMIN_DASHBOARD);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User loggedInUser = (User) session.getAttribute(ATTR_LOGGED_IN_USER);
        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!ROLE_ADMIN.equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Administrator privileges required.");
            return;
        }

        String paperIdParam = request.getParameter("paperId");
        String subjectName  = request.getParameter("subjectName");
        String subjectCode  = request.getParameter("subjectCode");
        String yearParam    = request.getParameter("year");
        String chapter      = request.getParameter("chapter");
        String examType     = request.getParameter("examType");

        if (paperIdParam == null || paperIdParam.trim().isEmpty() ||
            subjectName == null || subjectName.trim().isEmpty() ||
            subjectCode == null || subjectCode.trim().isEmpty() ||
            yearParam == null || yearParam.trim().isEmpty()) {

            session.setAttribute("errorMessage", "All required fields must be filled.");
            response.sendRedirect(request.getContextPath() + "/editPaper?paperId=" + paperIdParam);
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam);
            int year = Integer.parseInt(yearParam);

            int currentYear = java.time.Year.now().getValue();
            int minYear = currentYear - 20;

            if (year < minYear || year > currentYear) {
                String errorMsg = "Year must be between " + minYear + " and " + currentYear + ".";
                session.setAttribute("errorMessage", errorMsg);
                response.sendRedirect(request.getContextPath() + "/editPaper?paperId=" + paperIdParam);
                return;
            }

            Paper paper = new Paper();
            paper.setPaperId(paperId);
            paper.setSubjectName(subjectName.trim());
            paper.setSubjectCode(subjectCode.trim());
            paper.setYear(year);
            paper.setChapter(chapter != null && !chapter.trim().isEmpty() ? chapter.trim() : null);
            paper.setExamType(examType != null && !examType.trim().isEmpty() ? examType.trim() : null);

            Part replacementFile = request.getPart("file");
            String replacementFileName = saveReplacementFileIfPresent(replacementFile);
            if (replacementFileName != null) {
                paper.setFileUrl(replacementFileName);
            }

            boolean success = paperDAO.updatePaper(paper);

            if (success) {
                LOGGER.log(Level.INFO, "Paper ID {0} updated by user {1}",
                        new Object[]{paperId, loggedInUser.getUsername()});
                response.sendRedirect(request.getContextPath() + REDIRECT_ADMIN_DASHBOARD + "?updated=true");
                return;
            } else {
                session.setAttribute("errorMessage", "Failed to update paper.");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid paper ID or year format.");
            LOGGER.log(Level.WARNING, "Invalid number format in edit form.");
        } catch (IllegalArgumentException e) {
            session.setAttribute("errorMessage", e.getMessage());
            LOGGER.log(Level.WARNING, "Invalid edit paper input: {0}", e.getMessage());
        } catch (IOException e) {
            session.setAttribute("errorMessage", "Failed to save replacement file.");
            LOGGER.log(Level.SEVERE, "Error saving replacement file.", e);
        } catch (PaperDAO.DAOException e) {
            session.setAttribute("errorMessage", "Database error occurred while updating paper.");
            LOGGER.log(Level.SEVERE, "Error updating paper.", e);
        }

        response.sendRedirect(request.getContextPath() + REDIRECT_ADMIN_DASHBOARD);
    }

    private String saveReplacementFileIfPresent(Part filePart) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        String submittedName = filePart.getSubmittedFileName();
        if (submittedName == null || submittedName.trim().isEmpty()) {
            return null;
        }

        String originalFileName = Paths.get(submittedName).getFileName().toString();
        if (!isValidFileExtension(originalFileName)) {
            throw new IllegalArgumentException(
                    "Invalid file type. Allowed types: PDF, DOC, DOCX, PPT, PPTX, TXT, JPG, PNG, MP4, MKV");
        }

        File uploadDir = new File(UPLOAD_DIRECTORY);
        if (!uploadDir.exists() && !uploadDir.mkdirs()) {
            throw new IOException("Failed to create upload directory: " + UPLOAD_DIRECTORY);
        }

        String uniqueFileName = generateUniqueFileName(originalFileName);
        filePart.write(UPLOAD_DIRECTORY + File.separator + uniqueFileName);
        return uniqueFileName;
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
}
