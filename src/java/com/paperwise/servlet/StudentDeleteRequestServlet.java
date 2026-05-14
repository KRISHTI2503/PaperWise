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
import java.io.PrintWriter;

/**
 * Handles deletion of a student's own pending paper request.
 * POST /student/deleteRequest  { requestId }
 * Returns JSON: { success }
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

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // Session guard
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"error\":\"Not logged in\"}");
            return;
        }
        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"error\":\"Not logged in\"}");
            return;
        }

        String idParam = request.getParameter("requestId");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Missing requestId\"}");
            return;
        }

        int requestId;
        try {
            requestId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Invalid requestId\"}");
            return;
        }

        try {
            // deleteRequest checks user ownership — safe against IDOR
            boolean deleted = requestDAO.deleteRequest(requestId, user.getUserId());
            if (deleted) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"error\":\"Request not found or already deleted.\"}");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"error\":\"Database error.\"}");
        }
    }
}
