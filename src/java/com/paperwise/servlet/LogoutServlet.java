package com.paperwise.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(LogoutServlet.class.getName());
    private static final String LOGIN_PAGE = "/login.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        performLogout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        performLogout(request, response);
    }

    private void performLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            String username = "unknown";
            Object userObj = session.getAttribute("loggedInUser");

            if (userObj != null) {
                try {
                    username = ((com.paperwise.model.User) userObj).getUsername();
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Could not extract username during logout", e);
                }
            }

            session.invalidate();
            LOGGER.log(Level.INFO, "User ''{0}'' logged out successfully.", username);
        }

        String contextPath = request.getContextPath();
        response.sendRedirect(contextPath + LOGIN_PAGE);
    }
}