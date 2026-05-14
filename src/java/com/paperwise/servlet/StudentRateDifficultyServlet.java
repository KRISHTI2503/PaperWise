package com.paperwise.servlet;

import com.paperwise.dao.DifficultyVoteDAO;
import com.paperwise.model.DifficultyStats;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Set;

/**
 * Handles difficulty rating for students.
 * POST /student/rateDifficulty  { paperId, difficulty }
 * Returns JSON: { success, easy, medium, hard, userVote }
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

        // Parse params
        String idParam = request.getParameter("paperId");
        String level   = request.getParameter("difficulty");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Missing paperId\"}");
            return;
        }

        String normalizedLevel = level != null ? level.trim().toLowerCase() : "";
        if (!VALID_LEVELS.contains(normalizedLevel)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Invalid difficulty level\"}");
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

        try {
            // UPSERT — updates if user already voted on this paper
            difficultyVoteDAO.addOrUpdateDifficultyVote(paperId, user.getUserId(), normalizedLevel);

            // Fetch updated counts
            DifficultyStats stats = difficultyVoteDAO.getDifficultyStatsObject(paperId);

            out.print("{\"success\":true"
                    + ",\"easy\":"   + stats.getEasyCount()
                    + ",\"medium\":" + stats.getMediumCount()
                    + ",\"hard\":"   + stats.getHardCount()
                    + ",\"userVote\":\"" + normalizedLevel + "\""
                    + "}");

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"error\":\"Database error\"}");
        }
    }
}
