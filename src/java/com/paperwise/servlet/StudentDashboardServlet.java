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
import java.util.List;
import java.util.Set;

@WebServlet("/studentDashboard")
public class StudentDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

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
            System.err.println("Failed to initialise DAOs in StudentDashboardServlet.");
            e.printStackTrace();
            throw new ServletException("StudentDashboardServlet initialisation failed.", e);
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
                    System.err.println("Invalid year parameter: " + yearParam);
                }
            } else {
                papers = paperDAO.getAllPapersWithVotes();
            }

            Set<Integer> votedPapers = voteDAO.getUserVotedPapers(loggedInUser.getUserId());
            for (Paper paper : papers) {
                if (votedPapers.contains(paper.getPaperId())) {
                    paper.setAlreadyMarked(true);
                }
            }
            request.setAttribute("votedPapers", votedPapers);

            List<Integer> availableYears = paperDAO.getDistinctYears();
            request.setAttribute("availableYears", availableYears);

            request.setAttribute("papers", papers);

            List<PaperRequest> myRequests = paperRequestDAO.getRequestsByUserId(loggedInUser.getUserId());
            request.setAttribute("myRequests", myRequests);

            String searchQuery = request.getParameter("search");
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                request.setAttribute("searchQuery", searchQuery.trim());
            }

            System.out.println("Student dashboard loaded with " + papers.size() + " papers for user " + loggedInUser.getUsername());

            request.getRequestDispatcher(VIEW_STUDENT_DASHBOARD).forward(request, response);

        } catch (Exception e) {
            System.err.println("Error fetching papers for student dashboard:");
            e.printStackTrace();
            request.setAttribute("errorMessage", "Failed to load papers. Please try again.");
            request.getRequestDispatcher(VIEW_STUDENT_DASHBOARD).forward(request, response);
        }
    }
}