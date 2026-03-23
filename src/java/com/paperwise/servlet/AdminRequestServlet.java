package com.paperwise.servlet;

import com.paperwise.dao.PaperRequestDAO;
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

@WebServlet("/adminRequests")
public class AdminRequestServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AdminRequestServlet.class.getName());

    private static final String VIEW_ADMIN_REQUESTS = "/adminRequests.jsp";
    private static final String ATTR_LOGGED_IN_USER = "loggedInUser";
    private static final String ROLE_ADMIN = "admin";

    private PaperRequestDAO requestDAO;

    @Override
    public void init() throws ServletException {
        try {
            requestDAO = new PaperRequestDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise PaperRequestDAO.", e);
            throw new ServletException("AdminRequestServlet initialisation failed.", e);
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
            List<PaperRequest> requests = requestDAO.getAllRequests();
            request.setAttribute("requests", requests);

            LOGGER.log(Level.INFO, "Admin {0} viewing {1} paper requests.",
                    new Object[]{loggedInUser.getUsername(), requests.size()});

            request.getRequestDispatcher(VIEW_ADMIN_REQUESTS).forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching paper requests for admin.", e);
            e.printStackTrace();
            request.setAttribute("errorMessage", "Failed to load requests. Please try again.");
            request.getRequestDispatcher(VIEW_ADMIN_REQUESTS).forward(request, response);
        }
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

        if (!ROLE_ADMIN.equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Administrator privileges required.");
            return;
        }

        String requestIdParam = request.getParameter("requestId");
        String status = request.getParameter("status");

        if (requestIdParam == null || requestIdParam.trim().isEmpty() ||
            status == null || status.trim().isEmpty()) {

            session.setAttribute("errorMessage", "Request ID and status are required.");
            response.sendRedirect(request.getContextPath() + "/adminRequests");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdParam);

            String normalizedStatus = status.trim().toLowerCase();
            if (!normalizedStatus.equals("approved") &&
                !normalizedStatus.equals("rejected") &&
                !normalizedStatus.equals("completed")) {

                session.setAttribute("errorMessage",
                        "Invalid status. Must be: approved, rejected, or completed.");
                response.sendRedirect(request.getContextPath() + "/adminRequests");
                return;
            }

            boolean success = requestDAO.updateStatus(requestId, normalizedStatus);

            if (success) {
                session.setAttribute("successMessage",
                        "Request status updated to '" + normalizedStatus + "' successfully!");
                LOGGER.log(Level.INFO,
                        "Admin {0} updated request {1} status to: {2}",
                        new Object[]{loggedInUser.getUsername(), requestId, normalizedStatus});
            } else {
                session.setAttribute("errorMessage", "Failed to update request status.");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid request ID format.");
            LOGGER.log(Level.WARNING, "Invalid request ID: {0}", requestIdParam);

        } catch (IllegalArgumentException e) {
            session.setAttribute("errorMessage", e.getMessage());
            LOGGER.log(Level.WARNING, "Validation error: {0}", e.getMessage());

        } catch (PaperRequestDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "DAO error updating request status.", e);
            e.printStackTrace();
            session.setAttribute("errorMessage", "Database error: " + e.getMessage());

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating request status.", e);
            e.printStackTrace();
            session.setAttribute("errorMessage",
                    "An unexpected error occurred: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/adminRequests");
    }
}