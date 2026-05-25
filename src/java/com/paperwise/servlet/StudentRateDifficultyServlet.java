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

/**
 * Handles Easy / Medium / Hard difficulty voting from the student dashboard.
 * Accepts both fetch() (JSON) and plain form POST (redirect).
 * Parameter: paperId + difficulty (or vote as fallback)
 */
@WebServlet("/student/rateDifficulty")
public class StudentRateDifficultyServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Set<String> VALID_LEVELS = Set.of("easy", "medium", "hard");

    private DifficultyVoteDAO difficultyVoteDAO;

    @Override
    public void init() throws ServletException {
        difficultyVoteDAO = new DifficultyVoteDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Support both "loggedInUser" (User object) and legacy "userId" integer
        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String paperIdParam = request.getParameter("paperId");

        // Accept "difficulty" OR "vote" — whichever the form/JS sends
        String level = request.getParameter("difficulty");
        if (level == null || level.trim().isEmpty()) {
            level = request.getParameter("vote");
        }

        boolean isAjax = "application/x-www-form-urlencoded".equals(request.getContentType())
                && request.getHeader("Accept") != null
                && request.getHeader("Accept").contains("application/json");

        if (paperIdParam == null || paperIdParam.trim().isEmpty() || level == null) {
            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().print("{\"success\":false,\"error\":\"Missing parameters\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/studentDashboard");
            }
            return;
        }

        String normalizedLevel = level.trim().toLowerCase();
        if (!VALID_LEVELS.contains(normalizedLevel)) {
            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().print("{\"success\":false,\"error\":\"Invalid difficulty level\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/studentDashboard");
            }
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam.trim());
            difficultyVoteDAO.addOrUpdateDifficultyVote(paperId, user.getUserId(), normalizedLevel);

            // Always redirect — works for both form POST and fetch (fetch follows redirect)
            response.sendRedirect(request.getContextPath() + "/studentDashboard");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/studentDashboard");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/studentDashboard");
        }
    }
}
