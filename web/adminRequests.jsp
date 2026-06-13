<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.PaperRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.net.URLEncoder" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"admin".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<PaperRequest> requests = (List<PaperRequest>) request.getAttribute("requests");

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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/paperwise.css">
        <script>
        (function(){var t=localStorage.getItem('pw-theme')||'light';document.documentElement.setAttribute('data-theme',t);})();
    </script>
<script src="${pageContext.request.contextPath}/js/paperwise.js" defer></script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/tabler-icons/css/tabler-icons.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <style>
        
        :root {
            --bg-body: #f8fafc;
            --bg-card: #ffffff;
            --bg-sidebar: #0f2744;
            --text-primary: #0f172a;
            --text-secondary: #475569;
            --text-muted: #94a3b8;
            --border-color: #e2e8f0;
            --border-faint: #f1f5f9;
            --table-th-bg: #f8fafc;
            --table-hover-bg: #f8fafc;
            --btn-bg: #f1f5f9;
            --input-bg: #ffffff;
            --topbar-bg: #ffffff;
            --bell-dot-border: #ffffff;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
        }
        [data-theme="dark"] {
            --bg-body: #0b1329;
            --bg-card: #152238;
            --bg-sidebar: #080e1c;
            --text-primary: #f8fafc;
            --text-secondary: #94a3b8;
            --text-muted: #64748b;
            --border-color: #223554;
            --border-faint: #1b2a47;
            --table-th-bg: #0f1a30;
            --table-hover-bg: #1e2d4a;
            --btn-bg: #1c2e4a;
            --input-bg: #131f33;
            --topbar-bg: #111827;
            --bell-dot-border: #1e293b;
        }

        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Outfit', sans-serif;
            background: var(--bg-body);
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
            transition: background 0.3s, color 0.3s;
        }

        /* ═══════════ SIDEBAR ═══════════ */
        .sidebar {
            width: 220px;
            flex-shrink: 0;
            background: var(--bg-sidebar);
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            overflow-y: auto;
            z-index: 100;
            border-right: 1px solid var(--border-color);
            transition: background 0.3s, border-color 0.3s, left 0.3s ease;
        }
        .sidebar-logo {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 20px 18px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
        }
        .logo-sq {
            width: 34px; height: 34px;
            background: rgba(255,255,255,0.12);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .logo-sq i { font-size: 15px; color: #fff; margin: 0; }
        .logo-text { display: flex; flex-direction: column; }
        .logo-text .app-name  { font-size: 16px; font-weight: 700; color: #fff; line-height: 1.2; }
        .logo-text .app-sub   { font-size: 10px; color: rgba(255,255,255,0.4); }

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
            letter-spacing: 0.01em;
        }
        .nav-item i { font-size: 14px; margin: 0; width: 16px; text-align: center; flex-shrink: 0; }
        .nav-item:hover  { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.85); }
        .nav-item.active { background: rgba(255,255,255,0.13); color: #fff; font-weight: 500; }
        .nav-badge {
            margin-left: auto;
            background: #e53e3e;
            color: #fff;
            font-size: 10px;
            border-radius: 10px;
            padding: 1px 6px;
            font-weight: 600;
        }

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
            background: rgba(255,255,255,0.15);
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

        /* ═══════════ MAIN ═══════════ */
        .main {
            margin-left: 220px;
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            min-width: 0;
        }

        /* Top bar */
        .topbar {
            background: var(--topbar-bg);
            height: 56px;
            padding: 0 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid var(--border-color);
            flex-shrink: 0;
            transition: background 0.3s, border-color 0.3s;
        }
        .topbar-left .page-title { font-size: 18px; font-weight: 700; letter-spacing: -0.3px; color: var(--text-primary); }
        .topbar-left .page-sub   { font-size: 11px; color: var(--text-secondary); margin-top: 2px; }
        .topbar-right { display: flex; align-items: center; gap: 10px; }

        .date-chip {
            background: #f3f4f6;
            border-radius: 7px;
            padding: 5px 10px;
            font-size: 12px;
            color: #6b7280;
            display: flex;
            align-items: center;
            gap: 5px;
            white-space: nowrap;
        }
        .date-chip i { font-size: 15px; color: #f59e0b; margin: 0; }
        [data-theme="dark"] .date-chip {
            background: #1e293b;
            color: #94a3b8;
            border: 1px solid #334155;
        }
        [data-theme="dark"] .date-chip i { color: #fbbf24; }

        .bell-btn {
            position: relative;
            width: 34px; height: 34px;
            background: var(--btn-bg);
            border: none; border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; color: var(--text-secondary);
            transition: background 0.3s, color 0.3s;
        }
        .bell-btn i { font-size: 14px; margin: 0; }
        .bell-dot {
            position: absolute; top: 6px; right: 6px;
            width: 7px; height: 7px;
            background: #e53e3e; border-radius: 50%;
            border: 1.5px solid var(--bell-dot-border);
        }

        /* Content */
        .content { padding: 2rem; flex: 1; }

        /* Alerts */
        .alert {
            display: flex; align-items: center; gap: 10px;
            border-radius: 10px; padding: 12px 16px; margin-bottom: 20px;
            font-size: 13.5px; font-weight: 500;
            box-shadow: var(--shadow-sm);
        }
        .alert i { font-size: 16px; margin: 0; flex-shrink: 0; }
        .alert-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; }
        .alert-error   { background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; }

        /* ═══════════ STAT CARDS ═══════════ */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 2rem;
        }
        .stat-card {
            background: var(--bg-card);
            border-radius: 14px;
            border: 1px solid var(--border-color);
            padding: 20px;
            display: flex; align-items: center; gap: 16px;
            box-shadow: var(--shadow-sm);
            transition: all 0.3s ease;
        }
        .stat-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); }
        .stat-icon {
            width: 44px; height: 44px;
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .stat-icon i { font-size: 18px; margin: 0; }
        .stat-icon.blue   { background: #eff6ff; color: #3b82f6; }
        .stat-icon.amber  { background: #fffbeb; color: #d97706; }
        .stat-icon.green  { background: #f0fdf4; color: #16a34a; }
        .stat-icon.red    { background: #fef2f2; color: #dc2626; }
        .stat-num   { font-size: 24px; font-weight: 700; color: var(--text-primary); line-height: 1.1; letter-spacing: -0.5px; }
        .stat-label { font-size: 11.5px; color: var(--text-muted); margin-top: 3px; font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; }

        /* ═══════════ TABLE CARD ═══════════ */
        .table-card {
            background: var(--bg-card);
            border-radius: 14px;
            border: 1px solid var(--border-color);
            overflow: hidden;
            box-shadow: var(--shadow-sm);
            transition: background 0.3s, border-color 0.3s;
        }
        .table-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 1.2rem 1.5rem;
            border-bottom: 1px solid var(--border-color);
            flex-wrap: wrap; gap: 12px;
        }
        .table-header-left { display: flex; align-items: center; gap: 10px; }
        .table-header-left i { font-size: 20px; color: #3b82f6; margin: 0; }
        .table-title { font-size: 16px; font-weight: 700; color: var(--text-primary); letter-spacing: -0.2px; }
        .count-pill {
            background: #eff6ff; color: #1d4ed8;
            font-size: 12px; border-radius: 20px;
            padding: 2px 10px; font-weight: 600;
        }
        .table-controls { display: flex; align-items: center; gap: 10px; }
        .search-wrap {
            display: flex; align-items: center; gap: 8px;
            border: 1px solid var(--border-color); border-radius: 10px;
            background: var(--input-bg); padding: 6px 12px;
            transition: all 0.3s;
            box-shadow: var(--shadow-sm);
        }
        .search-wrap:focus-within { border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15); }
        .search-wrap i { font-size: 14px; color: var(--text-muted); margin: 0; flex-shrink: 0; }
        .search-wrap input {
            border: none; background: transparent; outline: none;
            font-size: 13px; color: var(--text-primary); width: 180px;
            font-family: inherit;
        }
        .search-wrap input::placeholder { color: var(--text-muted); }
        .filter-select {
            border: 1px solid var(--border-color); border-radius: 10px;
            background: var(--input-bg); padding: 7px 12px;
            font-size: 13px; color: var(--text-primary);
            font-family: inherit; cursor: pointer; outline: none;
            transition: all 0.3s;
            box-shadow: var(--shadow-sm);
        }
        .filter-select:focus { border-color: #3b82f6; }

        /* Table */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table thead tr { background: var(--table-th-bg); }
        .data-table th {
            font-size: 11px; font-weight: 600; color: var(--text-muted);
            text-transform: uppercase; letter-spacing: 0.06em;
            padding: 12px 16px; text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        .data-table td {
            padding: 12px 16px;
            border-bottom: 1px solid var(--border-faint);
            font-size: 13.5px; color: var(--text-secondary);
            vertical-align: middle;
        }
        .data-table tbody tr:last-child td { border-bottom: none; }
        .data-table tbody tr:hover td { background: var(--table-hover-bg); }

        /* Subject cell */
        .subj-name { font-weight: 600; color: var(--text-primary); font-size: 13.5px; }
        .subj-code {
            display: inline-block; margin-top: 4px;
            background: #e0e7ff; color: #3730a3;
            font-size: 11px; font-weight: 600;
            border-radius: 6px; padding: 2px 8px;
        }

        /* Description cell */
        .desc-cell {
            max-width: 180px;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
            color: var(--text-muted); font-size: 13px;
        }

        /* Requester cell */
        .req-cell { display: flex; align-items: center; gap: 8px; }
        .req-avatar {
            width: 28px; height: 28px;
            background: #eff6ff; color: #1d4ed8;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 11px; font-weight: 600; flex-shrink: 0;
            border: 1px solid rgba(29, 78, 216, 0.15);
        }
        .req-name { font-size: 13px; color: var(--text-primary); font-weight: 500; }

        /* Date cell */
        .date-cell { font-size: 12.5px; color: var(--text-muted); white-space: nowrap; }

        /* Status badge */
        .status-badge {
            display: inline-flex; align-items: center; gap: 6px;
            border-radius: 20px; padding: 4px 12px;
            font-size: 11.5px; font-weight: 600;
            white-space: nowrap;
        }
        .status-badge i { font-size: 12px; margin: 0; }
        .s-pending   { background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
        .s-rejected  { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }
        .s-completed { background: #e8f5e9; color: #1b5e20; border: 1px solid #a5d6a7; }

        /* Action cell */
        .action-cell { display: flex; align-items: center; gap: 8px; }
        .status-form { display: flex; align-items: center; gap: 8px; }
        .status-select {
            border: 1px solid var(--border-color); border-radius: 8px;
            padding: 6px 10px; font-size: 12.5px;
            background: var(--input-bg); min-width: 120px;
            color: var(--text-primary);
            font-family: inherit; cursor: pointer; outline: none;
            transition: all 0.3s;
            box-shadow: var(--shadow-sm);
        }
        .status-select:focus { border-color: #3b82f6; }
        .btn-update {
            display: inline-flex; align-items: center; gap: 6px;
            background: #0f2744; color: #fff;
            border: none; border-radius: 8px;
            padding: 6px 14px; font-size: 12.5px; font-weight: 600;
            cursor: pointer; font-family: inherit;
            transition: background 0.15s;
        }
        .btn-update i { font-size: 13px; margin: 0; }
        .btn-update:hover { background: #0d2a45; }

        /* Empty state */
        .empty-state {
            text-align: center; padding: 60px 20px; color: var(--text-muted);
        }
        .empty-state i { font-size: 44px; margin: 0 0 16px; display: block; color: var(--border-color); }
        .empty-state p { font-size: 13.5px; }

        /* ═══════════ TOAST ═══════════ */
        .pw-toast {
            position: fixed; bottom: 20px; right: 20px;
            background: var(--bg-sidebar); color: #fff;
            border-radius: 10px; padding: 10px 16px; font-size: 13px; font-weight: 500;
            display: flex; align-items: center; gap: 8px;
            opacity: 0; transform: translateY(8px); transition: all .25s;
            pointer-events: none; z-index: 9999;
            box-shadow: var(--shadow-md);
        }
        .pw-toast i { font-size: 16px; color: #4ade80; margin: 0; }
        .pw-toast.show { opacity: 1; transform: translateY(0); }

        /* Hamburger Menu Toggler */
        .menu-toggle {
            display: none;
        }

        /* ═══════════════════════════════════════
           RESPONSIVE DESIGN & MOBILE LAYOUTS
         ═══════════════════════════════════════ */
        @media (max-width: 1024px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            body {
                flex-direction: column;
            }
            .sidebar {
                position: fixed;
                left: -250px;
                top: 0;
                bottom: 0;
                z-index: 9999;
                box-shadow: 4px 0 15px rgba(0, 0, 0, 0.25);
                transition: left 0.3s ease;
            }
            .sidebar.open {
                left: 0;
            }
            .main {
                margin-left: 0;
            }
            .topbar {
                padding: 0 16px;
            }
            .menu-toggle {
                display: block !important;
            }
            .stats-grid {
                grid-template-columns: 1fr;
            }
            .content {
                padding: 16px;
            }
            .data-table-container {
                width: 100%;
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
            }
        }
    
.pw-toast-container {
  position: fixed;
  bottom: 24px;
  right: 24px;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  gap: 10px;
  pointer-events: none;
}

.pw-toast {
  background: #0f2744;
  color: #fff;
  border-radius: 12px;
  padding: 12px 18px;
  font-size: 13.5px;
  font-weight: 500;
  font-family: inherit;
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 260px;
  max-width: 380px;
  box-shadow: 0 8px 24px rgba(15,39,68,0.18);
  opacity: 0;
  transform: translateY(16px) scale(0.97);
  transition: all 0.3s cubic-bezier(0.16,1,0.3,1);
  pointer-events: auto;
}

.pw-toast.show {
  opacity: 1;
  transform: translateY(0) scale(1);
}

.pw-toast.success .pw-toast-icon { color: #4ade80; }
.pw-toast.error .pw-toast-icon   { color: #f87171; }
.pw-toast.info .pw-toast-icon    { color: #60a5fa; }
.pw-toast.warning .pw-toast-icon { color: #fbbf24; }

.pw-toast-icon { font-size: 18px; flex-shrink: 0; }
.pw-toast-msg  { flex: 1; line-height: 1.4; }
.pw-toast-close {
  background: none;
  border: none;
  color: rgba(255,255,255,0.5);
  cursor: pointer;
  font-size: 16px;
  padding: 0;
  display: flex;
  align-items: center;
  flex-shrink: 0;
  transition: color 0.15s;
}
.pw-toast-close:hover { color: #fff; }
</style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/ui-consistency.css">
</head>
<body>

<!-- ═══════════════════════════════════════════════════════
     SIDEBAR
════════════════════════════════════════════════════════ -->
<nav class="sidebar">

    <div class="sidebar-logo">
        <div class="logo-sq"><i class="fa-solid fa-book-open"></i></div>
        <div class="logo-text">
            <span class="app-name">PaperWise</span>
            <span class="app-sub">Admin Panel</span>
        </div>
    </div>

    <div class="nav-section">
        <p class="nav-label">MAIN</p>
        <a href="${pageContext.request.contextPath}/adminDashboard" class="nav-item">
            <i class="ti ti-layout-dashboard"></i> Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/allPapers" class="nav-item">
            <i class="ti ti-files"></i> All Papers
        </a>
        <a href="${pageContext.request.contextPath}/uploadPaper" class="nav-item">
            <i class="ti ti-upload"></i> Upload Paper
        </a>
    </div>

    <div class="nav-section">
        <p class="nav-label">MANAGE</p>
        <a href="${pageContext.request.contextPath}/adminRequests" class="nav-item active">
            <i class="ti ti-inbox"></i> Requests
            <% if (pendingCount > 0) { %>
                <span class="nav-badge"><%= pendingCount %></span>
            <% } %>
        </a>
        <a href="${pageContext.request.contextPath}/students" class="nav-item">
            <i class="ti ti-users"></i> Students
        </a>
        <a href="${pageContext.request.contextPath}/analytics" class="nav-item">
            <i class="ti ti-chart-bar"></i> Analytics
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

<!-- ═══════════════════════════════════════════════════════
     MAIN CONTENT
════════════════════════════════════════════════════════ -->
<div class="main">

    <!-- Top bar -->
    <div class="topbar">
        <div style="display: flex; align-items: center; gap: 12px;">
            <button type="button" class="menu-toggle" onclick="toggleSidebar()" style="background: none; border: none; font-size: 20px; cursor: pointer; color: var(--text-primary); display: none; align-items: center; justify-content: center; padding: 4px;">
                <i class="ti ti-menu-2"></i>
            </button>
            <div class="topbar-left">
                <div class="page-title">Manage Paper Requests</div>
                <div class="page-sub">Review and update student paper requests</div>
            </div>
        </div>
        <div class="topbar-right">
            <div class="date-chip">
                <i class="ti ti-calendar"></i>
                <span id="pageDate"></span>
            </div>
            <button class="pw-dark-toggle" id="pwDarkToggle" title="Toggle dark mode">
              <i class="fa-solid fa-moon" style="font-size:14px"></i>
            </button>
            <button class="bell-btn" aria-label="Notifications">
                <i class="ti ti-bell"></i>
                <% if (pendingCount > 0) { %><span class="bell-dot"></span><% } %>
            </button>
        </div>
    </div>

    <!-- Content area -->
    <div class="content">

        <!-- Alerts -->
        
        

        <!-- Stat cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="ti ti-inbox"></i></div>
                <div>
                    <div class="stat-num"><%= totalCount %></div>
                    <div class="stat-label">Total Requests</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon amber"><i class="ti ti-clock"></i></div>
                <div>
                    <div class="stat-num"><%= pendingCount %></div>
                    <div class="stat-label">Pending</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="ti ti-circle-check"></i></div>
                <div>
                    <div class="stat-num"><%= completedCount %></div>
                    <div class="stat-label">Completed</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon red"><i class="ti ti-circle-x"></i></div>
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
                    <i class="ti ti-list-details" style="font-size:20px;color:#3b82f6;"></i>
                    <span class="table-title">All Requests</span>
                    <span class="count-pill" id="req-count"><%= totalCount %></span>
                </div>
                <div class="table-controls">
                    <div class="search-wrap">
                        <i class="ti ti-search"></i>
                        <input type="text" id="searchIn" placeholder="Search subject, student…">
                    </div>
                    <select class="filter-select" id="filterSel">
                        <option value="">All Status</option>
                        <option value="pending">Pending</option>
                        <option value="rejected">Rejected</option>
                        <option value="completed">Completed</option>
                    </select>
                </div>
            </div>

            <% if (requests != null && !requests.isEmpty()) { %>
            <div class="data-table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Subject</th>
                        <th>Year</th>
                        <th>Description</th>
                        <th>Requested By</th>
                        <th>Requested At</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="reqTbody">
                <% for (PaperRequest req : requests) {
                    String st = req.getStatus() != null ? req.getStatus().toLowerCase() : "pending";
                    if ("approved".equals(st) || "accepted".equals(st)) {
                        st = "completed";
                    }

                    // Status badge class and icon
                    String badgeClass, statusIcon, statusLabel;
                    switch (st) {
                        case "rejected":
                            badgeClass = "s-rejected";
                            statusIcon = "ti ti-circle-x";
                            statusLabel = "Rejected";
                            break;
                        case "completed":
                            badgeClass = "s-completed";
                            statusIcon = "ti ti-circle-check";
                            statusLabel = "Completed";
                            break;
                        case "pending":
                        default:
                            badgeClass = "s-pending";
                            statusIcon = "ti ti-clock";
                            statusLabel = "Pending";
                            break;
                    }

                    String reqUsername = req.getRequesterUsername() != null ? req.getRequesterUsername() : "Unknown";
                    String reqInitials = reqUsername.length() >= 2
                            ? reqUsername.substring(0,2).toUpperCase()
                            : reqUsername.toUpperCase();

                    String desc = req.getDescription() != null ? req.getDescription() : "";
                    String requestedAt = req.getCreatedAt() != null ? req.getCreatedAt().format(dtf) : "—";
                %>
                <tr data-status="<%= st %>" data-yr="<%= req.getYear() %>">

                    <%-- Subject --%>
                    <td>
                        <div class="subj-name"><%= req.getSubjectName() %></div>
                        <span class="subj-code"><%= req.getSubjectCode() %></span>
                    </td>

                    <%-- Year --%>
                    <td><%= req.getYear() %></td>

                    <%-- Description --%>
                    <td>
                        <div class="desc-cell" title="<%= desc %>"><%= desc.isEmpty() ? "—" : desc %></div>
                    </td>

                    <%-- Requested By --%>
                    <td>
                        <div class="req-cell">
                            <div class="req-avatar"><%= reqInitials %></div>
                            <span class="req-name"><%= reqUsername %></span>
                        </div>
                    </td>

                    <%-- Requested At --%>
                    <td>
                        <span class="date-cell"><%= requestedAt %></span>
                    </td>

                    <%-- Status --%>
                    <td>
                        <span class="status-badge <%= badgeClass %>">
                            <i class="<%= statusIcon %>"></i>
                            <%= statusLabel %>
                        </span>
                    </td>

                    <%-- Action --%>
                    <td>
                        <div class="action-cell">
                            <% if ("pending".equals(st)) {
                                String uploadHref = request.getContextPath() + "/uploadPaper"
                                    + "?requestId=" + req.getRequestId()
                                    + "&subjectName=" + URLEncoder.encode(req.getSubjectName() != null ? req.getSubjectName() : "", "UTF-8")
                                    + "&subjectCode=" + URLEncoder.encode(req.getSubjectCode() != null ? req.getSubjectCode() : "", "UTF-8")
                                    + "&year=" + req.getYear();
                            %>
                            <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:10px">
                                <a href="<%= uploadHref %>"
                                   style="display:inline-flex;align-items:center;gap:5px;padding:6px 12px;background:#e8f5e9;color:#1b5e20;border:1.5px solid #a5d6a7;border-radius:7px;font-size:12px;font-weight:500;text-decoration:none;font-family:inherit">
                                    <i class="fas fa-upload"></i> Upload &amp; Complete
                                </a>
                                <button type="button" onclick="rejectRequest(<%= req.getRequestId() %>)"
                                        style="display:inline-flex;align-items:center;gap:5px;padding:6px 12px;background:#ffebee;color:#c62828;border:1.5px solid #ffcdd2;border-radius:7px;font-size:12px;font-weight:500;cursor:pointer;font-family:inherit">
                                    <i class="fas fa-times"></i> Reject
                                </button>
                            </div>
                            <% } else if ("completed".equals(st)) { %>
                            <div style="margin-bottom:10px">
                                <span style="background:#e8f5e9;color:#1b5e20;padding:4px 10px;border-radius:20px;font-size:11px;font-weight:600">&#10003; Completed</span>
                            </div>
                            <% } else if ("rejected".equals(st)) { %>
                            <div style="margin-bottom:10px">
                                <span style="background:#ffebee;color:#c62828;padding:4px 10px;border-radius:20px;font-size:11px;font-weight:600">&#10007; Rejected</span>
                            </div>
                            <% } %>

                            <div style="margin-top:10px">
                                <% if (req.getAdminMessage() != null && !req.getAdminMessage().isEmpty()) { %>
                                <div style="background:#f8fafc;border:1.5px solid #e5e7eb;border-radius:10px;padding:10px 14px;margin-bottom:8px;display:flex;align-items:flex-start;justify-content:space-between;gap:10px">
                                    <div style="display:flex;align-items:flex-start;gap:8px;flex:1;min-width:0">
                                        <i class="ti ti-message-circle" style="font-size:16px;color:#3b82f6;margin-top:1px;flex-shrink:0"></i>
                                        <div>
                                            <div style="font-size:11px;font-weight:600;color:#6b7280;margin-bottom:3px;text-transform:uppercase;letter-spacing:0.05em">Admin Reply</div>
                                            <div style="font-size:13px;color:#374151;line-height:1.5"><%= req.getAdminMessage() %></div>
                                        </div>
                                    </div>
                                    <form method="post" action="${pageContext.request.contextPath}/adminRequests" style="display:inline;flex-shrink:0;margin:0">
                                        <input type="hidden" name="action" value="deleteMessage">
                                        <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                                        <button type="submit"
                                                onclick="return confirm('Delete this reply?')"
                                                style="background:#fee2e2;border:none;border-radius:7px;padding:5px 10px;font-size:12px;font-weight:600;color:#dc2626;font-family:inherit;cursor:pointer;display:flex;align-items:center;gap:4px">
                                            <i class="ti ti-trash" style="font-size:13px"></i>
                                            Delete
                                        </button>
                                    </form>
                                </div>
                                <% } %>

                                <form method="post"
                                      action="${pageContext.request.contextPath}/adminRequests"
                                      style="display:flex;flex-direction:column;gap:8px;margin:0">
                                    <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                                    <input type="hidden" name="status" value="<%= st %>">
                                    <textarea name="adminMessage"
                                              placeholder="Type a message to send to the student..."
                                              maxlength="500"
                                              style="width:100%;border:1.5px solid #e5e7eb;border-radius:10px;padding:10px 12px;font-size:13px;font-family:inherit;color:#374151;background:#f9fafb;resize:vertical;min-height:80px;outline:none;transition:border .18s,box-shadow .18s"
                                              onfocus="this.style.borderColor='#3b82f6';this.style.boxShadow='0 0 0 3px rgba(59,130,246,.12)'"
                                              onblur="this.style.borderColor='#e5e7eb';this.style.boxShadow='none'"></textarea>
                                    <div style="display:flex;justify-content:flex-end">
                                        <button type="submit"
                                                style="background:#0f2744;color:#fff;border:none;border-radius:8px;padding:7px 16px;font-size:13px;font-weight:600;font-family:inherit;cursor:pointer;display:flex;align-items:center;gap:6px">
                                            <i class="ti ti-send" style="font-size:15px"></i>
                                            Send to Student
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </td>

                </tr>
                <% } %>
                </tbody>
            </table>
            </div>
            <% } else { %>
            <div class="empty-state">
                <i class="ti ti-inbox"></i>
                <p>No requests found</p>
            </div>
            <% } %>
        </div><!-- /table-card -->

    </div><!-- /content -->
</div><!-- /main -->

<div id="pwToast"><i class="ti ti-circle-check"></i><span id="pwToastMsg"></span></div>

<script>
    function filterTable() {
        const searchInput = document.getElementById('searchIn');
        const statusFilter = document.getElementById('filterSel');
        const q = searchInput ? searchInput.value.toLowerCase().trim() : '';
        const status = statusFilter ? statusFilter.value.toLowerCase() : '';
        let vis = 0;
        document.querySelectorAll('#reqTbody tr').forEach(function (r) {
            const text = r.textContent.toLowerCase();
            const rowStatus = (r.dataset.status || '').toLowerCase();
            const matchSearch = !q || text.includes(q);
            const matchStatus = !status || rowStatus === status;
            const visible = matchSearch && matchStatus;
            r.style.display = visible ? '' : 'none';
            if (visible) vis++;
        });
        const countEl = document.getElementById('req-count');
        if (countEl) countEl.textContent = vis;
    }
    function filterRows() { filterTable(); }
    document.addEventListener('DOMContentLoaded', function () {
        ['searchIn', 'filterSel'].forEach(function (id) {
            const el = document.getElementById(id);
            if (el) {
                el.addEventListener('input', filterTable);
                el.addEventListener('change', filterTable);
            }
        });
        filterTable();
    });

    window.addEventListener('load', () => {
        const savedTheme = localStorage.getItem('pw-theme') || 'light';
        const icon = document.getElementById('themeIcon');
        if (icon) icon.className = savedTheme === 'dark' ? 'fa-solid fa-sun' : 'fa-solid fa-moon';
    });

    function toggleSidebar() {
        var sb = document.querySelector('.sidebar');
        if (sb) {
            sb.classList.toggle('open');
        }
    }
</script>
<script>
(function() {
    var days=['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    var months=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var now=new Date();
    var el=document.getElementById('pageDate');
    if(el) el.textContent=now.toLocaleDateString('en-GB',{weekday:'short',day:'numeric',month:'short',year:'numeric'});
})();
</script>


<div class="pw-toast-container" id="pwToastContainer"></div>
<script>
function showToast(message, type, duration) {
  type = type || 'success';
  duration = duration || 4000;

  const container = document.getElementById('pwToastContainer');
  const toast = document.createElement('div');
  toast.className = 'pw-toast ' + type;

  const icons = {
    success: 'ti-circle-check',
    error:   'ti-circle-x',
    info:    'ti-info-circle',
    warning: 'ti-alert-triangle'
  };

  toast.innerHTML =
    '<i class="ti ' + icons[type] + ' pw-toast-icon"></i>' +
    '<span class="pw-toast-msg">' + message + '</span>' +
    '<button type="button" class="pw-toast-close" onclick="this.closest(\'.pw-toast\').remove()">' +
    '<i class="ti ti-x"></i></button>';

  container.appendChild(toast);

  requestAnimationFrame(() => {
    requestAnimationFrame(() => toast.classList.add('show'));
  });

  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 350);
  }, duration);
}

window.addEventListener('load', function() {
  const p = new URLSearchParams(window.location.search);

  if (p.get('msg_sent') === 'true') {
    showToast('Message sent to student!', 'success');
    document.querySelectorAll('textarea[name="adminMessage"]')
      .forEach(function(ta) { ta.value = ''; });
  } else if (p.get('msg_deleted') === 'true') {
    showToast('Message deleted.', 'info');
  } else {
  const messages = {
    'uploaded':        ['Paper uploaded successfully!',    'success'],
    'updated':         ['Paper updated successfully!',     'success'],
    'deleted':         ['Paper deleted successfully!',     'success'],
    'marked':          ['Marked as useful!',               'success'],
    'unmarked':        ['Removed from useful marks.',      'info'],
    'voted':           ['Difficulty vote saved!',          'success'],
    'rated':           ['Difficulty vote saved!',          'success'],
    'commented':       ['Comment posted!',                 'success'],
    'comment_deleted': ['Comment deleted.',                'info'],
    'submitted':       ['Request submitted successfully!', 'success'],
    'request_deleted': ['Request deleted.',                'info'],
    'status_updated':  ['Status updated successfully!',    'success'],
    'logged_out':      ['You have been logged out.',       'info'],
    'registered':      ['Account created! Please log in.', 'success'],
    'error':           ['Something went wrong. Try again.', 'error'],
    'unauthorized':    ['Please log in to continue.',      'warning'],
    'invalid':         ['Invalid input. Please check your fields.', 'warning'],
  };

  for (const [param, [msg, type]] of Object.entries(messages)) {
    if (p.get(param) === 'true' || p.get(param) === '1') {
      showToast(msg, type);
      break;
    }
  }

  const customMsg = p.get('msg');
  const customType = p.get('msgType') || 'info';
  if (customMsg) {
    showToast(decodeURIComponent(customMsg), customType);
  }
  }
});
</script>

<script>
(function() {
  var savedScroll = sessionStorage.getItem('scrollPos_' + window.location.pathname);
  var qs = window.location.search;
  if (savedScroll && (
    qs.indexOf('voted=true') !== -1 || qs.indexOf('rated=true') !== -1 ||
    qs.indexOf('marked=true') !== -1 || qs.indexOf('unmarked=true') !== -1 ||
    qs.indexOf('commented=true') !== -1 || qs.indexOf('comment_deleted=true') !== -1 ||
    qs.indexOf('request_deleted=true') !== -1 || qs.indexOf('submitted=true') !== -1 ||
    qs.indexOf('status_updated=true') !== -1 || qs.indexOf('deleted=true') !== -1 ||
    qs.indexOf('updated=true') !== -1 || qs.indexOf('msg_sent=true') !== -1 ||
    qs.indexOf('msg_deleted=true') !== -1
  )) {
    window.scrollTo(0, parseInt(savedScroll, 10));
  }
  document.addEventListener('submit', function() {
    sessionStorage.setItem('scrollPos_' + window.location.pathname, window.scrollY.toString());
  });
  window.addEventListener('beforeunload', function() {
    sessionStorage.setItem('scrollPos_' + window.location.pathname, window.scrollY.toString());
  });
})();
</script>

<script>
function rejectRequest(requestId) {
  if (!confirm('Reject this request?')) return;
  fetch('${pageContext.request.contextPath}/updateRequest', {
    method: 'POST',
    headers: {'Content-Type':'application/x-www-form-urlencoded'},
    body: 'requestId=' + requestId + '&status=rejected'
  })
  .then(function(r) { return r.json(); })
  .then(function(data) {
    if (data.success) {
      location.reload();
    }
  });
}
</script>

</body>
</html>
