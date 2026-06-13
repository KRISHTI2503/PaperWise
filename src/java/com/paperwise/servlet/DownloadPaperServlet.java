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
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Handles paper downloads.
 * Accepts:  ?paperId=<int>   (looks up filename from DB)
 *        OR ?fileName=<str>  (legacy direct filename)
 * Always serves as attachment (forces browser download).
 */
@WebServlet("/downloadPaper")
public class DownloadPaperServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(DownloadPaperServlet.class.getName());
    private static final String UPLOAD_DIR = ViewFileServlet.UPLOAD_DIRECTORY;

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

        String paperIdStr = request.getParameter("paperId");
        String fileName   = request.getParameter("fileName");

        if (paperIdStr != null && !paperIdStr.trim().isEmpty()) {
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

        File file = new File(UPLOAD_DIR, fileName);
        if (!file.exists() || !file.isFile()) {
            LOGGER.log(Level.WARNING, "[DownloadPaperServlet] FILE NOT FOUND - expected: {0}, fileName: {1}, dir exists: {2}",
                    new Object[]{file.getAbsolutePath(), fileName, new File(UPLOAD_DIR).exists()});
            response.sendError(HttpServletResponse.SC_NOT_FOUND,
                    "File not found on disk: " + file.getAbsolutePath()
                    + " — the file may have been deleted or never uploaded successfully.");
            return;
        }

        String contentType = getServletContext().getMimeType(fileName);
        if (contentType == null) contentType = "application/octet-stream";

        response.setContentType(contentType);
        response.setContentLengthLong(file.length());
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (FileInputStream fis = new FileInputStream(file);
             OutputStream os = response.getOutputStream()) {
            byte[] buf = new byte[8192];
            int n;
            while ((n = fis.read(buf)) != -1) os.write(buf, 0, n);
        }
    }
}
