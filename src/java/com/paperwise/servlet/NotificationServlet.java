package com.paperwise.servlet;

import com.paperwise.dao.NotificationDAO;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Handles notification actions: markAllRead, markRead.
 * Always redirects back to the referring page (or student dashboard as fallback).
 */
@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(NotificationServlet.class.getName());

    private NotificationDAO notificationDAO;

    @Override
    public void init() throws ServletException {
        try {
            notificationDAO = new NotificationDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise NotificationDAO.", e);
            throw new ServletException("NotificationServlet initialisation failed.", e);
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

        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Both students and admins use the notification system
        if (!"student".equalsIgnoreCase(user.getRole()) && !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String referer = request.getHeader("Referer");
        String fallback = "admin".equalsIgnoreCase(user.getRole()) 
            ? request.getContextPath() + "/adminDashboard"
            : request.getContextPath() + "/studentDashboard";
        String redirectTo = (referer != null && !referer.isEmpty()) ? referer : fallback;

        try {
            if ("markAllRead".equals(action)) {
                notificationDAO.markAllAsRead(user.getUserId());
                LOGGER.log(Level.INFO, "Marked all notifications read for user {0}", user.getUsername());

            } else if ("markRead".equals(action)) {
                String idStr = request.getParameter("id");
                String link  = request.getParameter("link");
                if (idStr != null && !idStr.trim().isEmpty()) {
                    try {
                        int notifId = Integer.parseInt(idStr.trim());
                        notificationDAO.markOneAsRead(notifId);
                    } catch (NumberFormatException e) {
                        LOGGER.log(Level.WARNING, "Invalid notification id: {0}", idStr);
                    }
                }
                // Navigate to the notification's link if provided
                if (link != null && !link.trim().isEmpty()) {
                    // link is stored as a relative path e.g. /studentDashboard
                    redirectTo = request.getContextPath() + link.trim();
                }
            }
        } catch (NotificationDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "Error processing notification action.", e);
        }

        response.sendRedirect(redirectTo);
    }

    // GET — treat same as POST for convenience (e.g. direct link clicks)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
