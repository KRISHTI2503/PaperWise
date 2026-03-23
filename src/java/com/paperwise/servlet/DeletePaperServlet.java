package com.paperwise.servlet;

import com.paperwise.dao.PaperDAO;
import com.paperwise.model.Paper;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/deletePaper")
public class DeletePaperServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(DeletePaperServlet.class.getName());

    private static final String ATTR_LOGGED_IN_USER = "loggedInUser";
    private static final String ROLE_ADMIN = "admin";
    private static final String REDIRECT_ADMIN_DASHBOARD = "/adminDashboard";

    private PaperDAO paperDAO;

    @Override
    public void init() throws ServletException {
        try {
            paperDAO = new PaperDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise PaperDAO in DeletePaperServlet.", e);
            throw new ServletException("DeletePaperServlet initialisation failed.", e);
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

            String fileUrl = paper.getFileUrl();
            if (fileUrl != null && !fileUrl.isEmpty()) {
                String filePath = "C:/paperwise_uploads" + File.separator + fileUrl;
                File file = new File(filePath);

                if (file.exists()) {
                    boolean deleted = file.delete();
                    if (deleted) {
                        LOGGER.log(Level.INFO, "Physical file deleted: {0}", filePath);
                    } else {
                        LOGGER.log(Level.WARNING, "Failed to delete physical file: {0}", filePath);
                    }
                } else {
                    LOGGER.log(Level.WARNING, "Physical file not found: {0}", filePath);
                }
            }

            boolean success = paperDAO.deletePaper(paperId);

            if (success) {
                session.setAttribute("successMessage",
                        "Paper '" + paper.getSubjectName() + "' deleted successfully!");
                LOGGER.log(Level.INFO, "Paper ID {0} deleted by user {1}",
                        new Object[]{paperId, loggedInUser.getUsername()});
            } else {
                session.setAttribute("errorMessage", "Failed to delete paper from database.");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid paper ID format.");
            LOGGER.log(Level.WARNING, "Invalid paper ID format: {0}", paperIdParam);
        } catch (PaperDAO.DAOException e) {
            session.setAttribute("errorMessage", "Database error occurred while deleting paper.");
            LOGGER.log(Level.SEVERE, "Error deleting paper.", e);
        }

        response.sendRedirect(request.getContextPath() + REDIRECT_ADMIN_DASHBOARD);
    }
}