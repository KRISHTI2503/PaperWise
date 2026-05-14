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
import java.io.PrintWriter;
import java.sql.SQLException;

/**
 * Handles useful-mark toggle for students.
 * POST /student/markUseful  { paperId }
 * Returns JSON: { success, count, marked }
 */
@WebServlet("/student/markUseful")
public class StudentMarkUsefulServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private VoteDAO voteDAO;

    @Override
    public void init() throws ServletException {
        voteDAO = new VoteDAO();
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

        // Parse paperId
        String idParam = request.getParameter("paperId");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Missing paperId\"}");
            return;
        }

        int paperId;
        try {
            paperId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Invalid paperId\"}");
            return;
        }

        int userId = user.getUserId();

        try {
            boolean alreadyMarked = voteDAO.hasUserVoted(paperId, userId);

            if (alreadyMarked) {
                // Toggle off — remove the vote
                voteDAO.removeVote(paperId, userId);
            } else {
                // Toggle on — insert (ON CONFLICT DO NOTHING)
                voteDAO.insertVote(paperId, userId);
            }

            boolean nowMarked = !alreadyMarked;
            int newCount = voteDAO.getVoteCount(paperId);

            out.print("{\"success\":true,\"count\":" + newCount + ",\"marked\":" + nowMarked + "}");

        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"error\":\"Database error\"}");
        }
    }
}
