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

@WebServlet("/myMarked")
public class MyMarkedServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private PaperDAO paperDAO;

    @Override
    public void init() throws ServletException {
        paperDAO = new PaperDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null)
                ? (User) session.getAttribute("loggedInUser")
                : null;

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!"student".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<Paper> markedPapers = paperDAO.getMarkedPapersByUser(loggedInUser.getUserId());

        int totalUsefulMarks = 0;
        for (Paper paper : markedPapers) {
            totalUsefulMarks += paper.getUsefulCount();
        }

        request.setAttribute("markedPapers", markedPapers);
        request.setAttribute("markedCount", markedPapers.size());
        request.setAttribute("yourMarksCount", markedPapers.size());
        request.setAttribute("totalUsefulMarks", totalUsefulMarks);

        request.getRequestDispatcher("/WEB-INF/views/myMarked.jsp")
                .forward(request, response);
    }
}
