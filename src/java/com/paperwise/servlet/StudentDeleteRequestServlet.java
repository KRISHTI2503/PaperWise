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

        HttpSession session = request.getSession(false);
        if (session == null) {
            out.print("{\"success\":false,\"error\":\"Not logged in\"}");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            out.print("{\"success\":false,\"error\":\"Not logged in\"}");
            return;
        }

        String requestIdParam = request.getParameter("requestId");
        if (requestIdParam == null || requestIdParam.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Missing requestId\"}");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdParam.trim());
            boolean deleted = requestDAO.deleteRequest(requestId, user.getUserId());

            if (deleted) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"error\":\"Request not found or not yours\"}");
            }

        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"error\":\"Invalid requestId\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"error\":\"Server error\"}");
        }
    }
}
