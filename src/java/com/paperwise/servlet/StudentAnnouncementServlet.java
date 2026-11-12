package com.paperwise.servlet;

import com.paperwise.dao.AnnouncementDAO;
import com.paperwise.model.Announcement;
import com.paperwise.dao.NotificationDAO;
import com.paperwise.model.Notification;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/studentAnnouncements")
public class StudentAnnouncementServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(StudentAnnouncementServlet.class.getName());

    private static final String VIEW = "/studentAnnouncements.jsp";
    private static final String ATTR_USER = "loggedInUser";

    private AnnouncementDAO announcementDAO;

    @Override
    public void init() throws ServletException {
        try {
            announcementDAO = new AnnouncementDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise AnnouncementDAO in StudentAnnouncementServlet.", e);
            throw new ServletException("StudentAnnouncementServlet initialisation failed.", e);
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

        User user = (User) session.getAttribute(ATTR_USER);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Students only — admins use /announcements
        if (!"student".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            List<Announcement> announcements = announcementDAO.getActiveAnnouncements();
            request.setAttribute("announcements",
                    announcements != null ? announcements : new ArrayList<>());
        } catch (AnnouncementDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "Error loading active announcements for student.", e);
            request.setAttribute("announcements", new ArrayList<>());
        }

        // ── Load notification count and list ──────────────────────────────
        try {
            NotificationDAO notifDAO = new NotificationDAO();
            request.setAttribute("unreadCount", notifDAO.getUnreadCount(user.getUserId()));
            List<Notification> notifList = notifDAO.getNotificationsForUser(user.getUserId());
            request.setAttribute("notificationsList", notifList != null ? notifList : new ArrayList<>());
        } catch (Exception notifEx) {
            LOGGER.log(Level.WARNING, "Could not load notifications.", notifEx);
            request.setAttribute("unreadCount", 0);
            request.setAttribute("notificationsList", new ArrayList<>());
        }

        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
