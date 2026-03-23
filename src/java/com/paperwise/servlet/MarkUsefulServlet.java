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

@WebServlet("/markUseful")
public class MarkUsefulServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private VoteDAO voteDAO;

    @Override
    public void init() throws ServletException {
        try {
            voteDAO = new VoteDAO();
        } catch (Exception e) {
            System.err.println("Failed to initialise VoteDAO in MarkUsefulServlet.");
            e.printStackTrace();
            throw new ServletException("MarkUsefulServlet initialisation failed.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null) {
            user = (User) session.getAttribute("loggedInUser");
        }

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String paperIdParam = request.getParameter("paperId");

        if (paperIdParam == null) {
            session.setAttribute("msg", "Error: No paper ID provided.");
            response.sendRedirect("studentDashboard");
            return;
        }

        if (paperIdParam.trim().isEmpty()) {
            session.setAttribute("msg", "Error: Invalid paper ID.");
            response.sendRedirect("studentDashboard");
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam.trim());
            int userId = user.getUserId();

            if (paperId <= 0) {
                session.setAttribute("msg", "Error: Invalid paper ID.");
                response.sendRedirect("studentDashboard");
                return;
            }

            if (userId <= 0) {
                session.setAttribute("msg", "Error: Invalid user ID.");
                response.sendRedirect("studentDashboard");
                return;
            }

            boolean alreadyMarked = voteDAO.hasUserMarked(paperId, userId);

            if (!alreadyMarked) {
                voteDAO.addMark(paperId, userId);
                session.setAttribute("msg", "Marked as useful.");
            } else {
                session.setAttribute("msg", "You already marked this paper.");
            }

        } catch (NumberFormatException e) {
            System.err.println("ERROR: NumberFormatException parsing paperId: " + paperIdParam);
            e.printStackTrace();
            session.setAttribute("msg", "Error: Invalid paper ID format.");
        } catch (Exception e) {
            System.err.println("ERROR: Unexpected exception in MarkUsefulServlet");
            e.printStackTrace();
            session.setAttribute("msg", "An error occurred. Please try again.");
        }

        response.sendRedirect("studentDashboard");
    }
}