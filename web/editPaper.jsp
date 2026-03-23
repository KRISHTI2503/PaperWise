<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.Paper" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    Paper paper = (Paper) request.getAttribute("paper");
    if (paper == null) {
        response.sendRedirect(request.getContextPath() + "/adminDashboard");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Paper - PaperWise</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            max-width: 600px;
            width: 100%;
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.15);
        }
        h1 {
            color: #1a202c;
            margin-bottom: 8px;
            font-size: 28px;
        }
        .subtitle {
            color: #718096;
            margin-bottom: 32px;
            font-size: 14px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #2d3748;
            font-weight: 600;
            font-size: 14px;
        }
        input[type="text"],
        input[type="number"] {
            width: 100%;
            padding: 12px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s ease;
            box-sizing: border-box;
        }
        input[type="text"]:focus,
        input[type="number"]:focus {
            outline: none;
            border-color: #667eea;
        }
        .required {
            color: #e53e3e;
        }
        .optional {
            color: #718096;
            font-weight: normal;
            font-size: 12px;
        }
        .button-group {
            display: flex;
            gap: 12px;
            margin-top: 32px;
        }
        .btn {
            flex: 1;
            padding: 14px 24px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-block;
            border: none;
            cursor: pointer;
            font-size: 16px;
            text-align: center;
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
        .info-box {
            background: #ebf8ff;
            border-left: 4px solid #4299e1;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 14px;
            color: #2c5282;
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
    </style>
</head>
<body>
    <div class="container">
        <h1>Edit Paper</h1>
        <div class="subtitle">Update paper metadata</div>

        <% 
            String errorMessage = (String) session.getAttribute("errorMessage");
            if (errorMessage != null) {
                session.removeAttribute("errorMessage");
        %>
            <div class="error-message">
                <%= errorMessage %>
            </div>
        <% } %>

        <div class="info-box">
            Note: You can only edit paper metadata. The uploaded file cannot be changed.
        </div>

        <form action="${pageContext.request.contextPath}/editPaper" method="post">
            <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">

            <div class="form-group">
                <label for="subjectName">
                    Subject Name <span class="required">*</span>
                </label>
                <input type="text" 
                       id="subjectName" 
                       name="subjectName" 
                       value="<%= paper.getSubjectName() %>"
                       required 
                       maxlength="150">
            </div>

            <div class="form-group">
                <label for="subjectCode">
                    Subject Code <span class="required">*</span>
                </label>
                <input type="text" 
                       id="subjectCode" 
                       name="subjectCode" 
                       value="<%= paper.getSubjectCode() %>"
                       required 
                       maxlength="50">
            </div>

            <div class="form-group">
                <label for="year">
                    Year <span class="required">*</span>
                </label>
                <% 
                    int currentYear = java.time.Year.now().getValue();
                    int minYear = currentYear - 20;
                %>
                <input type="number" 
                       id="year" 
                       name="year" 
                       value="<%= paper.getYear() %>"
                       required 
                       min="<%= minYear %>" 
                       max="<%= currentYear %>"
                       title="Year must be between <%= minYear %> and <%= currentYear %>">
                <small class="form-text text-muted">
                    Valid range: <%= minYear %> - <%= currentYear %>
                </small>
            </div>

            <div class="form-group">
                <label for="chapter">
                    Chapter <span class="optional">(optional)</span>
                </label>
                <input type="text" 
                       id="chapter" 
                       name="chapter" 
                       value="<%= paper.getChapter() != null ? paper.getChapter() : "" %>"
                       maxlength="100">
            </div>

            <div class="button-group">
                <button type="submit" class="btn btn-primary">
                    Update Paper
                </button>
                <a href="${pageContext.request.contextPath}/adminDashboard" class="btn btn-secondary">
                    Cancel
                </a>
            </div>
        </form>
    </div>
</body>
</html>