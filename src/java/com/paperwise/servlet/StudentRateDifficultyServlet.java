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
        String level        = request.getParameter("difficulty");

        if (paperIdParam == null || paperIdParam.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Missing paperId\"}");
            return;
        }

        String normalizedLevel = (level != null) ? level.trim().toLowerCase() : "";
        if (!VALID_LEVELS.contains(normalizedLevel)) {
            out.print("{\"success\":false,\"error\":\"Invalid difficulty level\"}");
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam.trim());
            difficultyVoteDAO.addOrUpdateDifficultyVote(paperId, user.getUserId(), normalizedLevel);

            // Return updated counts
            DifficultyStats stats = difficultyVoteDAO.getDifficultyStatsObject(paperId);
            out.print("{\"success\":true"
                    + ",\"easy\":"   + stats.getEasyCount()
                    + ",\"medium\":" + stats.getMediumCount()
                    + ",\"hard\":"   + stats.getHardCount()
                    + "}");

        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"error\":\"Invalid paperId\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"error\":\"Server error\"}");
        }
    }
}
