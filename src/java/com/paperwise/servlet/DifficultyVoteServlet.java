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
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/rateDifficulty")
public class DifficultyVoteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(DifficultyVoteServlet.class.getName());

    private static final Set<String> VALID_LEVELS = Set.of("easy", "medium", "hard");

    private DifficultyVoteDAO difficultyVoteDAO;

    @Override
    public void init() throws ServletException {
        try {
            difficultyVoteDAO = new DifficultyVoteDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise DifficultyVoteDAO in DifficultyVoteServlet.");
            throw new ServletException("DifficultyVoteServlet initialisation failed.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();
        String dashboard = contextPath + "/studentDashboard";

        if (session == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null) {
            user = (User) session.getAttribute("loggedInUser");
        }

        if (user == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        String paperIdParam = request.getParameter("paperId");
        String level = request.getParameter("difficulty");
        String normalizedLevel = (level != null) ? level.trim().toLowerCase() : null;

        if (paperIdParam == null || paperIdParam.trim().isEmpty()) {
            response.sendRedirect(dashboard + "?error=true");
            return;
        }

        if (normalizedLevel == null || normalizedLevel.isEmpty()) {
            response.sendRedirect(dashboard + "?invalid=true");
            return;
        }

        if (!VALID_LEVELS.contains(normalizedLevel)) {
            response.sendRedirect(dashboard + "?invalid=true");
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam);
            difficultyVoteDAO.addOrUpdateDifficultyVote(paperId, user.getUserId(), normalizedLevel);
            response.sendRedirect(dashboard + "?voted=true");
            return;

        } catch (NumberFormatException e) {
            response.sendRedirect(dashboard + "?error=true");
        } catch (Exception e) {
            response.sendRedirect(dashboard + "?error=true");
        }
    }
}
