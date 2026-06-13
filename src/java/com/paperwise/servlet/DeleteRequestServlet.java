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

            throw new ServletException("DeleteRequestServlet initialisation failed.", e);

        }

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



        User loggedInUser = (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {

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

            int userId = loggedInUser.getUserId();

            requestDAO.deleteRequest(requestId, userId);

        } catch (NumberFormatException e) {

            response.sendRedirect(contextPath + "/studentDashboard?error=true");

            return;

        } catch (PaperRequestDAO.DAOException e) {

            response.sendRedirect(contextPath + "/studentDashboard?error=true");

            return;

        }



        String redirectUrl = request.getParameter("redirectUrl");

        if (redirectUrl == null || redirectUrl.trim().isEmpty()) {

            redirectUrl = contextPath + "/studentDashboard";

        }

        if (!redirectUrl.startsWith(contextPath)) {

            redirectUrl = contextPath + "/studentDashboard";

        }



        String separator = redirectUrl.contains("?") ? "&" : "?";

        response.sendRedirect(redirectUrl + separator + "request_deleted=true");

    }

}


