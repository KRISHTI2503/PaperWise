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

@WebServlet("/student/viewPaper")
public class ViewPaperServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIR = "C:/paperwise_uploads";

    private PaperDAO paperDAO;

    @Override
    public void init() throws ServletException {
        paperDAO = new PaperDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing paper ID.");
            return;
        }

        try {
            int paperId = Integer.parseInt(idParam.trim());
            Paper paper = paperDAO.getPaperById(paperId);

            if (paper == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Paper not found.");
                return;
            }

            String fileName = paper.getFileUrl();
            if (fileName == null || fileName.isBlank()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "No file associated with this paper.");
                return;
            }

            // Security: strip any path components
            fileName = new File(fileName).getName();
            File file = new File(UPLOAD_DIR, fileName);

            if (!file.exists() || !file.isFile()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found on server.");
                return;
            }

            String contentType = getServletContext().getMimeType(fileName);
            if (contentType == null) contentType = "application/octet-stream";

            response.setContentType(contentType);
            response.setContentLengthLong(file.length());
            response.setHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");

            try (FileInputStream fis = new FileInputStream(file);
                 OutputStream os = response.getOutputStream()) {
                byte[] buf = new byte[8192];
                int n;
                while ((n = fis.read(buf)) != -1) os.write(buf, 0, n);
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid paper ID.");
        }
    }
}
