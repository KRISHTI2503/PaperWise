package com.paperwise.servlet;

import com.paperwise.dao.PaperDAO;
import com.paperwise.dao.PaperRequestDAO;
import com.paperwise.dao.VoteDAO;
import com.paperwise.model.Paper;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.Map;
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import com.paperwise.dao.CommentDAO;
import com.paperwise.model.PaperComment;

@WebServlet("/studentAllPapers")
public class StudentAllPapersServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(StudentAllPapersServlet.class.getName());

    private PaperDAO        paperDAO;
    private VoteDAO         voteDAO;
    private PaperRequestDAO requestDAO;

    @Override
    public void init() throws ServletException {
        paperDAO   = new PaperDAO();
        voteDAO    = new VoteDAO();
        requestDAO = new PaperRequestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User loggedInUser = (User) session.getAttribute("loggedInUser");
        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!"student".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // Fetch all papers with vote + difficulty counts
            List<Paper> papers = paperDAO.getAllPapersWithVotes();

            // Mark which papers this student has already voted useful
            if (papers == null) {
                papers = new ArrayList<>();
            }

            Set<Integer> votedPapers = voteDAO.getUserVotedPapers(loggedInUser.getUserId());
            if (votedPapers == null) {
                votedPapers = new HashSet<>();
            }
            for (Paper paper : papers) {
                if (votedPapers.contains(paper.getPaperId())) {
                    paper.setAlreadyMarked(true);
                }
            }

            // Stat: total useful marks across all papers
            int totalUsefulMarks = paperDAO.getTotalUsefulMarks();

            // Stat: most common difficulty
            int[] diffStats = paperDAO.getGlobalDifficultyStats();
            String mostCommonDiff = "Not Rated";
            if (diffStats[0] > 0 || diffStats[1] > 0 || diffStats[2] > 0) {
                if (diffStats[0] >= diffStats[1] && diffStats[0] >= diffStats[2]) mostCommonDiff = "Easy";
                else if (diffStats[1] >= diffStats[0] && diffStats[1] >= diffStats[2]) mostCommonDiff = "Medium";
                else mostCommonDiff = "Hard";
            }

            // Distinct years for filter
            List<Integer> availableYears = paperDAO.getDistinctYears();
            if (availableYears == null) {
                availableYears = new ArrayList<>();
            }

            request.setAttribute("papers",            papers);

            CommentDAO commentDAO = new CommentDAO();
            Map<Integer, List<PaperComment>> commentsMap = new HashMap<>();
            for (Paper p : papers) {
                List<PaperComment> comments = commentDAO.getCommentsByPaperId(p.getPaperId());
                commentsMap.put(p.getPaperId(), comments != null ? comments : new ArrayList<>());
            }
            request.setAttribute("commentsMap", commentsMap);
            request.setAttribute("totalPapers",       papers.size());
            request.setAttribute("totalUsefulMarks",  totalUsefulMarks);
            request.setAttribute("mostCommonDiff",    mostCommonDiff);
            request.setAttribute("availableYears",    availableYears);
            request.setAttribute("votedPapers",       votedPapers);

            request.getRequestDispatcher("/studentAllPapers.jsp").forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading student all papers page.", e);
            LOGGER.log(Level.FINE, String.valueOf("ALL PAPERS ERROR: " + e.getMessage()));
            request.setAttribute("papers", new ArrayList<Paper>());
            request.setAttribute("commentsMap", new HashMap<Integer, List<PaperComment>>());
            request.setAttribute("votedPapers", new HashSet<Integer>());
            request.setAttribute("totalPapers", 0);
            request.setAttribute("totalUsefulMarks", 0);
            request.setAttribute("mostCommonDiff", "Not Rated");
            request.setAttribute("availableYears", new ArrayList<Integer>());
            request.getRequestDispatcher("/studentAllPapers.jsp").forward(request, response);
        }
    }
}
