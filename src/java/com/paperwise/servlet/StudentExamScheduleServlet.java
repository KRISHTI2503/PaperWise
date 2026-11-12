package com.paperwise.servlet;

import com.paperwise.dao.ExamScheduleDAO;
import com.paperwise.model.ExamSchedule;
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

@WebServlet("/studentExamSchedule")
public class StudentExamScheduleServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(StudentExamScheduleServlet.class.getName());

    private static final String VIEW = "/studentExamSchedule.jsp";
    private static final String ATTR_USER = "loggedInUser";

    private ExamScheduleDAO examScheduleDAO;

    @Override
    public void init() throws ServletException {
        try {
            examScheduleDAO = new ExamScheduleDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise ExamScheduleDAO.", e);
            throw new ServletException("StudentExamScheduleServlet initialisation failed.", e);
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

        if (!"student".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            List<ExamSchedule> upcomingExams = examScheduleDAO.getUpcomingExams();
            request.setAttribute("upcomingExams", upcomingExams != null ? upcomingExams : new ArrayList<>());
        } catch (ExamScheduleDAO.DAOException e) {
            LOGGER.log(Level.WARNING, "Could not load upcoming exams.", e);
            request.setAttribute("upcomingExams", new ArrayList<>());
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
