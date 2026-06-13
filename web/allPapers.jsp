<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.Paper" %>
<%@ page import="com.paperwise.model.PaperRequest" %>
<%@ page import="com.paperwise.model.PaperComment" %>
<%@ page import="java.util.Map" %>
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

    @SuppressWarnings("unchecked")
    Map<Integer, List<PaperComment>> commentsMap = (Map<Integer, List<PaperComment>>) request.getAttribute("commentsMap");

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
            --text-primary: #0f2744;
            --text-secondary: #475569;
            --text-muted: #64748b;
            --border-color: #e2e8f0;
            --border-faint: #f1f5f9;
            --table-th-bg: #f8fafc;
            --table-td-text: #334155;
            --table-hover-bg: #f8fafc;
            --btn-bg: #f1f5f9;
            --input-bg: #ffffff;
            --input-border: #cbd5e1;
            --input-focus-bg: #ffffff;
            --topbar-bg: #ffffff;
            --bell-dot-border: #ffffff;
        }

        :root[data-theme="dark"] {
            --bg-body: #0f172a;
            --bg-card: #1e293b;
            --bg-sidebar: #0a1628;
            --text-primary: #f1f5f9;
            --text-secondary: #94a3b8;
            --text-muted: #64748b;
            --border-color: #334155;
            --border-faint: #1e293b;
            --table-th-bg: #1e293b;
            --table-td-text: #e2e8f0;
            --table-hover-bg: rgba(255, 255, 255, 0.02);
            --btn-bg: #1e293b;
            --input-bg: #1e293b;
            --input-border: #475569;
            --input-focus-bg: #0f172a;
            --topbar-bg: #111827;
            --bell-dot-border: #1e293b;
        }

        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--bg-body);
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
            transition: background 0.3s, color 0.3s;
        }

        /* ── SIDEBAR ─────────────────────────────────── */
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
            text-decoration: none; cursor: pointer;
            transition: background 0.15s, color 0.15s; position: relative;
            letter-spacing: 0.01em;
        }
        .nav-item i { font-size: 14px; margin: 0; width: 16px; text-align: center; flex-shrink: 0; }
        .nav-item:hover  { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.85); }
        .nav-item.active { background: rgba(255,255,255,0.13); color: #fff; font-weight: 500; }
        .nav-badge {
            margin-left: auto; background: #e53e3e; color: #fff;
            font-size: 10px; border-radius: 10px; padding: 1px 6px; font-weight: 600;
        }
        .sidebar-bottom {
            margin-top: auto; border-top: 1px solid rgba(255,255,255,0.08); padding: 12px 8px;
        }
        .user-row { display: flex; align-items: center; gap: 9px; padding: 6px 10px 10px; }
        .avatar {
            width: 32px; height: 32px; background: rgba(255,255,255,0.15); border-radius: 50%;
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
        .main {
            margin-left: 220px;
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            min-width: 0;
        }

        .topbar {
            background: var(--topbar-bg); height: 56px; padding: 0 24px;
            display: flex; align-items: center; justify-content: space-between;
            border-bottom: 1px solid var(--border-color); flex-shrink: 0;
            transition: background 0.3s, border-color 0.3s;
        }
        .topbar-left { display: flex; flex-direction: column; }
        .topbar-title {
            font-size: 18px;
            font-weight: 700;
            letter-spacing: -0.3px;
            color: var(--text-primary);
            line-height: 1.2;
        }
        .topbar-subtitle { font-size: 11px; color: var(--text-secondary); }
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
            position: relative; width: 34px; height: 34px; background: var(--btn-bg);
            border: none; border-radius: 8px; display: flex; align-items: center;
            justify-content: center; cursor: pointer; color: var(--text-secondary);
            transition: background 0.3s, color 0.3s;
        }
        .bell-btn i { font-size: 14px; margin: 0; }
        .bell-dot {
            position: absolute; top: 6px; right: 6px; width: 7px; height: 7px;
            background: #e53e3e; border-radius: 50%; border: 1.5px solid var(--bell-dot-border);
        }

        .content { padding: 1.6rem 2rem; flex: 1; }

        /* ── STAT CARDS ──────────────────────────────── */
        .stats-grid {
            display: grid; grid-template-columns: repeat(3, 1fr);
            gap: 14px; margin-bottom: 20px;
        }
        .stat-card {
            background: var(--bg-card);
            border-radius: 14px;
            padding: 1.2rem 1.4rem;
            border: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 14px;
            box-shadow: 0 1px 4px rgba(15,39,68,0.06);
            transition: background 0.3s, border-color 0.3s, box-shadow 0.3s;
        }
        .stat-icon {
            width: 36px; height: 36px; border-radius: 10px;
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        }
        .stat-icon i { font-size: 15px; margin: 0; }
        .stat-icon.blue   { background: #eef2ff; color: #4338ca; }
        .stat-icon.orange { background: #fff7ed; color: #9a3412; }
        .stat-icon.red    { background: #fef2f2; color: #991b1b; }
        .stat-body .stat-num   { font-size: 26px; font-weight: 700; color: var(--text-primary); line-height: 1.1; letter-spacing: -0.5px; }
        .stat-body .stat-label { font-size: 12.5px; color: var(--text-muted); margin-top: 2px; letter-spacing: 0.01em; }

        /* ── SECTION CARD ────────────────────────────── */
        .section-card {
            background: var(--bg-card);
            border-radius: 16px;
            border: 1px solid var(--border-color);
            overflow: hidden;
            margin-bottom: 20px;
            box-shadow: 0 1px 4px rgba(15,39,68,0.06);
            transition: background 0.3s, border-color 0.3s, box-shadow 0.3s;
        }
        .section-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 1.1rem 1.4rem; border-bottom: 1px solid var(--border-color); flex-wrap: wrap; gap: 10px;
        }
        .section-header-left { display: flex; align-items: center; gap: 8px; }
        .section-title { font-size: 14.5px; font-weight: 700; color: var(--text-primary); }
        .count-pill {
            font-size: 11px; padding: 3px 9px; border-radius: 20px; font-weight: 500;
        }
        .count-pill.indigo { background: #eef2ff; color: #3730a3; }

        /* Search + filter controls */
        .filter-controls { display: flex; align-items: center; gap: 8px; }
        .search-input {
            border: 1.5px solid var(--border-color); border-radius: 10px;
            padding: 7px 10px 7px 32px; font-size: 12.5px; color: var(--text-primary);
            background: var(--input-bg); outline: none; width: 200px;
            transition: border .18s, box-shadow .18s, background 0.3s;
            font-family: inherit;
        }
        .search-input:focus { border-color: #3b82f6; background: var(--input-focus-bg); box-shadow: 0 0 0 3px rgba(59,130,246,.1); }
        .search-wrap { position: relative; }
        .search-wrap i { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); font-size: 13px; color: var(--text-secondary); margin: 0; }
        .year-select {
            border: 1.5px solid var(--border-color); border-radius: 10px;
            padding: 7px 28px 7px 10px; font-size: 12.5px; color: var(--text-primary);
            background: var(--input-bg); outline: none; cursor: pointer;
            appearance: none; font-family: inherit;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%239ca3af'/%3E%3C/svg%3E");
            background-repeat: no-repeat; background-position: right 9px center;
            transition: border .18s;
        }
        .year-select:focus { border-color: #3b82f6; }

        /* ── TABLE ───────────────────────────────────── */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table thead tr { background: var(--table-th-bg); }
        .data-table th {
            font-size: 11px;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.06em;
            padding: 0.8rem 1.1rem;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
            font-weight: 600;
            white-space: nowrap;
        }
        .data-table td {
            padding: 1rem 1.1rem;
            border-bottom: 1px solid var(--border-faint);
            font-size: 13.5px;
            line-height: 1.5;
            color: var(--table-td-text);
            vertical-align: middle;
        }
        .data-table tbody tr:last-child td { border-bottom: none; }
        .data-table tbody tr:hover td { background: var(--table-hover-bg); }
        .td-subject { font-weight: 600; color: var(--text-primary); max-width: 180px; }

        .code-pill { background: #eef2ff; color: #3730a3; font-size: 11.5px; border-radius: 6px; padding: 3px 8px; font-weight: 500; border: 1px solid #ddd6fe; white-space: nowrap; }
        .year-pill  { background: #f0f9ff; color: #0369a1; font-size: 11.5px; border-radius: 6px; padding: 3px 8px; font-weight: 500; border: 1px solid #bae6fd; }

        /* Useful count cell */
        .useful-cell { display: flex; align-items: center; gap: 5px; white-space: nowrap; }
        .useful-cell i { color: #f97316; font-size: 12px; margin: 0; }
        .useful-num { font-size: 13px; font-weight: 600; color: var(--text-primary); }
        .muted { color: var(--text-muted); font-size: 12px; }

        .no-votes { font-size: 11px; color: var(--text-muted); font-style: italic; }

        /* Action buttons */
        .action-btns { display: flex; gap: 5px; flex-wrap: wrap; }
        .act-btn {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 5px 10px; border-radius: 8px; font-size: 11px; font-weight: 500;
            border: none; cursor: pointer; text-decoration: none; transition: opacity 0.15s;
        }
        .act-btn i { font-size: 10px; margin: 0; }
        .act-btn:hover { opacity: 0.82; }
        .act-view     { background: #eff6ff; color: #1d4ed8; }
        .act-download { background: #f0fdf4; color: #166534; }
        .act-edit     { background: #fff7ed; color: #9a3412; }
        .act-delete   { background: #fef2f2; color: #991b1b; }

        /* Empty state */
        .empty-state { text-align: center; padding: 48px 20px; color: var(--text-muted); }
        .empty-state i { font-size: 40px; margin: 0 0 12px; display: block; }
        .empty-state p { font-size: 13px; }

        /* Exam type pill */
        .exam-pill { background: #e0e7ff; color: #3730a3; font-size: 11px; font-weight: 600; border-radius: 5px; padding: 2px 8px; display: inline-block; white-space: nowrap; }

        /* Toast */
        .pw-toast {
            position: fixed; bottom: 20px; right: 20px; background: var(--bg-sidebar); color: #fff;
            border-radius: 10px; padding: 10px 16px; font-size: 13px; font-weight: 500;
            display: flex; align-items: center; gap: 8px;
            opacity: 0; transform: translateY(8px); transition: all .25s;
            pointer-events: none; z-index: 999;
        }
        .pw-toast i { font-size: 16px; color: #4ade80; margin: 0; }
        .pw-toast.show { opacity: 1; transform: translateY(0); }

        /* Difficulty badge variables */
        .diff-badge {
            font-size: 11.5px;
            font-weight: 600;
            border-radius: 20px;
            padding: 3px 10px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .diff-easy {
            background: #f0fdf4 !important;
            color: #15803d !important;
            border: 1px solid #bbf7d0 !important;
        }
        .diff-medium {
            background: #fffbeb !important;
            color: #92400e !important;
            border: 1px solid #fde68a !important;
        }
        .diff-hard {
            background: #fef2f2 !important;
            color: #991b1b !important;
            border: 1px solid #fecaca !important;
        }
        .diff-none {
            background: #f9fafb !important;
            color: #6b7280 !important;
            border: 1px solid #e5e7eb !important;
        }

        [data-theme="dark"] .diff-badge,
        [data-theme="dark"] .code-pill,
        [data-theme="dark"] .year-pill {
            opacity: 0.9;
        }
        [data-theme="dark"] .code-pill {
            background: #1e3a5f;
            color: #93c5fd;
            border: 1px solid #1e40af;
        }
        [data-theme="dark"] .year-pill {
            background: #1e293b;
            color: #94a3b8;
            border: 1px solid #334155;
        }

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
                left: -220px;
                top: 0;
                bottom: 0;
                z-index: 9999;
                box-shadow: 4px 0 15px rgba(0, 0, 0, 0.25);
                transition: left 0.3s ease;
            }
            .sidebar.open {
                left: 0;
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
        <p class="nav-label">MAIN</p>
        <a href="${pageContext.request.contextPath}/adminDashboard" class="nav-item">
            <i class="ti ti-layout-dashboard"></i> Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/allPapers" class="nav-item active">
            <i class="ti ti-files"></i> All Papers
        </a>
        <a href="${pageContext.request.contextPath}/uploadPaper" class="nav-item">
            <i class="ti ti-upload"></i> Upload Paper
        </a>
    </div>

    <div class="nav-section">
        <p class="nav-label">MANAGE</p>
        <a href="${pageContext.request.contextPath}/adminRequests" class="nav-item">
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

<!-- ── MAIN ────────────────────────────────────────────── -->
<div class="main">

    <!-- Topbar -->
    <div class="topbar">
        <div style="display: flex; align-items: center; gap: 12px;">
            <button type="button" class="menu-toggle" onclick="toggleSidebar()" style="background: none; border: none; font-size: 20px; cursor: pointer; color: var(--text-primary); display: none; align-items: center; justify-content: center; padding: 4px;">
                <i class="ti ti-menu-2"></i>
            </button>
            <div class="topbar-left">
                <span class="topbar-title">All Papers</span>
                <span class="topbar-subtitle">View and manage all uploaded academic papers</span>
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
            <button class="bell-btn" title="Notifications">
                <i class="ti ti-bell"></i>
                <% if (pendingCount > 0) { %><span class="bell-dot"></span><% } %>
            </button>
        </div>
    </div>

    <div class="content">
        <!-- ── STAT CARDS ── -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="ti ti-files"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= papers != null ? papers.size() : 0 %></div>
                    <div class="stat-label">Total Papers</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon orange"><i class="ti ti-thumb-up"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalUsefulMarks %></div>
                    <div class="stat-label">Total Useful Marks</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon red"><i class="ti ti-flame"></i></div>
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
                </div>
                <div class="filter-controls">
                    <!-- Search -->
                    <div class="search-wrap">
                        <i class="ti ti-search"></i>
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
                    <!-- Exam Type filter -->
                    <select id="examTypeFilter" class="year-select" onchange="filterTable()">
                        <option value="">All Types</option>
                        <option value="mid term">Mid Term</option>
                        <option value="end term">End Term</option>
                        <option value="quiz">Quiz</option>
                        <option value="sessional 1">Sessional 1</option>
                        <option value="sessional 2">Sessional 2</option>
                        <option value="assignment">Assignment</option>
                    </select>
                </div>
            </div>

            <% if (papers != null && !papers.isEmpty()) { %>
            <div class="data-table-container">
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
                <tr class="paper-row" data-subject="<%= paper.getSubjectName().toLowerCase() %>"
                    data-code="<%= paper.getSubjectCode().toLowerCase() %>"
                    data-year="<%= paper.getYear() %>"
                    data-yr="<%= paper.getYear() %>"
                    data-exam="<%= paper.getExamType() != null ? paper.getExamType().toLowerCase() : "" %>"
                    data-examtype="<%= paper.getExamType() != null ? paper.getExamType().toLowerCase() : "" %>">
                    <td class="td-subject">
                        <%= paper.getSubjectName() %>
                        <% if (paper.getDescription() != null && !paper.getDescription().isEmpty()) { %>
                            <div style="font-size:11px;color:#64748b;margin-top:3px;font-style:italic"><%= paper.getDescription() %></div>
                        <% } %>
                    </td>
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
                                <i class="ti ti-thumb-up"></i>
                                <span class="useful-num"><%= paper.getUsefulCount() %></span>
                            </div>
                        <% } else { %>
                            <span class="muted">—</span>
                        <% } %>
                    </td>

                    <!-- Difficulty votes -->
                    <td>
                        <% if (total == 0) { %>
                            <span class="no-votes">No votes yet</span>
                        <% } else { %>
                            <span style="font-size:12px;color:#16a34a;font-weight:600">Easy (<%= easy %>)</span>
                            <span style="color:#d1d5db;margin:0 4px">|</span>
                            <span style="font-size:12px;color:#d97706;font-weight:600">Med (<%= medium %>)</span>
                            <span style="color:#d1d5db;margin:0 4px">|</span>
                            <span style="font-size:12px;color:#dc2626;font-weight:600">Hard (<%= hard %>)</span>
                        <% } %>
                    </td>

                    <!-- Actions -->
                    <td>
                        <div class="action-btns">
                            <a href="${pageContext.request.contextPath}/viewFile?paperId=<%= paper.getPaperId() %>"
                               target="_blank" class="act-btn act-view">
                                <i class="ti ti-eye"></i> View
                            </a>
                            <a href="${pageContext.request.contextPath}/downloadPaper?paperId=<%= paper.getPaperId() %>"
                               class="act-btn act-download">
                                <i class="ti ti-download"></i> Download
                            </a>
                            <a href="${pageContext.request.contextPath}/editPaper?paperId=<%= paper.getPaperId() %>"
                               class="act-btn act-edit">
                                <i class="ti ti-edit"></i> Edit
                            </a>
                            <form action="${pageContext.request.contextPath}/deletePaper" method="post"
                                  style="display:inline;"
                                  onsubmit="return confirm('Delete this paper? This cannot be undone.');">
                                <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                <button type="submit" class="act-btn act-delete">
                                    <i class="ti ti-trash"></i> Delete
                                </button>
                            </form>
                            <%
                                List<PaperComment> commentList = commentsMap != null ? commentsMap.get(paper.getPaperId()) : null;
                                int commentCount = commentList != null ? commentList.size() : 0;
                            %>
                            <button type="button" onclick="toggleComments('comments-<%= paper.getPaperId() %>')" style="background:none;border:none;color:#64748b;font-size:12px;font-weight:500;cursor:pointer;padding:4px 6px;display:inline-flex;align-items:center;gap:5px;font-family:inherit;margin-left:4px">
                                <i class="ti ti-message-circle" style="font-size:14px;color:#64748b"></i>
                                Comments
                                <span style="background:#e5e7eb;color:#374151;border-radius:50%;min-width:18px;height:18px;padding:0 5px;font-size:10px;font-weight:600;display:inline-flex;align-items:center;justify-content:center;line-height:1"><%= commentCount %></span>
                            </button>
                        </div>
                    </td>
                </tr>
                <tr class="comments-row" style="display:none">
                    <td colspan="10" style="padding:8px 16px 12px;border-bottom:1px solid var(--border-color)">
                        <div id="comments-<%= paper.getPaperId() %>" style="background:#ffffff;border:1px solid #e5e7eb;border-radius:8px;padding:12px 14px">
                            <%-- Existing comments --%>
                            <% if (commentList != null && !commentList.isEmpty()) {
                                for (PaperComment comment : commentList) {
                                    String initial = comment.getUsername() != null && comment.getUsername().length() >= 2 
                                        ? comment.getUsername().substring(0, 2).toUpperCase() 
                                        : "U";
                            %>
                                    <div style="display:flex;align-items:flex-start;gap:10px;padding:8px 0">
                                        <div style="width:28px;height:28px;border-radius:50%;background:#dbeafe;color:#1e40af;display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:700;flex-shrink:0">
                                            <%= initial %>
                                        </div>
                                        <div style="flex:1;min-width:0">
                                            <div style="font-size:12.5px;font-weight:700;color:#1a2740;line-height:1.3">
                                                <%= comment.getUsername() %>
                                                <span style="font-size:10.5px;color:#94a3b8;font-weight:400;margin-left:6px">
                                                    <%= comment.getCreatedAt() %>
                                                </span>
                                            </div>
                                            <div style="font-size:13px;color:#374151;margin-top:4px;line-height:1.45;font-weight:400">
                                                <%= comment.getCommentText() %>
                                            </div>
                                        </div>
                                        <%-- Role-based delete: admin can delete own comments + student comments, NOT other admin comments --%>
                                        <%
                                            boolean canDeleteComment = loggedInUser != null && (
                                                loggedInUser.getUserId() == comment.getUserId() ||
                                                ("admin".equalsIgnoreCase(loggedInUser.getRole()) && "student".equalsIgnoreCase(comment.getUserRole()))
                                            );
                                        %>
                                        <% if (canDeleteComment) { %>
                                        <form action="<%= request.getContextPath() %>/paperComment" method="post" style="display:inline;margin:0">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="commentId" value="<%= comment.getCommentId() %>">
                                            <input type="hidden" name="redirectUrl" value="<%= request.getContextPath() %>/allPapers">
                                            <button type="submit"
                                                    onclick="return confirm('Delete this comment?')"
                                                    style="background:none;border:none;color:#dc2626;cursor:pointer;font-size:12px;display:flex;align-items:center;gap:3px;padding:0">
                                                <i class="ti ti-trash"></i>
                                            </button>
                                        </form>
                                        <% } %>
                                    <% if (loggedInUser != null && comment.getUserId() != loggedInUser.getUserId()) { %>
                                        <button type="button" onclick="toggleReplyForm('admin-reply-<%= paper.getPaperId() %>-<%= comment.getCommentId() %>')"
                                                style="background:none;border:none;color:#6b7280;font-size:11px;cursor:pointer;margin-left:38px;margin-top:2px;display:inline-flex;align-items:center;gap:4px;padding:2px 0;font-family:inherit">
                                            <i class="ti ti-arrow-back-up" style="font-size:12px"></i> Reply
                                        </button>
                                        <div id="admin-reply-<%= paper.getPaperId() %>-<%= comment.getCommentId() %>" style="display:none;margin-left:28px;margin-top:6px">
                                            <form action="<%= request.getContextPath() %>/paperComment" method="post" style="display:flex;gap:6px;align-items:center">
                                                <input type="hidden" name="action" value="add">
                                                <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                                <input type="hidden" name="parentCommentId" value="<%= comment.getCommentId() %>">
                                                <input type="hidden" name="redirectUrl" value="<%= request.getContextPath() %>/allPapers">
                                                <input type="text" name="commentText" placeholder="Write a reply..." maxlength="200" required
                                                       style="flex:1;padding:6px 10px;border:1.5px solid #e2e8f0;border-radius:7px;font-size:12px;font-family:inherit;outline:none;background:#f8fafc">
                                                <button type="submit"
                                                        style="background:#0f1b2d;color:#fff;border:none;border-radius:7px;padding:6px 12px;font-size:11.5px;font-weight:600;cursor:pointer;font-family:inherit;white-space:nowrap">
                                                    Post Reply
                                                </button>
                                            </form>
                                        </div>
                                    <% } %>
                                    <%-- Render replies with role-based delete --%>
                                    <% if (comment.getReplies() != null && !comment.getReplies().isEmpty()) {
                                        for (PaperComment reply : comment.getReplies()) {
                                            String replyInitial = reply.getUsername() != null && reply.getUsername().length() >= 2
                                                ? reply.getUsername().substring(0, 2).toUpperCase()
                                                : "U";
                                            boolean canDeleteReply = loggedInUser != null && (
                                                loggedInUser.getUserId() == reply.getUserId() ||
                                                ("admin".equalsIgnoreCase(loggedInUser.getRole()) && "student".equalsIgnoreCase(reply.getUserRole()))
                                            );
                                    %>
                                        <div style="display:flex;align-items:flex-start;gap:8px;padding:8px 0;margin-left:38px">
                                            <div style="width:24px;height:24px;border-radius:50%;background:#f3e8ff;color:#7e22ce;display:flex;align-items:center;justify-content:center;font-size:9px;font-weight:700;flex-shrink:0">
                                                <%= replyInitial %>
                                            </div>
                                            <div style="flex:1;min-width:0">
                                                <div style="font-size:12px;font-weight:700;color:#1a2740;line-height:1.3">
                                                    <%= reply.getUsername() %>
                                                    <span style="font-size:10px;color:#94a3b8;font-weight:400;margin-left:6px"><%= reply.getCreatedAt() %></span>
                                                </div>
                                                <div style="font-size:13px;color:#374151;margin-top:3px;line-height:1.45"><%= reply.getCommentText() %></div>
                                            </div>
                                            <% if (canDeleteReply) { %>
                                            <form action="<%= request.getContextPath() %>/paperComment" method="post" style="display:inline;margin:0">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="commentId" value="<%= reply.getCommentId() %>">
                                                <input type="hidden" name="redirectUrl" value="<%= request.getContextPath() %>/allPapers">
                                                <button type="submit"
                                                        onclick="return confirm('Delete this reply?')"
                                                        style="background:none;border:none;color:#dc2626;cursor:pointer;font-size:11px;display:flex;align-items:center;padding:0">
                                                    <i class="ti ti-trash"></i>
                                                </button>
                                            </form>
                                            <% } %>
                                        </div>
                                    <% } } %>
                            <%  }
                            } else { %>
                                <div style="font-size:12px;color:var(--text-muted);font-style:italic;padding:4px 0">
                                    No comments yet. Be the first to comment!
                                </div>
                            <% } %>

                            <%-- Add comment form --%>
                            <form action="<%= request.getContextPath() %>/paperComment" method="post" style="display:flex;gap:8px;margin-top:10px;align-items:center">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                <input type="hidden" name="redirectUrl" value="<%= request.getContextPath() %>/allPapers">
                                <input type="text" name="commentText" placeholder="Add a comment..." maxlength="300" required style="flex:1;padding:8px 12px;border:1.5px solid var(--border-color);border-radius:10px;font-size:13px;font-family:inherit;outline:none;background:var(--input-bg);color:var(--text-primary)">
                                <button type="submit" style="background:#0f2744;color:#fff;border:none;border-radius:10px;padding:8px 16px;font-size:12.5px;font-weight:600;cursor:pointer;font-family:inherit">
                                    Post
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
            <div id="noResults" style="display:none; text-align:center; padding:32px; color:var(--text-muted); font-size:13px;">
                No papers match your search.
            </div>

            <% } else { %>
            <div class="empty-state">
                <i class="ti ti-folder-off" style="color:#cbd5e0;"></i>
                <p>No papers uploaded yet.</p>
            </div>
            <% } %>
        </div>

    </div><!-- /.content -->
</div><!-- /.main -->

<div id="pwToast"><i class="ti ti-circle-check"></i><span id="pwToastMsg"></span></div>

<script>
    function filterTable() {
        var searchInput = document.getElementById('searchInput');
        var yearFilter = document.getElementById('yearFilter');
        var examFilter = document.getElementById('examTypeFilter');
        var q = searchInput ? searchInput.value.toLowerCase().trim() : '';
        var yr = yearFilter ? yearFilter.value : '';
        var exam = examFilter ? examFilter.value.toLowerCase().trim() : '';
        var rows = document.querySelectorAll('#papersBody tr.paper-row');
        var visible = 0;
        rows.forEach(function (row) {
            var text = row.textContent.toLowerCase();
            var rowYear = String(row.dataset.yr || row.dataset.year || '').toLowerCase();
            var rowExam = (row.dataset.exam || row.dataset.examtype || '').toLowerCase();
            var matchSearch = !q || text.includes(q);
            var matchYear = !yr || rowYear === String(yr).toLowerCase();
            var matchExam = !exam || rowExam === exam;
            var match = matchSearch && matchYear && matchExam;
            row.style.display = match ? '' : 'none';
            if (match) visible++;
            var next = row.nextElementSibling;
            if (next && next.tagName === 'TR' && next.classList.contains('comments-row')) {
                if (!match) {
                    next.style.display = 'none';
                } else {
                    var innerComments = next.querySelector('div[id^="comments-"]');
                    if (innerComments && innerComments.style.display !== 'none') {
                        next.style.display = '';
                    } else {
                        next.style.display = 'none';
                    }
                }
            }
        });
        var noResults = document.getElementById('noResults');
        if (noResults) noResults.style.display = visible === 0 ? 'block' : 'none';
    }
    document.addEventListener('DOMContentLoaded', function () {
        ['searchInput', 'yearFilter', 'examTypeFilter'].forEach(function (id) {
            var el = document.getElementById(id);
            if (el) {
                el.addEventListener('input', filterTable);
                el.addEventListener('change', filterTable);
            }
        });
        filterTable();
    });

    function toggleComments(id) {
        const el = document.getElementById(id);
        if (el) {
            // Find parent comments-row tr
            const tr = el.closest('tr.comments-row');
            if (tr) {
                if (el.style.display === 'none' || el.style.display === '') {
                    el.style.display = 'block';
                    tr.style.display = '';
                } else {
                    el.style.display = 'none';
                    tr.style.display = 'none';
                }
            }
        }
    }

    function replyToComment(paperId, username) {
        const input = document.querySelector(`#comments-${paperId} input[name="commentText"]`);
        if (input) {
            input.value = `@${username} `;
            input.focus();
        }
    }

    function toggleReplyForm(id) {
        const el = document.getElementById(id);
        if (el) {
            el.style.display = el.style.display === 'none' ? 'flex' : 'none';
        }
    }

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

</body>
</html>
