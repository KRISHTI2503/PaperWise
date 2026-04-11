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
        * { box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: #f7fafc;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1500px;
            margin: 0 auto;
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        h1 { color: #1a202c; margin-bottom: 8px; }
        .user-info { color: #718096; margin-bottom: 24px; }
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
            to   { opacity: 1; transform: translateY(0); }
        }
        .success-message::before { content: "OK"; margin-right: 8px; font-weight: bold; }
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
            transition: all 0.2s ease;
            display: inline-block;
            border: none;
            cursor: pointer;
            font-size: 14px;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(102,126,234,0.4); }
        .btn-secondary { background: #e2e8f0; color: #2d3748; }
        .btn-secondary:hover { background: #cbd5e0; }
        .btn-small { padding: 5px 10px; font-size: 13px; }
        .btn-view     { background: #4299e1; color: white; }
        .btn-view:hover { background: #3182ce; }
        .btn-download { background: #48bb78; color: white; }
        .btn-download:hover { background: #38a169; }
        .btn-edit     { background: #ed8936; color: white; }
        .btn-edit:hover { background: #dd6b20; }
        .btn-delete   { background: #e53e3e; color: white; }
        .btn-delete:hover { background: #c53030; }
        .btn-stats    { background: #805ad5; color: white; }
        .btn-stats:hover { background: #6b46c1; }
        .content { margin-top: 32px; }
        .papers-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            font-size: 14px;
        }
        .papers-table th {
            background: #f7fafc;
            padding: 11px 12px;
            text-align: left;
            font-weight: 600;
            color: #2d3748;
            border-bottom: 2px solid #e2e8f0;
            white-space: nowrap;
        }
        .papers-table td {
            padding: 11px 12px;
            border-bottom: 1px solid #e2e8f0;
            color: #4a5568;
            vertical-align: middle;
        }
        .papers-table tr:hover { background: #f7fafc; }
        .action-buttons { display: flex; gap: 6px; flex-wrap: wrap; }
        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-easy   { background: #c6f6d5; color: #276749; }
        .badge-medium { background: #fefcbf; color: #744210; }
        .badge-hard   { background: #fed7d7; color: #822727; }
        .badge-mixed  { background: #e9d8fd; color: #553c9a; }
        .badge-none   { background: #e2e8f0; color: #718096; }
        .vote-count { font-weight: 600; color: #2d3748; }
        .avg-score  { font-weight: 600; color: #553c9a; }
        /* Progress bar */
        .diff-bar { display: flex; height: 6px; border-radius: 4px; overflow: hidden; width: 80px; margin-top: 4px; }
        .diff-bar-easy   { background: #48bb78; }
        .diff-bar-medium { background: #ecc94b; }
        .diff-bar-hard   { background: #e53e3e; }
        /* Modal */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        .modal-overlay.active { display: flex; }
        .modal {
            background: white;
            border-radius: 12px;
            padding: 32px;
            width: 420px;
            max-width: 95vw;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        .modal h3 { margin: 0 0 4px; color: #1a202c; }
        .modal .subtitle { color: #718096; font-size: 13px; margin-bottom: 24px; }
        .modal-close {
            float: right;
            background: none;
            border: none;
            font-size: 20px;
            cursor: pointer;
            color: #718096;
            margin-top: -4px;
        }
        .stat-row { margin-bottom: 16px; }
        .stat-label {
            display: flex;
            justify-content: space-between;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 5px;
        }
        .progress-track {
            background: #e2e8f0;
            border-radius: 6px;
            height: 10px;
            overflow: hidden;
        }
        .progress-fill {
            height: 100%;
            border-radius: 6px;
            transition: width 0.4s ease;
        }
        .fill-easy   { background: #48bb78; }
        .fill-medium { background: #ecc94b; }
        .fill-hard   { background: #e53e3e; }
        .modal-summary {
            margin-top: 20px;
            padding-top: 16px;
            border-top: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            font-size: 13px;
            color: #4a5568;
        }
        .modal-summary strong { color: #1a202c; }
        .empty-state { text-align: center; padding: 60px 20px; color: #718096; }
        .empty-state h3 { margin-bottom: 8px; }
    </style>
</head>
<body>
<div class="container">
    <h1>Admin Dashboard</h1>
    <div class="user-info">
        <p>Welcome, <strong><%= loggedInUser.getUsername() %></strong> &mdash; <%= loggedInUser.getRole() %></p>
    </div>

    <%
        String successMessage = (String) session.getAttribute("successMessage");
        if (successMessage != null) { session.removeAttribute("successMessage");
    %>
        <div class="success-message" id="successMessage"><%= successMessage %></div>
    <% } %>
    <%
        String errorMessage = (String) request.getAttribute("errorMessage");
        if (errorMessage != null) {
    %>
        <div class="error-message"><%= errorMessage %></div>
    <% } %>

    <div class="actions">
        <a href="${pageContext.request.contextPath}/uploadPaper" class="btn btn-primary">Upload Paper</a>
        <a href="${pageContext.request.contextPath}/adminRequests" class="btn btn-primary">Manage Requests</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary">Logout</a>
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
                    <th>Total Votes</th>
                    <th>Difficulty</th>
                    <th>Avg Difficulty</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% for (Paper paper : papers) {
                int total = paper.getEasyCount() + paper.getMediumCount() + paper.getHardCount();
                int easyPct   = total > 0 ? (int) Math.round(paper.getEasyCount()   * 100.0 / total) : 0;
                int mediumPct = total > 0 ? (int) Math.round(paper.getMediumCount() * 100.0 / total) : 0;
                int hardPct   = total > 0 ? 100 - easyPct - mediumPct : 0;
                String label  = paper.getDifficultyLabel() != null ? paper.getDifficultyLabel() : "Not Rated";
                String badgeClass = "badge-none";
                if ("Easy".equalsIgnoreCase(label))        badgeClass = "badge-easy";
                else if ("Medium".equalsIgnoreCase(label)) badgeClass = "badge-medium";
                else if ("Hard".equalsIgnoreCase(label))   badgeClass = "badge-hard";
                else if ("Mixed".equalsIgnoreCase(label))  badgeClass = "badge-mixed";
                double avg = paper.getAvgDifficulty() > 0 ? paper.getAvgDifficulty() : paper.getAvgDifficultyScore();
            %>
                <tr>
                    <td><%= paper.getSubjectName() %></td>
                    <td><%= paper.getSubjectCode() %></td>
                    <td><%= paper.getYear() %></td>
                    <td><%= paper.getChapter() != null ? paper.getChapter() : "-" %></td>
                    <td><%= paper.getUploaderUsername() != null ? paper.getUploaderUsername() : "Unknown" %></td>
                    <td><span class="vote-count"><%= paper.getTotalVotes() %></span></td>
                    <td>
                        <span class="badge <%= badgeClass %>"><%= label %></span>
                        <% if (total > 0) { %>
                        <div class="diff-bar">
                            <div class="diff-bar-easy"   style="width:<%= easyPct %>%"></div>
                            <div class="diff-bar-medium" style="width:<%= mediumPct %>%"></div>
                            <div class="diff-bar-hard"   style="width:<%= hardPct %>%"></div>
                        </div>
                        <% } %>
                    </td>
                    <td>
                        <% if (avg > 0) { %>
                            <span class="avg-score"><%= String.format("%.2f", avg) %> / 3</span>
                        <% } else { %>
                            <span style="color:#a0aec0">-</span>
                        <% } %>
                    </td>
                    <td>
                        <div class="action-buttons">
                            <a href="${pageContext.request.contextPath}/viewFile?fileName=<%= paper.getFileUrl() %>"
                               target="_blank" class="btn btn-small btn-view">View</a>
                            <a href="${pageContext.request.contextPath}/viewFile?fileName=<%= paper.getFileUrl() %>&download=true"
                               class="btn btn-small btn-download">Download</a>
                            <a href="${pageContext.request.contextPath}/editPaper?paperId=<%= paper.getPaperId() %>"
                               class="btn btn-small btn-edit">Edit</a>
                            <button class="btn btn-small btn-stats"
                                onclick="openStats(
                                    '<%= paper.getSubjectName().replace("'", "\\'") %>',
                                    '<%= paper.getSubjectCode() %>',
                                    <%= paper.getTotalVotes() %>,
                                    <%= paper.getEasyCount() %>,
                                    <%= paper.getMediumCount() %>,
                                    <%= paper.getHardCount() %>,
                                    '<%= String.format("%.2f", avg) %>',
                                    '<%= label %>'
                                )">View Stats</button>
                            <form action="${pageContext.request.contextPath}/deletePaper" method="post"
                                  style="display:inline;"
                                  onsubmit="return confirm('Delete this paper? This cannot be undone.');">
                                <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                <button type="submit" class="btn btn-small btn-delete">Delete</button>
                            </form>
                        </div>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% } else { %>
        <div class="empty-state">
            <h3>No Papers Yet</h3>
            <p>Upload your first paper to get started.</p>
        </div>
        <% } %>
    </div>
</div>

<!-- Stats Modal -->
<div class="modal-overlay" id="statsModal" onclick="closeStatsOnOverlay(event)">
    <div class="modal">
        <button class="modal-close" onclick="closeStats()">&times;</button>
        <h3 id="modal-title"></h3>
        <div class="modal-subtitle" id="modal-subtitle"></div>

        <div class="stat-row">
            <div class="stat-label">
                <span>Easy</span>
                <span id="easy-label"></span>
            </div>
            <div class="progress-track">
                <div class="progress-fill fill-easy" id="easy-bar"></div>
            </div>
        </div>
        <div class="stat-row">
            <div class="stat-label">
                <span>Medium</span>
                <span id="medium-label"></span>
            </div>
            <div class="progress-track">
                <div class="progress-fill fill-medium" id="medium-bar"></div>
            </div>
        </div>
        <div class="stat-row">
            <div class="stat-label">
                <span>Hard</span>
                <span id="hard-label"></span>
            </div>
            <div class="progress-track">
                <div class="progress-fill fill-hard" id="hard-bar"></div>
            </div>
        </div>

        <div class="modal-summary">
            <span>Total useful votes: <strong id="modal-total-votes"></strong></span>
            <span>Avg difficulty: <strong id="modal-avg"></strong></span>
        </div>
    </div>
</div>

<script>
    function openStats(name, code, totalVotes, easy, medium, hard, avg, label) {
        document.getElementById('modal-title').textContent = name + ' (' + code + ')';
        document.getElementById('modal-subtitle').textContent = 'Difficulty: ' + label;
        const total = easy + medium + hard;
        const easyPct   = total > 0 ? Math.round(easy   / total * 100) : 0;
        const mediumPct = total > 0 ? Math.round(medium / total * 100) : 0;
        const hardPct   = total > 0 ? 100 - easyPct - mediumPct : 0;
        document.getElementById('easy-label').textContent   = easy   + ' votes (' + easyPct   + '%)';
        document.getElementById('medium-label').textContent = medium + ' votes (' + mediumPct + '%)';
        document.getElementById('hard-label').textContent   = hard   + ' votes (' + hardPct   + '%)';
        document.getElementById('easy-bar').style.width   = easyPct   + '%';
        document.getElementById('medium-bar').style.width = mediumPct + '%';
        document.getElementById('hard-bar').style.width   = hardPct   + '%';
        document.getElementById('modal-total-votes').textContent = totalVotes;
        document.getElementById('modal-avg').textContent = total > 0 ? avg + ' / 3' : 'Not rated';
        document.getElementById('statsModal').classList.add('active');
    }
    function closeStats() {
        document.getElementById('statsModal').classList.remove('active');
    }
    function closeStatsOnOverlay(e) {
        if (e.target === document.getElementById('statsModal')) closeStats();
    }
    document.addEventListener('keydown', e => { if (e.key === 'Escape') closeStats(); });

    const successMsg = document.getElementById('successMessage');
    if (successMsg) {
        setTimeout(() => {
            successMsg.style.transition = 'opacity 0.5s ease-out';
            successMsg.style.opacity = '0';
            setTimeout(() => successMsg.style.display = 'none', 500);
        }, 3000);
    }
</script>
</body>
</html>
