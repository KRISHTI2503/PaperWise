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

@WebServlet("/viewFile")
public class ViewFileServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(ViewFileServlet.class.getName());

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

        // Get file - either from Supabase or local storage
        try {
            // Check if file is from Supabase (no leading slash) or local (starts with "uploads/")
            if (fileName.startsWith("uploads/")) {
                // Check if production mode - never serve local files in production
                if (SupabaseStorageService.isProduction()) {
                    LOGGER.log(Level.SEVERE, "Production mode: Cannot serve local file: {0}", fileName);
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, 
                            "File not found in storage: " + fileName);
                    return;
                }
                
                // Local file - serve directly (only in local mode)
                java.io.File file = new java.io.File(getServletContext().getRealPath("/"), fileName);
                if (!file.exists()) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found: " + fileName);
                    return;
                }
                
                // Determine content type
                String mimeType = getServletContext().getMimeType(fileName);
                if (mimeType == null) {
                    mimeType = "application/octet-stream";
                }
                
                response.setContentType(mimeType);
                response.setContentLengthLong(file.length());
                response.setHeader("Content-Disposition", "inline; filename=\"" + 
                        new java.io.File(fileName).getName() + "\"");
                
                // Serve file
                try (java.io.FileInputStream fis = new java.io.FileInputStream(file);
                     java.io.OutputStream os = response.getOutputStream()) {
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = fis.read(buffer)) != -1) {
                        os.write(buffer, 0, bytesRead);
                    }
                }
            } else {
                // Supabase file - check if Supabase is initialized
                if (!SupabaseStorageService.isInitialized()) {
                    try {
                        SupabaseStorageService.initialize();
                    } catch (Exception initEx) {
                        // Check if production mode
                        if (SupabaseStorageService.isProduction()) {
                            LOGGER.log(Level.SEVERE, "Production mode: Supabase not configured: {0}", initEx.getMessage());
                            response.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                                    "File storage unavailable");
                            return;
                        }
                        
                        // Local mode - try local file as fallback
                        LOGGER.log(Level.WARNING, "Supabase not configured, trying local file: {0}", fileName);
                        java.io.File file = new java.io.File(getServletContext().getRealPath("/"), "uploads/" + fileName);
                        if (!file.exists()) {
                            response.sendError(HttpServletResponse.SC_NOT_FOUND, 
                                    "File not found. Supabase is not configured and local file doesn't exist: " + fileName);
                            return;
                        }
                        
                        String mimeType = getServletContext().getMimeType(fileName);
                        if (mimeType == null) {
                            mimeType = "application/octet-stream";
                        }
                        
                        response.setContentType(mimeType);
                        response.setContentLengthLong(file.length());
                        response.setHeader("Content-Disposition", "inline; filename=\"" + 
                                new java.io.File(fileName).getName() + "\"");
                        
                        try (java.io.FileInputStream fis = new java.io.FileInputStream(file);
                             java.io.OutputStream os = response.getOutputStream()) {
                            byte[] buffer = new byte[4096];
                            int bytesRead;
                            while ((bytesRead = fis.read(buffer)) != -1) {
                                os.write(buffer, 0, bytesRead);
                            }
                        }
                        return;
                    }
                }
                
                // Try to get signed URL from Supabase
                String signedUrl = SupabaseStorageService.getSignedUrl(fileName);
                
                if (signedUrl != null) {
                    response.sendRedirect(signedUrl);
                } else {
                    LOGGER.log(Level.SEVERE, "Failed to generate signed URL for file: {0}", fileName);
                    response.sendError(HttpServletResponse.SC_NOT_FOUND,
                            "File not found in storage: " + fileName);
                }
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving file", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error accessing file storage: " + e.getMessage());
        }
    }
}
