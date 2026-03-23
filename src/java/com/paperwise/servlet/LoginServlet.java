package com.paperwise.servlet;

import com.paperwise.dao.UserDAO;
import com.paperwise.model.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = Logger.getLogger(LoginServlet.class.getName());

    private static final String VIEW_LOGIN = "/login.jsp";
    private static final String REDIRECT_ADMIN_DASHBOARD = "/adminDashboard";
    private static final String REDIRECT_STUDENT_DASHBOARD = "/studentDashboard";

    private static final String ROLE_ADMIN = "admin";
    private static final String ROLE_STUDENT = "student";

    private static final String ATTR_ERROR = "errorMessage";
    private static final String ATTR_USER = "loggedInUser";

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        try {
            userDAO = new UserDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise UserDAO in LoginServlet.", e);
            throw new ServletException("LoginServlet initialisation failed: unable to create UserDAO.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = sanitise(request.getParameter("username"));
        String password = sanitise(request.getParameter("password"));

        if (username.isEmpty() || password.isEmpty()) {
            forwardWithError(request, response, "Username and password are required.");
            return;
        }

        try {
            boolean isValid = userDAO.validateLogin(username, password);

            if (!isValid) {
                forwardWithError(request, response, "Invalid username or password. Please try again.");
                return;
            }

            User user = userDAO.getUserByUsername(username);

            if (user == null) {
                LOGGER.log(Level.WARNING,
                        "Login validated for username ''{0}'' but no User record found.", username);
                forwardWithError(request, response,
                        "An unexpected error occurred. Please contact support.");
                return;
            }

            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            session = request.getSession(true);
            session.setAttribute(ATTR_USER, user);
            session.setMaxInactiveInterval(30 * 60);

            LOGGER.log(Level.INFO,
                    "User ''{0}'' authenticated successfully with role ''{1}''.",
                    new Object[]{user.getUsername(), user.getRole()});

            String redirectPath = resolveRedirectPath(request, user.getRole());
            response.sendRedirect(redirectPath);

        } catch (UserDAO.DAOException e) {
            LOGGER.log(Level.SEVERE,
                    "DAO error during login attempt for username: " + username, e);
            forwardWithError(request, response,
                    "A server error occurred. Please try again later.");
        }
    }

    private String resolveRedirectPath(HttpServletRequest request, String role) {
        String contextPath = request.getContextPath();

        if (ROLE_ADMIN.equalsIgnoreCase(role)) {
            return contextPath + REDIRECT_ADMIN_DASHBOARD;
        }

        return contextPath + REDIRECT_STUDENT_DASHBOARD;
    }

    private void forwardWithError(HttpServletRequest request,
                                  HttpServletResponse response,
                                  String message)
            throws ServletException, IOException {

        request.setAttribute(ATTR_ERROR, message);
        RequestDispatcher dispatcher = request.getRequestDispatcher(VIEW_LOGIN);
        dispatcher.forward(request, response);
    }

    private String sanitise(String value) {
        return (value == null) ? "" : value.trim();
    }
}