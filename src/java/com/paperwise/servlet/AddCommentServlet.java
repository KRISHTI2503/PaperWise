package com.paperwise.servlet;

import com.paperwise.dao.CommentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/addComment")
public class AddCommentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        com.paperwise.model.User loggedInUser = (com.paperwise.model.User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userId = loggedInUser.getUserId();
        String paperIdStr = request.getParameter("paperId");
        String commentText = request.getParameter("commentText");
        String redirectUrl = request.getParameter("redirectUrl");
        String parentIdStr = request.getParameter("parentCommentId");
        String base = redirectUrl != null ? redirectUrl : request.getContextPath() + "/studentDashboard";

        if (paperIdStr == null || commentText == null || commentText.trim().isEmpty()) {
            response.sendRedirect(base);
            return;
        }

        int paperId = Integer.parseInt(paperIdStr);
        Integer parentCommentId = null;
        CommentDAO dao = new CommentDAO();
        if (parentIdStr != null && !parentIdStr.isEmpty()) {
            parentCommentId = Integer.parseInt(parentIdStr);
            int parentCommentUserId = dao.getCommentAuthorId(parentCommentId);
            if (parentCommentUserId == userId) {
                String msg = URLEncoder.encode("You cannot reply to your own comment.",
                        StandardCharsets.UTF_8);
                response.sendRedirect(appendParam(base, "msg=" + msg + "&msgType=warning"));
                return;
            }
        }
        dao.addComment(paperId, userId, commentText.trim(), parentCommentId);

        response.sendRedirect(appendParam(base, "commented=true"));
    }

    private static String appendParam(String url, String param) {
        return url + (url.contains("?") ? "&" : "?") + param;
    }
}
