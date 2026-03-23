<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.Paper" %>
<%@ page import="java.util.List" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    @SuppressWarnings("unchecked")
    List<Paper> papers = (List<Paper>) request.getAttribute("papers");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - PaperWise</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: #f7fafc;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        h1 {
            color: #1a202c;
            margin-bottom: 8px;
        }
        .user-info {
            color: #718096;
            margin-bottom: 24px;
        }
        .success-message {
            background: #e6ffed;
            border-left: 4px solid #38a169;
            color: #22543d;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 14px;
            display: flex;
            align-items: center;
            animation: slideDown 0.3s ease-out;
        }
        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .success-message::before {
            content: "✓";
            margin-right: 8px;
            font-size: 18px;
            font-weight: bold;
        }
        .error-message {
            background: #fee;
            border-left: 4px solid #e53e3e;
            color: #c53030;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 14px;
        }
        .actions {
            display: flex;
            gap: 12px;
            margin-bottom: 32px;
            flex-wrap: wrap;
        }
        .btn {
            padding: 12px 24px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-block;
            border: none;
            cursor: pointer;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }
        .btn-secondary {
            background: #e2e8f0;
            color: #2d3748;
        }
        .btn-secondary:hover {
            background: #cbd5e0;
        }
        .btn-small {
            padding: 6px 12px;
            font-size: 14px;
        }
        .btn-view {
            background: #4299e1;
            color: white;
        }
        .btn-view:hover {
            background: #3182ce;
        }
        .btn-download {
            background: #48bb78;
            color: white;
        }
        .btn-download:hover {
            background: #38a169;
        }
        .btn-edit {
            background: #ed8936;
            color: white;
        }
        .btn-edit:hover {
            background: #dd6b20;
        }
        .btn-delete {
            background: #e53e3e;
            color: white;
        }
        .btn-delete:hover {
            background: #c53030;
        }
        .content {
            margin-top: 32px;
        }
        .papers-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .papers-table th {
            background: #f7fafc;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            color: #2d3748;
            border-bottom: 2px solid #e2e8f0;
        }
        .papers-table td {
            padding: 12px;
            border-bottom: 1px solid #e2e8f0;
            color: #4a5568;
        }
        .papers-table tr:hover {
            background: #f7fafc;
        }
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #718096;
        }
        .empty-state-icon {
            font-size: 64px;
            margin-bottom: 16px;
        }
        .action-buttons {
            display: flex;
            gap: 8px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Admin Dashboard</h1>
        <div class="user-info">
            <p>Welcome, <strong><%= loggedInUser.getUsername() %></strong>!</p>
            <p>Role: <%= loggedInUser.getRole() %></p>
        </div>

        <% 
            String successMessage = (String) session.getAttribute("successMessage");
            if (successMessage != null) {
                session.removeAttribute("successMessage");
        %>
            <div class="success-message" id="successMessage">
                <%= successMessage %>
            </div>
        <% } %>

        <% 
            String errorMessage = (String) request.getAttribute("errorMessage");
            if (errorMessage != null) {
        %>
            <div class="error-message">
                <%= errorMessage %>
            </div>
        <% } %>

        <div class="actions">
            <a href="${pageContext.request.contextPath}/uploadPaper" class="btn btn-primary">
                Upload Paper
            </a>
            <a href="${pageContext.request.contextPath}/adminRequests" class="btn btn-primary">
                Manage Requests
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary">
                Logout
            </a>
        </div>
        
        <div class="content">
            <h2>Uploaded Papers (<%= papers != null ? papers.size() : 0 %>)</h2>
            
            <% if (papers != null && !papers.isEmpty()) { %>
                <table class="papers-table">
                    <thead>
                        <tr>
                            <th>Subject Name</th>
                            <th>Subject Code</th>
                            <th>Year</th>
                            <th>Chapter</th>
                            <th>Uploaded By</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Paper paper : papers) { %>
                        <tr>
                            <td><%= paper.getSubjectName() %></td>
                            <td><%= paper.getSubjectCode() %></td>
                            <td><%= paper.getYear() %></td>
                            <td><%= paper.getChapter() != null ? paper.getChapter() : "-" %></td>
                            <td><%= paper.getUploaderUsername() != null ? paper.getUploaderUsername() : "Unknown" %></td>
                            <td>
                                <div class="action-buttons">
                                    <a href="${pageContext.request.contextPath}/viewFile?fileName=<%= paper.getFileUrl() %>" 
                                       target="_blank" 
                                       class="btn btn-small btn-view">
                                        View
                                    </a>
                                    <a href="${pageContext.request.contextPath}/viewFile?fileName=<%= paper.getFileUrl() %>&download=true" 
                                       class="btn btn-small btn-download">
                                        Download
                                    </a>
                                    <a href="${pageContext.request.contextPath}/editPaper?paperId=<%= paper.getPaperId() %>" 
                                       class="btn btn-small btn-edit">
                                        Edit
                                    </a>
                                    <form action="${pageContext.request.contextPath}/deletePaper" 
                                          method="post" 
                                          style="display: inline;"
                                          onsubmit="return confirm('Are you sure you want to delete this paper? This action cannot be undone.');">
                                        <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                        <button type="submit" class="btn btn-small btn-delete">
                                            Delete
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="empty-state">
                    <div class="empty-state-icon"></div>
                    <h3>No Papers Yet</h3>
                    <p>Upload your first paper to get started!</p>
                </div>
            <% } %>
        </div>
    </div>

    <script>
        const successMsg = document.getElementById('successMessage');
        if (successMsg) {
            setTimeout(() => {
                successMsg.style.transition = 'opacity 0.5s ease-out';
                successMsg.style.opacity = '0';
                setTimeout(() => {
                    successMsg.style.display = 'none';
                }, 500);
            }, 3000);
        }
    </script>
</body>
</html>