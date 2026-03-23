package com.paperwise.servlet;

import com.paperwise.dao.PaperDAO;
import com.paperwise.model.Paper;
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

@WebServlet("/adminDashboard")
public class AdminDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AdminDashboardServlet.class.getName());
    private static final String VIEW_ADMIN_DASHBOARD = "/admin-dashboard.jsp";
    private static final String ATTR_LOGGED_IN_USER = "loggedInUser";
    private static final String ROLE_ADMIN = "admin";

    private PaperDAO paperDAO;

    @Override
    public void init() throws ServletException {
        try {
            paperDAO = new PaperDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise PaperDAO in AdminDashboardServlet.", e);
            throw new ServletException("AdminDashboardServlet initialisation failed.", e);
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
            List<Paper> papers = paperDAO.getAllPapers();
            request.setAttribute("papers", papers);
            LOGGER.log(Level.INFO, "Admin dashboard loaded with {0} papers.", papers.size());
            request.getRequestDispatcher(VIEW_ADMIN_DASHBOARD).forward(request, response);
        } catch (PaperDAO.DAOException e) {
            LOGGER.log(Level.SEVERE, "Error fetching papers for admin dashboard.", e);
            request.setAttribute("errorMessage", "Failed to load papers. Please try again.");
            request.getRequestDispatcher(VIEW_ADMIN_DASHBOARD).forward(request, response);
        }
    }
}