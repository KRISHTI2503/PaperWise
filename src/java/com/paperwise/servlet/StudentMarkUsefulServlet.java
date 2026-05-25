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

/**
 * Toggles "Mark as Useful" for a paper.
 * Accepts both fetch() and plain form POST.
 * Parameter: paperId
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
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String paperIdParam = request.getParameter("paperId");
        if (paperIdParam == null || paperIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/studentDashboard");
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam.trim());
            int userId  = user.getUserId();

            boolean alreadyMarked = voteDAO.hasUserMarked(paperId, userId);
            if (alreadyMarked) {
                voteDAO.removeVote(paperId, userId);
            } else {
                voteDAO.addMark(paperId, userId);
            }

        } catch (NumberFormatException e) {
            // ignore, redirect anyway
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/studentDashboard");
    }
}
