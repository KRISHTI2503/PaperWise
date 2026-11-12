package com.paperwise.servlet;

import com.paperwise.dao.PaperRequestDAO;
import com.paperwise.dao.NotificationDAO;
import com.paperwise.model.Notification;
import com.paperwise.model.PaperRequest;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.Year;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/requestPaper")
public class RequestPaperServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(RequestPaperServlet.class.getName());

    private static final String VIEW_REQUEST_FORM = "/requestPaper.jsp";
    private static final String REDIRECT_STUDENT_DASHBOARD = "/studentDashboard";
    private static final String ATTR_LOGGED_IN_USER = "loggedInUser";

    private PaperRequestDAO requestDAO;

    @Override
    public void init() throws ServletException {
        try {
            requestDAO = new PaperRequestDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise PaperRequestDAO.", e);
            throw new ServletException("RequestPaperServlet initialisation failed.", e);
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

        List<com.paperwise.model.PaperRequest> myRequests =
                requestDAO.getRequestsByUserId(loggedInUser.getUserId());
        request.setAttribute("myRequests",     myRequests);
        request.setAttribute("totalRequests",  myRequests.size());
        request.setAttribute("pendingCount",   myRequests.stream()
                .filter(r -> "pending".equalsIgnoreCase(r.getStatus())).count());
        request.setAttribute("completedCount", myRequests.stream()
                .filter(r -> "completed".equalsIgnoreCase(r.getStatus())).count());

        // ── Load notification count and list ──────────────────────────────
        try {
            NotificationDAO notifDAO = new NotificationDAO();
            request.setAttribute("unreadCount", notifDAO.getUnreadCount(loggedInUser.getUserId()));
            List<Notification> notifList = notifDAO.getNotificationsForUser(loggedInUser.getUserId());
            request.setAttribute("notificationsList", notifList != null ? notifList : new java.util.ArrayList<>());
        } catch (Exception notifEx) {
            request.setAttribute("unreadCount", 0);
            request.setAttribute("notificationsList", new java.util.ArrayList<>());
        }

        request.getRequestDispatcher(VIEW_REQUEST_FORM).forward(request, response);
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

        String action = request.getParameter("action");

        if ("update".equals(action)) {
            handleUpdate(request, response, loggedInUser);
        } else {
            handleCreate(request, response, loggedInUser);
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response, User loggedInUser)
            throws IOException {

        String subjectName = request.getParameter("subject_name");
        String subjectCode = request.getParameter("subject_code");
        String yearStr = request.getParameter("year");
        String description = request.getParameter("description");
        int userId = loggedInUser.getUserId();

        if (subjectName == null || subjectName.trim().isEmpty() ||
            subjectCode == null || subjectCode.trim().isEmpty() ||
            yearStr == null || yearStr.trim().isEmpty()) {

            response.sendRedirect(request.getContextPath() + "/requestPaper?invalid=true");
            return;
        }

        try {
            int year = Integer.parseInt(yearStr.trim());

            int currentYear = Year.now().getValue();
            int minYear = currentYear - 20;

            if (year < minYear || year > currentYear) {
                response.sendRedirect(request.getContextPath() + "/requestPaper?invalid=true");
                return;
            }

            PaperRequest paperRequest = new PaperRequest();
            paperRequest.setSubjectName(subjectName.trim());
            paperRequest.setSubjectCode(subjectCode.trim());
            paperRequest.setYear(year);
            paperRequest.setDescription(description != null ? description.trim() : null);
            paperRequest.setRequestedBy(userId);

            boolean success = requestDAO.saveRequest(paperRequest);

            if (success) {
                LOGGER.log(Level.INFO,
                        "Paper request submitted by user {0}: {1} ({2}) - Year {3}",
                        new Object[]{loggedInUser.getUsername(), subjectName, subjectCode, year});

                // ── Notify all admins about the new paper request ──
                try {
                    NotificationDAO notifDAO = new NotificationDAO();
                    String notifMsg = "New paper request: " + subjectName.trim() + " (" + subjectCode.trim() + ") - " + year;
                    // Don't exclude any user since student can't be admin
                    notifDAO.notifyAllAdmins(notifMsg, "/adminRequests", null);
                } catch (Exception notifEx) {
                    LOGGER.log(Level.WARNING, "Could not send admin notification for paper request.", notifEx);
                }

                response.sendRedirect(request.getContextPath() + "/requestPaper?submitted=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/requestPaper?error=true");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/requestPaper?invalid=true");

        } catch (IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath() + "/requestPaper?invalid=true");

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error submitting paper request.", e);
                        response.sendRedirect(request.getContextPath() + "/requestPaper?error=true");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, User loggedInUser)
            throws IOException {

        String requestIdStr = request.getParameter("requestId");
        String subjectName = request.getParameter("subject_name");
        String subjectCode = request.getParameter("subject_code");
        String yearStr = request.getParameter("year");
        String description = request.getParameter("description");
        int userId = loggedInUser.getUserId();

        if (requestIdStr == null || requestIdStr.trim().isEmpty() ||
            subjectName == null || subjectName.trim().isEmpty() ||
            subjectCode == null || subjectCode.trim().isEmpty() ||
            yearStr == null || yearStr.trim().isEmpty()) {

            response.sendRedirect(request.getContextPath() + "/requestPaper?invalid=true");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr.trim());
            int year = Integer.parseInt(yearStr.trim());

            int currentYear = Year.now().getValue();
            int minYear = currentYear - 20;

            if (year < minYear || year > currentYear) {
                response.sendRedirect(request.getContextPath() + "/requestPaper?invalid=true");
                return;
            }

            // Update only if owned by user and status is pending
            boolean success = requestDAO.updateRequest(requestId, subjectName.trim(),
                    subjectCode.trim(), year, description != null ? description.trim() : null, userId);

            if (success) {
                LOGGER.log(Level.INFO,
                        "Paper request {0} updated by user {1}: {2} ({3}) - Year {4}",
                        new Object[]{requestId, loggedInUser.getUsername(), subjectName, subjectCode, year});

                response.sendRedirect(request.getContextPath() + "/requestPaper?updated=true");
            } else {
                // No rows updated - either not owned or not pending
                response.sendRedirect(request.getContextPath() + "/requestPaper?error=true");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/requestPaper?invalid=true");

        } catch (IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath() + "/requestPaper?invalid=true");

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating paper request.", e);
            response.sendRedirect(request.getContextPath() + "/requestPaper?error=true");
        }
    }

    private void preserveFormData(HttpServletRequest request, String subjectName,
                                  String subjectCode, String year, String description) {
        request.setAttribute("subjectName", subjectName);
        request.setAttribute("subjectCode", subjectCode);
        request.setAttribute("year", year);
        request.setAttribute("description", description);
    }
}