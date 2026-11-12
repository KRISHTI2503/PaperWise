package com.paperwise.servlet;

import com.paperwise.dao.PaperDAO;
import com.paperwise.model.Paper;
import com.paperwise.model.User;
import com.paperwise.util.SupabaseStorageService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

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

        String contextPath = request.getContextPath();
        String paperIdParam = request.getParameter("paperId");
        if (paperIdParam == null || paperIdParam.trim().isEmpty()) {
            response.sendRedirect(contextPath + REDIRECT_ADMIN_DASHBOARD + "?error=true");
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam);

            Paper paper = paperDAO.getPaperById(paperId);
            if (paper == null) {
                response.sendRedirect(contextPath + REDIRECT_ADMIN_DASHBOARD + "?error=true");
                return;
            }

            // Delete file from Supabase Storage
            String fileUrl = paper.getFileUrl();
            if (fileUrl != null && !fileUrl.isEmpty()) {
                boolean deleted = SupabaseStorageService.deleteFile(fileUrl);
                if (deleted) {
                    LOGGER.log(Level.INFO, "File deleted from Supabase: {0}", fileUrl);
                } else {
                    LOGGER.log(Level.WARNING, "Failed to delete file from Supabase: {0}", fileUrl);
                }
            }

            // Delete database record
            boolean success = paperDAO.deletePaper(paperId);

            if (success) {
                LOGGER.log(Level.INFO, "Paper ID {0} deleted by user {1}",
                        new Object[]{paperId, loggedInUser.getUsername()});
                response.sendRedirect(contextPath + REDIRECT_ADMIN_DASHBOARD + "?deleted=true");
                return;
            }

        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid paper ID format: {0}", paperIdParam);
        } catch (PaperDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "Error deleting paper.", e);
        }

        response.sendRedirect(contextPath + REDIRECT_ADMIN_DASHBOARD + "?error=true");
    }
}
