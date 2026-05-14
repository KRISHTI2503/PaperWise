package com.paperwise.servlet;

import com.paperwise.dao.PaperDAO;
import com.paperwise.model.Paper;

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

@WebServlet("/viewFile")
public class ViewFileServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    static final String UPLOAD_DIRECTORY = "C:/paperwise_uploads";

    private PaperDAO paperDAO;

    @Override
    public void init() throws ServletException {
        paperDAO = new PaperDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Require login
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Support both ?paperId= (new) and ?fileName= (legacy) so nothing breaks
        String paperIdStr = request.getParameter("paperId");
        String fileName   = request.getParameter("fileName");

        if (paperIdStr != null && !paperIdStr.trim().isEmpty()) {
            // Resolve filename from DB by paper ID
            try {
                int paperId = Integer.parseInt(paperIdStr.trim());
                Paper paper = paperDAO.getPaperById(paperId);
                if (paper == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND,
                            "Paper not found in database (id=" + paperId + ").");
                    return;
                }
                fileName = paper.getFileUrl();
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid paperId.");
                return;
            }
        }

        if (fileName == null || fileName.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Missing parameter: provide paperId or fileName.");
            return;
        }

        // Security: strip any path traversal
        fileName = new File(fileName).getName();
        if (fileName.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid file name.");
            return;
        }

        File file = new File(UPLOAD_DIRECTORY, fileName);
        if (!file.exists() || !file.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND,
                    "File not found on disk: " + file.getAbsolutePath());
            return;
        }

        String contentType = getServletContext().getMimeType(fileName);
        if (contentType == null) contentType = "application/octet-stream";

        response.setContentType(contentType);
        response.setContentLengthLong(file.length());

        // ?download param → force download; otherwise inline (view in browser)
        String disposition = request.getParameter("download") != null ? "attachment" : "inline";
        response.setHeader("Content-Disposition", disposition + "; filename=\"" + fileName + "\"");

        try (FileInputStream fis = new FileInputStream(file);
             OutputStream os = response.getOutputStream()) {
            byte[] buf = new byte[8192];
            int n;
            while ((n = fis.read(buf)) != -1) os.write(buf, 0, n);
        }
    }
}
