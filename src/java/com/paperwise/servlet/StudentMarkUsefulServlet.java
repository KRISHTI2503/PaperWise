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

        String paperIdParam = request.getParameter("paperId");
        if (paperIdParam == null || paperIdParam.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Missing paperId\"}");
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam.trim());
            int userId  = user.getUserId();

            boolean alreadyMarked = voteDAO.hasUserMarked(paperId, userId);
            boolean nowMarked;

            if (alreadyMarked) {
                // Toggle off
                voteDAO.removeVote(paperId, userId);
                nowMarked = false;
            } else {
                voteDAO.addMark(paperId, userId);
                nowMarked = true;
            }

            int count = voteDAO.getVoteCount(paperId);
            out.print("{\"success\":true,\"marked\":" + nowMarked + ",\"count\":" + count + "}");

        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"error\":\"Invalid paperId\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"error\":\"Server error\"}");
        }
    }
}
