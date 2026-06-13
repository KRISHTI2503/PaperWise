package com.paperwise.servlet;

import com.paperwise.dao.AnalyticsDAO;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/analytics")
public class AnalyticsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AnalyticsServlet.class.getName());

    private AnalyticsDAO analyticsDAO;

    @Override
    public void init() throws ServletException {
        analyticsDAO = new AnalyticsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        User user = (User) session.getAttribute("loggedInUser");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // Section 1 — summary counts
            int[] counts = analyticsDAO.getSummaryCounts();
            request.setAttribute("totalPapers",     counts[0]);
            request.setAttribute("totalStudents",   counts[1]);
            request.setAttribute("totalDiffVotes",  counts[2]);
            request.setAttribute("totalUsefulMarks",counts[3]);

            // Section 2 — global difficulty distribution
            int[] diff = analyticsDAO.getGlobalDifficultyStats();
            int totalDiff = diff[0] + diff[1] + diff[2];
            request.setAttribute("easyCount",   diff[0]);
            request.setAttribute("mediumCount", diff[1]);
            request.setAttribute("hardCount",   diff[2]);
            request.setAttribute("totalDiff",   totalDiff);
            request.setAttribute("easyPct",   totalDiff > 0 ? (diff[0] * 100 / totalDiff) : 0);
            request.setAttribute("mediumPct", totalDiff > 0 ? (diff[1] * 100 / totalDiff) : 0);
            request.setAttribute("hardPct",   totalDiff > 0 ? (diff[2] * 100 / totalDiff) : 0);

            // Section 3 — papers by subject code
            List<Map<String, Object>> bySubject = analyticsDAO.getPapersBySubjectCode();
            request.setAttribute("papersBySubject", bySubject);

            // Section 4 — top papers
            List<Map<String, Object>> topPapers = analyticsDAO.getTopPapers();
            request.setAttribute("topPapers", topPapers);

            // Section 5 — monthly uploads
            List<Map<String, Object>> monthly = analyticsDAO.getMonthlyUploads();
            request.setAttribute("monthlyUploads", monthly);

            // Sidebar data
            request.setAttribute("username", user.getUsername());
            String initials = user.getUsername().length() >= 2
                    ? user.getUsername().substring(0, 2).toUpperCase()
                    : user.getUsername().toUpperCase();
            request.setAttribute("initials", initials);

            request.getRequestDispatcher("/analytics.jsp").forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading analytics page.", e);
            response.sendRedirect(request.getContextPath() + "/analytics?error=true");
        }
    }
}
