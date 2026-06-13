package com.paperwise.servlet;

import com.paperwise.dao.PaperCommentDAO;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/paperComment")
public class PaperCommentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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

        String action = request.getParameter("action");
        String redirectUrl = request.getParameter("redirectUrl");
        String base = redirectUrl != null && !redirectUrl.isEmpty()
                ? redirectUrl
                : request.getContextPath() + "/studentDashboard";

        String username = loggedInUser.getUsername();
        boolean isAdmin = "admin".equalsIgnoreCase(loggedInUser.getRole());
        PaperCommentDAO commentDAO = new PaperCommentDAO();

        if ("delete".equals(action)) {
            String commentIdStr = request.getParameter("commentId");
            if (commentIdStr != null && !commentIdStr.isEmpty()) {
                int commentId = Integer.parseInt(commentIdStr);
                boolean deleted = commentDAO.deleteComment(
                        commentId,
                        loggedInUser.getUserId(),
                        loggedInUser.getRole());
                if (!deleted) {
                    // Permission denied or not found — redirect with error
                    response.sendRedirect(appendParam(base, "error=true&msg="
                            + java.net.URLEncoder.encode(
                                "You don't have permission to delete this comment.",
                                java.nio.charset.StandardCharsets.UTF_8)));
                    return;
                }
            }
            response.sendRedirect(appendParam(base, "comment_deleted=true"));
            return;
        }

        String paperIdStr = request.getParameter("paperId");
        String commentText = request.getParameter("commentText");
        String parentIdStr = request.getParameter("parentCommentId");

        if (paperIdStr == null || commentText == null || commentText.trim().isEmpty()) {
            response.sendRedirect(base);
            return;
        }

        int paperId = Integer.parseInt(paperIdStr);
        Integer parentCommentId = null;
        if (parentIdStr != null && !parentIdStr.isEmpty()) {
            parentCommentId = Integer.parseInt(parentIdStr);
            int parentAuthorId = commentDAO.getCommentAuthorId(parentCommentId);
            if (parentAuthorId == loggedInUser.getUserId()) {
                String msg = URLEncoder.encode("You cannot reply to your own comment.",
                        StandardCharsets.UTF_8);
                response.sendRedirect(appendParam(base, "msg=" + msg + "&msgType=warning"));
                return;
            }
        }

        commentDAO.addComment(paperId, loggedInUser.getUserId(), commentText.trim(), parentCommentId);
        response.sendRedirect(appendParam(base, "commented=true"));
    }

    private static String appendParam(String url, String param) {
        return url + (url.contains("?") ? "&" : "?") + param;
    }
}
