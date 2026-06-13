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

    private boolean wantsJson(HttpServletRequest request) {
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            return true;
        }
        String accept = request.getHeader("Accept");
        return accept != null && accept.contains("application/json");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            if (wantsJson(request)) {
                sendJsonError(response, "Not authenticated");
            } else {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            if (wantsJson(request)) {
                sendJsonError(response, "Not authenticated");
            } else {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }
            return;
        }

        String paperIdParam = request.getParameter("paperId");

        String level = request.getParameter("difficulty");
        if (level == null || level.trim().isEmpty()) {
            level = request.getParameter("vote");
        }

        if (paperIdParam == null || paperIdParam.trim().isEmpty() || level == null) {
            if (wantsJson(request)) {
                sendJsonError(response, "Missing parameters");
            } else {
                response.sendRedirect(request.getContextPath() + "/studentDashboard");
            }
            return;
        }

        String normalizedLevel = level.trim().toLowerCase();
        if (!VALID_LEVELS.contains(normalizedLevel)) {
            if (wantsJson(request)) {
                sendJsonError(response, "Invalid difficulty level");
            } else {
                response.sendRedirect(request.getContextPath() + "/studentDashboard");
            }
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam.trim());
            difficultyVoteDAO.addOrUpdateDifficultyVote(paperId, user.getUserId(), normalizedLevel);

            if (wantsJson(request)) {
                DifficultyStats stats = difficultyVoteDAO.getDifficultyStatsObject(paperId);
                String userVote = difficultyVoteDAO.getUserDifficultyVote(paperId, user.getUserId());
                if (userVote == null) {
                    userVote = normalizedLevel;
                }
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                PrintWriter out = response.getWriter();
                out.print("{\"success\":true,\"easy\":" + stats.getEasyCount()
                        + ",\"medium\":" + stats.getMediumCount()
                        + ",\"hard\":" + stats.getHardCount()
                        + ",\"userVote\":\"" + userVote + "\"}");
                out.flush();
                return;
            }

            String referer = request.getHeader("Referer");
            String contextPath = request.getContextPath();
            String redirectTo;
            if (referer != null && referer.contains("studentAllPapers")) {
                redirectTo = contextPath + "/studentAllPapers?voted=true";
            } else {
                redirectTo = contextPath + "/studentDashboard?voted=true";
            }
            response.sendRedirect(redirectTo);

        } catch (NumberFormatException e) {
            if (wantsJson(request)) {
                sendJsonError(response, "Invalid paperId");
            } else {
                response.sendRedirect(request.getContextPath() + "/studentDashboard");
            }
        } catch (Exception e) {
            if (wantsJson(request)) {
                sendJsonError(response, "Server error");
            } else {
                response.sendRedirect(request.getContextPath() + "/studentDashboard");
            }
        }
    }

    private void sendJsonError(HttpServletResponse response, String message) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        PrintWriter out = response.getWriter();
        out.print("{\"success\":false,\"error\":\"" + message.replace("\"", "\\\"") + "\"}");
        out.flush();
    }
}
