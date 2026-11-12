package com.paperwise.servlet;

import com.paperwise.dao.AnnouncementDAO;
import com.paperwise.dao.NotificationDAO;
import com.paperwise.model.Announcement;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/announcements")
public class AnnouncementServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AnnouncementServlet.class.getName());

    private static final String VIEW = "/announcements.jsp";
    private static final String ATTR_USER = "loggedInUser";
    private static final String ROLE_ADMIN = "admin";

    private AnnouncementDAO announcementDAO;

    @Override
    public void init() throws ServletException {
        try {
            announcementDAO = new AnnouncementDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise AnnouncementDAO.", e);
            throw new ServletException("AnnouncementServlet initialisation failed.", e);
        }
    }

    // ── GET — show announcement management page ──────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getAdminOrRedirect(request, response);
        if (user == null) return;

        try {
            List<Announcement> announcements = announcementDAO.getAllAnnouncements();
            request.setAttribute("announcements", announcements);
            request.setAttribute("pendingRequestsCount", 0); // sidebar badge placeholder

            // ── Load notification count and list for admin ──────────────────────────────
            try {
                NotificationDAO notifDAO = new NotificationDAO();
                request.setAttribute("unreadCount", notifDAO.getUnreadCount(user.getUserId()));
                java.util.List<com.paperwise.model.Notification> notifList = notifDAO.getNotificationsForUser(user.getUserId());
                request.setAttribute("notificationsList", notifList != null ? notifList : new java.util.ArrayList<>());
            } catch (Exception notifEx) {
                LOGGER.log(Level.WARNING, "Could not load admin notifications.", notifEx);
                request.setAttribute("unreadCount", 0);
                request.setAttribute("notificationsList", new java.util.ArrayList<>());
            }
        } catch (AnnouncementDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "Error loading announcements page.", e);
        }

        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    // ── POST — create, update, or delete ─────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getAdminOrRedirect(request, response);
        if (user == null) return;

        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            handleDelete(request, response, user);
        } else if ("update".equals(action)) {
            handleUpdate(request, response, user);
        } else {
            handleCreate(request, response, user);
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response,
                               User user) throws IOException {

        String title    = request.getParameter("title");
        String body     = request.getParameter("body");
        String pinStr   = request.getParameter("isPinned");
        String expStr   = request.getParameter("expiresAt");   // optional, e.g. "2026-12-31T23:59"

        if (title == null || title.trim().isEmpty() ||
            body  == null || body.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/announcements?error=invalid");
            return;
        }

        boolean isPinned = "on".equals(pinStr) || "true".equals(pinStr);

        Timestamp expiresAt = null;
        if (expStr != null && !expStr.trim().isEmpty()) {
            try {
                // HTML datetime-local format: "yyyy-MM-ddTHH:mm"
                LocalDateTime ldt = LocalDateTime.parse(expStr.trim());
                expiresAt = Timestamp.valueOf(ldt);
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Invalid expires_at value: {0}", expStr);
                // ignore bad input — treat as no expiry
            }
        }

        try {
            boolean ok = announcementDAO.createAnnouncement(
                    title.trim(), body.trim(), user.getUserId(), isPinned, expiresAt);
            if (ok) {
                LOGGER.log(Level.INFO, "Admin {0} created announcement: {1}",
                        new Object[]{user.getUsername(), title.trim()});

                // ── Notify all students about the new announcement ────────
                try {
                    NotificationDAO notifDAO = new NotificationDAO();
                    notifDAO.notifyAllStudents(
                            "New announcement: " + title.trim(),
                            "/studentAnnouncements");
                } catch (Exception notifEx) {
                    LOGGER.log(Level.WARNING, "Could not send announcement notifications.", notifEx);
                }

                response.sendRedirect(request.getContextPath() + "/announcements?created=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/announcements?error=true");
            }
        } catch (AnnouncementDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "Error creating announcement.", e);
            response.sendRedirect(request.getContextPath() + "/announcements?error=true");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response,
                               User user) throws IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/announcements?error=true");
            return;
        }

        try {
            int id = Integer.parseInt(idStr.trim());
            announcementDAO.deleteAnnouncement(id);
            LOGGER.log(Level.INFO, "Admin {0} deleted announcement id={1}",
                    new Object[]{user.getUsername(), id});
            response.sendRedirect(request.getContextPath() + "/announcements?deleted=true");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/announcements?error=true");
        } catch (AnnouncementDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "Error deleting announcement.", e);
            response.sendRedirect(request.getContextPath() + "/announcements?error=true");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response,
                              User user) throws IOException {

        String idStr    = request.getParameter("id");
        String title    = request.getParameter("title");
        String body     = request.getParameter("body");
        String pinStr   = request.getParameter("isPinned");
        String expStr   = request.getParameter("expiresAt");   // optional, e.g. "2026-12-31T23:59"

        if (idStr == null || idStr.trim().isEmpty() ||
            title == null || title.trim().isEmpty() ||
            body  == null || body.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/announcements?error=invalid");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid announcement id: {0}", idStr);
            response.sendRedirect(request.getContextPath() + "/announcements?error=invalid");
            return;
        }

        boolean isPinned = "on".equals(pinStr) || "true".equals(pinStr);

        Timestamp expiresAt = null;
        if (expStr != null && !expStr.trim().isEmpty()) {
            try {
                // HTML datetime-local format: "yyyy-MM-ddTHH:mm"
                LocalDateTime ldt = LocalDateTime.parse(expStr.trim());
                expiresAt = Timestamp.valueOf(ldt);
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Invalid expires_at value: {0}", expStr);
                // ignore bad input — treat as no expiry
            }
        }

        try {
            boolean ok = announcementDAO.updateAnnouncement(
                    id, title.trim(), body.trim(), isPinned, expiresAt);
            if (ok) {
                LOGGER.log(Level.INFO, "Admin {0} updated announcement id={1}: {2}",
                        new Object[]{user.getUsername(), id, title.trim()});
                response.sendRedirect(request.getContextPath() + "/announcements?updated=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/announcements?error=true");
            }
        } catch (AnnouncementDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "Error updating announcement.", e);
            response.sendRedirect(request.getContextPath() + "/announcements?error=true");
        }
    }

    // ── Helper: validate admin session, redirect otherwise ───────────────────
    private User getAdminOrRedirect(HttpServletRequest request,
                                    HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return null;
        }
        User user = (User) session.getAttribute(ATTR_USER);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return null;
        }
        if (!ROLE_ADMIN.equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Administrator privileges required.");
            return null;
        }
        return user;
    }
}
