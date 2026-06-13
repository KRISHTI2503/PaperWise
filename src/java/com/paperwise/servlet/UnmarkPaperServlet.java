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

@WebServlet("/unmarkPaper")
public class UnmarkPaperServlet extends HttpServlet {

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
        User loggedInUser = (session != null)
                ? (User) session.getAttribute("loggedInUser")
                : null;

        if (loggedInUser == null || !"student".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String paperIdParam = request.getParameter("paperId");
        if (paperIdParam != null && !paperIdParam.trim().isEmpty()) {
            try {
                int paperId = Integer.parseInt(paperIdParam.trim());
                voteDAO.removeVote(paperId, loggedInUser.getUserId());
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/myMarked?error=true");
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/myMarked?unmarked=true");
    }
}
