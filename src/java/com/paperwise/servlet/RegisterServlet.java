package com.paperwise.servlet;

import com.paperwise.dao.UserDAO;
import com.paperwise.model.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = Logger.getLogger(RegisterServlet.class.getName());

    private static final String VIEW_REGISTER = "/register.jsp";
    private static final String VIEW_LOGIN = "/login.jsp";

    private static final String ATTR_ERROR = "errorMessage";
    private static final String ATTR_SUCCESS = "successMessage";
    private static final String PARAM_SUCCESS = "success";

    private static final String DEFAULT_ROLE = "student";

    private static final int MIN_PASSWORD_LENGTH = 8;
    private static final int MIN_USERNAME_LENGTH = 3;

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        try {
            userDAO = new UserDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise UserDAO in RegisterServlet.", e);
            throw new ServletException("RegisterServlet initialisation failed: unable to create UserDAO.", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        RequestDispatcher dispatcher = request.getRequestDispatcher(VIEW_REGISTER);
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = sanitise(request.getParameter("username"));
        String email = sanitise(request.getParameter("email"));
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        String validationError = validateInput(username, email, password, confirmPassword);
        if (validationError != null) {
            forwardWithError(request, response, validationError);
            return;
        }

        try {
            if (userDAO.usernameExists(username)) {
                forwardWithError(request, response,
                        "Username '" + username + "' is already taken. Please choose another.");
                return;
            }

            User newUser = new User();
            newUser.setUsername(username);
            newUser.setEmail(email);
            newUser.setPassword(password);
            newUser.setRole(DEFAULT_ROLE);

            boolean success = userDAO.registerUser(newUser);

            if (success) {
                LOGGER.log(Level.INFO,
                        "New user ''{0}'' registered successfully with email ''{1}''.",
                        new Object[]{username, email});

                String contextPath = request.getContextPath();
                response.sendRedirect(contextPath + VIEW_LOGIN + "?" + PARAM_SUCCESS +
                        "=Account created successfully! Please login.");
            } else {
                forwardWithError(request, response,
                        "Registration failed. Please try again.");
            }

        } catch (UserDAO.DAOException e) {
            LOGGER.log(Level.SEVERE,
                    "DAO error during registration for username: " + username, e);
            forwardWithError(request, response,
                    "A server error occurred. Please try again later.");
        }
    }

    private String validateInput(String username, String email,
                                 String password, String confirmPassword) {

        if (username.isEmpty() || email.isEmpty() ||
            password == null || password.isEmpty() ||
            confirmPassword == null || confirmPassword.isEmpty()) {
            return "All fields are required.";
        }

        if (username.length() < MIN_USERNAME_LENGTH) {
            return "Username must be at least " + MIN_USERNAME_LENGTH + " characters long.";
        }

        if (!username.matches("^[a-zA-Z0-9_]+$")) {
            return "Username can only contain letters, numbers, and underscores.";
        }

        if (!isValidEmail(email)) {
            return "Please enter a valid email address.";
        }

        if (password.length() < MIN_PASSWORD_LENGTH) {
            return "Password must be at least " + MIN_PASSWORD_LENGTH + " characters long.";
        }

        if (!hasUpperCase(password)) {
            return "Password must contain at least one uppercase letter.";
        }

        if (!hasLowerCase(password)) {
            return "Password must contain at least one lowercase letter.";
        }

        if (!hasDigit(password)) {
            return "Password must contain at least one digit.";
        }

        if (!hasSpecialChar(password)) {
            return "Password must contain at least one special character (!@#$%^&*).";
        }

        if (!password.equals(confirmPassword)) {
            return "Passwords do not match.";
        }

        return null;
    }

    private boolean hasUpperCase(String password) {
        return password.matches(".*[A-Z].*");
    }

    private boolean hasLowerCase(String password) {
        return password.matches(".*[a-z].*");
    }

    private boolean hasDigit(String password) {
        return password.matches(".*\\d.*");
    }

    private boolean hasSpecialChar(String password) {
        return password.matches(".*[!@#$%^&*].*");
    }

    private boolean isValidEmail(String email) {
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        return email.matches(emailRegex);
    }

    private void forwardWithError(HttpServletRequest request,
                                  HttpServletResponse response,
                                  String message)
            throws ServletException, IOException {

        request.setAttribute(ATTR_ERROR, message);
        RequestDispatcher dispatcher = request.getRequestDispatcher(VIEW_REGISTER);
        dispatcher.forward(request, response);
    }

    private String sanitise(String value) {
        return (value == null) ? "" : value.trim();
    }
}