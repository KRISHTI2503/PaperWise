<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.Paper" %>
<%@ page import="com.paperwise.model.PaperRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Paper> papers = (List<Paper>) request.getAttribute("papers");

    int totalUsefulMarks  = request.getAttribute("totalUsefulMarks")  != null ? (int) request.getAttribute("totalUsefulMarks")  : 0;
    String mostCommonDiff = request.getAttribute("mostCommonDifficulty") != null ? (String) request.getAttribute("mostCommonDifficulty") : "Not Rated";
    int pendingCount      = request.getAttribute("pendingRequestsCount") != null ? (int) request.getAttribute("pendingRequestsCount") : 0;

    String username = loggedInUser.getUsername();
    String initials = username.length() >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();

    String currentMonthYear = java.time.format.DateTimeFormatter.ofPattern("MMM yyyy")
        .format(java.time.LocalDate.now());

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>All Papers - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: #f0f4f8;
            min-height: 100vh;
            display: flex;
        }

        /* ── SIDEBAR ─────────────────────────────────── */
        .sidebar {
            width: 220px; min-width: 220px;
            background: #0d1b2a;
            min-height: 100vh;
            position: sticky; top: 0; height: 100vh;
            display: flex; flex-direction: column;
            overflow-y: auto;
        }
        .sidebar-logo {
            display: flex; align-items: center; gap: 10px;
            padding: 20px 18px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
        }
        .logo-sq {
            width: 34px; height: 34px; background: #1a3a5c;
            border-radius: 9px; display: flex; align-items: center;
            justify-content: center; flex-shrink: 0;
        }
        .logo-sq i { font-size: 15px; color: #fff; margin: 0; }
        .logo-text .app-name { font-size: 16px; font-weight: 700; color: #fff; line-height: 1.2; }
        .logo-text .app-sub  { font-size: 10px; color: rgba(255,255,255,0.4); }

        .nav-section { padding: 14px 0 4px; }
        .nav-label {
            font-size: 10px; color: rgba(255,255,255,0.3);
            letter-spacing: 0.8px; text-transform: uppercase;
            padding: 0 18px 6px;
        }
        .nav-item {
            display: flex; align-items: center; gap: 10px;
            padding: 9px 14px; margin: 1px 8px; border-radius: 8px;
            font-size: 13px; color: rgba(255,255,255,0.55);
            text-decoration: none; cursor: pointer;
            transition: background 0.15s, color 0.15s; position: relative;
        }
        .nav-item i { font-size: 13px; margin: 0; width: 16px; text-align: center; flex-shrink: 0; }
        .nav-item:hover  { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.85); }
        .nav-item.active { background: #1a3a5c; color: #fff; }
        .nav-badge {
            margin-left: auto; background: #e53e3e; color: #fff;
            font-size: 10px; border-radius: 10px; padding: 1px 6px; font-weight: 600;
        }
        .sidebar-bottom {
            margin-top: auto; border-top: 1px solid rgba(255,255,255,0.08); padding: 12px 8px;
        }
        .user-row { display: flex; align-items: center; gap: 9px; padding: 6px 10px 10px; }
        .avatar {
            width: 32px; height: 32px; background: #1a3a5c; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 11px; font-weight: 700; color: #fff; flex-shrink: 0;
        }
        .user-meta .u-name { font-size: 12px; font-weight: 700; color: #fff; }
        .user-meta .u-role { font-size: 10px; color: rgba(255,255,255,0.35); }
        .logout-btn {
            display: flex; align-items: center; gap: 8px; width: 100%;
            padding: 8px 14px; border-radius: 8px; background: none; border: none;
            cursor: pointer; font-size: 13px; color: rgba(255,100,100,0.7);
            transition: background 0.15s, color 0.15s; text-align: left;
        }
        .logout-btn i { font-size: 13px; margin: 0; }
        .logout-btn:hover { background: rgba(255,80,80,0.1); color: #ff6b6b; }

        /* ── MAIN ────────────────────────────────────── */
        .main { flex: 1; display: flex; flex-direction: column; min-width: 0; }

        .topbar {
            background: #fff; height: 56px; padding: 0 24px;
            display: flex; align-items: center; justify-content: space-between;
            border-bottom: 1px solid #e8edf2; flex-shrink: 0;
        }
        .topbar-left { display: flex; flex-direction: column; }
        .topbar-title    { font-size: 16px; font-weight: 600; color: #0d1b2a; line-height: 1.2; }
        .topbar-subtitle { font-size: 11px; color: #9ca3af; }
        .topbar-right { display: flex; align-items: center; gap: 10px; }
        .pill-date {
            background: #fff4e0; color: #854f0b; font-size: 11px;
            padding: 4px 10px; border-radius: 20px; display: flex; align-items: center; gap: 5px;
        }
        .pill-date i { font-size: 11px; margin: 0; }
        .bell-btn {
            position: relative; width: 34px; height: 34px; background: #f0f4f8;
            border: none; border-radius: 8px; display: flex; align-items: center;
            justify-content: center; cursor: pointer; color: #4f7396;
        }
        .bell-btn i { font-size: 14px; margin: 0; }
        .bell-dot {
            position: absolute; top: 6px; right: 6px; width: 7px; height: 7px;
            background: #e53e3e; border-radius: 50%; border: 1.5px solid #fff;
        }

        .content { padding: 20px 24px; flex: 1; }

        /* ── STAT CARDS ──────────────────────────────── */
        .stats-grid {
            display: grid; grid-template-columns: repeat(3, 1fr);
            gap: 12px; margin-bottom: 20px;
        }
        .stat-card {
            background: #fff; border-radius: 12px; padding: 16px;
            border: 1px solid #e8edf2; display: flex; align-items: center; gap: 14px;
        }
        .stat-icon {
            width: 36px; height: 36px; border-radius: 9px;
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        }
        .stat-icon i { font-size: 15px; margin: 0; }
        .stat-icon.blue   { background: #eef2ff; color: #4338ca; }
        .stat-icon.orange { background: #fff7ed; color: #9a3412; }
        .stat-icon.red    { background: #fef2f2; color: #991b1b; }
        .stat-body .stat-num   { font-size: 22px; font-weight: 700; color: #0d1b2a; line-height: 1.1; }
        .stat-body .stat-label { font-size: 11px; color: #6b7280; margin-top: 2px; }

        /* ── SECTION CARD ────────────────────────────── */
        .section-card {
            background: #fff; border-radius: 12px;
            border: 1px solid #e8edf2; overflow: hidden; margin-bottom: 20px;
        }
        .section-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 14px 18px; border-bottom: 1px solid #f0f4f8; flex-wrap: wrap; gap: 10px;
        }
        .section-header-left { display: flex; align-items: center; gap: 8px; }
        .section-title { font-size: 14px; font-weight: 600; color: #0d1b2a; }
        .count-pill {
            font-size: 11px; padding: 3px 9px; border-radius: 20px; font-weight: 500;
        }
        .count-pill.indigo { background: #eef2ff; color: #3730a3; }

        /* Search + filter controls */
        .filter-controls { display: flex; align-items: center; gap: 8px; }
        .search-input {
            border: 1.5px solid #e5e7eb; border-radius: 8px;
            padding: 6px 10px 6px 30px; font-size: 12px; color: #111827;
            background: #f9fafb; outline: none; width: 200px;
            transition: border .18s, box-shadow .18s;
            font-family: inherit;
        }
        .search-input:focus { border-color: #3b82f6; background: #fff; box-shadow: 0 0 0 3px rgba(59,130,246,.1); }
        .search-wrap { position: relative; }
        .search-wrap i { position: absolute; left: 9px; top: 50%; transform: translateY(-50%); font-size: 12px; color: #9ca3af; margin: 0; }
        .year-select {
            border: 1.5px solid #e5e7eb; border-radius: 8px;
            padding: 6px 28px 6px 10px; font-size: 12px; color: #374151;
            background: #f9fafb; outline: none; cursor: pointer;
            appearance: none; font-family: inherit;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%239ca3af'/%3E%3C/svg%3E");
            background-repeat: no-repeat; background-position: right 9px center;
            transition: border .18s;
        }
        .year-select:focus { border-color: #3b82f6; }

        /* ── TABLE ───────────────────────────────────── */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table thead tr { background: #f8fafc; }
        .data-table th {
            font-size: 11px; color: #6b7280; text-transform: uppercase;
            letter-spacing: 0.5px; padding: 10px 14px; text-align: left;
            border-bottom: 1px solid #e8edf2; font-weight: 600; white-space: nowrap;
        }
        .data-table td {
            padding: 11px 14px; border-bottom: 1px solid #f0f4f8;
            font-size: 13px; color: #1f2937; vertical-align: middle;
        }
        .data-table tbody tr:last-child td { border-bottom: none; }
        .data-table tbody tr:hover td { background: #f8fafc; }
        .td-subject { font-weight: 600; color: #0d1b2a; max-width: 180px; }

        .code-pill { background: #eef2ff; color: #3730a3; font-size: 11px; border-radius: 6px; padding: 3px 8px; font-weight: 500; white-space: nowrap; }
        .year-pill  { background: #f0f9ff; color: #0369a1; font-size: 11px; border-radius: 6px; padding: 3px 8px; font-weight: 500; }

        /* Useful count cell */
        .useful-cell { display: flex; align-items: center; gap: 5px; white-space: nowrap; }
        .useful-cell i { color: #f97316; font-size: 12px; margin: 0; }
        .useful-num { font-size: 13px; font-weight: 600; color: #0d1b2a; }
        .muted { color: #9ca3af; font-size: 12px; }

        /* Difficulty mini bars */
        .diff-bars { display: flex; flex-direction: column; gap: 4px; min-width: 110px; }
        .diff-bar-row { display: flex; align-items: center; gap: 5px; }
        .diff-bar-label { font-size: 10px; font-weight: 600; width: 28px; flex-shrink: 0; }
        .diff-bar-label.easy { color: #16a34a; }
        .diff-bar-label.med  { color: #ea580c; }
        .diff-bar-label.hard { color: #dc2626; }
        .diff-bar-track { flex: 1; height: 5px; background: #f0f4f8; border-radius: 3px; overflow: hidden; min-width: 50px; }
        .diff-bar-fill  { height: 100%; border-radius: 3px; transition: width .3s; }
        .fill-easy { background: #22c55e; }
        .fill-med  { background: #f97316; }
        .fill-hard { background: #ef4444; }
        .diff-bar-count { font-size: 10px; color: #6b7280; width: 18px; text-align: right; flex-shrink: 0; }
        .no-votes { font-size: 11px; color: #9ca3af; font-style: italic; }

        /* Action buttons */
        .action-btns { display: flex; gap: 4px; flex-wrap: wrap; }
        .act-btn {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 5px 10px; border-radius: 6px; font-size: 11px; font-weight: 500;
            border: none; cursor: pointer; text-decoration: none; transition: opacity 0.15s;
        }
        .act-btn i { font-size: 10px; margin: 0; }
        .act-btn:hover { opacity: 0.82; }
        .act-view     { background: #eff6ff; color: #1d4ed8; }
        .act-download { background: #f0fdf4; color: #166534; }
        .act-edit     { background: #fff7ed; color: #9a3412; }
        .act-delete   { background: #fef2f2; color: #991b1b; }

        /* Empty state */
        .empty-state { text-align: center; padding: 48px 20px; color: #9ca3af; }
        .empty-state i { font-size: 40px; margin: 0 0 12px; display: block; }
        .empty-state p { font-size: 13px; }

        /* Exam type pill */
        .exam-pill { background: #e0e7ff; color: #3730a3; font-size: 11px; font-weight: 600; border-radius: 5px; padding: 2px 8px; display: inline-block; white-space: nowrap; }

        /* Toast */
        .pw-toast {
            position: fixed; bottom: 20px; right: 20px; background: #0f2744; color: #fff;
            border-radius: 10px; padding: 10px 16px; font-size: 13px; font-weight: 500;
            display: flex; align-items: center; gap: 8px;
            opacity: 0; transform: translateY(8px); transition: all .25s;
            pointer-events: none; z-index: 999;
        }
        .pw-toast i { font-size: 16px; color: #4ade80; margin: 0; }
        .pw-toast.show { opacity: 1; transform: translateY(0); }
    </style>
</head>
<body>

<!-- ── SIDEBAR ──────────────────────────────────────────── -->
<nav class="sidebar">
    <div class="sidebar-logo">
        <div class="logo-sq"><i class="fa-solid fa-book-open"></i></div>
        <div class="logo-text">
            <span class="app-name">PaperWise</span>
            <span class="app-sub">Admin Panel</span>
        </div>
    </div>

    <div class="nav-section">
        <p class="nav-label">Main</p>
        <a href="${pageContext.request.contextPath}/adminDashboard" class="nav-item">
            <i class="fa-solid fa-table-cells-large"></i> Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/allPapers" class="nav-item active">
            <i class="fa-regular fa-file-lines"></i> All Papers
        </a>
        <a href="${pageContext.request.contextPath}/uploadPaper" class="nav-item">
            <i class="fa-solid fa-upload"></i> Upload Paper
        </a>
    </div>

    <div class="nav-section">
        <p class="nav-label">Manage</p>
        <a href="${pageContext.request.contextPath}/adminRequests" class="nav-item">
            <i class="fa-solid fa-clipboard-list"></i> Requests
            <% if (pendingCount > 0) { %>
                <span class="nav-badge"><%= pendingCount %></span>
            <% } %>
        </a>
        <a href="${pageContext.request.contextPath}/students" class="nav-item">
            <i class="fa-solid fa-users"></i> Students
        </a>
        <a href="#" class="nav-item">
            <i class="fa-solid fa-chart-bar"></i> Analytics
        </a>
    </div>

    <div class="sidebar-bottom">
        <div class="user-row">
            <div class="avatar"><%= initials %></div>
            <div class="user-meta">
                <div class="u-name"><%= username %></div>
                <div class="u-role">Administrator</div>
            </div>
        </div>
        <form action="${pageContext.request.contextPath}/logout" method="post">
            <button type="submit" class="logout-btn">
                <i class="fa-solid fa-right-from-bracket"></i> Logout
            </button>
        </form>
    </div>
</nav>

<!-- ── MAIN ────────────────────────────────────────────── -->
<div class="main">

    <!-- Topbar -->
    <div class="topbar">
        <div class="topbar-left">
            <span class="topbar-title">All Papers</span>
            <span class="topbar-subtitle">View and manage all uploaded academic papers</span>
        </div>
        <div class="topbar-right">
            <span class="pill-date">
                <i class="fa-regular fa-calendar"></i> <%= currentMonthYear %>
            </span>
            <button class="bell-btn" title="Notifications">
                <i class="fa-regular fa-bell"></i>
                <% if (pendingCount > 0) { %><span class="bell-dot"></span><% } %>
            </button>
        </div>
    </div>

    <div class="content">

        <!-- ── STAT CARDS ── -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fa-regular fa-file-lines"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= papers != null ? papers.size() : 0 %></div>
                    <div class="stat-label">Total Papers</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon orange"><i class="fa-solid fa-thumbs-up"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalUsefulMarks %></div>
                    <div class="stat-label">Total Useful Marks</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon red"><i class="fa-solid fa-fire"></i></div>
                <div class="stat-body">
                    <div class="stat-num" style="font-size:16px;"><%= mostCommonDiff %></div>
                    <div class="stat-label">Most Common Difficulty</div>
                </div>
            </div>
        </div>

        <!-- ── PAPERS TABLE CARD ── -->
        <div class="section-card">
            <div class="section-header">
                <div class="section-header-left">
                    <span class="section-title">Uploaded Papers</span>
                    <span class="count-pill indigo"><%= papers != null ? papers.size() : 0 %></span>
                </div>
                <div class="filter-controls">
                    <!-- Search -->
                    <div class="search-wrap">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" id="searchInput" class="search-input"
                               placeholder="Search subject or code…"
                               oninput="filterTable()">
                    </div>
                    <!-- Year filter -->
                    <select id="yearFilter" class="year-select" onchange="filterTable()">
                        <option value="">All Years</option>
                        <%
                            if (papers != null) {
                                java.util.TreeSet<Integer> years = new java.util.TreeSet<>(java.util.Collections.reverseOrder());
                                for (Paper p : papers) years.add(p.getYear());
                                for (int yr : years) {
                        %>
                        <option value="<%= yr %>"><%= yr %></option>
                        <%      }
                            }
                        %>
                    </select>
                </div>
            </div>

            <% if (papers != null && !papers.isEmpty()) { %>
            <div style="overflow-x:auto;">
            <table class="data-table" id="papersTable">
                <thead>
                    <tr>
                        <th>Subject Name</th>
                        <th>Code</th>
                        <th>Year</th>
                        <th>Chapter</th>
                        <th>Exam Type</th>
                        <th>Uploaded By</th>
                        <th>Useful</th>
                        <th>Difficulty Votes</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="papersBody">
                <%
                    for (Paper paper : papers) {
                        int easy   = paper.getEasyCount();
                        int medium = paper.getMediumCount();
                        int hard   = paper.getHardCount();
                        int total  = easy + medium + hard;
                        int easyPct   = total > 0 ? (int) Math.round(easy   * 100.0 / total) : 0;
                        int mediumPct = total > 0 ? (int) Math.round(medium * 100.0 / total) : 0;
                        int hardPct   = total > 0 ? (int) Math.round(hard   * 100.0 / total) : 0;
                %>
                <tr data-subject="<%= paper.getSubjectName().toLowerCase() %>"
                    data-code="<%= paper.getSubjectCode().toLowerCase() %>"
                    data-year="<%= paper.getYear() %>">
                    <td class="td-subject"><%= paper.getSubjectName() %></td>
                    <td><span class="code-pill"><%= paper.getSubjectCode() %></span></td>
                    <td><span class="year-pill"><%= paper.getYear() %></span></td>
                    <td><%= paper.getChapter() != null && !paper.getChapter().isEmpty() ? paper.getChapter() : "<span class=\"muted\">—</span>" %></td>
                    <td>
                        <% if (paper.getExamType() != null && !paper.getExamType().isEmpty()) { %>
                            <span class="exam-pill"><%= paper.getExamType() %></span>
                        <% } else { %>
                            <span class="muted">—</span>
                        <% } %>
                    </td>
                    <td><%= paper.getUploaderUsername() != null ? paper.getUploaderUsername() : "Unknown" %></td>

                    <!-- Useful count -->
                    <td>
                        <% if (paper.getUsefulCount() > 0) { %>
                            <div class="useful-cell">
                                <i class="fa-solid fa-thumbs-up"></i>
                                <span class="useful-num"><%= paper.getUsefulCount() %></span>
                            </div>
                        <% } else { %>
                            <span class="muted">—</span>
                        <% } %>
                    </td>

                    <!-- Difficulty votes mini bars -->
                    <td>
                        <% if (total == 0) { %>
                            <span class="no-votes">No votes yet</span>
                        <% } else { %>
                            <div class="diff-bars">
                                <div class="diff-bar-row">
                                    <span class="diff-bar-label easy">Easy</span>
                                    <div class="diff-bar-track">
                                        <div class="diff-bar-fill fill-easy" style="width:<%= easyPct %>%"></div>
                                    </div>
                                    <span class="diff-bar-count"><%= easy %></span>
                                </div>
                                <div class="diff-bar-row">
                                    <span class="diff-bar-label med">Med</span>
                                    <div class="diff-bar-track">
                                        <div class="diff-bar-fill fill-med" style="width:<%= mediumPct %>%"></div>
                                    </div>
                                    <span class="diff-bar-count"><%= medium %></span>
                                </div>
                                <div class="diff-bar-row">
                                    <span class="diff-bar-label hard">Hard</span>
                                    <div class="diff-bar-track">
                                        <div class="diff-bar-fill fill-hard" style="width:<%= hardPct %>%"></div>
                                    </div>
                                    <span class="diff-bar-count"><%= hard %></span>
                                </div>
                            </div>
                        <% } %>
                    </td>

                    <!-- Actions -->
                    <td>
                        <div class="action-btns">
                            <a href="${pageContext.request.contextPath}/viewFile?fileName=<%= paper.getFileUrl() %>"
                               target="_blank" class="act-btn act-view">
                                <i class="fa-regular fa-eye"></i> View
                            </a>
                            <a href="${pageContext.request.contextPath}/viewFile?fileName=<%= paper.getFileUrl() %>&download=true"
                               class="act-btn act-download">
                                <i class="fa-solid fa-download"></i> Download
                            </a>
                            <a href="${pageContext.request.contextPath}/editPaper?paperId=<%= paper.getPaperId() %>"
                               class="act-btn act-edit">
                                <i class="fa-solid fa-pen"></i> Edit
                            </a>
                            <form action="${pageContext.request.contextPath}/deletePaper" method="post"
                                  style="display:inline;"
                                  onsubmit="return confirm('Delete this paper? This cannot be undone.');">
                                <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                <button type="submit" class="act-btn act-delete">
                                    <i class="fa-solid fa-trash"></i> Delete
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
            </div>

            <!-- No results row (shown by JS when filter matches nothing) -->
            <div id="noResults" style="display:none; text-align:center; padding:32px; color:#9ca3af; font-size:13px;">
                No papers match your search.
            </div>

            <% } else { %>
            <div class="empty-state">
                <i class="fa-regular fa-folder-open" style="color:#cbd5e0;"></i>
                <p>No papers uploaded yet.</p>
            </div>
            <% } %>
        </div>

    </div><!-- /.content -->
</div><!-- /.main -->

<!-- Toast -->
<div id="pwToast" class="pw-toast">
    <i class="fa-solid fa-circle-check"></i>
    <span id="pwToastMsg">Done!</span>
</div>

<script>
    function filterTable() {
        var query   = document.getElementById('searchInput').value.toLowerCase().trim();
        var yearVal = document.getElementById('yearFilter').value;
        var rows    = document.querySelectorAll('#papersBody tr');
        var visible = 0;

        rows.forEach(function (row) {
            var subject = row.dataset.subject || '';
            var code    = row.dataset.code    || '';
            var year    = row.dataset.year    || '';

            var matchSearch = !query || subject.includes(query) || code.includes(query);
            var matchYear   = !yearVal || year === yearVal;

            if (matchSearch && matchYear) {
                row.style.display = '';
                visible++;
            } else {
                row.style.display = 'none';
            }
        });

        var noResults = document.getElementById('noResults');
        if (noResults) noResults.style.display = visible === 0 ? 'block' : 'none';
    }

    function showToast(msg) {
        var t = document.getElementById('pwToast');
        document.getElementById('pwToastMsg').textContent = msg;
        t.classList.add('show');
        setTimeout(function () { t.classList.remove('show'); }, 3500);
    }

    window.addEventListener('load', function () {
        var p = new URLSearchParams(window.location.search);
        if (p.get('deleted') === 'true') {
            showToast('Paper deleted successfully!');
            if (window.history.replaceState) {
                window.history.replaceState(null, '', window.location.pathname);
            }
        }
    });
</script>
</body>
</html>
