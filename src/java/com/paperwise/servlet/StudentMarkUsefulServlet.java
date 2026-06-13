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

/**
 * Toggles "Mark as Useful" for a paper.
 * Accepts fetch() POST with JSON response, or plain form POST with redirect.
 * Parameters: paperId, action (mark|unmark — optional, auto-detected if absent)
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

        HttpSession session = request.getSession(false);
        if (session == null) {
            sendJsonError(response, "Not authenticated");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            sendJsonError(response, "Not authenticated");
            return;
        }

        String paperIdParam = request.getParameter("paperId");
        if (paperIdParam == null || paperIdParam.trim().isEmpty()) {
            sendJsonError(response, "Missing paperId");
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam.trim());
            int userId  = user.getUserId();

            // Support explicit action param (from fetch) or auto-detect (from form)
            String action = request.getParameter("action");
            if (action == null || action.trim().isEmpty()) {
                // Legacy form POST: auto-toggle
                boolean alreadyMarked = voteDAO.hasUserMarked(paperId, userId);
                if (alreadyMarked) {
                    voteDAO.removeVote(paperId, userId);
                } else {
                    voteDAO.addMark(paperId, userId);
                }
            } else if ("unmark".equalsIgnoreCase(action.trim())) {
                voteDAO.removeVote(paperId, userId);
            } else {
                // "mark" or anything else → add
                voteDAO.addMark(paperId, userId);
            }

            // Get updated count and marked state
            int newCount = voteDAO.getVoteCount(paperId);
            boolean isMarked = voteDAO.hasUserMarked(paperId, userId);

            // Return JSON
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            out.print("{\"success\":true,\"count\":" + newCount + ",\"marked\":" + isMarked + "}");
            out.flush();

        } catch (NumberFormatException e) {
            sendJsonError(response, "Invalid paperId");
        } catch (Exception e) {
            sendJsonError(response, "Server error");
        }
    }

    private void sendJsonError(HttpServletResponse response, String message) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        PrintWriter out = response.getWriter();
        out.print("{\"success\":false,\"error\":\"" + message + "\"}");
        out.flush();
    }
}
