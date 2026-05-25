<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.Paper" %>
<%@ page import="com.paperwise.model.PaperRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"student".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Paper> papers = (List<Paper>) request.getAttribute("papers");
    @SuppressWarnings("unchecked")
    Set<Integer> votedPapers = (Set<Integer>) request.getAttribute("votedPapers");
    @SuppressWarnings("unchecked")
    List<PaperRequest> myRequests = (List<PaperRequest>) request.getAttribute("myRequests");
    @SuppressWarnings("unchecked")
    List<Integer> availableYears = (List<Integer>) request.getAttribute("availableYears");

    int totalPapers      = request.getAttribute("totalPapers")      != null ? (int) request.getAttribute("totalPapers")      : 0;
    int totalUsefulMarks = request.getAttribute("totalUsefulMarks") != null ? (int) request.getAttribute("totalUsefulMarks") : 0;
    int myMarksCount     = request.getAttribute("myMarksCount")     != null ? (int) request.getAttribute("myMarksCount")     : 0;
    Integer selectedYear = (Integer) request.getAttribute("selectedYear");
    String searchQuery   = (String)  request.getAttribute("searchQuery");

    String username = loggedInUser.getUsername();
    String initials = username.length() >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();

    String currentMonthYear = java.time.format.DateTimeFormatter
        .ofPattern("MMM yyyy").format(java.time.LocalDate.now());
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: #f7f9fc;
            min-height: 100vh;
            display: flex;
        }

        /* ── SIDEBAR ── */
        .sidebar {
            width: 220px; min-width: 220px;
            background: #0f2744;
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
            width: 34px; height: 34px; background: rgba(255,255,255,0.12);
            border-radius: 8px; display: flex; align-items: center;
            justify-content: center; flex-shrink: 0;
        }
        .logo-sq i { font-size: 15px; color: #fff; margin: 0; }
        .logo-text { display: flex; flex-direction: column; }
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
            text-decoration: none; transition: background .15s, color .15s;
        }
        .nav-item i { font-size: 13px; margin: 0; width: 16px; text-align: center; flex-shrink: 0; }
        .nav-item:hover  { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.85); }
        .nav-item.active { background: rgba(30,136,229,0.15); color: #42a5f5; }
        .sidebar-bottom {
            margin-top: auto;
            border-top: 1px solid rgba(255,255,255,0.08);
            padding: 12px 8px;
        }
        .user-row { display: flex; align-items: center; gap: 9px; padding: 6px 10px 10px; }
        .avatar {
            width: 32px; height: 32px; background: #1e3a5f;
            border-radius: 50%; display: flex; align-items: center;
            justify-content: center; font-size: 11px; font-weight: 700;
            color: #fff; flex-shrink: 0;
        }
        .user-meta .u-name { font-size: 12px; font-weight: 700; color: #fff; }
        .user-meta .u-role { font-size: 10px; color: rgba(255,255,255,0.35); }
        .logout-btn {
            display: flex; align-items: center; gap: 8px;
            width: 100%; padding: 8px 14px; border-radius: 8px;
            background: none; border: none; cursor: pointer;
            font-size: 13px; color: rgba(255,100,100,0.7);
            transition: background .15s, color .15s; text-align: left;
        }
        .logout-btn i { font-size: 13px; margin: 0; }
        .logout-btn:hover { background: rgba(255,80,80,0.1); color: #ff6b6b; }

        /* ── MAIN ── */
        .main { flex: 1; display: flex; flex-direction: column; min-width: 0; }
        .topbar {
            background: #fff; height: 56px; padding: 0 24px;
            display: flex; align-items: center; justify-content: space-between;
            border-bottom: 1px solid #e8edf2; flex-shrink: 0;
        }
        .topbar-title { font-size: 16px; font-weight: 600; color: #0d1b2a; }
        .topbar-right { display: flex; align-items: center; gap: 10px; }
        .pill-date {
            background: #fff4e0; color: #854f0b; font-size: 11px;
            padding: 4px 10px; border-radius: 20px;
            display: flex; align-items: center; gap: 5px;
        }
        .pill-date i { font-size: 11px; margin: 0; }
        .bell-btn {
            position: relative; width: 34px; height: 34px;
            background: #f0f4f8; border: none; border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; color: #4f7396;
        }
        .bell-btn i { font-size: 14px; margin: 0; }
        .content { padding: 20px 24px; flex: 1; }

        /* ── ALERTS ── */
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

        /* ── STAT CARDS ── */
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
        .stat-icon.green  { background: #f0fdf4; color: #166534; }
        .stat-icon.orange { background: #fff7ed; color: #9a3412; }
        .stat-body .stat-num   { font-size: 22px; font-weight: 700; color: #0d1b2a; line-height: 1.1; }
        .stat-body .stat-label { font-size: 11px; color: #6b7280; margin-top: 2px; }

        /* ── SECTION CARD ── */
        .section-card {
            background: #fff; border-radius: 12px;
            border: 1px solid #e8edf2; overflow: hidden; margin-bottom: 20px;
        }
        .section-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 14px 18px; border-bottom: 1px solid #f0f4f8;
        }
        .section-header-left { display: flex; align-items: center; gap: 8px; }
        .section-title { font-size: 14px; font-weight: 600; color: #0d1b2a; }
        .count-pill {
            font-size: 11px; padding: 3px 9px; border-radius: 20px; font-weight: 500;
        }
        .count-pill.indigo { background: #eef2ff; color: #3730a3; }
        .count-pill.amber  { background: #fff4e0; color: #854f0b; }

        /* ── FILTER BAR ── */
        .filter-bar {
            display: flex; align-items: center; gap: 10px;
            padding: 12px 18px; border-bottom: 1px solid #f0f4f8; flex-wrap: wrap;
        }
        .search-input {
            flex: 1; min-width: 180px; max-width: 320px;
            border: 1.5px solid #e5e7eb; border-radius: 8px;
            padding: 7px 12px 7px 32px; font-size: 13px; color: #111827;
            background: #f9fafb url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%239ca3af' stroke-width='2'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cpath d='m21 21-4.35-4.35'/%3E%3C/svg%3E") no-repeat 10px center;
            outline: none; transition: border .18s;
        }
        .search-input:focus { border-color: #3b82f6; background-color: #fff; }
        .year-select {
            border: 1.5px solid #e5e7eb; border-radius: 8px;
            padding: 7px 28px 7px 10px; font-size: 13px; color: #374151;
            background: #f9fafb; outline: none; cursor: pointer;
            appearance: none; transition: border .18s;
        }
        .year-select:focus { border-color: #3b82f6; }

        /* ── TABLE ── */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table thead tr { background: #f8fafc; }
        .data-table th {
            font-size: 11px; color: #6b7280; text-transform: uppercase;
            letter-spacing: 0.5px; padding: 10px 18px; text-align: left;
            border-bottom: 1px solid #e8edf2; font-weight: 600;
        }
        .data-table td {
            padding: 12px 18px; border-bottom: 1px solid #f0f4f8;
            font-size: 13px; color: #1f2937;
        }
        .data-table tbody tr:last-child td { border-bottom: none; }
        .data-table tbody tr:hover td { background: #f0f7ff; }
        .td-subject { font-weight: 600; color: #0d1b2a; }
        .code-pill { background: #eef2ff; color: #3730a3; font-size: 11px; border-radius: 6px; padding: 3px 8px; font-weight: 500; }
        .year-pill  { background: #162636; color: #fff; font-size: 11px; border-radius: 6px; padding: 3px 8px; font-weight: 500; }

        /* Difficulty badge */
        .diff-badge { font-size: 11px; padding: 3px 8px; border-radius: 20px; font-weight: 500; display: inline-flex; align-items: center; gap: 4px; }
        .diff-badge i { font-size: 10px; margin: 0; }
        .diff-easy   { background: #dcfce7; color: #166534; }
        .diff-medium { background: #fef3c7; color: #92400e; }
        .diff-hard   { background: #fee2e2; color: #991b1b; }
        .diff-none   { background: #f3f4f6; color: #6b7280; }

        /* Action buttons */
        .action-btns { display: flex; gap: 5px; flex-wrap: wrap; }
        .act-btn {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 5px 10px; border-radius: 6px; font-size: 11px;
            font-weight: 500; border: 1.5px solid transparent; cursor: pointer;
            text-decoration: none; transition: opacity .15s, background .15s;
        }
        .act-btn i { font-size: 10px; margin: 0; }
        .act-btn:hover { opacity: 0.82; }
        .act-view     { background: #eff6ff; color: #1d4ed8; border-color: #bfdbfe; }
        .act-download { background: #f0fdf4; color: #166534; border-color: #bbf7d0; }
        .act-vote     { background: transparent; color: #374151; border-color: #d1d5db; }
        .act-vote:hover { background: #f9fafb; }
        .act-voted    { background: #f3f4f6; color: #9ca3af; border-color: transparent; cursor: not-allowed; }
        .act-marked   { background: #dbeafe; color: #1d4ed8; border-color: #93c5fd; font-weight: 600; }
        .act-easy     { background: #f0fdf4; color: #166534; border-color: transparent; }
        .act-medium   { background: #fff7ed; color: #9a3412; border-color: transparent; }
        .act-hard     { background: #fef2f2; color: #991b1b; border-color: transparent; }
        .act-diff-selected { outline: 2px solid currentColor; outline-offset: 1px; font-weight: 700; }

        /* Popular badge */
        .pop-badge { background: #fff4e0; color: #854f0b; font-size: 10px; border-radius: 5px; padding: 2px 7px; font-weight: 500; margin-left: 5px; }

        /* File-type badge */
        .ft-badge { display: inline-block; font-size: 9px; font-weight: 700; letter-spacing: 0.4px; border-radius: 4px; padding: 2px 5px; margin-right: 6px; vertical-align: middle; text-transform: uppercase; }
        .ft-pdf  { background: #fee2e2; color: #991b1b; }
        .ft-doc  { background: #dbeafe; color: #1e40af; }
        .ft-ppt  { background: #ffedd5; color: #9a3412; }
        .ft-img  { background: #d1fae5; color: #065f46; }
        .ft-vid  { background: #ede9fe; color: #5b21b6; }
        .ft-txt  { background: #f3f4f6; color: #374151; }
        .ft-other{ background: #f3f4f6; color: #6b7280; }

        /* Date cell */
        .date-cell { font-size: 11px; color: #9ca3af; white-space: nowrap; }

        /* Empty state */
        .empty-state { text-align: center; padding: 48px 20px; color: #9ca3af; }
        .empty-state i { font-size: 36px; margin: 0 0 10px; display: block; color: #d1d5db; }
        .empty-state p { font-size: 13px; color: #9ca3af; }

        /* Useful count — blue bold */
        .useful-num { color: #1d4ed8; font-weight: 700; font-size: 13px; }

        /* Requests table */
        .status-pill { font-size: 10px; padding: 3px 8px; border-radius: 20px; font-weight: 500; display: inline-flex; align-items: center; gap: 4px; }
        .status-pill i { font-size: 10px; margin: 0; }
        .s-pending   { background: #fff4e0; color: #854f0b; }
        .s-approved  { background: #f0fdf4; color: #166534; }
        .s-rejected  { background: #fef2f2; color: #991b1b; }
        .s-completed { background: #eff6ff; color: #1d4ed8; }

        .act-delete-sm { background: #fef2f2; color: #991b1b; }

        @media (max-width: 900px) {
            .sidebar { display: none; }
            .stats-grid { grid-template-columns: 1fr 1fr; }
        }
        @media (max-width: 560px) {
            .stats-grid { grid-template-columns: 1fr; }
        }

        /* ── REQUEST PAPER BUTTON ── */
        .btn-request-paper {
            display: inline-flex; align-items: center; gap: 6px;
            background: #1e3a5f; color: #fff; border: none;
            border-radius: 8px; padding: 7px 14px; font-size: 12px;
            font-weight: 500; cursor: pointer; transition: background .15s;
        }
        .btn-request-paper i { font-size: 11px; margin: 0; }
        .btn-request-paper:hover { background: #0d2a45; }

        /* ── MODAL OVERLAY ── */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,0.45); z-index: 1000;
            align-items: center; justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal-box {
            background: #fff; border-radius: 14px;
            width: 100%; max-width: 460px; padding: 28px 28px 24px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.18);
            position: relative; animation: modalIn .18s ease;
        }
        @keyframes modalIn {
            from { opacity: 0; transform: translateY(-12px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .modal-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 20px;
        }
        .modal-title { font-size: 15px; font-weight: 700; color: #0d1b2a; }
        .modal-close {
            background: none; border: none; cursor: pointer;
            color: #9ca3af; font-size: 18px; line-height: 1;
            padding: 2px 6px; border-radius: 6px; transition: color .15s;
        }
        .modal-close:hover { color: #374151; }
        .form-group { margin-bottom: 14px; }
        .form-label {
            display: block; font-size: 12px; font-weight: 600;
            color: #374151; margin-bottom: 5px;
        }
        .form-label .req { color: #e53e3e; margin-left: 2px; }
        .form-input, .form-textarea {
            width: 100%; border: 1.5px solid #e5e7eb; border-radius: 8px;
            padding: 8px 12px; font-size: 13px; color: #111827;
            background: #f9fafb; outline: none; transition: border .18s;
            font-family: inherit;
        }
        .form-input:focus, .form-textarea:focus { border-color: #3b82f6; background: #fff; }
        .form-textarea { resize: vertical; min-height: 72px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .modal-error {
            background: #fff0f0; border: 1px solid #f5c6cb; color: #c0392b;
            border-radius: 8px; padding: 8px 12px; font-size: 12px;
            margin-bottom: 14px; display: none;
        }
        .modal-error.show { display: block; }
        .btn-submit-request {
            width: 100%; background: #1e3a5f; color: #fff; border: none;
            border-radius: 8px; padding: 10px; font-size: 13px; font-weight: 600;
            cursor: pointer; transition: background .15s; margin-top: 4px;
        }
        .btn-submit-request:hover { background: #0d2a45; }
        .btn-submit-request:disabled { background: #93c5fd; cursor: not-allowed; }
    </style>
</head>
<body>

<!-- ═══════════════════ SIDEBAR ═══════════════════ -->
<nav class="sidebar">
    <div class="sidebar-logo">
        <div class="logo-sq"><i class="fa-solid fa-book-open"></i></div>
        <div class="logo-text">
            <span class="app-name">PaperWise</span>
            <span class="app-sub">Student Panel</span>
        </div>
    </div>

    <div class="nav-section">
        <p class="nav-label">Main</p>
        <a href="${pageContext.request.contextPath}/studentDashboard" class="nav-item active">
            <i class="fa-solid fa-house"></i> Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/studentDashboard" class="nav-item">
            <i class="fa-regular fa-file-lines"></i> All Papers
        </a>
        <a href="#marked" class="nav-item">
            <i class="fa-regular fa-bookmark"></i> My Marked
        </a>
        <a href="#requests" class="nav-item">
            <i class="fa-regular fa-file"></i> My Requests
        </a>
    </div>

    <div class="sidebar-bottom">
        <div class="user-row">
            <div class="avatar"><%= initials %></div>
            <div class="user-meta">
                <div class="u-name"><%= username %></div>
                <div class="u-role">Student</div>
            </div>
        </div>
        <form action="${pageContext.request.contextPath}/logout" method="post">
            <button type="submit" class="logout-btn">
                <i class="fa-solid fa-right-from-bracket"></i> Logout
            </button>
        </form>
    </div>
</nav>

<!-- ═══════════════════ MAIN ═══════════════════ -->
<div class="main">

    <!-- Top bar -->
    <div class="topbar">
        <span class="topbar-title">Student Dashboard</span>
        <div class="topbar-right">
            <span class="pill-date">
                <i class="fa-regular fa-calendar"></i> <%= currentMonthYear %>
            </span>
            <button class="btn-request-paper" id="openRequestModal" title="Request a paper" style="display:none">
                <i class="fa-solid fa-plus"></i> Request Paper
            </button>
            <button class="bell-btn" title="Notifications">
                <i class="fa-regular fa-bell"></i>
            </button>
        </div>
    </div>

    <div class="content">

        <%-- Flash messages --%>
        <%
            String successMsg = (String) session.getAttribute("successMessage");
            String msgAttr    = (String) session.getAttribute("msg");
            if (successMsg != null) { session.removeAttribute("successMessage"); %>
            <div class="alert-success" id="flashMsg">
                <i class="fa-solid fa-circle-check"></i> <%= successMsg %>
            </div>
        <% } else if (msgAttr != null) { session.removeAttribute("msg"); %>
            <div class="alert-success" id="flashMsg">
                <i class="fa-solid fa-circle-check"></i> <%= msgAttr %>
            </div>
        <% } %>
        <%
            String errorMsg = (String) session.getAttribute("errorMessage");
            if (errorMsg != null) { session.removeAttribute("errorMessage"); %>
            <div class="alert-error">
                <i class="fa-solid fa-circle-exclamation"></i> <%= errorMsg %>
            </div>
        <% } %>

        <!-- ── STAT CARDS ── -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fa-regular fa-copy"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalPapers %></div>
                    <div class="stat-label">Total Papers</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="fa-solid fa-thumbs-up"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalUsefulMarks %></div>
                    <div class="stat-label">Total Useful Marks</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon orange"><i class="fa-solid fa-star"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= myMarksCount %></div>
                    <div class="stat-label">Your Marks</div>
                </div>
            </div>
        </div>


        <!-- ── PAPERS TABLE ── -->
        <div class="section-card" id="papers">
            <div class="section-header">
                <div class="section-header-left">
                    <span class="section-title">All Papers</span>
                    <span class="count-pill indigo"><%= papers != null ? papers.size() : 0 %></span>
                </div>
            </div>

            <!-- Filter bar -->
            <div class="filter-bar">
                <input type="text"
                       id="searchInput"
                       class="search-input"
                       placeholder="Search subject, code, year…"
                       oninput="filterTable()"
                       value="<%= searchQuery != null ? searchQuery : "" %>">
                <select id="yearFilter" class="year-select"
                        onchange="filterTable()">
                    <option value="all" <%= selectedYear == null ? "selected" : "" %>>All Years</option>
                    <% if (availableYears != null) {
                           for (Integer yr : availableYears) { %>
                        <option value="<%= yr %>" <%= (selectedYear != null && selectedYear.equals(yr)) ? "selected" : "" %>><%= yr %></option>
                    <% } } %>
                </select>
            </div>

            <% if (papers != null && !papers.isEmpty()) { %>
            <table class="data-table" id="papersTable">
                <thead>
                    <tr>
                        <th>Subject</th>
                        <th>Code</th>
                        <th>Year</th>
                        <th>Chapter</th>
                        <th>Exam Type</th>
                        <th>Useful</th>
                        <th>Difficulty</th>
                        <th>Uploaded</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="papersTableBody">
                <%
                for (Paper paper : papers) {
                    String diffLabel = paper.getDifficultyLabel();
                    if (diffLabel == null || diffLabel.isEmpty()) diffLabel = "Not Rated";
                    String diffCls = "diff-none";
                    String diffIcon = "";
                    if ("Easy".equalsIgnoreCase(diffLabel))   { diffCls = "diff-easy";   diffIcon = "fa-solid fa-check"; }
                    else if ("Medium".equalsIgnoreCase(diffLabel)) { diffCls = "diff-medium"; diffIcon = "fa-solid fa-minus"; }
                    else if ("Hard".equalsIgnoreCase(diffLabel))   { diffCls = "diff-hard";   diffIcon = "fa-solid fa-exclamation"; }

                    // Derive file-type badge from fileUrl extension
                    String fileUrl = paper.getFileUrl() != null ? paper.getFileUrl().toLowerCase() : "";
                    String ftClass = "ft-other";
                    String ftLabel = "FILE";
                    if      (fileUrl.endsWith(".pdf"))                          { ftClass = "ft-pdf";  ftLabel = "PDF"; }
                    else if (fileUrl.endsWith(".doc") || fileUrl.endsWith(".docx")) { ftClass = "ft-doc";  ftLabel = "DOC"; }
                    else if (fileUrl.endsWith(".ppt") || fileUrl.endsWith(".pptx")) { ftClass = "ft-ppt";  ftLabel = "PPT"; }
                    else if (fileUrl.endsWith(".jpg") || fileUrl.endsWith(".jpeg") || fileUrl.endsWith(".png")) { ftClass = "ft-img"; ftLabel = "IMG"; }
                    else if (fileUrl.endsWith(".mp4") || fileUrl.endsWith(".mkv")) { ftClass = "ft-vid"; ftLabel = "VID"; }
                    else if (fileUrl.endsWith(".txt"))                          { ftClass = "ft-txt";  ftLabel = "TXT"; }

                    String uploadedDate = paper.getCreatedAt() != null
                        ? paper.getCreatedAt().format(dtf) : "-";
                %>
                <tr data-subject-code="<%= paper.getSubjectCode().toLowerCase() %>"
                    data-subject-name="<%= paper.getSubjectName().toLowerCase() %>"
                    data-year="<%= paper.getYear() %>">
                    <td class="td-subject">
                        <span class="ft-badge <%= ftClass %>"><%= ftLabel %></span><%= paper.getSubjectName() %>
                        <% if (paper.isPopular()) { %>
                            <span class="pop-badge"><i class="fa-solid fa-star"></i> Popular</span>
                        <% } %>
                    </td>
                    <td><span class="code-pill"><%= paper.getSubjectCode() %></span></td>
                    <td><span class="year-pill"><%= paper.getYear() %></span></td>
                    <td><%= paper.getChapter() != null ? paper.getChapter() : "-" %></td>
                    <td>
                        <% String examType = paper.getExamType();
                           if (examType != null && !examType.isEmpty()) {
                               String examBg = "#f1f5f9", examColor = "#475569";
                               if ("Mid Term".equalsIgnoreCase(examType))  { examBg = "#f3e8ff"; examColor = "#7e22ce"; }
                               else if ("End Term".equalsIgnoreCase(examType)) { examBg = "#dcfce7"; examColor = "#166534"; }
                               else if ("Quiz".equalsIgnoreCase(examType))     { examBg = "#fefce8"; examColor = "#854d0e"; }
                               else if (examType.toLowerCase().contains("sessional")) { examBg = "#eff6ff"; examColor = "#1d4ed8"; }
                        %>
                            <span style="background:<%= examBg %>;color:<%= examColor %>;padding:2px 8px;border-radius:20px;font-size:11px;font-weight:600;display:inline-block;white-space:nowrap"><%= examType %></span>
                        <% } else { %>
                            <span style="color:#94a3b8;font-size:11px;font-style:italic">—</span>
                        <% } %>
                    </td>
                    <td><span class="useful-num"><%= paper.getUsefulCount() %></span></td>
                    <td>
                        <span class="diff-badge <%= diffCls %>">
                            <% if (!diffIcon.isEmpty()) { %><i class="<%= diffIcon %>"></i><% } %>
                            <%= diffLabel %>
                        </span>
                        <br><small style="font-size:10px;color:#9ca3af;">
                            (<%= paper.getEasyCount() %> | <%= paper.getMediumCount() %> | <%= paper.getHardCount() %>)
                        </small>
                        <% if (paper.getEasyCount() == 0 && paper.getMediumCount() == 0 && paper.getHardCount() == 0) { %>
                        <div style="margin-top:4px">
                            <span style="background:#fff7ed;color:#c2410c;padding:2px 8px;border-radius:20px;font-size:10px;font-weight:600;display:inline-block;border:1px solid #fed7aa">&#11088; Be first to rate!</span>
                        </div>
                        <% } %>
                    </td>
                    <td class="date-cell"><%= uploadedDate %></td>
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
                            <%-- Useful mark toggle — form POST --%>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/student/markUseful"
                                  style="display:inline">
                                <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                <button type="submit"
                                        class="act-btn <%= paper.isAlreadyMarked() ? "act-marked" : "act-vote" %>">
                                    <i class="fa-solid fa-thumbs-up"></i>
                                    <span><%= paper.isAlreadyMarked() ? "Marked" : "Useful" %></span>
                                    (<%= paper.getUsefulCount() %>)
                                </button>
                            </form>
                            <%-- Difficulty rating — form POST --%>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/student/rateDifficulty"
                                  style="display:inline">
                                <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                <input type="hidden" name="difficulty" value="easy">
                                <button type="submit" class="act-btn act-easy">
                                    <i class="fa-solid fa-check"></i> Easy
                                    (<%= paper.getEasyCount() %>)
                                </button>
                            </form>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/student/rateDifficulty"
                                  style="display:inline">
                                <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                <input type="hidden" name="difficulty" value="medium">
                                <button type="submit" class="act-btn act-medium">
                                    <i class="fa-solid fa-minus"></i> Med
                                    (<%= paper.getMediumCount() %>)
                                </button>
                            </form>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/student/rateDifficulty"
                                  style="display:inline">
                                <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                <input type="hidden" name="difficulty" value="hard">
                                <button type="submit" class="act-btn act-hard">
                                    <i class="fa-solid fa-exclamation"></i> Hard
                                    (<%= paper.getHardCount() %>)
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
                <p>No papers available yet.</p>
            </div>
            <% } %>
        </div>


        <!-- ── MY REQUESTS TABLE ── -->
        <div class="section-card" id="requests">
            <div class="section-header">
                <div class="section-header-left">
                    <span class="section-title">My Paper Requests</span>
                    <span class="count-pill amber" id="requestsCountPill"><%= myRequests != null ? myRequests.size() : 0 %></span>
                </div>
                <button class="act-btn act-view" style="font-size:12px; padding:6px 12px;" onclick="document.getElementById('openRequestModal').click()">
                    <i class="fa-solid fa-plus"></i> New Request
                </button>
            </div>

            <% if (myRequests != null && !myRequests.isEmpty()) { %>
            <table class="data-table" id="requestsTable">
                <thead>
                    <tr>
                        <th>Subject Name</th>
                        <th>Code</th>
                        <th>Year</th>
                        <th>Description</th>
                        <th>Status</th>
                        <th>Requested</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <% for (PaperRequest req : myRequests) {
                    String st = req.getStatus() != null ? req.getStatus().toLowerCase() : "pending";
                    String stCls = "s-pending";
                    String stIcon = "fa-regular fa-clock";
                    if ("approved".equals(st))  { stCls = "s-approved";  stIcon = "fa-solid fa-circle-check"; }
                    else if ("rejected".equals(st))  { stCls = "s-rejected";  stIcon = "fa-solid fa-circle-xmark"; }
                    else if ("completed".equals(st)) { stCls = "s-completed"; stIcon = "fa-solid fa-flag"; }
                %>
                <tr id="req-row-<%= req.getRequestId() %>">
                    <td class="td-subject"><%= req.getSubjectName() %></td>
                    <td><span class="code-pill"><%= req.getSubjectCode() %></span></td>
                    <td><span class="year-pill"><%= req.getYear() %></span></td>
                    <td style="max-width:180px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
                        <%= req.getDescription() != null && !req.getDescription().isEmpty() ? req.getDescription() : "-" %>
                    </td>
                    <td>
                        <span class="status-pill <%= stCls %>">
                            <i class="<%= stIcon %>"></i> <%= st %>
                        </span>
                    </td>
                    <td style="font-size:12px; color:#6b7280;">
                        <%= req.getCreatedAt() != null ? req.getCreatedAt().format(dtf) : "-" %>
                    </td>
                    <td>
                        <form method="post"
                              action="${pageContext.request.contextPath}/student/deleteRequest"
                              style="display:inline"
                              onsubmit="return confirm('Delete this request?')">
                            <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                            <button type="submit" class="act-btn act-delete-sm">
                                <i class="fa-solid fa-trash"></i> Delete
                            </button>
                        </form>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
            <% } else { %>
            <div class="empty-state" id="requestsEmpty" style="padding:32px 20px;">
                <i class="fa-regular fa-folder-open" style="color:#cbd5e0; font-size:28px;"></i>
                <p>No requests yet. Click "New Request" to get started.</p>
            </div>
            <% } %>
        </div>

    </div><!-- /content -->
</div><!-- /main -->

<!-- ═══════════════════ REQUEST PAPER MODAL ═══════════════════ -->
<div class="modal-overlay" id="requestModal">
    <div class="modal-box">
        <div class="modal-header">
            <span class="modal-title"><i class="fa-regular fa-file" style="margin-right:7px;color:#1e3a5f;"></i>Request a Paper</span>
            <button class="modal-close" id="closeRequestModal" title="Close">&times;</button>
        </div>
        <div class="modal-error" id="modalError"></div>
        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Subject Name <span class="req">*</span></label>
                <input type="text" id="req-subject-name" class="form-input" placeholder="e.g. Data Structures" maxlength="120">
            </div>
            <div class="form-group">
                <label class="form-label">Subject Code <span class="req">*</span></label>
                <input type="text" id="req-subject-code" class="form-input" placeholder="e.g. CS301" maxlength="30">
            </div>
        </div>
        <div class="form-group">
            <label class="form-label">Year <span class="req">*</span></label>
            <input type="number" id="req-year" class="form-input" placeholder="e.g. 2023" min="2006" max="2026">
        </div>
        <div class="form-group">
            <label class="form-label">Description / Note</label>
            <textarea id="req-description" class="form-textarea" placeholder="e.g. Need the 2022 mid-term paper by tomorrow" maxlength="500"></textarea>
        </div>
        <button class="btn-submit-request" id="submitRequestBtn"
                data-ctx="${pageContext.request.contextPath}">
            <i class="fa-solid fa-paper-plane"></i> Submit Request
        </button>
    </div>
</div>

<script>
    // Client-side search + year filter
    function filterTable() {
        const searchVal = document.getElementById('searchInput').value.toLowerCase();
        const yearVal   = document.getElementById('yearFilter').value;
        const rows      = document.querySelectorAll('#papersTableBody tr');
        rows.forEach(function(row) {
            const text    = row.innerText.toLowerCase();
            const rowYear = row.getAttribute('data-year') || '';
            const matchSearch = searchVal === '' || text.includes(searchVal);
            const matchYear   = yearVal === '' || yearVal === 'all' || yearVal === 'All Years' || rowYear === yearVal;
            row.style.display = (matchSearch && matchYear) ? '' : 'none';
        });
    }

    // Auto-dismiss flash message
    const flash = document.getElementById('flashMsg');
    if (flash) {
        setTimeout(() => {
            flash.style.transition = 'opacity .4s';
            flash.style.opacity = '0';
            setTimeout(() => flash.remove(), 400);
        }, 3000);
    }

    // Client-side search filter
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', function () {
            const q = this.value.toLowerCase();
            document.querySelectorAll('#papersTable tbody tr').forEach(row => {
                const code = row.dataset.subjectCode || '';
                const name = row.dataset.subjectName || '';
                const year = row.dataset.year || '';
                row.style.display = (code.includes(q) || name.includes(q) || year.includes(q)) ? '' : 'none';
            });
        });
    }

    // ── Useful mark toggle ──────────────────────────────────────────────────
    document.querySelectorAll('.btn-useful').forEach(btn => {
        btn.addEventListener('click', function () {
            const paperId = this.dataset.paperId;
            const ctx     = this.dataset.ctx;
            const self    = this;

            self.disabled = true;

            const body = new URLSearchParams({ paperId });

            fetch(ctx + '/student/markUseful', { method: 'POST', body, headers: { 'Content-Type': 'application/x-www-form-urlencoded' } })
                .then(r => r.json())
                .then(data => {
                    if (!data.success) { self.disabled = false; return; }

                    const label = self.querySelector('.useful-label');
                    const count = self.querySelector('.useful-count');

                    if (data.marked) {
                        self.classList.remove('act-vote');
                        self.classList.add('act-marked');
                        label.textContent = 'Marked';
                    } else {
                        self.classList.remove('act-marked');
                        self.classList.add('act-vote');
                        label.textContent = 'Useful';
                    }
                    count.textContent = data.count;
                    self.dataset.marked = data.marked;
                    self.disabled = false;
                })
                .catch(() => { self.disabled = false; });
        });
    });

    // ── Difficulty rating ───────────────────────────────────────────────────
    document.querySelectorAll('.btn-diff').forEach(btn => {
        btn.addEventListener('click', function () {
            const paperId = this.dataset.paperId;
            const level   = this.dataset.level;
            const ctx     = this.dataset.ctx;
            const self    = this;

            self.disabled = true;

            const body = new URLSearchParams({ paperId, difficulty: level });

            fetch(ctx + '/student/rateDifficulty', { method: 'POST', body, headers: { 'Content-Type': 'application/x-www-form-urlencoded' } })
                .then(r => r.json())
                .then(data => {
                    if (!data.success) { self.disabled = false; return; }

                    // Update counts in all three buttons for this paper
                    const container = document.querySelector(`.diff-btns[data-paper-id="${paperId}"]`);
                    if (!container) { self.disabled = false; return; }

                    container.querySelector('.diff-count-easy').textContent   = data.easy;
                    container.querySelector('.diff-count-medium').textContent = data.medium;
                    container.querySelector('.diff-count-hard').textContent   = data.hard;

                    // Highlight selected, clear others
                    container.querySelectorAll('.btn-diff').forEach(b => {
                        b.classList.remove('act-diff-selected');
                        b.disabled = false;
                    });
                    self.classList.add('act-diff-selected');
                })
                .catch(() => { self.disabled = false; });
        });
    });

    // ── Request Paper Modal ─────────────────────────────────────────────────
    const modal       = document.getElementById('requestModal');
    const openBtn     = document.getElementById('openRequestModal');
    const closeBtn    = document.getElementById('closeRequestModal');
    const submitBtn   = document.getElementById('submitRequestBtn');
    const modalError  = document.getElementById('modalError');

    function openModal() {
        modal.classList.add('open');
        document.getElementById('req-subject-name').focus();
    }
    function closeModal() {
        modal.classList.remove('open');
        modalError.classList.remove('show');
        modalError.textContent = '';
        document.getElementById('req-subject-name').value = '';
        document.getElementById('req-subject-code').value = '';
        document.getElementById('req-year').value = '';
        document.getElementById('req-description').value = '';
    }

    openBtn.addEventListener('click', openModal);
    closeBtn.addEventListener('click', closeModal);
    modal.addEventListener('click', e => { if (e.target === modal) closeModal(); });
    document.addEventListener('keydown', e => { if (e.key === 'Escape') closeModal(); });

    submitBtn.addEventListener('click', function () {
        const ctx         = this.dataset.ctx;
        const subjectName = document.getElementById('req-subject-name').value.trim();
        const subjectCode = document.getElementById('req-subject-code').value.trim();
        const year        = document.getElementById('req-year').value.trim();
        const description = document.getElementById('req-description').value.trim();

        // Client-side validation
        if (!subjectName) { showModalError('Subject Name is required.'); return; }
        if (!subjectCode) { showModalError('Subject Code is required.'); return; }
        if (!year)        { showModalError('Year is required.'); return; }
        const yr = parseInt(year);
        if (isNaN(yr) || yr < 2006 || yr > 2026) { showModalError('Year must be between 2006 and 2026.'); return; }

        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Submitting…';
        modalError.classList.remove('show');

        const body = new URLSearchParams({ subjectName, subjectCode, year, description });

        fetch(ctx + '/student/submitRequest', {
            method: 'POST', body,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        })
        .then(r => r.json())
        .then(data => {
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fa-solid fa-paper-plane"></i> Submit Request';
            if (!data.success) { showModalError(data.error || 'Submission failed.'); return; }

            closeModal();
            addRequestRow(data.request, ctx);
        })
        .catch(() => {
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fa-solid fa-paper-plane"></i> Submit Request';
            showModalError('Network error. Please try again.');
        });
    });

    function showModalError(msg) {
        modalError.textContent = msg;
        modalError.classList.add('show');
    }

    function addRequestRow(req, ctx) {
        // Update count pill
        const pill = document.getElementById('requestsCountPill');
        if (pill) pill.textContent = parseInt(pill.textContent || '0') + 1;

        // Hide empty state if visible
        const empty = document.getElementById('requestsEmpty');
        if (empty) empty.style.display = 'none';

        // Create table if it doesn't exist yet
        let tbody = document.querySelector('#requestsTable tbody');
        if (!tbody) {
            const card = document.getElementById('requests');
            const table = document.createElement('table');
            table.id = 'requestsTable';
            table.className = 'data-table';
            table.innerHTML = `<thead><tr>
                <th>Subject Name</th><th>Code</th><th>Year</th>
                <th>Description</th><th>Status</th><th>Requested</th><th>Action</th>
            </tr></thead><tbody></tbody>`;
            card.appendChild(table);
            tbody = table.querySelector('tbody');
        }

        const tr = document.createElement('tr');
        tr.id = 'req-row-' + req.requestId;
        tr.innerHTML = `
            <td class="td-subject">${escHtml(req.subjectName)}</td>
            <td><span class="code-pill">${escHtml(req.subjectCode)}</span></td>
            <td><span class="year-pill">${req.year}</span></td>
            <td style="max-width:180px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${req.description ? escHtml(req.description) : '-'}</td>
            <td><span class="status-pill s-pending"><i class="fa-regular fa-clock"></i> pending</span></td>
            <td style="font-size:12px;color:#6b7280;">${req.requestedAt}</td>
            <td><button class="act-btn act-delete-sm btn-delete-req"
                        data-request-id="${req.requestId}" data-ctx="${ctx}">
                    <i class="fa-solid fa-trash"></i> Delete
                </button></td>`;
        tbody.insertBefore(tr, tbody.firstChild);

        // Attach delete listener to the new button
        attachDeleteListener(tr.querySelector('.btn-delete-req'));
    }

    function escHtml(str) {
        return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    // ── Delete Request ──────────────────────────────────────────────────────
    function attachDeleteListener(btn) {
        btn.addEventListener('click', function () {
            if (!confirm('Delete this request?')) return;
            const requestId = this.dataset.requestId;
            const ctx       = this.dataset.ctx;
            const self      = this;
            self.disabled   = true;

            fetch(ctx + '/student/deleteRequest', {
                method: 'POST',
                body: new URLSearchParams({ requestId }),
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            })
            .then(r => r.json())
            .then(data => {
                if (!data.success) { self.disabled = false; return; }
                const row = document.getElementById('req-row-' + requestId);
                if (row) row.remove();

                // Update count pill
                const pill = document.getElementById('requestsCountPill');
                if (pill) {
                    const n = Math.max(0, parseInt(pill.textContent || '1') - 1);
                    pill.textContent = n;
                }

                // Show empty state if no rows left
                const tbody = document.querySelector('#requestsTable tbody');
                if (tbody && tbody.children.length === 0) {
                    const table = document.getElementById('requestsTable');
                    if (table) table.remove();
                    let empty = document.getElementById('requestsEmpty');
                    if (!empty) {
                        empty = document.createElement('div');
                        empty.id = 'requestsEmpty';
                        empty.className = 'empty-state';
                        empty.style.padding = '32px 20px';
                        empty.innerHTML = '<i class="fa-regular fa-folder-open" style="color:#cbd5e0;font-size:28px;"></i><p>No requests yet. Click "New Request" to get started.</p>';
                        document.getElementById('requests').appendChild(empty);
                    } else {
                        empty.style.display = '';
                    }
                }
            })
            .catch(() => { self.disabled = false; });
        });
    }

    document.querySelectorAll('.btn-delete-req').forEach(attachDeleteListener);
</script>
</body>
</html>
