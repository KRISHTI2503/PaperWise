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

 * Parameter: requestId, redirectUrl

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

        String contextPath = request.getContextPath();

        if (session == null) {

            response.sendRedirect(contextPath + "/login.jsp");

            return;

        }



        User user = (User) session.getAttribute("loggedInUser");

        if (user == null) {

            response.sendRedirect(contextPath + "/login.jsp");

            return;

        }



        String requestIdParam = request.getParameter("requestId");

        if (requestIdParam == null || requestIdParam.trim().isEmpty()) {

            response.sendRedirect(contextPath + "/studentDashboard?error=true");

            return;

        }



        try {

            int requestId = Integer.parseInt(requestIdParam.trim());

            requestDAO.deleteRequest(requestId, user.getUserId());

        } catch (NumberFormatException e) {

            response.sendRedirect(contextPath + "/studentDashboard?error=true");

            return;

        } catch (Exception e) {

        }



        String redirectUrl = request.getParameter("redirectUrl");

        if (redirectUrl == null || redirectUrl.trim().isEmpty()) {

            redirectUrl = contextPath + "/studentDashboard";

        }

        if (!redirectUrl.startsWith(contextPath)) {

            redirectUrl = contextPath + "/studentDashboard";

        }



        String separator = redirectUrl.contains("?") ? "&" : "?";
        String target = redirectUrl + separator + "request_deleted=true";

        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            response.setContentType("application/json;charset=UTF-8");
            String safe = target.replace("\\", "\\\\").replace("\"", "\\\"");
            response.getWriter().print("{\"success\":true,\"redirect\":\"" + safe + "\"}");
            return;
        }

        response.sendRedirect(target);
    }

}


