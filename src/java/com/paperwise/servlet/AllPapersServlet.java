package com.paperwise.servlet;

import com.paperwise.dao.PaperDAO;
import com.paperwise.dao.PaperRequestDAO;
import com.paperwise.dao.UserDAO;
import com.paperwise.model.Paper;
import com.paperwise.model.PaperRequest;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/allPapers")
public class AllPapersServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AllPapersServlet.class.getName());

    private static final String VIEW_ALL_PAPERS      = "/allPapers.jsp";
    private static final String ATTR_LOGGED_IN_USER  = "loggedInUser";
    private static final String ROLE_ADMIN           = "admin";

    private PaperDAO        paperDAO;
    private PaperRequestDAO requestDAO;
    private UserDAO         userDAO;

    @Override
    public void init() throws ServletException {
        try {
            paperDAO   = new PaperDAO();
            requestDAO = new PaperRequestDAO();
            userDAO    = new UserDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise DAOs in AllPapersServlet.", e);
            throw new ServletException("AllPapersServlet initialisation failed.", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User loggedInUser = (User) session.getAttribute(ATTR_LOGGED_IN_USER);
        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!ROLE_ADMIN.equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied. Administrator privileges required.");
            return;
        }

        try {
            // All papers with vote + difficulty counts
            List<Paper> papers = paperDAO.getAllPapersWithVotes();
            request.setAttribute("papers", papers);

            // Stat: total useful marks
            int totalUsefulMarks = paperDAO.getTotalUsefulMarks();
            request.setAttribute("totalUsefulMarks", totalUsefulMarks);

            // Stat: global difficulty breakdown
            int[] diffStats = paperDAO.getGlobalDifficultyStats();
            int easyCount   = diffStats[0];
            int mediumCount = diffStats[1];
            int hardCount   = diffStats[2];
            request.setAttribute("easyCount",   easyCount);
            request.setAttribute("mediumCount",  mediumCount);
            request.setAttribute("hardCount",    hardCount);

            // Most common difficulty
            String mostCommonDifficulty = "Not Rated";
            if (easyCount > 0 || mediumCount > 0 || hardCount > 0) {
                if (easyCount >= mediumCount && easyCount >= hardCount) {
                    mostCommonDifficulty = "Easy";
                } else if (mediumCount >= easyCount && mediumCount >= hardCount) {
                    mostCommonDifficulty = "Medium";
                } else {
                    mostCommonDifficulty = "Hard";
                }
            }
            request.setAttribute("mostCommonDifficulty", mostCommonDifficulty);

            // Pending requests count (for sidebar badge)
            List<PaperRequest> requests = requestDAO.getAllRequests();
            long pendingCount = requests.stream()
                    .filter(r -> "pending".equalsIgnoreCase(r.getStatus()))
                    .count();
            request.setAttribute("pendingRequestsCount", (int) pendingCount);

            LOGGER.log(Level.INFO, "All Papers page loaded: {0} papers.", papers.size());

            request.getRequestDispatcher(VIEW_ALL_PAPERS).forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading All Papers page.", e);
            request.setAttribute("errorMessage", "Failed to load papers. Please try again.");
            request.getRequestDispatcher(VIEW_ALL_PAPERS).forward(request, response);
        }
    }
}
