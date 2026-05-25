<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.Paper" %>
<%@ page import="com.paperwise.model.PaperRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDateTime" %>
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
    List<PaperRequest> requests = (List<PaperRequest>) request.getAttribute("requests");

    int totalStudents    = request.getAttribute("totalStudents")    != null ? (int) request.getAttribute("totalStudents")    : 0;
    int totalUsefulMarks = request.getAttribute("totalUsefulMarks") != null ? (int) request.getAttribute("totalUsefulMarks") : 0;
    int pendingCount     = request.getAttribute("pendingRequestsCount") != null ? (int) request.getAttribute("pendingRequestsCount") : 0;
    int easyCount        = request.getAttribute("easyCount")   != null ? (int) request.getAttribute("easyCount")   : 0;
    int mediumCount      = request.getAttribute("mediumCount") != null ? (int) request.getAttribute("mediumCount") : 0;
    int hardCount        = request.getAttribute("hardCount")   != null ? (int) request.getAttribute("hardCount")   : 0;
    int totalDiff        = easyCount + mediumCount + hardCount;
    int easyPct   = totalDiff > 0 ? (int) Math.round(easyCount   * 100.0 / totalDiff) : 0;
    int mediumPct = totalDiff > 0 ? (int) Math.round(mediumCount * 100.0 / totalDiff) : 0;
    int hardPct   = totalDiff > 0 ? (int) Math.round(hardCount   * 100.0 / totalDiff) : 0;

    String username = loggedInUser.getUsername();
    String initials = username.length() >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    String currentMonthYear = java.time.format.DateTimeFormatter.ofPattern("MMM yyyy")
        .format(java.time.LocalDate.now());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: #f0f4f8;
            min-height: 100vh;
            display: flex;
        }

        /* ═══════════════════════════════════════
           SIDEBAR
        ═══════════════════════════════════════ */
        .sidebar {
            width: 220px;
            min-width: 220px;
            background: #0d1b2a;
            min-height: 100vh;
            position: sticky;
            top: 0;
            height: 100vh;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
        }

        /* Logo */
        .sidebar-logo {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 20px 18px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
        }
        .logo-sq {
            width: 34px; height: 34px;
            background: #1a3a5c;
            border-radius: 9px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .logo-sq i { font-size: 15px; color: #fff; margin: 0; }
        .logo-text { display: flex; flex-direction: column; }
        .logo-text .app-name  { font-size: 16px; font-weight: 700; color: #fff; line-height: 1.2; }
        .logo-text .app-sub   { font-size: 10px; color: rgba(255,255,255,0.4); }

        /* Nav */
        .nav-section { padding: 14px 0 4px; }
        .nav-label {
            font-size: 10px;
            color: rgba(255,255,255,0.3);
            letter-spacing: 0.8px;
            text-transform: uppercase;
            padding: 0 18px 6px;
        }
        .nav-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 9px 14px;
            margin: 1px 8px;
            border-radius: 8px;
            font-size: 13px;
            color: rgba(255,255,255,0.55);
            text-decoration: none;
            cursor: pointer;
            transition: background 0.15s, color 0.15s;
            position: relative;
        }
        .nav-item i { font-size: 13px; margin: 0; width: 16px; text-align: center; flex-shrink: 0; }
        .nav-item:hover  { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.85); }
        .nav-item.active { background: #1a3a5c; color: #fff; }
        .nav-badge {
            margin-left: auto;
            background: #e53e3e;
            color: #fff;
            font-size: 10px;
            border-radius: 10px;
            padding: 1px 6px;
            font-weight: 600;
        }

        /* Sidebar bottom */
        .sidebar-bottom {
            margin-top: auto;
            border-top: 1px solid rgba(255,255,255,0.08);
            padding: 12px 8px;
        }
        .user-row {
            display: flex;
            align-items: center;
            gap: 9px;
            padding: 6px 10px 10px;
        }
        .avatar {
            width: 32px; height: 32px;
            background: #1a3a5c;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 11px; font-weight: 700; color: #fff;
            flex-shrink: 0;
        }
        .user-meta .u-name { font-size: 12px; font-weight: 700; color: #fff; }
        .user-meta .u-role { font-size: 10px; color: rgba(255,255,255,0.35); }
        .logout-btn {
            display: flex;
            align-items: center;
            gap: 8px;
            width: 100%;
            padding: 8px 14px;
            margin: 0 0;
            border-radius: 8px;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 13px;
            color: rgba(255,100,100,0.7);
            transition: background 0.15s, color 0.15s;
            text-align: left;
        }
        .logout-btn i { font-size: 13px; margin: 0; }
        .logout-btn:hover { background: rgba(255,80,80,0.1); color: #ff6b6b; }

        /* ═══════════════════════════════════════
           MAIN CONTENT
        ═══════════════════════════════════════ */
        .main {
            flex: 1;
            display: flex;
            flex-direction: column;
            min-width: 0;
        }

        /* Top bar */
        .topbar {
            background: #fff;
            height: 56px;
            padding: 0 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid #e8edf2;
            flex-shrink: 0;
        }
        .topbar-title { font-size: 16px; font-weight: 600; color: #0d1b2a; }
        .topbar-right { display: flex; align-items: center; gap: 10px; }
        .pill-date {
            background: #fff4e0;
            color: #854f0b;
            font-size: 11px;
            padding: 4px 10px;
            border-radius: 20px;
            display: flex; align-items: center; gap: 5px;
        }
        .pill-date i { font-size: 11px; margin: 0; }
        .bell-btn {
            position: relative;
            width: 34px; height: 34px;
            background: #f0f4f8;
            border: none;
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer;
            color: #4f7396;
        }
        .bell-btn i { font-size: 14px; margin: 0; }
        .bell-dot {
            position: absolute;
            top: 6px; right: 6px;
            width: 7px; height: 7px;
            background: #e53e3e;
            border-radius: 50%;
            border: 1.5px solid #fff;
        }

        /* Content area */
        .content { padding: 20px 24px; flex: 1; }

        /* Alerts */
        .alert-success {
            background: #f0fff4; border: 1px solid #9ae6b4; color: #276749;
            border-radius: 8px; padding: 10px 14px; margin-bottom: 16px;
            font-size: 13px; display: flex; align-items: center; gap: 8px;
        }
        .alert-error {
            background: #fff0f0; border: 1px solid #f5c6cb; color: #c0392b;
            border-radius: 8px; padding: 10px 14px; margin-bottom: 16px;
            font-size: 13px; display: flex; align-items: center; gap: 8px;
        }
        .alert-success i, .alert-error i { font-size: 13px; margin: 0; flex-shrink: 0; }

        /* ═══════════════════════════════════════
           STAT CARDS
        ═══════════════════════════════════════ */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
            margin-bottom: 20px;
        }
        .stat-card {
            background: #fff;
            border-radius: 12px;
            padding: 16px;
            border: 1px solid #e8edf2;
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .stat-icon {
            width: 36px; height: 36px;
            border-radius: 9px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .stat-icon i { font-size: 15px; margin: 0; }
        .stat-icon.blue   { background: #eef2ff; color: #4338ca; }
        .stat-icon.green  { background: #f0fdf4; color: #166534; }
        .stat-icon.orange { background: #fff7ed; color: #9a3412; }
        .stat-icon.pink   { background: #fff0f6; color: #9d174d; }
        .stat-body .stat-num   { font-size: 22px; font-weight: 700; color: #0d1b2a; line-height: 1.1; }
        .stat-body .stat-label { font-size: 11px; color: #6b7280; margin-top: 2px; }

        /* ═══════════════════════════════════════
           PAPERS TABLE SECTION
        ═══════════════════════════════════════ */
        .section-card {
            background: #fff;
            border-radius: 12px;
            border: 1px solid #e8edf2;
            overflow: hidden;
            margin-bottom: 20px;
        }
        .section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 18px;
            border-bottom: 1px solid #f0f4f8;
        }
        .section-header-left { display: flex; align-items: center; gap: 8px; }
        .section-title { font-size: 14px; font-weight: 600; color: #0d1b2a; }
        .count-pill {
            font-size: 11px;
            padding: 3px 9px;
            border-radius: 20px;
            font-weight: 500;
        }
        .count-pill.indigo { background: #eef2ff; color: #3730a3; }
        .count-pill.amber  { background: #fff4e0; color: #854f0b; }

        .btn-upload {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: #1a3a5c;
            color: #fff;
            border: none;
            border-radius: 8px;
            padding: 7px 14px;
            font-size: 12px;
            font-weight: 500;
            text-decoration: none;
            cursor: pointer;
            transition: background 0.15s;
        }
        .btn-upload i { font-size: 11px; margin: 0; }
        .btn-upload:hover { background: #0d2a45; }

        /* Table */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table thead tr { background: #f8fafc; }
        .data-table th {
            font-size: 11px;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 10px 18px;
            text-align: left;
            border-bottom: 1px solid #e8edf2;
            font-weight: 600;
        }
        .data-table td {
            padding: 12px 18px;
            border-bottom: 1px solid #f0f4f8;
            font-size: 13px;
            color: #1f2937;
        }
        .data-table tbody tr:last-child td { border-bottom: none; }
        .data-table tbody tr:hover td { background: #f8fafc; }
        .td-subject { font-weight: 600; color: #0d1b2a; }

        .code-pill { background: #eef2ff; color: #3730a3; font-size: 11px; border-radius: 6px; padding: 3px 8px; font-weight: 500; }
        .year-pill  { background: #f0f9ff; color: #0369a1; font-size: 11px; border-radius: 6px; padding: 3px 8px; font-weight: 500; }

        .diff-badge {
            font-size: 11px;
            padding: 3px 8px;
            border-radius: 6px;
            font-weight: 500;
            display: inline-block;
        }
        .diff-easy   { background: #f0fdf4; color: #166534; }
        .diff-medium { background: #fff7ed; color: #9a3412; }
        .diff-hard   { background: #fef2f2; color: #991b1b; }
        .diff-none   { background: #f3f4f6; color: #6b7280; }

        .action-btns { display: flex; gap: 5px; flex-wrap: wrap; }
        .act-btn {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 5px 10px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 500;
            border: none;
            cursor: pointer;
            text-decoration: none;
            transition: opacity 0.15s;
        }
        .act-btn i { font-size: 10px; margin: 0; }
        .act-btn:hover { opacity: 0.82; }
        .act-view     { background: #eff6ff; color: #1d4ed8; }
        .act-download { background: #f0fdf4; color: #166534; }
        .act-edit     { background: #fff7ed; color: #9a3412; }
        .act-delete   { background: #fef2f2; color: #991b1b; }

        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 48px 20px;
            color: #9ca3af;
        }
        .empty-state i { font-size: 40px; margin: 0 0 12px; display: block; }
        .empty-state p { font-size: 13px; }

        /* ═══════════════════════════════════════
           BOTTOM TWO-PANEL ROW
        ═══════════════════════════════════════ */
        .bottom-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        /* Recent requests */
        .req-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 14px;
            border-bottom: 1px solid #f0f4f8;
        }
        .req-row:last-child { border-bottom: none; }
        .req-left .req-subject { font-size: 12px; color: #374151; font-weight: 500; }
        .req-left .req-meta    { font-size: 11px; color: #9ca3af; margin-top: 2px; }
        .status-pill {
            font-size: 10px;
            padding: 3px 8px;
            border-radius: 20px;
            font-weight: 500;
            white-space: nowrap;
        }
        .s-pending  { background: #fff4e0; color: #854f0b; }
        .s-approved { background: #f0fdf4; color: #166534; }
        .s-rejected { background: #fef2f2; color: #991b1b; }
        .s-completed{ background: #eff6ff; color: #1d4ed8; }

        /* Difficulty breakdown */
        .diff-row { padding: 10px 18px; border-bottom: 1px solid #f0f4f8; }
        .diff-row:last-child { border-bottom: none; }
        .diff-row-header {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            color: #374151;
            margin-bottom: 6px;
        }
        .diff-row-header span:last-child { color: #6b7280; font-size: 11px; }
        .progress-track {
            background: #f0f4f8;
            height: 8px;
            border-radius: 6px;
            overflow: hidden;
        }
        .progress-fill { height: 100%; border-radius: 6px; transition: width 0.4s ease; }
        .fill-easy   { background: #1d9e75; }
        .fill-medium { background: #e97c30; }
        .fill-hard   { background: #e53e3e; }
    </style>
</head>
<body>

<!-- ═══════════════════════════════════════════════════
     SIDEBAR
═══════════════════════════════════════════════════ -->
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
        <a href="${pageContext.request.contextPath}/adminDashboard" class="nav-item active">
            <i class="fa-solid fa-table-cells-large"></i> Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/allPapers" class="nav-item">
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

<!-- ═══════════════════════════════════════════════════
     MAIN CONTENT
═══════════════════════════════════════════════════ -->
<div class="main">

    <!-- Top bar -->
    <div class="topbar">
        <span class="topbar-title">Dashboard Overview</span>
        <div class="topbar-right">
            <span class="pill-date">
                <i class="fa-regular fa-calendar"></i> <span id="topbarDate"></span>
            </span>
            <button class="bell-btn" title="Notifications">
                <i class="fa-regular fa-bell"></i>
                <% if (pendingCount > 0) { %><span class="bell-dot"></span><% } %>
            </button>
        </div>
    </div>

    <!-- Content -->
    <div class="content">

        <%-- Flash messages --%>
        <%
            String successMsg = (String) session.getAttribute("successMessage");
            if (successMsg != null) { session.removeAttribute("successMessage"); %>
            <div class="alert-success" id="flashMsg">
                <i class="fa-solid fa-circle-check"></i> <%= successMsg %>
            </div>
        <% } %>
        <%
            String errorMsg = (String) request.getAttribute("errorMessage");
            if (errorMsg != null) { %>
            <div class="alert-error">
                <i class="fa-solid fa-circle-exclamation"></i> <%= errorMsg %>
            </div>
        <% } %>

        <!-- Stat cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fa-regular fa-copy"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= papers != null ? papers.size() : 0 %></div>
                    <div class="stat-label">Total Papers</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="fa-solid fa-users"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalStudents %></div>
                    <div class="stat-label">Total Students</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon orange"><i class="fa-solid fa-clipboard-list"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= pendingCount %></div>
                    <div class="stat-label">Pending Requests</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon pink"><i class="fa-solid fa-heart"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalUsefulMarks %></div>
                    <div class="stat-label">Total Useful Marks</div>
                </div>
            </div>
        </div>

        <!-- Papers table -->
        <div class="section-card">
            <div class="section-header">
                <div class="section-header-left">
                    <span class="section-title">Uploaded Papers</span>
                    <span class="count-pill indigo"><%= papers != null ? papers.size() : 0 %></span>
                </div>
                <a href="${pageContext.request.contextPath}/uploadPaper" class="btn-upload">
                    <i class="fa-solid fa-plus"></i> Upload Paper
                </a>
            </div>

            <% if (papers != null && !papers.isEmpty()) { %>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Subject Name</th>
                        <th>Code</th>
                        <th>Year</th>
                        <th>Chapter</th>
                        <th>Exam Type</th>
                        <th>Uploaded By</th>
                        <th>Uploaded On</th>
                        <th>Difficulty</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Paper paper : papers) {
                    String diffLabel = paper.getDifficultyLabel();
                    if (diffLabel == null || diffLabel.isEmpty()) diffLabel = "Not Rated";
                    String diffCls = "diff-none";
                    if ("Easy".equalsIgnoreCase(diffLabel))   diffCls = "diff-easy";
                    else if ("Medium".equalsIgnoreCase(diffLabel)) diffCls = "diff-medium";
                    else if ("Hard".equalsIgnoreCase(diffLabel))   diffCls = "diff-hard";
                %>
                    <tr>
                        <td class="td-subject"><%= paper.getSubjectName() %></td>
                        <td><span class="code-pill"><%= paper.getSubjectCode() %></span></td>
                        <td><span class="year-pill"><%= paper.getYear() %></span></td>
                        <td><%= paper.getChapter() != null ? paper.getChapter() : "-" %></td>
                        <td>
                            <% if (paper.getExamType() != null && !paper.getExamType().isEmpty()) { %>
                                <span style="background:#e0e7ff;color:#3730a3;font-size:11px;font-weight:600;border-radius:5px;padding:2px 8px;display:inline-block;white-space:nowrap"><%= paper.getExamType() %></span>
                            <% } else { %>
                                <span style="color:#9ca3af;font-size:12px">—</span>
                            <% } %>
                        </td>
                        <td><%= paper.getUploaderUsername() != null ? paper.getUploaderUsername() : "Unknown" %></td>
                        <td style="color:#64748b;font-size:12px;white-space:nowrap">
                            <% if (paper.getCreatedAt() != null) { %>
                                <%= paper.getCreatedAt().format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy")) %>
                            <% } else { %>
                                <span style="color:#94a3b8;font-style:italic">—</span>
                            <% } %>
                        </td>
                        <td><span class="diff-badge <%= diffCls %>"><%= diffLabel %></span></td>
                        <td>
                            <div class="action-btns">
                                <a href="${pageContext.request.contextPath}/viewFile?paperId=<%= paper.getPaperId() %>"
                                   target="_blank" class="act-btn act-view">
                                    <i class="fa-regular fa-eye"></i> View
                                </a>
                                <a href="${pageContext.request.contextPath}/downloadPaper?paperId=<%= paper.getPaperId() %>"
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
            <% } else { %>
            <div class="empty-state">
                <i class="fa-regular fa-folder-open" style="color:#cbd5e0;"></i>
                <p>No papers uploaded yet.</p>
            </div>
            <% } %>
        </div>

        <!-- Bottom row: Recent Requests full width -->
        <div class="bottom-grid" style="grid-template-columns: 1fr;">

            <!-- Recent Requests -->
            <div class="section-card" style="margin-bottom:0;">
                <div class="section-header">
                    <div class="section-header-left">
                        <span class="section-title">Recent Requests</span>
                        <span class="count-pill amber"><%= pendingCount %> pending</span>
                    </div>
                </div>
                <% if (requests != null && !requests.isEmpty()) {
                    int shown = 0;
                    for (PaperRequest req : requests) {
                        if (shown >= 5) break;
                        String st = req.getStatus() != null ? req.getStatus().toLowerCase() : "pending";
                        String stCls = "s-pending";
                        if ("approved".equals(st))  stCls = "s-approved";
                        else if ("rejected".equals(st))  stCls = "s-rejected";
                        else if ("completed".equals(st)) stCls = "s-completed";
                        String reqTime = req.getCreatedAt() != null ? req.getCreatedAt().format(dtf) : "-";
                        shown++;
                %>
                    <div class="req-row">
                        <div class="req-left">
                            <div class="req-subject"><%= req.getSubjectName() %> (<%= req.getSubjectCode() %>)</div>
                            <div class="req-meta"><%= req.getRequesterUsername() != null ? req.getRequesterUsername() : "Unknown" %> &middot; <%= reqTime %></div>
                        </div>
                        <span class="status-pill <%= stCls %>"><%= st %></span>
                    </div>
                <% } } else { %>
                    <div class="empty-state" style="padding:28px 20px;">
                        <i class="fa-regular fa-folder-open" style="color:#cbd5e0; font-size:28px;"></i>
                        <p>No requests yet.</p>
                    </div>
                <% } %>
            </div>

        </div><!-- /.bottom-grid -->
    </div><!-- /.content -->
</div><!-- /.main -->

<script>
    const flash = document.getElementById('flashMsg');
    if (flash) {
        setTimeout(() => {
            flash.style.transition = 'opacity 0.5s';
            flash.style.opacity = '0';
            setTimeout(() => flash.remove(), 500);
        }, 3000);
    }

    function showToast(msg) {
        const t = document.getElementById('pwToast');
        document.getElementById('pwToastMsg').textContent = msg;
        t.style.opacity = '1';
        t.style.transform = 'translateY(0)';
        setTimeout(() => {
            t.style.opacity = '0';
            t.style.transform = 'translateY(8px)';
        }, 3500);
    }

    window.addEventListener('load', function () {
        const p = new URLSearchParams(window.location.search);
        if (p.get('uploaded') === 'true') {
            showToast('Paper uploaded successfully!');
            // Clean URL so refresh doesn't re-trigger toast
            if (window.history.replaceState) {
                window.history.replaceState(null, '', window.location.pathname);
            }
        }
        if (p.get('updated') === 'true') {
            showToast('Paper updated successfully!');
            if (window.history.replaceState) {
                window.history.replaceState(null, '', window.location.pathname);
            }
        }
    });
</script>

<div id="pwToast" style="position:fixed;bottom:20px;right:20px;background:#0f2744;color:#fff;border-radius:10px;padding:10px 16px;font-size:13px;font-weight:500;display:flex;align-items:center;gap:8px;opacity:0;transform:translateY(8px);transition:all .25s;pointer-events:none;z-index:999;">
    <i class="fa-solid fa-circle-check" style="font-size:16px;color:#4ade80;margin:0;"></i>
    <span id="pwToastMsg">Done!</span>
</div>
<script>
(function() {
    var days=['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    var months=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var now=new Date();
    var el=document.getElementById('topbarDate');
    if(el) el.textContent=days[now.getDay()]+', '+now.getDate()+' '+months[now.getMonth()]+' '+now.getFullYear();
})();
</script>
</body>
</html>
