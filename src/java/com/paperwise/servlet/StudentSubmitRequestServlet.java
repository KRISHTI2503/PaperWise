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

@WebServlet("/student/submitRequest")
public class StudentSubmitRequestServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final DateTimeFormatter DTF = DateTimeFormatter.ofPattern("MMM dd, yyyy");

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

        HttpSession session = request.getSession(false);
        if (session == null) {
            out.print("{\"success\":false,\"error\":\"Not logged in\"}");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            out.print("{\"success\":false,\"error\":\"Not logged in\"}");
            return;
        }

        String subjectName = trim(request.getParameter("subjectName"));
        String subjectCode = trim(request.getParameter("subjectCode"));
        String yearParam   = trim(request.getParameter("year"));
        String description = trim(request.getParameter("description"));

        if (subjectName.isEmpty()) { out.print("{\"success\":false,\"error\":\"Subject Name is required.\"}"); return; }
        if (subjectCode.isEmpty()) { out.print("{\"success\":false,\"error\":\"Subject Code is required.\"}"); return; }
        if (yearParam.isEmpty())   { out.print("{\"success\":false,\"error\":\"Year is required.\"}"); return; }

        int year;
        try {
            year = Integer.parseInt(yearParam);
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"error\":\"Year must be a number.\"}");
            return;
        }

        if (!requestDAO.isValidYear(year)) {
            out.print("{\"success\":false,\"error\":\"Year must be between "
                    + requestDAO.getValidYearRange() + ".\"}");
            return;
        }

        PaperRequest req = new PaperRequest();
        req.setRequestedBy(user.getUserId());
        req.setSubjectName(subjectName);
        req.setSubjectCode(subjectCode);
        req.setYear(year);
        req.setDescription(description.isEmpty() ? null : description);

        try {
            boolean saved = requestDAO.saveRequest(req);
            if (!saved) {
                out.print("{\"success\":false,\"error\":\"Failed to save request.\"}");
                return;
            }

            // Fetch the saved request to get its generated ID
            java.util.List<PaperRequest> recent = requestDAO.getRequestsByUserId(user.getUserId());
            int newId = recent.isEmpty() ? 0 : recent.get(0).getRequestId();
            String requestedAt = LocalDateTime.now().format(DTF);

            // Build JSON — escape strings manually to avoid extra dependencies
            out.print("{\"success\":true,\"request\":{"
                    + "\"requestId\":"   + newId
                    + ",\"subjectName\":\"" + escJson(subjectName) + "\""
                    + ",\"subjectCode\":\"" + escJson(subjectCode) + "\""
                    + ",\"year\":"      + year
                    + ",\"description\":\"" + escJson(description) + "\""
                    + ",\"requestedAt\":\"" + requestedAt + "\""
                    + "}}");

        } catch (IllegalArgumentException e) {
            out.print("{\"success\":false,\"error\":\"" + escJson(e.getMessage()) + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"error\":\"Server error. Please try again.\"}");
        }
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private String escJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
