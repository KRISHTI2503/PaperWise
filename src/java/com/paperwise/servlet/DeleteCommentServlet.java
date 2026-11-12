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

@WebServlet("/deleteComment")
public class DeleteCommentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

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

        String commentIdStr = request.getParameter("commentId");
        String redirectUrl  = request.getParameter("redirectUrl");
        String base = redirectUrl != null && !redirectUrl.isEmpty()
                ? redirectUrl
                : request.getContextPath() + "/adminDashboard";

        if (commentIdStr != null && !commentIdStr.isEmpty()) {
            try {
                int commentId = Integer.parseInt(commentIdStr);
                PaperCommentDAO dao = new PaperCommentDAO();
                boolean deleted = dao.deleteComment(
                        commentId,
                        loggedInUser.getUserId(),
                        loggedInUser.getRole());
                if (!deleted) {
                    String msg = URLEncoder.encode(
                            "You don't have permission to delete this comment.",
                            StandardCharsets.UTF_8);
                    response.sendRedirect(appendParam(base, "error=true&msg=" + msg));
                    return;
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(appendParam(base, "error=true"));
                return;
            }
        }

        response.sendRedirect(appendParam(base, "comment_deleted=true"));
    }

    private static String appendParam(String url, String param) {
        return url + (url.contains("?") ? "&" : "?") + param;
    }
}
