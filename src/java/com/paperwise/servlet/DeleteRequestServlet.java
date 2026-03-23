package com.paperwise.servlet;

import com.paperwise.dao.PaperRequestDAO;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/deleteRequest")
public class DeleteRequestServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private PaperRequestDAO requestDAO;

    @Override
    public void init() throws ServletException {
        try {
            requestDAO = new PaperRequestDAO();
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("DeleteRequestServlet initialisation failed.", e);
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

        User loggedInUser = (User) session.getAttribute("loggedInUser");
        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String requestIdParam = request.getParameter("requestId");
        if (requestIdParam == null || requestIdParam.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Invalid request.");
            response.sendRedirect(request.getContextPath() + "/studentDashboard");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdParam.trim());
            int userId = loggedInUser.getUserId();

            boolean deleted = requestDAO.deleteRequest(requestId, userId);

            if (deleted) {
                session.setAttribute("successMessage", "Request deleted successfully.");
            } else {
                session.setAttribute("errorMessage",
                        "Request could not be deleted. It may not exist or belong to another user.");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid request ID.");
        } catch (PaperRequestDAO.DAOException e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "A database error occurred. Please try again.");
        }

        response.sendRedirect(request.getContextPath() + "/studentDashboard");
    }
}