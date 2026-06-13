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

            // Stat counts for dashboard cards
            long pendingCount   = requests.stream().filter(r -> "pending".equalsIgnoreCase(r.getStatus())).count();
            long completedCount = requests.stream().filter(r ->
                    "completed".equalsIgnoreCase(r.getStatus())
                    || "approved".equalsIgnoreCase(r.getStatus())
                    || "accepted".equalsIgnoreCase(r.getStatus())).count();
            long rejectedCount  = requests.stream().filter(r -> "rejected".equalsIgnoreCase(r.getStatus())).count();
            request.setAttribute("totalCount",     requests.size());
            request.setAttribute("pendingCount",   pendingCount);
            request.setAttribute("completedCount", completedCount);
            request.setAttribute("rejectedCount",  rejectedCount);

            LOGGER.log(Level.INFO, "Admin {0} viewing {1} paper requests.",
                    new Object[]{loggedInUser.getUsername(), requests.size()});

            request.getRequestDispatcher(VIEW_ADMIN_REQUESTS).forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching paper requests for admin.", e);
                        response.sendRedirect(request.getContextPath() + "/adminRequests?error=true");
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

        String action = request.getParameter("action");
        if ("deleteMessage".equals(action)) {
            String requestIdStr = request.getParameter("requestId");
            String adminReqBase = request.getContextPath() + "/adminRequests";
            if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
                response.sendRedirect(adminReqBase + "?error=true");
                return;
            }
            try {
                int requestId = Integer.parseInt(requestIdStr);
                requestDAO.deleteAdminMessage(requestId);
                LOGGER.log(Level.INFO,
                        "Admin {0} deleted message on request {1}",
                        new Object[]{loggedInUser.getUsername(), requestId});
            } catch (NumberFormatException e) {
                response.sendRedirect(adminReqBase + "?error=true");
                return;
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error deleting admin message.", e);
                response.sendRedirect(adminReqBase + "?error=true");
                return;
            }
            response.sendRedirect(adminReqBase + "?msg_deleted=true");
            return;
        }

        String requestIdParam = request.getParameter("requestId");
        String status = request.getParameter("status");
        String adminMessage = request.getParameter("adminMessage");

        if (requestIdParam == null || requestIdParam.trim().isEmpty() ||
            status == null || status.trim().isEmpty()) {

            response.sendRedirect(request.getContextPath() + "/adminRequests?error=true");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdParam);

            String normalizedStatus = status.trim().toLowerCase();
            if ("approved".equals(normalizedStatus) || "accepted".equals(normalizedStatus)) {
                normalizedStatus = "completed";
            }
            if (!normalizedStatus.equals("pending") &&
                !normalizedStatus.equals("rejected") &&
                !normalizedStatus.equals("completed")) {

                response.sendRedirect(request.getContextPath() + "/adminRequests?invalid=true");
                return;
            }

            boolean success = requestDAO.updateRequestStatus(requestId, normalizedStatus, adminMessage);

            if (success) {
                LOGGER.log(Level.INFO,
                        "Admin {0} updated request {1} status to: {2}",
                        new Object[]{loggedInUser.getUsername(), requestId, normalizedStatus});
                if (adminMessage != null && !adminMessage.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/adminRequests?msg_sent=true");
                } else {
                    response.sendRedirect(request.getContextPath() + "/adminRequests?status_updated=true");
                }
                return;
            }

        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid request ID: {0}", requestIdParam);

        } catch (IllegalArgumentException e) {
            LOGGER.log(Level.WARNING, "Validation error: {0}", e.getMessage());

        } catch (PaperRequestDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "DAO error updating request status.", e);
                    } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating request status.", e);
                    }

        response.sendRedirect(request.getContextPath() + "/adminRequests?error=true");
    }
}