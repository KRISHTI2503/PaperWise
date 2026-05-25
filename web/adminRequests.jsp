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
    String errorMessage   = (String) request.getAttribute("errorMessage");
    if (errorMessage == null) errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm");

    int totalCount     = request.getAttribute("totalCount")     != null ? (int) request.getAttribute("totalCount")     : (requests != null ? requests.size() : 0);
    long pendingCount  = request.getAttribute("pendingCount")   != null ? (long) request.getAttribute("pendingCount")  : 0;
    long completedCount= request.getAttribute("completedCount") != null ? (long) request.getAttribute("completedCount"): 0;
    long rejectedCount = request.getAttribute("rejectedCount")  != null ? (long) request.getAttribute("rejectedCount") : 0;

    String username = loggedInUser.getUsername();
    String initials = username.length() >= 2 ? username.substring(0,2).toUpperCase() : username.toUpperCase();
    String currentMonthYear = java.time.format.DateTimeFormatter.ofPattern("MMM yyyy").format(java.time.LocalDate.now());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Requests - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            background: #f0f4f8;
            min-height: 100vh;
            display: flex;
        }

        /* ═══════════ SIDEBAR ═══════════ */
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
        .sidebar-logo {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 1.2rem 1.1rem;
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
        .logo-text .app-name { font-size: 16px; font-weight: 700; color: #fff; line-height: 1.2; }
        .logo-text .app-sub  { font-size: 10px; color: rgba(255,255,255,0.4); }

        .nav-section { padding: 10px 0 4px; }
        .nav-label {
            font-size: 10px; font-weight: 600; letter-spacing: 0.08em;
            text-transform: uppercase; color: rgba(255,255,255,0.3);
            padding: 0.9rem 1.1rem 0.35rem;
        }
        .nav-item {
            display: flex; align-items: center; gap: 9px;
            padding: 0.55rem 1.1rem;
            color: rgba(255,255,255,0.6);
            font-size: 13px;
            text-decoration: none;
            transition: background 0.15s, color 0.15s;
        }
        .nav-item i { font-size: 15px; margin: 0; width: 18px; text-align: center; flex-shrink: 0; }
        .nav-item:hover  { background: rgba(255,255,255,0.07); color: #fff; }
        .nav-item.active { background: #1a3a5c; color: #fff; font-weight: 500; }

        .sidebar-bottom {
            margin-top: auto;
            border-top: 1px solid rgba(255,255,255,0.08);
            padding: 12px 0 8px;
        }
        .user-row {
            display: flex; align-items: center; gap: 9px;
            padding: 6px 1.1rem 10px;
        }
        .avatar {
            width: 30px; height: 30px;
            background: rgba(255,255,255,0.15);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 10px; font-weight: 700; color: #fff;
            flex-shrink: 0;
        }
        .user-meta .u-name { font-size: 12.5px; color: #fff; font-weight: 500; }
        .user-meta .u-role { font-size: 11px; color: rgba(255,255,255,0.4); }
        .logout-btn {
            display: flex; align-items: center; gap: 8px;
            width: 100%; padding: 8px 14px; border-radius: 8px;
            background: none; border: none; cursor: pointer;
            font-size: 13px; color: rgba(255,100,100,0.7);
            transition: background 0.15s, color 0.15s; text-align: left;
            font-family: inherit;
        }
        .logout-btn i { font-size: 13px; margin: 0; }
        .logout-btn:hover { background: rgba(255,80,80,0.1); color: #ff6b6b; }

        /* ═══════════ MAIN ═══════════ */
        .main { flex: 1; display: flex; flex-direction: column; min-width: 0; }

        /* Top bar */
        .topbar {
            background: #fff;
            height: 56px;
            border-bottom: 1px solid #e5e7eb;
            padding: 0 1.6rem;
            display: flex; align-items: center; justify-content: space-between;
            flex-shrink: 0;
        }
        .topbar-left .page-title { font-size: 16px; font-weight: 600; color: #0d1b2a; }
        .topbar-left .page-sub   { font-size: 12.5px; color: #8a97a8; margin-top: 1px; }
        .topbar-right { display: flex; align-items: center; gap: 10px; }
        .date-chip {
            display: flex; align-items: center; gap: 6px;
            background: #f3f4f6; border-radius: 7px;
            padding: 5px 11px; font-size: 12px; color: #374151;
        }
        .date-chip i { font-size: 13px; margin: 0; }
        .bell-btn {
            position: relative;
            width: 34px; height: 34px;
            background: #f3f4f6; border: none; border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; color: #6b7280;
        }
        .bell-btn i { font-size: 15px; margin: 0; }
        .bell-dot {
            position: absolute; top: 7px; right: 7px;
            width: 7px; height: 7px;
            background: #ef4444; border-radius: 50%;
            border: 1.5px solid #fff;
        }

        /* Content */
        .content { padding: 1.3rem 1.6rem; flex: 1; }

        /* Alerts */
        .alert {
            display: flex; align-items: center; gap: 8px;
            border-radius: 8px; padding: 10px 14px; margin-bottom: 14px;
            font-size: 13px;
        }
        .alert i { font-size: 13px; margin: 0; flex-shrink: 0; }
        .alert-success { background: #f0fff4; border: 1px solid #9ae6b4; color: #276749; }
        .alert-error   { background: #fff0f0; border: 1px solid #f5c6cb; color: #c0392b; }

        /* ═══════════ STAT CARDS ═══════════ */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-bottom: 1.3rem;
        }
        .stat-card {
            background: #fff;
            border-radius: 12px;
            border: 1px solid #e9ecef;
            padding: 1rem 1.1rem;
            display: flex; align-items: center; gap: 12px;
        }
        .stat-icon {
            width: 42px; height: 42px;
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .stat-icon i { font-size: 16px; margin: 0; }
        .stat-icon.blue   { background: #dbeafe; color: #2563eb; }
        .stat-icon.amber  { background: #fef9c3; color: #ca8a04; }
        .stat-icon.green  { background: #dcfce7; color: #16a34a; }
        .stat-icon.red    { background: #fee2e2; color: #dc2626; }
        .stat-num   { font-size: 24px; font-weight: 700; color: #0f2744; line-height: 1.1; }
        .stat-label { font-size: 12px; color: #8a97a8; margin-top: 2px; }

        /* ═══════════ TABLE CARD ═══════════ */
        .table-card {
            background: #fff;
            border-radius: 14px;
            border: 1px solid #e9ecef;
            overflow: hidden;
        }
        .table-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 1rem 1.2rem;
            border-bottom: 1px solid #f0f0f0;
            flex-wrap: wrap; gap: 10px;
        }
        .table-header-left { display: flex; align-items: center; gap: 8px; }
        .table-header-left i { font-size: 18px; color: #3b82f6; margin: 0; }
        .table-title { font-size: 14.5px; font-weight: 700; color: #0f2744; }
        .count-pill {
            background: #dbeafe; color: #1e40af;
            font-size: 11.5px; border-radius: 20px;
            padding: 2px 9px; font-weight: 600;
        }
        .table-controls { display: flex; align-items: center; gap: 8px; }
        .search-wrap {
            display: flex; align-items: center; gap: 6px;
            border: 1.5px solid #e5e7eb; border-radius: 8px;
            background: #f9fafb; padding: 5px 10px;
        }
        .search-wrap i { font-size: 14px; color: #9ca3af; margin: 0; flex-shrink: 0; }
        .search-wrap input {
            border: none; background: transparent; outline: none;
            font-size: 12.5px; color: #374151; width: 160px;
            font-family: inherit;
        }
        .search-wrap input::placeholder { color: #9ca3af; }
        .filter-select {
            border: 1.5px solid #e5e7eb; border-radius: 8px;
            background: #f9fafb; padding: 6px 10px;
            font-size: 12.5px; color: #374151;
            font-family: inherit; cursor: pointer; outline: none;
        }
        .filter-select:focus { border-color: #3b82f6; }

        /* Table */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table thead tr { background: #f8fafc; }
        .data-table th {
            font-size: 11.5px; font-weight: 600; color: #6b7280;
            text-transform: uppercase; letter-spacing: 0.04em;
            padding: 10px 14px; text-align: left;
            border-bottom: 1px solid #f0f0f0;
        }
        .data-table td {
            padding: 11px 14px;
            border-bottom: 1px solid #f7f8fa;
            font-size: 13px; color: #374151;
            vertical-align: middle;
        }
        .data-table tbody tr:last-child td { border-bottom: none; }
        .data-table tbody tr:hover td { background: #fafbff; }

        /* Subject cell */
        .subj-name { font-weight: 600; color: #0f2744; font-size: 13px; }
        .subj-code {
            display: inline-block; margin-top: 3px;
            background: #e0e7ff; color: #3730a3;
            font-size: 11px; font-weight: 600;
            border-radius: 5px; padding: 2px 7px;
        }

        /* Description cell */
        .desc-cell {
            max-width: 140px;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
            color: #6b7280; font-size: 12.5px;
        }

        /* Requester cell */
        .req-cell { display: flex; align-items: center; gap: 7px; }
        .req-avatar {
            width: 26px; height: 26px;
            background: #dbeafe; color: #1e40af;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 10px; font-weight: 600; flex-shrink: 0;
        }
        .req-name { font-size: 12.5px; color: #374151; }

        /* Date cell */
        .date-cell { font-size: 12px; color: #9ca3af; white-space: nowrap; }

        /* Status badge */
        .status-badge {
            display: inline-flex; align-items: center; gap: 4px;
            border-radius: 20px; padding: 3px 10px;
            font-size: 11.5px; font-weight: 600;
            white-space: nowrap;
        }
        .status-badge i { font-size: 12px; margin: 0; }
        .s-pending   { background: #fef3c7; color: #92400e; }
        .s-approved  { background: #dcfce7; color: #065f46; }
        .s-rejected  { background: #fee2e2; color: #7f1d1d; }
        .s-completed { background: #e0e7ff; color: #3730a3; }

        /* Action cell */
        .action-cell { display: flex; align-items: center; gap: 7px; }
        .status-form { display: flex; align-items: center; gap: 6px; }
        .status-select {
            border: 1.5px solid #e5e7eb; border-radius: 7px;
            padding: 5px 8px; font-size: 12px;
            background: #f9fafb; min-width: 110px;
            font-family: inherit; cursor: pointer; outline: none;
        }
        .status-select:focus { border-color: #3b82f6; }
        .btn-update {
            display: inline-flex; align-items: center; gap: 5px;
            background: #0f2744; color: #fff;
            border: none; border-radius: 7px;
            padding: 5px 12px; font-size: 12px; font-weight: 600;
            cursor: pointer; font-family: inherit;
            transition: background 0.15s;
        }
        .btn-update i { font-size: 11px; margin: 0; }
        .btn-update:hover { background: #0d2a45; }

        /* Empty state */
        .empty-state {
            text-align: center; padding: 52px 20px; color: #9ca3af;
        }
        .empty-state i { font-size: 40px; margin: 0 0 12px; display: block; color: #d1d5db; }
        .empty-state p { font-size: 13px; }

        /* ═══════════ TOAST ═══════════ */
        .toast {
            position: fixed; bottom: 20px; right: 20px;
            background: #0f2744; color: #fff;
            border-radius: 10px; padding: 10px 16px;
            font-size: 13px; font-weight: 500;
            display: flex; align-items: center; gap: 8px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.25);
            z-index: 9999;
            animation: toastIn 0.3s ease-out both;
        }
        .toast i { font-size: 15px; color: #4ade80; margin: 0; }
        @keyframes toastIn {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>

<!-- ═══════════════════════════════════════════════════════
     SIDEBAR
════════════════════════════════════════════════════════ -->
<aside class="sidebar">

    <!-- Logo -->
    <div class="sidebar-logo">
        <div class="logo-sq">
            <i class="fa-solid fa-book-open"></i>
        </div>
        <div class="logo-text">
            <div class="app-name">PaperWise</div>
            <div class="app-sub">Admin Panel</div>
        </div>
    </div>

    <!-- MAIN section -->
    <div class="nav-section">
        <div class="nav-label">Main</div>
        <a href="${pageContext.request.contextPath}/adminDashboard" class="nav-item">
            <i class="fa-solid fa-table-cells-large"></i> Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/allPapers" class="nav-item">
            <i class="fa-regular fa-file-lines"></i> All Papers
        </a>
        <a href="${pageContext.request.contextPath}/uploadPaper" class="nav-item">
            <i class="fa-solid fa-upload"></i> Upload Paper
        </a>
    </div>

    <!-- MANAGE section -->
    <div class="nav-section">
        <div class="nav-label">Manage</div>
        <a href="${pageContext.request.contextPath}/adminRequests" class="nav-item active">
            <i class="fa-solid fa-clipboard-list"></i> Requests
        </a>
        <a href="${pageContext.request.contextPath}/students" class="nav-item">
            <i class="fa-solid fa-users"></i> Students
        </a>
        <a href="#" class="nav-item">
            <i class="fa-solid fa-chart-bar"></i> Analytics
        </a>
    </div>

    <!-- Bottom: user + logout -->
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

</aside>

<!-- ═══════════════════════════════════════════════════════
     MAIN CONTENT
════════════════════════════════════════════════════════ -->
<div class="main">

    <!-- Top bar -->
    <div class="topbar">
        <div class="topbar-left">
            <div class="page-title">Manage Paper Requests</div>
            <div class="page-sub">Review and update student paper requests</div>
        </div>
        <div class="topbar-right">
            <div class="date-chip">
                <i class="fa-regular fa-calendar"></i>
                <span id="topbarDate"></span>
            </div>
            <button class="bell-btn" aria-label="Notifications">
                <i class="fa-regular fa-bell"></i>
                <% if (pendingCount > 0) { %><span class="bell-dot"></span><% } %>
            </button>
        </div>
    </div>

    <!-- Content area -->
    <div class="content">

        <!-- Alerts -->
        <% if (successMessage != null) { %>
        <div class="alert alert-success">
            <i class="fa-solid fa-circle-check"></i>
            <%= successMessage %>
        </div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <i class="fa-solid fa-circle-exclamation"></i>
            <%= errorMessage %>
        </div>
        <% } %>

        <!-- Stat cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fas fa-inbox"></i></div>
                <div>
                    <div class="stat-num"><%= totalCount %></div>
                    <div class="stat-label">Total Requests</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon amber"><i class="fas fa-clock"></i></div>
                <div>
                    <div class="stat-num"><%= pendingCount %></div>
                    <div class="stat-label">Pending</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="fas fa-check-circle"></i></div>
                <div>
                    <div class="stat-num"><%= completedCount %></div>
                    <div class="stat-label">Completed</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon red"><i class="fas fa-times-circle"></i></div>
                <div>
                    <div class="stat-num"><%= rejectedCount %></div>
                    <div class="stat-label">Rejected</div>
                </div>
            </div>
        </div>

        <!-- Table card -->
        <div class="table-card">
            <div class="table-header">
                <div class="table-header-left">
                    <i class="fa-solid fa-clipboard-list" style="font-size:18px;color:#3b82f6;"></i>
                    <span class="table-title">All Requests</span>
                </div>
                <div class="table-controls">
                    <div class="search-wrap">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" id="searchIn" placeholder="Search subject, student…">
                    </div>
                    <select class="filter-select" id="filterSel">
                        <option value="">All Status</option>
                        <option value="pending">Pending</option>
                        <option value="approved">Approved</option>
                        <option value="rejected">Rejected</option>
                        <option value="completed">Completed</option>
                    </select>
                </div>
            </div>

            <% if (requests != null && !requests.isEmpty()) { %>
            <table style="width:100%;border-collapse:collapse">
                <thead style="background:#f8fafc">
                    <tr>
                        <th style="padding:0.7rem 1rem;font-size:11.5px;font-weight:600;color:#6b7280;text-align:left;text-transform:uppercase;letter-spacing:0.04em;border-bottom:1px solid #f0f0f0">Subject</th>
                        <th style="padding:0.7rem 1rem;font-size:11.5px;font-weight:600;color:#6b7280;text-align:left;text-transform:uppercase;letter-spacing:0.04em;border-bottom:1px solid #f0f0f0">Year</th>
                        <th style="padding:0.7rem 1rem;font-size:11.5px;font-weight:600;color:#6b7280;text-align:left;text-transform:uppercase;letter-spacing:0.04em;border-bottom:1px solid #f0f0f0">Description</th>
                        <th style="padding:0.7rem 1rem;font-size:11.5px;font-weight:600;color:#6b7280;text-align:left;text-transform:uppercase;letter-spacing:0.04em;border-bottom:1px solid #f0f0f0">Requested By</th>
                        <th style="padding:0.7rem 1rem;font-size:11.5px;font-weight:600;color:#6b7280;text-align:left;text-transform:uppercase;letter-spacing:0.04em;border-bottom:1px solid #f0f0f0">Requested At</th>
                        <th style="padding:0.7rem 1rem;font-size:11.5px;font-weight:600;color:#6b7280;text-align:left;text-transform:uppercase;letter-spacing:0.04em;border-bottom:1px solid #f0f0f0">Status</th>
                        <th style="padding:0.7rem 1rem;font-size:11.5px;font-weight:600;color:#6b7280;text-align:left;text-transform:uppercase;letter-spacing:0.04em;border-bottom:1px solid #f0f0f0">Action</th>
                    </tr>
                </thead>
                <tbody id="reqTbody">
                <% for (PaperRequest req : requests) {
                    String st = req.getStatus() != null ? req.getStatus().toLowerCase() : "pending";

                    // Status badge colours
                    String badgeBg, badgeColor, statusIcon;
                    switch (st) {
                        case "approved":
                            badgeBg = "#dcfce7"; badgeColor = "#065f46";
                            statusIcon = "fas fa-check-circle"; break;
                        case "rejected":
                            badgeBg = "#fee2e2"; badgeColor = "#7f1d1d";
                            statusIcon = "fas fa-times-circle"; break;
                        case "completed":
                            badgeBg = "#e0e7ff"; badgeColor = "#3730a3";
                            statusIcon = "fas fa-flag"; break;
                        default:
                            badgeBg = "#fef9c3"; badgeColor = "#92400e";
                            statusIcon = "fas fa-clock"; break;
                    }
                    String statusLabel = st.substring(0,1).toUpperCase() + st.substring(1);

                    String reqUsername = req.getRequesterUsername() != null ? req.getRequesterUsername() : "Unknown";
                    String reqInitials = reqUsername.length() >= 2
                            ? reqUsername.substring(0,2).toUpperCase()
                            : reqUsername.toUpperCase();

                    String desc = req.getDescription() != null ? req.getDescription() : "";
                    String requestedAt = req.getCreatedAt() != null ? req.getCreatedAt().format(dtf) : "—";
                %>
                <tr data-status="<%= st %>" style="border-bottom:1px solid #f7f8fa">

                    <%-- Subject --%>
                    <td style="padding:0.7rem 1rem;vertical-align:middle">
                        <div style="font-weight:600;color:#0f2744"><%= req.getSubjectName() %></div>
                        <span style="background:#e0e7ff;color:#3730a3;font-size:11px;font-weight:600;border-radius:5px;padding:2px 7px"><%= req.getSubjectCode() %></span>
                    </td>

                    <%-- Year --%>
                    <td style="padding:0.7rem 1rem;vertical-align:middle;font-size:13px;color:#374151"><%= req.getYear() %></td>

                    <%-- Description --%>
                    <td style="padding:0.7rem 1rem;vertical-align:middle">
                        <div style="max-width:140px;color:#6b7280;font-size:12.5px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis"
                             title="<%= desc %>"><%= desc.isEmpty() ? "—" : desc %></div>
                    </td>

                    <%-- Requested By --%>
                    <td style="padding:0.7rem 1rem;vertical-align:middle">
                        <div style="display:flex;align-items:center;gap:7px">
                            <div style="width:26px;height:26px;border-radius:50%;background:#dbeafe;color:#1e40af;font-size:10px;font-weight:600;display:flex;align-items:center;justify-content:center;flex-shrink:0"><%= reqInitials %></div>
                            <span style="font-size:12.5px;color:#374151"><%= reqUsername %></span>
                        </div>
                    </td>

                    <%-- Requested At --%>
                    <td style="padding:0.7rem 1rem;vertical-align:middle">
                        <span style="font-size:12px;color:#9ca3af;white-space:nowrap"><%= requestedAt %></span>
                    </td>

                    <%-- Status --%>
                    <td style="padding:0.7rem 1rem;vertical-align:middle">
                        <span style="display:inline-flex;align-items:center;gap:4px;border-radius:20px;padding:3px 10px;font-size:11.5px;font-weight:600;background:<%= badgeBg %>;color:<%= badgeColor %>">
                            <i class="<%= statusIcon %>" style="font-size:9px;vertical-align:middle"></i>
                            <%= statusLabel %>
                        </span>
                    </td>

                    <%-- Action --%>
                    <td style="padding:0.7rem 1rem;vertical-align:middle">
                        <div style="display:flex;align-items:center;gap:7px">
                            <form method="post"
                                  action="${pageContext.request.contextPath}/adminRequests"
                                  style="display:flex;align-items:center;gap:7px">
                                <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                                <select name="status"
                                        style="border:1.5px solid #e5e7eb;border-radius:7px;padding:5px 8px;font-size:12px;font-family:inherit;color:#374151;background:#f9fafb;min-width:110px;outline:none;cursor:pointer">
                                    <option value="pending"   <%= "pending".equals(st)   ? "selected" : "" %>>Pending</option>
                                    <option value="approved"  <%= "approved".equals(st)  ? "selected" : "" %>>Approved</option>
                                    <option value="rejected"  <%= "rejected".equals(st)  ? "selected" : "" %>>Rejected</option>
                                    <option value="completed" <%= "completed".equals(st) ? "selected" : "" %>>Completed</option>
                                </select>
                                <button type="submit"
                                        style="background:#0f2744;color:white;border:none;border-radius:7px;padding:5px 14px;font-size:12px;font-weight:600;font-family:inherit;cursor:pointer;display:flex;align-items:center;gap:5px">
                                    <i class="fas fa-sync-alt"></i> Update
                                </button>
                            </form>
                        </div>
                    </td>

                </tr>
                <% } %>
                </tbody>
            </table>
            <% } else { %>
            <div style="text-align:center;padding:3rem;color:#9ca3af">
                <i class="fas fa-inbox" style="font-size:40px;color:#d1d5db;display:block;margin-bottom:12px"></i>
                No requests found
            </div>
            <% } %>
        </div><!-- /table-card -->

    </div><!-- /content -->
</div><!-- /main -->

<!-- Toast -->
<div id="pw-toast"
     style="position:fixed;bottom:20px;right:20px;background:#0f2744;color:white;border-radius:10px;padding:10px 16px;font-size:13px;font-weight:500;display:flex;align-items:center;gap:8px;opacity:0;transform:translateY(8px);transition:all .25s;pointer-events:none;z-index:999">
    <i class="ti ti-circle-check" style="font-size:16px;color:#4ade80"></i>
    <span id="pw-toast-msg">Done!</span>
</div>

<script>
    function filterRows() {
        const q = document.getElementById('searchIn').value.toLowerCase();
        const f = document.getElementById('filterSel').value;
        let vis = 0;
        document.querySelectorAll('#reqTbody tr').forEach(r => {
            const match = (!q || r.textContent.toLowerCase().includes(q)) &&
                          (!f || r.dataset.status === f);
            r.style.display = match ? '' : 'none';
            if (match) vis++;
        });
        document.getElementById('req-count').textContent = vis;
    }
    document.getElementById('searchIn').addEventListener('keyup', filterRows);
    document.getElementById('filterSel').addEventListener('change', filterRows);

    function showToast(msg) {
        const t = document.getElementById('pw-toast');
        document.getElementById('pw-toast-msg').textContent = msg;
        t.style.opacity = '1';
        t.style.transform = 'translateY(0)';
        setTimeout(() => {
            t.style.opacity = '0';
            t.style.transform = 'translateY(8px)';
        }, 2800);
    }

    window.addEventListener('load', () => {
        const p = new URLSearchParams(window.location.search);
        if (p.get('updated') === 'true') showToast('Status updated successfully!');
        if (p.get('deleted') === 'true') showToast('Request deleted successfully!');
    });
</script>
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
