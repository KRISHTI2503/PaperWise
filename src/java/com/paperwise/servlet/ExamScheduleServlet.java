package com.paperwise.servlet;

import com.paperwise.dao.ExamScheduleDAO;
import com.paperwise.dao.NotificationDAO;
import com.paperwise.model.ExamSchedule;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/examSchedule")
public class ExamScheduleServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(ExamScheduleServlet.class.getName());

    private static final String VIEW = "/examSchedule.jsp";
    private static final String ATTR_USER = "loggedInUser";
    private static final String ROLE_ADMIN = "admin";

    private ExamScheduleDAO examScheduleDAO;

    @Override
    public void init() throws ServletException {
        try {
            examScheduleDAO = new ExamScheduleDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise ExamScheduleDAO.", e);
            throw new ServletException("ExamScheduleServlet initialisation failed.", e);
        }
    }

    // ── GET — show exam schedule management page ──────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getAdminOrRedirect(request, response);
        if (user == null) return;

        try {
            List<ExamSchedule> exams = examScheduleDAO.getAllExams();
            request.setAttribute("exams", exams);

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
        } catch (ExamScheduleDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "Error loading exam schedule page.", e);
            request.setAttribute("exams", new java.util.ArrayList<>());
        }

        request.setAttribute("pendingRequestsCount", 0);
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

        String subjectName = request.getParameter("subjectName");
        String subjectCode = request.getParameter("subjectCode");
        String examType    = request.getParameter("examType");
        String examDateStr = request.getParameter("examDate");

        if (subjectName == null || subjectName.trim().isEmpty() ||
            subjectCode == null || subjectCode.trim().isEmpty() ||
            examType    == null || examType.trim().isEmpty() ||
            examDateStr == null || examDateStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/examSchedule?error=invalid");
            return;
        }

        LocalDate examDate;
        try {
            examDate = LocalDate.parse(examDateStr.trim());
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Invalid exam date value: {0}", examDateStr);
            response.sendRedirect(request.getContextPath() + "/examSchedule?error=invalid");
            return;
        }

        try {
            boolean ok = examScheduleDAO.addExam(
                    subjectName.trim(), subjectCode.trim(), examType.trim(),
                    examDate, user.getUsername());
            if (ok) {
                LOGGER.log(Level.INFO, "Admin {0} added exam: {1} ({2}) on {3}",
                        new Object[]{user.getUsername(), subjectName.trim(), examType.trim(), examDate});

                // ── Notify all students about the new exam ────────────────
                try {
                    NotificationDAO notifDAO = new NotificationDAO();
                    String msg = "New exam scheduled: " + subjectName.trim()
                            + " (" + examType.trim() + ") on " + examDate.toString();
                    notifDAO.notifyAllStudents(msg, "/studentExamSchedule");
                } catch (Exception notifEx) {
                    LOGGER.log(Level.WARNING, "Could not send exam schedule notifications.", notifEx);
                }

                response.sendRedirect(request.getContextPath() + "/examSchedule?created=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/examSchedule?error=true");
            }
        } catch (ExamScheduleDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "Error adding exam schedule entry.", e);
            response.sendRedirect(request.getContextPath() + "/examSchedule?error=true");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response,
                               User user) throws IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/examSchedule?error=true");
            return;
        }

        try {
            int id = Integer.parseInt(idStr.trim());
            examScheduleDAO.deleteExam(id);
            LOGGER.log(Level.INFO, "Admin {0} deleted exam id={1}",
                    new Object[]{user.getUsername(), id});
            response.sendRedirect(request.getContextPath() + "/examSchedule?deleted=true");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/examSchedule?error=true");
        } catch (ExamScheduleDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "Error deleting exam schedule entry.", e);
            response.sendRedirect(request.getContextPath() + "/examSchedule?error=true");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response,
                              User user) throws IOException {

        String idStr = request.getParameter("id");
        String subjectName = request.getParameter("subjectName");
        String subjectCode = request.getParameter("subjectCode");
        String examType    = request.getParameter("examType");
        String examDateStr = request.getParameter("examDate");

        if (idStr == null || idStr.trim().isEmpty() ||
            subjectName == null || subjectName.trim().isEmpty() ||
            subjectCode == null || subjectCode.trim().isEmpty() ||
            examType    == null || examType.trim().isEmpty() ||
            examDateStr == null || examDateStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/examSchedule?error=invalid");
            return;
        }

        LocalDate examDate;
        int id;
        try {
            id = Integer.parseInt(idStr.trim());
            examDate = LocalDate.parse(examDateStr.trim());
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Invalid exam id or date value: id={0}, date={1}",
                    new Object[]{idStr, examDateStr});
            response.sendRedirect(request.getContextPath() + "/examSchedule?error=invalid");
            return;
        }

        try {
            boolean ok = examScheduleDAO.updateExam(
                    id, subjectName.trim(), subjectCode.trim(), examType.trim(), examDate);
            if (ok) {
                LOGGER.log(Level.INFO, "Admin {0} updated exam id={1}: {2} ({3}) on {4}",
                        new Object[]{user.getUsername(), id, subjectName.trim(), examType.trim(), examDate});
                response.sendRedirect(request.getContextPath() + "/examSchedule?updated=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/examSchedule?error=true");
            }
        } catch (ExamScheduleDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "Error updating exam schedule entry.", e);
            response.sendRedirect(request.getContextPath() + "/examSchedule?error=true");
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
