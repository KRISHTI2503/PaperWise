<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.Paper" %>
<%@ page import="com.paperwise.model.PaperComment" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Map" %>
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

    int totalPapers      = request.getAttribute("totalPapers")      != null ? (int) request.getAttribute("totalPapers")      : 0;
    int totalUsefulMarks = request.getAttribute("totalUsefulMarks") != null ? (int) request.getAttribute("totalUsefulMarks") : 0;
    int myMarksCount     = votedPapers != null ? votedPapers.size() : 0;

    @SuppressWarnings("unchecked")
    List<Integer> availableYears = (List<Integer>) request.getAttribute("availableYears");
    @SuppressWarnings("unchecked")
    Map<Integer, List<PaperComment>> commentsMap = (Map<Integer, List<PaperComment>>) request.getAttribute("commentsMap");

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
    <title>All Papers - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/paperwise.css">
        <script>
        (function(){var t=localStorage.getItem('pw-theme')||'light';document.documentElement.setAttribute('data-theme',t);})();
    </script>
<script src="${pageContext.request.contextPath}/js/paperwise.js" defer></script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/tabler-icons/css/tabler-icons.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <style>
        /* ── THEME COLORS ── */
        :root {
            --bg-body: #f7f9fc;
            --bg-sidebar: #0f2744;
            --bg-card: #ffffff;
            --text-primary: #0f2744;
            --text-secondary: #4f7396;
            --text-muted: #64748b;
            --border-color: #e2e8f0;
            --btn-bg: #f1f5f9;
            --input-bg: #f8fafc;
            --input-border: #e2e8f0;
            --input-focus-bg: #ffffff;
            --table-th-bg: #f8fafc;
            --table-hover-bg: #f8fafc;
            --table-td-text: #334155;
        }

        [data-theme="dark"] {
            --bg-body: #0f172a;
            --bg-card: #1e293b;
            --bg-card-hover: #263348;
            --bg-input: #1e293b;
            --bg-table-head: #1a2744;
            --bg-row-hover: #1e2d44;

            /* Text colors */
            --text-primary: #f1f5f9;
            --text-secondary: #94a3b8;
            --text-muted: #64748b;
            --text-heading: #e2e8f0;

            /* Borders */
            --border-color: #334155;
            --border-light: #1e293b;

            /* Sidebar */
            --sb-bg: #0a1628;

            /* Topbar */
            --topbar-bg: #111827;
            --topbar-border: #1e293b;

            /* Theme overrides for default roots */
            --table-th-bg: #1e293b;
            --table-hover-bg: #1e2d44;
            --table-td-text: #f1f5f9;
            --btn-bg: #1e293b;
            --input-bg: #1e293b;
            --input-border: #334155;
            --input-focus-bg: #0f172a;
        }

        /* ── RESET ── */
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: var(--bg-body);
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
            transition: background 0.3s, color 0.3s;
        }

        /* ── FIXED SIDEBAR ── */
        .sb {
            width: 220px;
            flex-shrink: 0;
            background: #0f2744;
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            overflow-y: auto;
            z-index: 100;
        }
        .main {
            margin-left: 220px;
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        [data-theme="dark"] .sb {
            background: var(--sb-bg);
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
            transition: background .15s, color .15s;
            letter-spacing: 0.01em;
        }
        .nav-item i { font-size: 13px; margin: 0; width: 16px; text-align: center; flex-shrink: 0; }
        .nav-item:hover  { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.85); }
        .nav-item.active { background: rgba(255,255,255,0.13); color: #fff; font-weight: 500; }
        .sidebar-bottom {
            margin-top: auto;
            border-top: 1px solid rgba(255,255,255,0.08);
            padding: 12px 8px;
        }
        .user-row { display: flex; align-items: center; gap: 9px; padding: 6px 10px 10px; }
        .avatar {
            width: 32px; height: 32px; background: rgba(255,255,255,0.15);
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

        /* ── TOPBAR ── */
        .topbar {
            background: var(--bg-card); height: 56px; padding: 0 24px;
            display: flex; align-items: center; justify-content: space-between;
            border-bottom: 1px solid var(--border-color); flex-shrink: 0;
            transition: background 0.3s, border-color 0.3s;
        }
        .topbar-title {
            font-size: 18px;
            font-weight: 700;
            letter-spacing: -0.3px;
            color: var(--text-primary);
        }
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
            position: relative; width: 34px; height: 34px;
            background: var(--btn-bg); border: none; border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; color: var(--text-secondary);
            transition: background 0.3s, color 0.3s;
        }
        .bell-btn i { font-size: 14px; margin: 0; }
        .content { padding: 1.6rem 2rem; flex: 1; }

        /* Hamburger Menu Toggler */
        .menu-toggle {
            display: none;
            background: none;
            border: none;
            font-size: 18px;
            cursor: pointer;
            color: var(--text-primary);
            padding: 8px 0;
            margin-right: 12px;
        }

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

        /* ── PAGE LAYOUT ELEMENTS ── */
        .stats-grid {
            display: grid; grid-template-columns: repeat(3, 1fr);
            gap: 14px; margin-bottom: 20px;
        }
        .stat-card {
            background: var(--bg-card); border-radius: 14px; padding: 1.2rem 1.4rem;
            border: 1px solid var(--border-color); display: flex; align-items: center; gap: 14px;
            transition: background 0.3s, border-color 0.3s;
            box-shadow: 0 1px 4px rgba(15,39,68,0.06);
        }
        .stat-icon {
            width: 36px; height: 36px; border-radius: 9px;
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        }
        .stat-icon i { font-size: 15px; margin: 0; }
        .stat-icon.blue   { background: #eef2ff; color: #4338ca; }
        .stat-icon.green  { background: #f0fdf4; color: #166534; }
        .stat-icon.orange { background: #fff7ed; color: #9a3412; }
        .stat-body .stat-num   { font-size: 26px; font-weight: 700; color: var(--text-primary); line-height: 1.1; letter-spacing: -0.5px; }
        .stat-body .stat-label { font-size: 12.5px; color: var(--text-muted); margin-top: 2px; letter-spacing: 0.01em; }
        .table-card {
            background: var(--bg-card);
            border-radius: 16px;
            border: 1px solid var(--border-color);
            overflow: hidden;
            margin-bottom: 20px;
            transition: background 0.3s, border-color 0.3s;
            box-shadow: 0 1px 4px rgba(15,39,68,0.06);
        }
        .tc-head {
            padding: 1.1rem 1.4rem;
            border-bottom: 1px solid var(--border-color);
            display: flex; align-items: center;
            justify-content: space-between;
            gap: 10px; flex-wrap: wrap;
            transition: border-color 0.3s;
        }
        .tc-title {
            font-size: 14px; font-weight: 600;
            color: var(--text-primary);
            display: flex; align-items: center; gap: 7px;
        }
        .tc-title i { font-size: 15px; color: var(--text-muted); margin: 0; }
        .tc-right {
            display: flex; align-items: center; gap: 8px;
        }
        .search-box {
            display: flex; align-items: center; gap: 6px;
            border: 1.5px solid var(--input-border); border-radius: 10px;
            padding: 5px 10px; background: var(--input-bg);
            transition: border-color 0.3s, background 0.3s;
        }
        .search-box i { font-size: 13px; color: var(--text-muted); margin: 0; }
        .search-box input {
            border: none; background: transparent; outline: none;
            font-size: 12.5px; font-family: inherit;
            color: var(--text-primary); width: 160px;
        }
        .fsel {
            border: 1.5px solid var(--input-border); border-radius: 10px;
            padding: 5px 10px; font-size: 12px;
            font-family: inherit; color: var(--text-primary);
            background: var(--input-bg); cursor: pointer; outline: none;
            transition: border-color 0.3s, background 0.3s, color 0.3s;
        }
        table { width: 100%; border-collapse: collapse; }
        thead tr { background: var(--table-th-bg); }
        th {
            font-size: 11px; color: var(--text-muted); text-transform: uppercase;
            letter-spacing: 0.06em; padding: .8rem 1.1rem; text-align: left;
            border-bottom: 1px solid var(--border-color); font-weight: 600;
        }
        td {
            padding: 1rem 1.1rem; border-bottom: 1px solid var(--border-color);
            font-size: 13.5px; line-height: 1.5; color: var(--table-td-text); vertical-align: middle;
            transition: background 0.3s, border-color 0.3s;
        }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: var(--table-hover-bg); }
        .td-subject { font-weight: 600; color: var(--text-primary); }
        .code-pill { background: #eef2ff; color: #3730a3; font-size: 11px; border-radius: 6px; padding: 3px 8px; font-weight: 500; }
        .year-pill  { background: #162636; color: #fff; font-size: 11px; border-radius: 6px; padding: 3px 8px; font-weight: 500; }
        .date-cell { font-size: 11px; color: var(--text-muted); white-space: nowrap; }

        /* Unified difficulty badges */
        .diff-badge {
            font-size: 11.5px;
            font-weight: 600;
            border-radius: 20px;
            padding: 3px 10px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .diff-easy   { background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0; }
        .selected-diff { outline: 2px solid currentColor; outline-offset: 1px; font-weight: 700; }
        .diff-medium { background: #fffbeb; color: #92400e; border: 1px solid #fde68a; }
        .diff-hard   { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }
        .diff-none   { background: #f9fafb; color: #6b7280; border: 1px solid #e5e7eb; }

        /* Action buttons — exact from dashboard */
        .action-btns { display: flex; gap: 5px; flex-wrap: wrap; }
        .act-btn {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 5px 10px; border-radius: 8px; font-size: 11px;
            font-weight: 500; border: 1.5px solid transparent; cursor: pointer;
            text-decoration: none; transition: opacity .15s, background .15s;
            font-family: inherit; background: none;
        }
        .act-btn i { font-size: 10px; margin: 0; }
        .act-btn:hover { opacity: 0.82; }
        .act-view     { background: #eff6ff; color: #1d4ed8; border-color: #bfdbfe; }
        .act-download { background: #f0fdf4; color: #166534; border-color: #bbf7d0; }
        .act-vote     { background: transparent; color: var(--text-primary); border-color: var(--border-color); }
        .act-vote:hover { background: var(--btn-bg); }
        .act-marked   { background: #f1f5f9; color: #0f2744; border-color: var(--border-color); font-weight: 600; }
        .act-easy     { background: #f0fdf4; color: #15803d; border-color: transparent; }
        .act-medium   { background: #fffbeb; color: #92400e; border-color: transparent; }
        .act-hard     { background: #fef2f2; color: #991b1b; border-color: transparent; }

        /* Unified popular badge */
        .pop-badge {
            background: #fff7ed;
            color: #c2410c;
            border: 1px solid #fed7aa;
            font-size: 10px;
            font-weight: 700;
            border-radius: 5px;
            padding: 2px 7px;
            display: inline-flex;
            align-items: center;
            gap: 3px;
        }

        /* File-type badge */
        .ft-badge { display: inline-block; font-size: 9px; font-weight: 700; letter-spacing: 0.4px; border-radius: 4px; padding: 2px 5px; margin-right: 6px; vertical-align: middle; text-transform: uppercase; }
        .ft-pdf  { background: #fee2e2; color: #991b1b; }
        .ft-doc  { background: #dbeafe; color: #1e40af; }
        .ft-ppt  { background: #ffedd5; color: #9a3412; }
        .ft-img  { background: #d1fae5; color: #065f46; }
        .ft-vid  { background: #ede9fe; color: #5b21b6; }
        .ft-txt  { background: #f3f4f6; color: #374151; }
        .ft-other{ background: #f3f4f6; color: #6b7280; }

        /* Useful count display */
        .useful-num { color: #0f2744; font-weight: 700; font-size: 13.5px; }

        /* Empty state */
        .empty { padding: 3rem; text-align: center; }
        .empty i { font-size: 48px; color: var(--border-color); display: block; margin-bottom: .7rem; }
        .empty p { font-size: 13.5px; font-weight: 600; color: var(--text-muted); }
        .pw-toast {
            position: fixed; bottom: 20px; right: 20px;
            background: var(--bg-sidebar); color: #fff;
            border-radius: 10px; padding: 10px 16px;
            font-size: 13px; font-weight: 500;
            display: flex; align-items: center; gap: 8px;
            opacity: 0; transform: translateY(8px);
            transition: all .25s; pointer-events: none; z-index: 999;
        }
        .pw-toast i { font-size: 16px; color: #4ade80; }
        .pw-toast.show { opacity: 1; transform: translateY(0); }

        [data-theme="dark"] .code-pill { background: #1e3a5f; color: #93c5fd; border: 1px solid #1e40af; }
        [data-theme="dark"] .year-pill { background: #1e293b; color: #94a3b8; border: 1px solid #334155; }
        [data-theme="dark"] .diff-badge, [data-theme="dark"] .code-pill { opacity: 0.9; }

        @media (max-width: 768px) {
            body {
                flex-direction: column;
            }
            .sb {
                position: fixed;
                left: -220px;
                top: 0;
                bottom: 0;
                z-index: 9999;
                box-shadow: 4px 0 15px rgba(0, 0, 0, 0.25);
                transition: left 0.3s ease;
            }
            .sb.open {
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

<!-- ═══════════════════ SIDEBAR ═══════════════════ -->
<nav class="sb sidebar">
    <div class="sidebar-logo">
        <div class="logo-sq"><i class="fa-solid fa-book-open"></i></div>
        <div class="logo-text">
            <span class="app-name">PaperWise</span>
            <span class="app-sub">Student Panel</span>
        </div>
    </div>

    <div class="nav-section">
        <p class="nav-label">MAIN</p>
        <a href="${pageContext.request.contextPath}/studentDashboard" class="nav-item">
            <i class="ti ti-layout-dashboard"></i> Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/studentAllPapers" class="nav-item active">
            <i class="ti ti-files"></i> All Papers
        </a>
        <a href="${pageContext.request.contextPath}/myMarked" class="nav-item">
            <i class="fa-solid fa-bookmark"></i> My Marked
        </a>
    </div>

    <div class="nav-section">
        <p class="nav-label">REQUESTS</p>
        <a href="${pageContext.request.contextPath}/requestPaper" class="nav-item">
            <i class="ti ti-inbox"></i> My Requests
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
        <div style="display:flex; align-items:center; gap:12px;">
            <button class="menu-toggle" onclick="toggleSidebar()"><i class="fa-solid fa-bars"></i></button>
            <span class="topbar-title">All Papers</span>
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
                <i class="fa-regular fa-bell"></i>
            </button>
        </div>
    </div>

    <div class="content">

        <!-- ── STAT CARDS ── -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="ti ti-files"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalPapers %></div>
                    <div class="stat-label">Total Papers</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green" style="background:#dbeafe;color:#2563eb;"><i class="fa-solid fa-bookmark"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalUsefulMarks %></div>
                    <div class="stat-label">Total Useful Marks</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon orange"><i class="ti ti-star"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= myMarksCount %></div>
                    <div class="stat-label">Your Marks</div>
                </div>
            </div>
        </div>

        <!-- ── TABLE CARD ── -->
        <div class="table-card">
            <div class="tc-head">
                <div class="tc-title">
                    All Papers
                </div>
                <div class="tc-right">
                    <div class="search-box">
                        <i class="ti ti-search"></i>
                        <input type="text" id="srch"
                               placeholder="Search subject, code, year…"
                               oninput="filterTable()">
                    </div>
                    <select class="fsel" id="yrF" onchange="filterTable()">
                        <option value="">All Years</option>
                        <% if (availableYears != null) {
                               for (Integer yr : availableYears) { %>
                            <option value="<%= yr %>"><%= yr %></option>
                        <% } } %>
                    </select>
                    <select class="fsel" id="examF" onchange="filterTable()">
                        <option value="">All Exam Types</option>
                        <option value="mid term">Mid Term</option>
                        <option value="end term">End Term</option>
                        <option value="sessional 1">Sessional 1</option>
                        <option value="sessional 2">Sessional 2</option>
                        <option value="quiz">Quiz</option>
                    </select>
                    <select class="fsel" id="diffF" onchange="filterTable()">
                        <option value="">All Difficulties</option>
                        <option value="easy">Easy</option>
                        <option value="medium">Medium</option>
                        <option value="hard">Hard</option>
                        <option value="mixed">Mixed</option>
                    </select>
                </div>
            </div>

            <% if (papers == null || papers.isEmpty()) { %>
            <div class="empty">
                <i class="ti ti-folder-open"></i>
                <p>No papers uploaded yet.</p>
            </div>
            <% } else { %>
            <div class="data-table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Subject</th>
                        <th>Code</th>
                        <th>Year</th>
                        <th>Chapter</th>
                        <th>Exam Type</th>
                        <th>Useful</th>
                        <th>Difficulty Votes</th>
                        <th>Uploaded</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="tbody">
                <%
                for (Paper paper : papers) {
                    pageContext.setAttribute("paper", paper);
                    boolean alreadyMarked = votedPapers != null && votedPapers.contains(paper.getPaperId());

                    // Dominant difficulty
                    int ec = paper.getEasyCount(), mc = paper.getMediumCount(), hc = paper.getHardCount();
                    int totalVotes = ec + mc + hc;
                    String dom = "none";
                    if (totalVotes > 0) {
                        if (ec > mc && ec > hc)      dom = "easy";
                        else if (mc > ec && mc > hc) dom = "medium";
                        else if (hc > ec && hc > mc) dom = "hard";
                        else                          dom = "mixed";
                    }

                    // Bar widths (integer %)
                    int easyW = totalVotes > 0 ? (ec * 100 / totalVotes) : 0;
                    int medW  = totalVotes > 0 ? (mc * 100 / totalVotes) : 0;
                    int hardW = totalVotes > 0 ? (hc * 100 / totalVotes) : 0;

                    // File type badge
                    String fileUrl = paper.getFileUrl() != null ? paper.getFileUrl().toLowerCase() : "";
                    String ftClass = "ft-other";
                    String ftLabel = "FILE";
                    if      (fileUrl.endsWith(".pdf"))                                  { ftClass = "ft-pdf";  ftLabel = "PDF"; }
                    else if (fileUrl.endsWith(".doc") || fileUrl.endsWith(".docx"))     { ftClass = "ft-doc";  ftLabel = "DOC"; }
                    else if (fileUrl.endsWith(".ppt") || fileUrl.endsWith(".pptx"))     { ftClass = "ft-ppt";  ftLabel = "PPT"; }
                    else if (fileUrl.endsWith(".jpg") || fileUrl.endsWith(".jpeg") || fileUrl.endsWith(".png")) { ftClass = "ft-img"; ftLabel = "IMG"; }
                    else if (fileUrl.endsWith(".mp4") || fileUrl.endsWith(".mkv"))      { ftClass = "ft-vid";  ftLabel = "VID"; }
                    else if (fileUrl.endsWith(".txt"))                                  { ftClass = "ft-txt";  ftLabel = "TXT"; }

                    String uploadedDate = paper.getCreatedAt() != null ? paper.getCreatedAt().format(dtf) : "-";
                    String examType = paper.getExamType();
                %>
                <tr data-subject="<%= paper.getSubjectName().toLowerCase() %>"
                    data-code="<%= paper.getSubjectCode().toLowerCase() %>"
                    data-year="<%= paper.getYear() %>"
                    data-subj="<%= paper.getSubjectName().toLowerCase() %>"
                    data-yr="<%= paper.getYear() %>"
                    data-diff="<%= dom %>"
                    data-exam="<%= examType != null ? examType.toLowerCase() : "" %>">
                    <td class="td-subject">
                        <span class="ft-badge <%= ftClass %>"><%= ftLabel %></span><%= paper.getSubjectName() %>
                        <% if (paper.isPopular()) { %>
                            <span class="pop-badge"><i class="ti ti-flame" style="color:#ea580c;font-size:11px"></i> Popular</span>
                        <% } %>
                        <% if (paper.getDescription() != null && !paper.getDescription().isEmpty()) { %>
                            <div style="font-size:11px;color:#64748b;margin-top:3px;font-style:italic"><<%= paper.getDescription() %></div>
                        <% } %>
                    </td>
                    <td><span class="code-pill"><%= paper.getSubjectCode() %></span></td>
                    <td><span class="year-pill"><%= paper.getYear() %></span></td>
                    <td><%= paper.getChapter() != null ? paper.getChapter() : "-" %></td>
                    <td>
                        <% if (examType != null && !examType.isEmpty()) {
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
                    <td><span class="useful-num useful-count"><%= paper.getUsefulCount() %></span></td>
                    <td>
                        <span style="font-size:12px;color:#16a34a;font-weight:600">Easy (<%= ec %>)</span>
                        <span style="color:#d1d5db;margin:0 4px">|</span>
                        <span style="font-size:12px;color:#d97706;font-weight:600">Med (<%= mc %>)</span>
                        <span style="color:#d1d5db;margin:0 4px">|</span>
                        <span style="font-size:12px;color:#dc2626;font-weight:600">Hard (<%= hc %>)</span>
                    </td>
                    <td class="date-cell" style="color:#8a95a3;font-size:12px;"><%= uploadedDate %></td>
                    <td>
                        <div style="display:flex;align-items:center;gap:6px;flex-wrap:nowrap;margin-bottom:5px">
                            <a href="${pageContext.request.contextPath}/viewFile?paperId=<%= paper.getPaperId() %>"
                               target="_blank" class="act-btn act-view">
                                <i class="fa-regular fa-eye"></i> View
                            </a>
                            <a href="${pageContext.request.contextPath}/downloadPaper?paperId=<%= paper.getPaperId() %>"
                               class="act-btn act-download">
                                <i class="fa-solid fa-download"></i> Download
                            </a>
                            <button type="button"
                                    class="act-btn <%= alreadyMarked ? "act-marked" : "act-vote" %>"
                                    onclick="toggleUseful(this, <%= paper.getPaperId() %>)"
                                    style="color:<%= alreadyMarked ? "#2563eb" : "#6c757d" %>"
                                    title="<%= alreadyMarked ? "Unmark" : "Mark as Useful" %>">
                                <i class="fa-solid fa-bookmark"></i>
                                <span><%= alreadyMarked ? "Marked" : "Useful" %></span>
                                (<%= paper.getUsefulCount() %>)
                            </button>
                        </div>
                        <div style="display:flex;align-items:center;gap:6px;flex-wrap:nowrap">
                            <button type="button"
                                    class="act-btn act-easy diff-easy"
                                    onclick="rateDiff(this, 'easy', <%= paper.getPaperId() %>)">
                                Easy (<%= ec %>)
                            </button>
                            <button type="button"
                                    class="act-btn act-medium diff-med"
                                    onclick="rateDiff(this, 'medium', <%= paper.getPaperId() %>)">
                                Med (<%= mc %>)
                            </button>
                            <button type="button"
                                    class="act-btn act-hard diff-hard"
                                    onclick="rateDiff(this, 'hard', <%= paper.getPaperId() %>)">
                                Hard (<%= hc %>)
                            </button>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td colspan="9" style="padding:0;border-bottom:1px solid #e2e8f0">
                        <div style="padding:0 16px 12px">
                            <%
                                List<PaperComment> commentList = commentsMap != null ? commentsMap.get(paper.getPaperId()) : null;
                                int commentCount = commentList != null ? commentList.size() : 0;
                            %>
                            <%-- Toggle button --%>
                            <button type="button" onclick="toggleComments('comments-<%= paper.getPaperId() %>')"
                                    style="background:none;border:none;color:#64748b;font-size:12px;font-weight:500;cursor:pointer;padding:6px 0;display:flex;align-items:center;gap:6px;font-family:inherit">
                                <i class="ti ti-message-circle" style="font-size:15px;color:#64748b"></i>
                                Comments
                                <span style="background:#e5e7eb;color:#374151;border-radius:50%;min-width:20px;height:20px;padding:0 6px;font-size:10px;font-weight:600;display:inline-flex;align-items:center;justify-content:center;line-height:1"><%= commentCount %></span>
                            </button>

                            <%-- Comments section --%>
                            <div id="comments-<%= paper.getPaperId() %>" style="display:none;margin-top:8px;background:#ffffff;border:1px solid #e5e7eb;border-radius:8px;padding:12px 14px">
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
                                            <% if (loggedInUser != null && comment.getUserId() == loggedInUser.getUserId()) { %>
                                                <form action="<%= request.getContextPath() %>/paperComment" method="post" style="display:inline;margin:0">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="commentId" value="<%= comment.getCommentId() %>">
                                                    <input type="hidden" name="redirectUrl" value="<%= request.getContextPath() %>/studentAllPapers">
                                                    <button type="submit" style="background:none;border:none;color:#ef4444;cursor:pointer;font-size:11px;padding:0">
                                                        <i class="fas fa-trash"></i>
                                                    </button>
                                                </form>
                                            <% } %>
                                        </div>
                                        <% if (comment.getReplies() != null && !comment.getReplies().isEmpty()) { %>
                                            <div style="margin-left:38px;padding-left:0;margin-top:4px">
                                                <% for (PaperComment reply : comment.getReplies()) {
                                                    String replyInitial = reply.getUsername() != null && reply.getUsername().length() >= 2
                                                        ? reply.getUsername().substring(0, 2).toUpperCase()
                                                        : "U";
                                                %>
                                                    <div style="display:flex;align-items:flex-start;gap:8px;padding:8px 0">
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
                                                        <% if (loggedInUser != null && reply.getUserId() == loggedInUser.getUserId()) { %>
                                                            <form action="<%= request.getContextPath() %>/paperComment" method="post" style="display:inline;margin:0">
                                                                <input type="hidden" name="action" value="delete">
                                                                <input type="hidden" name="commentId" value="<%= reply.getCommentId() %>">
                                                                <input type="hidden" name="redirectUrl" value="<%= request.getContextPath() %>/studentAllPapers">
                                                                <button type="submit" style="background:none;border:none;color:#ef4444;cursor:pointer;font-size:10px;padding:0">
                                                                    <i class="fas fa-trash"></i>
                                                                </button>
                                                            </form>
                                                        <% } %>
                                                    </div>
                                                <% } %>
                                            </div>
                                        <% } %>
                                        <button type="button" onclick="toggleReplyForm('reply-<%= comment.getCommentId() %>')"
                                                style="background:none;border:none;color:#6b7280;font-size:11px;cursor:pointer;margin-left:38px;margin-top:2px;display:inline-flex;align-items:center;gap:4px;padding:2px 0;font-family:inherit">
                                            <i class="ti ti-arrow-back-up" style="font-size:12px"></i> Reply
                                        </button>
                                        <div id="reply-<%= comment.getCommentId() %>" style="display:none;margin-left:32px;margin-top:6px">
                                            <form action="<%= request.getContextPath() %>/paperComment" method="post" style="display:flex;gap:6px;align-items:center">
                                                <input type="hidden" name="action" value="add">
                                                <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                                <input type="hidden" name="parentCommentId" value="<%= comment.getCommentId() %>">
                                                <input type="hidden" name="redirectUrl" value="<%= request.getContextPath() %>/studentAllPapers">
                                                <input type="text" name="commentText" placeholder="Write a reply..." maxlength="200" required
                                                       style="flex:1;padding:6px 10px;border:1.5px solid #e2e8f0;border-radius:7px;font-size:12px;font-family:inherit;outline:none;background:#f8fafc">
                                                <button type="submit"
                                                        style="background:#0f1b2d;color:#fff;border:none;border-radius:7px;padding:6px 12px;font-size:11.5px;font-weight:600;cursor:pointer;font-family:inherit;white-space:nowrap">
                                                    Post Reply
                                                </button>
                                            </form>
                                        </div>
                                <%  }
                                } else { %>
                                    <div style="font-size:12px;color:#94a3b8;font-style:italic;padding:4px 0">
                                        No comments yet. Be the first to comment!
                                    </div>
                                <% } %>

                                <%-- Add comment form --%>
                                <form action="<%= request.getContextPath() %>/paperComment" method="post" style="display:flex;gap:8px;margin-top:10px;align-items:center">
                                    <input type="hidden" name="action" value="add">
                                    <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                    <input type="hidden" name="redirectUrl" value="<%= request.getContextPath() %>/studentAllPapers">
                                    <input type="text" name="commentText" placeholder="Add a comment..." maxlength="300" required style="flex:1;padding:7px 12px;border:1.5px solid #e2e8f0;border-radius:7px;font-size:12.5px;font-family:inherit;outline:none;background:#f8fafc">
                                    <button type="submit" style="background:#0f1b2d;color:#fff;border:none;border-radius:7px;padding:7px 14px;font-size:12px;font-weight:600;cursor:pointer;font-family:inherit">
                                        Post
                                    </button>
                                </form>
                            </div>
                        </div>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
            </div>
            <% } %>
        </div><!-- /table-card -->

    </div><!-- /content -->
</div><!-- /main -->

<!-- TOAST -->
<script>
    function toggleComments(id) {
        const el = document.getElementById(id);
        if (!el) return;
        const currentScroll = window.scrollY;
        el.style.display = (el.style.display === 'none') ? 'block' : 'none';
        window.scrollTo(0, currentScroll);
    }

    const contextPath = '<%= request.getContextPath() %>';

    function filterTable() {
        const searchInput = document.getElementById('srch');
        const yearFilter = document.getElementById('yrF');
        const diffFilter = document.getElementById('diffF');
        const examFilter = document.getElementById('examF');
        const q = searchInput ? searchInput.value.toLowerCase().trim() : '';
        const yr = yearFilter ? yearFilter.value : '';
        const diff = diffFilter ? diffFilter.value.toLowerCase() : '';
        const exam = examFilter ? examFilter.value.toLowerCase().trim() : '';
        document.querySelectorAll('#tbody tr[data-subj]').forEach(function (r) {
            const text = r.textContent.toLowerCase();
            const rowYear = String(r.dataset.yr || '').toLowerCase();
            const rowDiff = (r.dataset.diff || '').toLowerCase();
            const rowExam = (r.dataset.exam || '').toLowerCase();
            const matchSearch = !q || text.includes(q);
            const matchYear = !yr || rowYear === String(yr).toLowerCase();
            const matchDiff = !diff || rowDiff === diff;
            const matchExam = !exam || rowExam === exam;
            const match = matchSearch && matchYear && matchDiff && matchExam;
            r.style.display = match ? '' : 'none';
            if (r.nextElementSibling) {
                r.nextElementSibling.style.display = match ? '' : 'none';
            }
        });
    }
    function filterRows() { filterTable(); }
    document.addEventListener('DOMContentLoaded', function () {
        ['srch', 'yrF', 'diffF', 'examF'].forEach(function (id) {
            const el = document.getElementById(id);
            if (el) {
                el.addEventListener('input', filterTable);
                el.addEventListener('change', filterTable);
            }
        });
        filterTable();
    });

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

    function rateDiff(btn, difficulty, paperId) {
        fetch(contextPath + '/student/rateDifficulty', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Accept': 'application/json'
            },
            body: 'paperId=' + paperId + '&difficulty=' + difficulty
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                const row = btn.closest('tr') || btn.closest('.paper-row');
                const easyBtn = row.querySelector('.diff-easy');
                const medBtn  = row.querySelector('.diff-med');
                const hardBtn = row.querySelector('.diff-hard');
                if (easyBtn) easyBtn.textContent = 'Easy (' + data.easy + ')';
                if (medBtn)  medBtn.textContent  = 'Med ('  + data.medium + ')';
                if (hardBtn) hardBtn.textContent = 'Hard (' + data.hard + ')';
                [easyBtn, medBtn, hardBtn].forEach(function(b) { if (b) b.classList.remove('selected-diff'); });
                btn.classList.add('selected-diff');
                showToast('Difficulty vote saved!', 'success');
            }
        })
        .catch(function(e) { console.error('Diff vote failed:', e); });
    }

    function toggleUseful(btn, paperId) {
        fetch(contextPath + '/student/markUseful', {
            method: 'POST',
            headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: 'paperId=' + paperId
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                if (data.marked) {
                    btn.innerHTML = '<i class="fa-solid fa-bookmark" style="color:#2563eb"></i><span>Marked</span> (' + data.count + ')';
                    btn.className = 'act-btn act-marked';
                } else {
                    btn.innerHTML = '<i class="fa-solid fa-bookmark" style="color:#6c757d"></i><span>Useful</span> (' + data.count + ')';
                    btn.className = 'act-btn act-vote';
                }
                const row = btn.closest('tr') || btn.closest('.paper-row');
                const usefulCell = row ? row.querySelector('.useful-count') : null;
                if (usefulCell) usefulCell.textContent = data.count;
                showToast(data.marked ? 'Marked as useful!' : 'Removed from useful!', data.marked ? 'success' : 'info');
            }
        })
        .catch(function(e) { console.error('Useful toggle failed:', e); });
    }

    window.addEventListener('load', function () {
        // Dynamic date chip
        const d    = new Date();
        const opts = { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' };
        const el   = document.getElementById('pageDate');
        if (el) { el.textContent = d.toLocaleDateString('en-GB', opts); }
    });
</script>
<div id="pwToast"><i class="ti ti-circle-check"></i><span id="pwToastMsg"></span></div>

<div class="pw-toast-container" id="pwToastContainer"></div>
<script>
function showSimpleToast(msg) {
  const t = document.getElementById('pwToast');
  const m = document.getElementById('pwToastMsg');
  if (!t || !m) return false;
  m.textContent = msg;
  t.style.opacity = '1';
  t.style.transform = 'translateX(-50%) translateY(0)';
  setTimeout(function() {
    t.style.opacity = '0';
    t.style.transform = 'translateX(-50%) translateY(30px)';
  }, 3000);
  return true;
}

function showToast(message, type, duration) {
  if (arguments.length === 1 && showSimpleToast(message)) {
    return;
  }
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

  if (p.get('voted') === 'true' || p.get('rated') === 'true') {
    showToast('Difficulty vote saved!', 'success');
    return;
  }
  if (p.get('marked') === 'true') {
    showToast('Marked as useful!', 'success');
    return;
  }
  if (p.get('unmarked') === 'true') {
    showToast('Removed from useful marks.', 'info');
    return;
  }
  if (p.get('commented') === 'true') {
    showToast('Comment posted!', 'success');
    return;
  }
  if (p.get('comment_deleted') === 'true') {
    showToast('Comment deleted.', 'info');
    return;
  }

  const messages = {
    'uploaded':        ['Paper uploaded successfully!',    'success'],
    'updated':         ['Paper updated successfully!',     'success'],
    'deleted':         ['Paper deleted successfully!',     'success'],
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
