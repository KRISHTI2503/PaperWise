package com.paperwise.servlet;

import com.paperwise.dao.PaperRequestDAO;
import com.paperwise.model.PaperRequest;
import com.paperwise.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Handles paper request submission from the student dashboard modal.
 * POST /student/submitRequest
 * Returns JSON: { success, request: { requestId, subjectName, subjectCode, year, description, requestedAt } }
 */
@WebServlet("/student/submitRequest")
public class StudentSubmitRequestServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final DateTimeFormatter DISPLAY_FMT = DateTimeFormatter.ofPattern("MMM dd, yyyy");

    private PaperRequestDAO requestDAO;

    @Override
    public void init() throws ServletException {
        requestDAO = new PaperRequestDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // Session guard
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"error\":\"Not logged in\"}");
            return;
        }
        User user = (User) session.getAttribute("loggedInUser");
        if (user == null || !"student".equalsIgnoreCase(user.getRole())) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"error\":\"Not logged in\"}");
            return;
        }

        // Read params
        String subjectName = request.getParameter("subjectName");
        String subjectCode = request.getParameter("subjectCode");
        String yearParam   = request.getParameter("year");
        String description = request.getParameter("description");

        // Validate
        if (subjectName == null || subjectName.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Subject Name is required.\"}");
            return;
        }
        if (subjectCode == null || subjectCode.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Subject Code is required.\"}");
            return;
        }
        if (yearParam == null || yearParam.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Year is required.\"}");
            return;
        }

        int year;
        try {
            year = Integer.parseInt(yearParam.trim());
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"error\":\"Year must be a valid number.\"}");
            return;
        }

        if (year < 2006 || year > 2026) {
            out.print("{\"success\":false,\"error\":\"Year must be between 2006 and 2026.\"}");
            return;
        }

        try {
            PaperRequest req = new PaperRequest();
            req.setSubjectName(subjectName.trim());
            req.setSubjectCode(subjectCode.trim().toUpperCase());
            req.setYear(year);
            req.setDescription(description != null ? description.trim() : null);
            req.setRequestedBy(user.getUserId());

            boolean saved = requestDAO.saveRequest(req);
            if (!saved) {
                out.print("{\"success\":false,\"error\":\"Failed to save request.\"}");
                return;
            }

            // Fetch the newly created request to get its ID
            java.util.List<PaperRequest> recent = requestDAO.getRequestsByUserId(user.getUserId());
            int newId = recent.isEmpty() ? 0 : recent.get(0).getRequestId();
            String requestedAt = LocalDateTime.now().format(DISPLAY_FMT);
            String descJson = (description != null && !description.trim().isEmpty())
                    ? "\"" + escJson(description.trim()) + "\""
                    : "null";

            out.print("{\"success\":true,\"request\":{"
                    + "\"requestId\":"   + newId
                    + ",\"subjectName\":\"" + escJson(req.getSubjectName()) + "\""
                    + ",\"subjectCode\":\"" + escJson(req.getSubjectCode()) + "\""
                    + ",\"year\":"       + year
                    + ",\"description\":" + descJson
                    + ",\"requestedAt\":\"" + requestedAt + "\""
                    + "}}");

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"error\":\"Database error.\"}");
        }
    }

    private String escJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r");
    }
}
