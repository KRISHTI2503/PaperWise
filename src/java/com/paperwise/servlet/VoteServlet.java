package com.paperwise.servlet;

import com.paperwise.dao.VoteDAO;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/votePaper")
public class VoteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(VoteServlet.class.getName());

    private VoteDAO voteDAO;

    @Override
    public void init() throws ServletException {
        try {
            voteDAO = new VoteDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise VoteDAO in VoteServlet.", e);
            throw new ServletException("VoteServlet initialisation failed.", e);
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

        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        if (!"student".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(dashboard + "?error=true");
            return;
        }

        String paperIdParam = request.getParameter("id");
        if (paperIdParam == null || paperIdParam.trim().isEmpty()) {
            response.sendRedirect(dashboard + "?error=true");
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam);
            int userId = user.getUserId();

            if (voteDAO.hasUserVoted(paperId, userId)) {
                response.sendRedirect(dashboard + "?error=true");
                return;
            }

            boolean success = voteDAO.insertVote(paperId, userId);

            if (success) {
                response.sendRedirect(dashboard + "?marked=true");
                return;
            }

        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid paper ID format: {0}", paperIdParam);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while processing vote.", e);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error while processing vote.", e);
        }

        response.sendRedirect(dashboard + "?error=true");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
