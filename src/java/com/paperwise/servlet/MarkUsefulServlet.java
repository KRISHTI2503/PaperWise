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
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/markUseful")
public class MarkUsefulServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(MarkUsefulServlet.class.getName());

    private VoteDAO voteDAO;

    @Override
    public void init() throws ServletException {
        try {
            voteDAO = new VoteDAO();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialise VoteDAO in MarkUsefulServlet.");
            throw new ServletException("MarkUsefulServlet initialisation failed.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();
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
        String dashboard = contextPath + "/studentDashboard";

        if (paperIdParam == null || paperIdParam.trim().isEmpty()) {
            response.sendRedirect(dashboard + "?error=true");
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam.trim());
            int userId = user.getUserId();

            if (paperId <= 0 || userId <= 0) {
                response.sendRedirect(dashboard + "?error=true");
                return;
            }

            boolean alreadyMarked = voteDAO.hasUserMarked(paperId, userId);

            if (!alreadyMarked) {
                voteDAO.addMark(paperId, userId);
                response.sendRedirect(dashboard + "?marked=true");
                return;
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(dashboard + "?error=true");
            return;
        } catch (Exception e) {
            response.sendRedirect(dashboard + "?error=true");
            return;
        }

        response.sendRedirect(dashboard);
    }
}
