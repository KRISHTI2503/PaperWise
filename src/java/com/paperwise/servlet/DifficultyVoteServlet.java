package com.paperwise.servlet;

import com.paperwise.dao.DifficultyVoteDAO;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Set;

@WebServlet("/rateDifficulty")
public class DifficultyVoteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Set<String> VALID_LEVELS = Set.of("easy", "medium", "hard");

    private DifficultyVoteDAO difficultyVoteDAO;

    @Override
    public void init() throws ServletException {
        try {
            difficultyVoteDAO = new DifficultyVoteDAO();
        } catch (Exception e) {
            System.err.println("Failed to initialise DifficultyVoteDAO in DifficultyVoteServlet.");
            e.printStackTrace();
            throw new ServletException("DifficultyVoteServlet initialisation failed.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User user = (User) session.getAttribute("user");
        if (user == null) {
            user = (User) session.getAttribute("loggedInUser");
        }

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String paperIdParam = request.getParameter("paperId");
        String level = request.getParameter("difficulty");

        if (level != null) {
            level = level.toLowerCase().trim();
        }

        if (paperIdParam == null || paperIdParam.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Invalid paper ID.");
            response.sendRedirect("studentDashboard");
            return;
        }

        if (level == null || level.isEmpty()) {
            session.setAttribute("errorMessage", "Please select a difficulty level.");
            response.sendRedirect("studentDashboard");
            return;
        }

        if (!VALID_LEVELS.contains(level)) {
            session.setAttribute("errorMessage",
                    "Invalid difficulty level. Must be one of: " + String.join(", ", VALID_LEVELS));
            response.sendRedirect("studentDashboard");
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam);

            difficultyVoteDAO.addOrUpdateDifficultyVote(paperId, user.getUserId(), level);

            session.setAttribute("successMessage", "Difficulty rating recorded: " + level);

        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid paper ID format.");
            System.err.println("Invalid paper ID format: " + paperIdParam);
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            session.setAttribute("errorMessage", e.getMessage());
            System.err.println("Invalid difficulty vote: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Failed to record difficulty rating. Please try again.");
            System.err.println("Unexpected error while recording difficulty vote:");
            e.printStackTrace();
        }

        response.sendRedirect("studentDashboard");
    }
}