<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="java.time.Year" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
    String subjectName = (String) request.getAttribute("subjectName");
    String subjectCode = (String) request.getAttribute("subjectCode");
    String yearStr = (String) request.getAttribute("year");
    String description = (String) request.getAttribute("description");
    
    int currentYear = Year.now().getValue();
    int minYear = currentYear - 20;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Request Paper - PaperWise</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 600px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            padding: 40px;
        }

        h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 28px;
        }

        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }

        .error-message {
            background: #fee;
            border-left: 4px solid #f44;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            color: #c33;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
        }

        .required {
            color: #f44;
        }

        input[type="text"],
        input[type="number"],
        select,
        textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }

        input[type="text"]:focus,
        input[type="number"]:focus,
        select:focus,
        textarea:focus {
            outline: none;
            border-color: #667eea;
        }

        textarea {
            resize: vertical;
            min-height: 100px;
        }

        .year-info {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
        }

        .button-group {
            display: flex;
            gap: 10px;
            margin-top: 30px;
        }

        button {
            flex: 1;
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-submit {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-cancel {
            background: #f5f5f5;
            color: #666;
        }

        .btn-cancel:hover {
            background: #e0e0e0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Request Paper</h1>
        <p class="subtitle">Can't find the paper you need? Request it here!</p>

        <% if (errorMessage != null) { %>
            <div class="error-message">
                <%= errorMessage %>
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/requestPaper" method="post">
            <div class="form-group">
                <label for="subject_name">
                    Subject Name <span class="required">*</span>
                </label>
                <input type="text" 
                       id="subject_name" 
                       name="subject_name" 
                       placeholder="e.g., Data Structures and Algorithms"
                       value="<%= subjectName != null ? subjectName : "" %>"
                       required>
            </div>

            <div class="form-group">
                <label for="subject_code">
                    Subject Code <span class="required">*</span>
                </label>
                <input type="text" 
                       id="subject_code" 
                       name="subject_code" 
                       placeholder="e.g., CS201"
                       value="<%= subjectCode != null ? subjectCode : "" %>"
                       required>
            </div>

            <div class="form-group">
                <label for="year">
                    Year <span class="required">*</span>
                </label>
                <input type="number"
                       id="year"
                       name="year"
                       placeholder="e.g., <%= currentYear %>"
                       value="<%= yearStr != null ? yearStr : "" %>"
                       min="<%= minYear %>"
                       max="<%= currentYear %>"
                       required>
            </div>

            <div class="form-group">
                <label for="description">
                    Description <span style="color: #999;">(optional)</span>
                </label>
                <textarea id="description" 
                          name="description" 
                          placeholder="Any additional details about the paper you need..."
                ><%= description != null ? description : "" %></textarea>
            </div>

            <div class="button-group">
                <button type="submit" class="btn-submit">
                    Submit Request
                </button>
                <button type="button" class="btn-cancel" onclick="window.location.href='${pageContext.request.contextPath}/studentDashboard'">
                    Cancel
                </button>
            </div>
        </form>
    </div>
</body>
</html>