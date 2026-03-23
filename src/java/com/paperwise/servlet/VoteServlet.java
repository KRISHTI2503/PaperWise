package com.paperwise.servlet;

import com.paperwise.dao.VoteDAO;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/votePaper")
public class VoteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private VoteDAO voteDAO;

    @Override
    public void init() throws ServletException {
        try {
            voteDAO = new VoteDAO();
        } catch (Exception e) {
            System.err.println("Failed to initialise VoteDAO in VoteServlet.");
            e.printStackTrace();
            throw new ServletException("VoteServlet initialisation failed.", e);
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

        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!"student".equalsIgnoreCase(user.getRole())) {
            session.setAttribute("errorMessage", "Only students can vote for papers.");
            response.sendRedirect(request.getContextPath() + "/studentDashboard");
            return;
        }

        String paperIdParam = request.getParameter("id");
        if (paperIdParam == null || paperIdParam.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Invalid paper ID.");
            response.sendRedirect(request.getContextPath() + "/studentDashboard");
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam);
            int userId = user.getUserId();

            if (voteDAO.hasUserVoted(paperId, userId)) {
                session.setAttribute("errorMessage", "You already voted.");
                response.sendRedirect(request.getContextPath() + "/studentDashboard");
                return;
            }

            boolean success = voteDAO.insertVote(paperId, userId);

            if (success) {
                session.setAttribute("successMessage", "Vote added successfully!");
            } else {
                session.setAttribute("errorMessage", "Failed to add vote. Please try again.");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid paper ID format.");
            System.err.println("Invalid paper ID format: " + paperIdParam);
            e.printStackTrace();
        } catch (SQLException e) {
            session.setAttribute("errorMessage", "Database error occurred. Please try again.");
            System.err.println("Database error while processing vote:");
            e.printStackTrace();
        } catch (Exception e) {
            session.setAttribute("errorMessage", "An error occurred. Please try again.");
            System.err.println("Unexpected error while processing vote:");
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/studentDashboard");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}