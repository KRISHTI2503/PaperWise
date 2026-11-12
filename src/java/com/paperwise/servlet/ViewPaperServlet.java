package com.paperwise.servlet;

import com.paperwise.dao.PaperDAO;
import com.paperwise.model.Paper;
import com.paperwise.util.SupabaseStorageService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Handles viewing papers inline (same as ViewFileServlet but different URL pattern)
 * Now redirects to Supabase Storage signed URL.
 */
@WebServlet("/student/viewPaper")
public class ViewPaperServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(ViewPaperServlet.class.getName());

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

        String idParam = request.getParameter("paperId");
        if (idParam == null || idParam.trim().isEmpty()) {
            // also accept legacy ?id= param
            idParam = request.getParameter("id");
        }
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

            // Get signed URL from Supabase Storage and redirect
            String signedUrl = SupabaseStorageService.getSignedUrl(fileName);
            
            if (signedUrl != null) {
                // Redirect to Supabase signed URL for inline viewing
                response.sendRedirect(signedUrl);
            } else {
                LOGGER.log(Level.SEVERE, "Failed to generate signed URL for file: {0}", fileName);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found in storage.");
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid paper ID.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving file from Supabase Storage", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error accessing file storage");
        }
    }
}
