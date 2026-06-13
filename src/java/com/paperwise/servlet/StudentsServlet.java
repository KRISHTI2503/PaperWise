package com.paperwise.servlet;

import com.paperwise.dao.PaperRequestDAO;
import com.paperwise.dao.UserDAO;
import com.paperwise.model.PaperRequest;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/students")
public class StudentsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(StudentsServlet.class.getName());

    private static final String VIEW_STUDENTS        = "/students.jsp";
    private static final String ATTR_LOGGED_IN_USER  = "loggedInUser";
    private static final String ROLE_ADMIN           = "admin";

    private UserDAO         userDAO;
    private PaperRequestDAO requestDAO;

    @Override
    public void init() throws ServletException {
        try {
            userDAO    = new UserDAO();
            requestDAO = new PaperRequestDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise DAOs in StudentsServlet.", e);
            throw new ServletException("StudentsServlet initialisation failed.", e);
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

        try {
            // All students with per-student counts
            List<User> students = userDAO.getAllStudents();
            request.setAttribute("students", students);

            // Stat: total students
            int totalStudents = students.size();
            request.setAttribute("totalStudents", totalStudents);

            // Stat: active this month (at least 1 vote OR 1 request in current month)
            int activeThisMonth = userDAO.getActiveStudentsThisMonth();
            request.setAttribute("activeThisMonth", activeThisMonth);

            // Stat: total useful marks given (sum across all students)
            int totalUsefulMarks = students.stream()
                    .mapToInt(User::getUsefulMarksGiven)
                    .sum();
            request.setAttribute("totalUsefulMarks", totalUsefulMarks);

            // Stat: total requests made (sum across all students)
            int totalRequests = students.stream()
                    .mapToInt(User::getRequestsMade)
                    .sum();
            request.setAttribute("totalRequests", totalRequests);

            // Pending requests count for sidebar badge
            List<PaperRequest> allRequests = requestDAO.getAllRequests();
            long pendingCount = allRequests.stream()
                    .filter(r -> "pending".equalsIgnoreCase(r.getStatus()))
                    .count();
            request.setAttribute("pendingRequestsCount", (int) pendingCount);

            LOGGER.log(Level.INFO,
                    "Students page loaded: {0} students, {1} active this month.",
                    new Object[]{totalStudents, activeThisMonth});

            request.getRequestDispatcher(VIEW_STUDENTS).forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading Students page.", e);
            response.sendRedirect(request.getContextPath() + "/students?error=true");
        }
    }
}
