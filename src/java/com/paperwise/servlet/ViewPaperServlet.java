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

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

/**
 * Serves a paper file inline (for viewing in browser) by paper ID.
 * URL: /student/viewPaper?id={paperId}
 * Requires an active student session.
 */
@WebServlet("/student/viewPaper")
public class ViewPaperServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIRECTORY = "C:/paperwise_uploads";

    private PaperDAO paperDAO;

    @Override
    public void init() throws ServletException {
        paperDAO = new PaperDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session guard
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Parse paper ID
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Paper ID is required.");
            return;
        }

        int paperId;
        try {
            paperId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid paper ID.");
            return;
        }

        // Fetch paper
        Paper paper = paperDAO.getPaperById(paperId);
        if (paper == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Paper not found.");
            return;
        }

        String fileName = paper.getFileUrl();
        if (fileName == null || fileName.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not associated with this paper.");
            return;
        }

        // Path traversal guard
        if (fileName.contains("..") || fileName.contains("/") || fileName.contains("\\")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid file name.");
            return;
        }

        File file = new File(UPLOAD_DIRECTORY + File.separator + fileName);
        if (!file.exists() || !file.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found on server.");
            return;
        }

        String contentType = getServletContext().getMimeType(fileName);
        if (contentType == null) contentType = "application/octet-stream";

        response.setContentType(contentType);
        response.setContentLengthLong(file.length());
        response.setHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");

        try (FileInputStream in = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            byte[] buf = new byte[4096];
            int read;
            while ((read = in.read(buf)) != -1) out.write(buf, 0, read);
            out.flush();
        }
    }
}
