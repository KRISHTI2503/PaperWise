<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.Paper" %>
<%@ page import="com.paperwise.model.PaperRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    @SuppressWarnings("unchecked")
    List<Paper> papers = (List<Paper>) request.getAttribute("papers");
    
    @SuppressWarnings("unchecked")
    Set<Integer> votedPapers = (Set<Integer>) request.getAttribute("votedPapers");

    @SuppressWarnings("unchecked")
    List<PaperRequest> myRequests = (List<PaperRequest>) request.getAttribute("myRequests");
    
    String searchQuery = (String) request.getAttribute("searchQuery");
    
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - PaperWise</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 32px;
            flex-wrap: wrap;
            gap: 16px;
        }
        .header-left h1 {
            color: #1a202c;
            margin-bottom: 8px;
            font-size: 32px;
        }
        .user-info {
            color: #718096;
            font-size: 14px;
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
        .search-bar {
            margin-bottom: 24px;
        }
        .search-bar input {
            width: 100%;
            max-width: 400px;
            padding: 12px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s ease;
        }
        .search-bar input:focus {
            outline: none;
            border-color: #667eea;
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
            font-size: 14px;
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
            font-size: 13px;
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
        .btn-vote {
            background: #48bb78;
            color: white;
        }
        .btn-vote:hover {
            background: #38a169;
        }
        .btn-voted {
            background: #cbd5e0;
            color: #718096;
            cursor: not-allowed;
        }
        .papers-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .papers-table th {
            background: #f7fafc;
            padding: 14px 12px;
            text-align: left;
            font-weight: 600;
            color: #2d3748;
            border-bottom: 2px solid #e2e8f0;
            font-size: 14px;
        }
        .papers-table td {
            padding: 14px 12px;
            border-bottom: 1px solid #e2e8f0;
            color: #4a5568;
            font-size: 14px;
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
            gap: 6px;
            flex-wrap: wrap;
        }
        .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .badge-popular {
            background: #fef5e7;
            color: #d97706;
        }
        .badge-success {
            background: #d4edda;
            color: #155724;
        }
        .badge-warning {
            background: #fff3cd;
            color: #856404;
        }
        .badge-danger {
            background: #f8d7da;
            color: #721c24;
        }
        .badge-secondary {
            background: #e2e3e5;
            color: #6c757d;
        }
        .btn-success {
            background: #48bb78;
            color: white;
        }
        .btn-success:hover {
            background: #38a169;
        }
        .btn-warning {
            background: #f6ad55;
            color: white;
        }
        .btn-warning:hover {
            background: #ed8936;
        }
        .btn-danger {
            background: #fc8181;
            color: white;
        }
        .btn-danger:hover {
            background: #f56565;
        }
        .text-muted {
            color: #a0aec0;
            font-size: 11px;
        }
        .vote-count {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            color: #9f7aea;
            font-weight: 600;
        }
        .file-icon {
            display: inline-block;
            width: 20px;
            height: 20px;
            margin-right: 4px;
            vertical-align: middle;
        }
        .subject-name-cell {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .upload-date {
            color: #a0aec0;
            font-size: 12px;
        }
        .stats {
            display: flex;
            gap: 24px;
            margin-bottom: 24px;
            padding: 16px;
            background: #f7fafc;
            border-radius: 8px;
        }
        .stat-item {
            display: flex;
            flex-direction: column;
        }
        .stat-label {
            font-size: 12px;
            color: #718096;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .stat-value {
            font-size: 24px;
            font-weight: 700;
            color: #2d3748;
        }
        .requests-section {
            margin-top: 40px;
            border-top: 2px solid #e2e8f0;
            padding-top: 32px;
        }
        .requests-section h2 {
            font-size: 20px;
            color: #1a202c;
            margin-bottom: 16px;
        }
        .status-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }
        .status-pending  { background: #fef3c7; color: #92400e; }
        .status-approved { background: #dbeafe; color: #1e40af; }
        .status-rejected { background: #fee2e2; color: #991b1b; }
        .status-completed{ background: #d1fae5; color: #065f46; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="header-left">
                <h1>Student Dashboard</h1>
                <div class="user-info">
                    Welcome, <strong><%= loggedInUser.getUsername() %></strong>!
                </div>
            </div>
            <div style="display: flex; gap: 10px;">
                <a href="${pageContext.request.contextPath}/requestPaper" class="btn btn-secondary">
                    Request Paper
                </a>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary">
                    Logout
                </a>
            </div>
        </div>

        <% 
            String successMessage = (String) session.getAttribute("successMessage");
            String msg = (String) session.getAttribute("msg");
            if (successMessage != null || msg != null) {
                String displayMessage = successMessage != null ? successMessage : msg;
                session.removeAttribute("successMessage");
                session.removeAttribute("msg");
        %>
            <div class="success-message" id="successMessage">
                <%= displayMessage %>
            </div>
        <% } %>

        <% 
            String errorMessage = (String) session.getAttribute("errorMessage");
            if (errorMessage != null) {
                session.removeAttribute("errorMessage");
        %>
            <div class="error-message">
                <%= errorMessage %>
            </div>
        <% } %>

        <% if (papers != null && !papers.isEmpty()) { 
            int totalVotes = 0;
            for (Paper p : papers) {
                totalVotes += p.getUsefulCount();
            }
        %>
            <div class="stats">
                <div class="stat-item">
                    <span class="stat-label">Total Papers</span>
                    <span class="stat-value"><%= papers.size() %></span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">Total Useful Marks</span>
                    <span class="stat-value"><%= totalVotes %></span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">Your Marks</span>
                    <span class="stat-value"><%= votedPapers != null ? votedPapers.size() : 0 %></span>
                </div>
            </div>

            <div class="filter-section" style="display: flex; gap: 15px; margin-bottom: 20px; align-items: center;">
                <div class="search-bar" style="flex: 1;">
                    <input type="text" 
                           id="searchInput" 
                           placeholder="Search by subject code, name, or year..." 
                           value="<%= searchQuery != null ? searchQuery : "" %>">
                </div>
                
                <div class="year-filter" style="min-width: 150px;">
                    <select id="yearFilter" 
                            class="form-control" 
                            onchange="window.location.href='${pageContext.request.contextPath}/studentDashboard?year=' + this.value"
                            style="padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px; width: 100%;">
                        <option value="all" <%= request.getAttribute("selectedYear") == null ? "selected" : "" %>>
                            All Years
                        </option>
                        <%
                            @SuppressWarnings("unchecked")
                            List<Integer> availableYears = (List<Integer>) request.getAttribute("availableYears");
                            Integer selectedYear = (Integer) request.getAttribute("selectedYear");
                            if (availableYears != null) {
                                for (Integer year : availableYears) {
                        %>
                                    <option value="<%= year %>" 
                                            <%= (selectedYear != null && selectedYear.equals(year)) ? "selected" : "" %>>
                                        <%= year %>
                                    </option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
            </div>

            <table class="papers-table" id="papersTable">
                <thead>
                    <tr>
                        <th>Subject</th>
                        <th>Code</th>
                        <th>Year</th>
                        <th>Chapter</th>
                        <th>Useful</th>
                        <th>Difficulty</th>
                        <th>Uploaded</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                    for (Paper paper : papers) { 
                        String fileExt = "";
                        if (paper.getFileUrl() != null) {
                            int lastDot = paper.getFileUrl().lastIndexOf('.');
                            if (lastDot > 0) {
                                fileExt = paper.getFileUrl().substring(lastDot + 1).toLowerCase();
                            }
                        }
                        
                        String fileIcon = "";
                        if (fileExt.equals("pdf")) fileIcon = "PDF";
                        else if (fileExt.equals("doc") || fileExt.equals("docx")) fileIcon = "DOC";
                        else if (fileExt.equals("ppt") || fileExt.equals("pptx")) fileIcon = "PPT";
                        else if (fileExt.equals("jpg") || fileExt.equals("jpeg") || fileExt.equals("png")) fileIcon = "IMG";
                        else if (fileExt.equals("mp4") || fileExt.equals("mkv")) fileIcon = "VID";
                    %>
                    <tr data-subject-code="<%= paper.getSubjectCode().toLowerCase() %>" 
                        data-subject-name="<%= paper.getSubjectName().toLowerCase() %>"
                        data-year="<%= paper.getYear() %>">
                        <td>
                            <div class="subject-name-cell">
                                <span class="file-icon"><%= fileIcon %></span>
                                <div>
                                    <%= paper.getSubjectName() %>
                                    <% if (paper.isPopular()) { %>
                                        <span class="badge badge-popular">Popular</span>
                                    <% } %>
                                </div>
                            </div>
                        </td>
                        <td><%= paper.getSubjectCode() %></td>
                        <td><%= paper.getYear() %></td>
                        <td><%= paper.getChapter() != null ? paper.getChapter() : "-" %></td>
                        <td>
                            <span class="vote-count">
                                <%= paper.getUsefulCount() %>
                            </span>
                        </td>
                        <td>
                            <%
                                String diffLabel = paper.getDifficultyLabel();
                                String diffClass = "";
                                if ("Easy".equals(diffLabel)) {
                                    diffClass = "badge-success";
                                } else if ("Medium".equals(diffLabel)) {
                                    diffClass = "badge-warning";
                                } else if ("Hard".equals(diffLabel)) {
                                    diffClass = "badge-danger";
                                } else if ("Mixed".equals(diffLabel)) {
                                    diffClass = "badge-dark";
                                } else {
                                    diffClass = "badge-light";
                                }
                            %>
                            <span class="badge <%= diffClass %>">
                                <%= diffLabel %>
                            </span>
                            <br>
                            <small class="text-muted">
                                (<%= paper.getEasyCount() %> | <%= paper.getMediumCount() %> | <%= paper.getHardCount() %>)
                            </small>
                        </td>
                        <td>
                            <% if (paper.getCreatedAt() != null) { %>
                                <span class="upload-date"><%= paper.getCreatedAt().format(dateFormatter) %></span>
                            <% } else { %>
                                <span class="upload-date">-</span>
                            <% } %>
                        </td>
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
                                <% if ("student".equalsIgnoreCase(loggedInUser.getRole())) { %>
                                    <div class="vote-section">
                                        <% if (paper.isAlreadyMarked()) { %>
                                            <button disabled class="btn btn-small btn-voted">
                                                Marked (<%= paper.getUsefulCount() %>)
                                            </button>
                                        <% } else { %>
                                            <form action="${pageContext.request.contextPath}/markUseful" 
                                                  method="post" 
                                                  style="display:inline;"
                                                  name="usefulForm_<%= paper.getPaperId() %>">
                                                <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                                <button type="submit" class="btn btn-small btn-vote">
                                                    Useful (<%= paper.getUsefulCount() %>)
                                                </button>
                                            </form>
                                        <% } %>
                                    </div>
                                    <br>
                                    <div class="difficulty-section" style="margin-top: 4px;">
                                        <form action="${pageContext.request.contextPath}/rateDifficulty" 
                                              method="post" 
                                              style="display:inline;"
                                              name="diffEasyForm_<%= paper.getPaperId() %>">
                                            <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                            <button type="submit" 
                                                    name="difficulty" 
                                                    value="Easy" 
                                                    class="btn btn-small btn-success" 
                                                    style="padding: 4px 8px; font-size: 11px;">
                                                Easy
                                            </button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/rateDifficulty" 
                                              method="post" 
                                              style="display:inline;"
                                              name="diffMediumForm_<%= paper.getPaperId() %>">
                                            <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                            <button type="submit" 
                                                    name="difficulty" 
                                                    value="Medium" 
                                                    class="btn btn-small btn-warning" 
                                                    style="padding: 4px 8px; font-size: 11px;">
                                                Medium
                                            </button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/rateDifficulty" 
                                              method="post" 
                                              style="display:inline;"
                                              name="diffHardForm_<%= paper.getPaperId() %>">
                                            <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                            <button type="submit" 
                                                    name="difficulty" 
                                                    value="Hard" 
                                                    class="btn btn-small btn-danger" 
                                                    style="padding: 4px 8px; font-size: 11px;">
                                                Hard
                                            </button>
                                        </form>
                                    </div>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="empty-state">
                <div class="empty-state-icon"></div>
                <h3>No Papers Available</h3>
                <p>Check back later for new study materials!</p>
            </div>
        <% } %>
    </div>

    <div class="container requests-section" style="margin-top: 24px;">
        <h2>My Paper Requests</h2>

        <% if (myRequests != null && !myRequests.isEmpty()) { %>
            <table class="papers-table">
                <thead>
                    <tr>
                        <th>Subject Name</th>
                        <th>Subject Code</th>
                        <th>Year</th>
                        <th>Description</th>
                        <th>Status</th>
                        <th>Requested At</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (PaperRequest req : myRequests) {
                        String statusClass = "status-" + (req.getStatus() != null ? req.getStatus().toLowerCase() : "pending");
                    %>
                    <tr>
                        <td><%= req.getSubjectName() %></td>
                        <td><%= req.getSubjectCode() %></td>
                        <td><%= req.getYear() %></td>
                        <td><%= req.getDescription() != null && !req.getDescription().isEmpty() ? req.getDescription() : "-" %></td>
                        <td>
                            <span class="status-badge <%= statusClass %>">
                                <%= req.getStatus() != null ? req.getStatus() : "pending" %>
                            </span>
                        </td>
                        <td>
                            <% if (req.getCreatedAt() != null) { %>
                                <%= req.getCreatedAt().format(dateFormatter) %>
                            <% } else { %>
                                -
                            <% } %>
                        </td>
                        <td>
                            <form action="${pageContext.request.contextPath}/deleteRequest"
                                  method="post"
                                  style="display:inline;"
                                  onsubmit="return confirm('Are you sure you want to delete this request?');">
                                <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                                <button type="submit" class="btn btn-small btn-danger">Delete</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="empty-state" style="padding: 32px 20px;">
                <div class="empty-state-icon"></div>
                <h3>No Requests Yet</h3>
                <p>You have not submitted any paper requests yet.</p>
                <a href="${pageContext.request.contextPath}/requestPaper"
                   style="display:inline-block; margin-top:12px; color:#667eea; font-weight:500; text-decoration:none;">
                    + Request a Paper
                </a>
            </div>
        <% } %>
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

        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('input', function() {
                const query = this.value.toLowerCase();
                const rows = document.querySelectorAll('#papersTable tbody tr');
                
                rows.forEach(row => {
                    const subjectCode = row.getAttribute('data-subject-code');
                    const subjectName = row.getAttribute('data-subject-name');
                    const year = row.getAttribute('data-year');
                    
                    if (subjectCode.includes(query) || 
                        subjectName.includes(query) || 
                        year.includes(query)) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            });
        }
    </script>
</body>
</html>