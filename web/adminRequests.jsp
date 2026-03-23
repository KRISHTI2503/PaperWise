<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.PaperRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"admin".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<PaperRequest> requests = (List<PaperRequest>) request.getAttribute("requests");
    
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
    if (errorMessage == null) {
        errorMessage = (String) session.getAttribute("errorMessage");
    }
    
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
    
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Requests - PaperWise Admin</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f7fa;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .header {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }

        h1 {
            color: #333;
            margin-bottom: 10px;
        }

        .subtitle {
            color: #666;
            font-size: 14px;
        }

        .back-link {
            display: inline-block;
            margin-bottom: 15px;
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        .message {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .success-message {
            background: #d4edda;
            border-left: 4px solid #28a745;
            color: #155724;
        }

        .error-message {
            background: #f8d7da;
            border-left: 4px solid #dc3545;
            color: #721c24;
        }

        .requests-table {
            background: white;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
        }

        td {
            padding: 15px;
            border-bottom: 1px solid #eee;
        }

        tbody tr:hover {
            background: #f9f9f9;
        }

        .status-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }

        .status-pending {
            background: #fff3cd;
            color: #856404;
        }

        .status-approved {
            background: #d4edda;
            color: #155724;
        }

        .status-rejected {
            background: #f8d7da;
            color: #721c24;
        }

        .status-completed {
            background: #d1ecf1;
            color: #0c5460;
        }

        .status-form {
            display: flex;
            gap: 5px;
            align-items: center;
        }

        select {
            padding: 6px 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 13px;
        }

        .btn-update {
            padding: 6px 15px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            transition: background 0.3s;
        }

        .btn-update:hover {
            background: #5568d3;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }

        .empty-state-icon {
            font-size: 48px;
            margin-bottom: 15px;
        }

        .requested-at {
            font-size: 13px;
            color: #666;
        }

        .requester {
            font-size: 13px;
            color: #999;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <a href="${pageContext.request.contextPath}/adminDashboard" class="back-link">
                Back to Dashboard
            </a>
            <h1>Manage Paper Requests</h1>
            <p class="subtitle">Review and update student paper requests</p>
        </div>

        <% if (successMessage != null) { %>
            <div class="message success-message">
                <%= successMessage %>
            </div>
        <% } %>

        <% if (errorMessage != null) { %>
            <div class="message error-message">
                <%= errorMessage %>
            </div>
        <% } %>

        <% if (requests != null && !requests.isEmpty()) { %>
            <div class="requests-table">
                <table>
                    <thead>
                        <tr>
                            <th>Subject Name</th>
                            <th>Subject Code</th>
                            <th>Year</th>
                            <th>Description</th>
                            <th>Requested By</th>
                            <th>Requested At</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (PaperRequest req : requests) { 
                            String statusClass = "status-" + req.getStatus().toLowerCase();
                        %>
                            <tr>
                                <td><strong><%= req.getSubjectName() %></strong></td>
                                <td><%= req.getSubjectCode() %></td>
                                <td><%= req.getYear() %></td>
                                <td>
                                    <% if (req.getDescription() != null && !req.getDescription().isEmpty()) { %>
                                        <%= req.getDescription().length() > 50 ? 
                                            req.getDescription().substring(0, 50) + "..." : 
                                            req.getDescription() %>
                                    <% } else { %>
                                        <span style="color: #999;">-</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="requester">
                                        <%= req.getRequesterUsername() != null ? 
                                            req.getRequesterUsername() : "Unknown" %>
                                    </div>
                                </td>
                                <td>
                                    <div class="requested-at">
                                        <%= req.getCreatedAt() != null ? 
                                            req.getCreatedAt().format(dateFormatter) : "-" %>
                                    </div>
                                </td>
                                <td>
                                    <span class="status-badge <%= statusClass %>">
                                        <%= req.getStatus().toUpperCase() %>
                                    </span>
                                </td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/adminRequests" 
                                          method="post" 
                                          class="status-form">
                                        <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                                        <select name="status" required>
                                            <option value="">Update...</option>
                                            <option value="approved">Approved</option>
                                            <option value="rejected">Rejected</option>
                                            <option value="completed">Completed</option>
                                        </select>
                                        <button type="submit" class="btn-update">Update</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <div class="requests-table">
                <div class="empty-state">
                    <div class="empty-state-icon"></div>
                    <h3>No Requests Yet</h3>
                    <p>Student paper requests will appear here.</p>
                </div>
            </div>
        <% } %>
    </div>

    <script>
        setTimeout(function() {
            const successMsg = document.querySelector('.success-message');
            if (successMsg) {
                successMsg.style.transition = 'opacity 0.5s';
                successMsg.style.opacity = '0';
                setTimeout(() => successMsg.remove(), 500);
            }
        }, 3000);
    </script>
</body>
</html>