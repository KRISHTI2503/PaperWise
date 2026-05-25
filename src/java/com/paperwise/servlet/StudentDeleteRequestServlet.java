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

/**
 * Deletes a student's own paper request.
 * Accepts both fetch() and plain form POST.
 * Parameter: requestId
 */
@WebServlet("/student/deleteRequest")
public class StudentDeleteRequestServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private PaperRequestDAO requestDAO;

    @Override
    public void init() throws ServletException {
        requestDAO = new PaperRequestDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String requestIdParam = request.getParameter("requestId");
        if (requestIdParam == null || requestIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/studentDashboard");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdParam.trim());
            requestDAO.deleteRequest(requestId, user.getUserId());
        } catch (NumberFormatException e) {
            // ignore
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/studentDashboard");
    }
}
