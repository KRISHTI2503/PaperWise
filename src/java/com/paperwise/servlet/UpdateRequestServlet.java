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
import java.util.Set;

@WebServlet("/updateRequest")
public class UpdateRequestServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Set<String> ALLOWED_STATUSES = Set.of("pending", "completed", "rejected");

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
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String requestIdStr = request.getParameter("requestId");
        String status = request.getParameter("status");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (requestIdStr == null || requestIdStr.trim().isEmpty() || status == null || status.trim().isEmpty()) {
            out.print("{\"success\":false}");
            out.flush();
            return;
        }

        String normalizedStatus = status.trim().toLowerCase();
        if ("approved".equals(normalizedStatus) || "accepted".equals(normalizedStatus)) {
            normalizedStatus = "completed";
        }

        if (!ALLOWED_STATUSES.contains(normalizedStatus)) {
            out.print("{\"success\":false}");
            out.flush();
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr.trim());
            boolean success = requestDAO.updateStatus(requestId, normalizedStatus);
            if (success) {
                out.print("{\"success\":true,\"status\":\"" + normalizedStatus + "\"}");
            } else {
                out.print("{\"success\":false}");
            }
        } catch (NumberFormatException e) {
            out.print("{\"success\":false}");
        } catch (Exception e) {
            out.print("{\"success\":false}");
        }
        out.flush();
    }
}
