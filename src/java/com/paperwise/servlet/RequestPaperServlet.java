package com.paperwise.servlet;

import com.paperwise.dao.PaperRequestDAO;
import com.paperwise.model.PaperRequest;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.Year;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/requestPaper")
public class RequestPaperServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(RequestPaperServlet.class.getName());

    private static final String VIEW_REQUEST_FORM = "/requestPaper.jsp";
    private static final String REDIRECT_STUDENT_DASHBOARD = "/studentDashboard";
    private static final String ATTR_LOGGED_IN_USER = "loggedInUser";

    private PaperRequestDAO requestDAO;

    @Override
    public void init() throws ServletException {
        try {
            requestDAO = new PaperRequestDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise PaperRequestDAO.", e);
            throw new ServletException("RequestPaperServlet initialisation failed.", e);
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

        List<com.paperwise.model.PaperRequest> myRequests =
                requestDAO.getRequestsByUserId(loggedInUser.getUserId());
        request.setAttribute("myRequests",     myRequests);
        request.setAttribute("totalRequests",  myRequests.size());
        request.setAttribute("pendingCount",   myRequests.stream()
                .filter(r -> "pending".equalsIgnoreCase(r.getStatus())).count());
        request.setAttribute("completedCount", myRequests.stream()
                .filter(r -> "completed".equalsIgnoreCase(r.getStatus())).count());

        request.getRequestDispatcher(VIEW_REQUEST_FORM).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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

        String subjectName = request.getParameter("subject_name");
        String subjectCode = request.getParameter("subject_code");
        String yearStr = request.getParameter("year");
        String description = request.getParameter("description");
        int userId = loggedInUser.getUserId();

        if (subjectName == null || subjectName.trim().isEmpty() ||
            subjectCode == null || subjectCode.trim().isEmpty() ||
            yearStr == null || yearStr.trim().isEmpty()) {

            response.sendRedirect(request.getContextPath() + "/requestPaper?invalid=true");
            return;
        }

        try {
            int year = Integer.parseInt(yearStr.trim());

            int currentYear = Year.now().getValue();
            int minYear = currentYear - 20;

            if (year < minYear || year > currentYear) {
                response.sendRedirect(request.getContextPath() + "/requestPaper?invalid=true");
                return;
            }

            PaperRequest paperRequest = new PaperRequest();
            paperRequest.setSubjectName(subjectName.trim());
            paperRequest.setSubjectCode(subjectCode.trim());
            paperRequest.setYear(year);
            paperRequest.setDescription(description != null ? description.trim() : null);
            paperRequest.setRequestedBy(userId);

            boolean success = requestDAO.saveRequest(paperRequest);

            if (success) {
                LOGGER.log(Level.INFO,
                        "Paper request submitted by user {0}: {1} ({2}) - Year {3}",
                        new Object[]{loggedInUser.getUsername(), subjectName, subjectCode, year});

                response.sendRedirect(request.getContextPath() + "/requestPaper?submitted=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/requestPaper?error=true");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/requestPaper?invalid=true");

        } catch (IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath() + "/requestPaper?invalid=true");

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error submitting paper request.", e);
                        response.sendRedirect(request.getContextPath() + "/requestPaper?error=true");
        }
    }

    private void preserveFormData(HttpServletRequest request, String subjectName,
                                  String subjectCode, String year, String description) {
        request.setAttribute("subjectName", subjectName);
        request.setAttribute("subjectCode", subjectCode);
        request.setAttribute("year", year);
        request.setAttribute("description", description);
    }
}