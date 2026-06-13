package com.paperwise.servlet;

import com.paperwise.dao.PaperDAO;
import com.paperwise.dao.PaperRequestDAO;
import com.paperwise.dao.VoteDAO;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import com.paperwise.dao.CommentDAO;
import com.paperwise.model.PaperComment;

@WebServlet("/studentDashboard")
public class StudentDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(StudentDashboardServlet.class.getName());

    private static final String VIEW_STUDENT_DASHBOARD = "/student-dashboard.jsp";
    private static final String ATTR_LOGGED_IN_USER = "loggedInUser";

    private PaperDAO paperDAO;
    private VoteDAO voteDAO;
    private PaperRequestDAO paperRequestDAO;

    @Override
    public void init() throws ServletException {
        try {
            paperDAO = new PaperDAO();
            voteDAO = new VoteDAO();
            paperRequestDAO = new PaperRequestDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise DAOs in StudentDashboardServlet.", e);
            throw new ServletException("StudentDashboardServlet initialisation failed.", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LOGGER.log(Level.FINE, "StudentDashboard GET: {0}", request.getQueryString());

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

        if (!"student".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            String yearParam = request.getParameter("year");
            List<Paper> papers;

            if (yearParam != null && !yearParam.trim().isEmpty() && !yearParam.equals("all")) {
                try {
                    int year = Integer.parseInt(yearParam);
                    papers = paperDAO.getPapersByYear(year);
                    request.setAttribute("selectedYear", year);
                } catch (NumberFormatException e) {
                    papers = paperDAO.getAllPapersWithVotes();
                }
            } else {
                papers = paperDAO.getAllPapersWithVotes();
            }

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
            request.setAttribute("votedPapers", votedPapers);

            int totalPapers      = paperDAO.getAllPapers().size();
            int totalUsefulMarks = paperDAO.getTotalUsefulMarks();
            int myMarksCount     = votedPapers.size();

            request.setAttribute("totalPapers",      totalPapers);
            request.setAttribute("totalUsefulMarks", totalUsefulMarks);
            request.setAttribute("myMarksCount",     myMarksCount);

            List<Integer> availableYears = paperDAO.getDistinctYears();
            if (availableYears == null) {
                availableYears = new ArrayList<>();
            }
            request.setAttribute("availableYears", availableYears);
            request.setAttribute("papers", papers);

            CommentDAO commentDAO = new CommentDAO();
            Map<Integer, List<PaperComment>> commentsMap = new HashMap<>();
            for (Paper p : papers) {
                List<PaperComment> comments = commentDAO.getCommentsByPaperId(p.getPaperId());
                commentsMap.put(p.getPaperId(), comments != null ? comments : new ArrayList<>());
            }
            request.setAttribute("commentsMap", commentsMap);

            List<PaperRequest> myRequests = paperRequestDAO.getRequestsByUserId(loggedInUser.getUserId());
            if (myRequests == null) {
                myRequests = new ArrayList<>();
            }
            request.setAttribute("myRequests", myRequests);

            String searchQuery = request.getParameter("search");
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                request.setAttribute("searchQuery", searchQuery.trim());
            }

            request.getRequestDispatcher(VIEW_STUDENT_DASHBOARD).forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading student dashboard.", e);
            request.setAttribute("papers", new ArrayList<Paper>());
            request.setAttribute("myRequests", new ArrayList<PaperRequest>());
            request.setAttribute("commentsMap", new HashMap<Integer, List<PaperComment>>());
            request.setAttribute("votedPapers", new HashSet<Integer>());
            request.setAttribute("totalPapers", 0);
            request.setAttribute("totalUsefulMarks", 0);
            request.setAttribute("myMarksCount", 0);
            request.setAttribute("availableYears", new ArrayList<Integer>());
            request.getRequestDispatcher(VIEW_STUDENT_DASHBOARD).forward(request, response);
        }
    }
}
