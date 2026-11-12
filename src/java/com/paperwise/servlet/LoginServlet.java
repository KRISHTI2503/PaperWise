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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
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
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Simply forward to the login page JSP for display
        RequestDispatcher dispatcher = request.getRequestDispatcher(VIEW_LOGIN);
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== LoginServlet doPost START ===");
        
        String username = sanitise(request.getParameter("username"));
        String password = request.getParameter("password");  // Don't trim password - must match registration behavior
        
        // Validate parameters - handle null password
        if (password == null) {
            password = "";
        }
        
        System.out.println("Received username: " + username);
        System.out.println("Password received: " + (password != null && !password.isEmpty() ? "YES" : "NO"));

        if (username.isEmpty() || password.isEmpty()) {
            System.out.println("ERROR: Username or password is empty");
            forwardWithError(request, response, "Username and password are required.");
            return;
        }

        try {
            System.out.println("Calling userDAO.validateLogin()...");
            boolean isValid = userDAO.validateLogin(username, password);
            System.out.println("Login validation result: " + isValid);

            if (!isValid) {
                System.out.println("ERROR: Invalid credentials");
                forwardWithError(request, response, "Invalid username or password. Please try again.");
                return;
            }

            System.out.println("Calling userDAO.getUserByUsername()...");
            User user = userDAO.getUserByUsername(username);
            System.out.println("User object retrieved: " + (user != null ? "YES" : "NULL"));

            if (user == null) {
                System.out.println("ERROR: User is null after validation succeeded");
                LOGGER.log(Level.WARNING,
                        "Login validated for username ''{0}'' but no User record found.", username);
                forwardWithError(request, response,
                        "An unexpected error occurred. Please contact support.");
                return;
            }

            System.out.println("User details - ID: " + user.getUserId() + ", Role: " + user.getRole());

            HttpSession session = request.getSession(false);
            if (session != null) {
                System.out.println("Invalidating existing session");
                session.invalidate();
            }
            session = request.getSession(true);
            session.setAttribute(ATTR_USER, user);
            session.setMaxInactiveInterval(30 * 60);
            System.out.println("New session created with ID: " + session.getId());

            LOGGER.log(Level.INFO,
                    "User ''{0}'' authenticated successfully with role ''{1}''.",
                    new Object[]{user.getUsername(), user.getRole()});

            String redirectPath = resolveRedirectPath(request, user.getRole());
            System.out.println("Redirect path: " + redirectPath);
            System.out.println("=== LoginServlet doPost END - SUCCESS ===");
            response.sendRedirect(redirectPath);

        } catch (UserDAO.DAOException e) {
            System.out.println("ERROR: DAO Exception caught");
            System.out.println("Exception type: " + e.getClass().getName());
            System.out.println("Exception message: " + e.getMessage());
            e.printStackTrace();
            LOGGER.log(Level.SEVERE,
                    "DAO error during login attempt for username: " + username, e);
            forwardWithError(request, response,
                    "A server error occurred. Please try again later.");
        } catch (Exception e) {
            System.out.println("ERROR: Unexpected exception");
            System.out.println("Exception type: " + e.getClass().getName());
            System.out.println("Exception message: " + e.getMessage());
            e.printStackTrace();
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
            throws IOException {

        String encoded = URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath() + VIEW_LOGIN
                + "?msg=" + encoded + "&msgType=error");
    }

    private String sanitise(String value) {
        return (value == null) ? "" : value.trim();
    }
}