<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.PaperRequest" %>
<%@ page import="java.time.Year" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"student".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<PaperRequest> myRequests = (List<PaperRequest>) request.getAttribute("myRequests");

    String subjectName = (String) request.getAttribute("subjectName");
    String subjectCode = (String) request.getAttribute("subjectCode");
    String yearStr = (String) request.getAttribute("year");
    String description = (String) request.getAttribute("description");

    int currentYear = Year.now().getValue();
    int minYear = currentYear - 20;

    int totalRequests = request.getAttribute("totalRequests") != null
        ? ((Number) request.getAttribute("totalRequests")).intValue()
        : (myRequests != null ? myRequests.size() : 0);
    int pendingCount = request.getAttribute("pendingCount") != null
        ? ((Number) request.getAttribute("pendingCount")).intValue()
        : 0;
    int completedCount = request.getAttribute("completedCount") != null
        ? ((Number) request.getAttribute("completedCount")).intValue()
        : 0;

    if (request.getAttribute("pendingCount") == null && myRequests != null) {
        for (PaperRequest req : myRequests) {
            if ("pending".equalsIgnoreCase(req.getStatus())) {
                pendingCount++;
            }
            if ("completed".equalsIgnoreCase(req.getStatus())) {
                completedCount++;
            }
        }
    }

    String username = loggedInUser.getUsername();
    String initials = username.length() >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();

    DateTimeFormatter reqDtf = DateTimeFormatter.ofPattern("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Paper Requests - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/paperwise.css">
        <script>
        (function(){var t=localStorage.getItem('pw-theme')||'light';document.documentElement.setAttribute('data-theme',t);})();
    </script>
<script src="${pageContext.request.contextPath}/js/paperwise.js" defer></script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/tabler-icons/css/tabler-icons.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <style>
        :root {
            --bg-body: #f7f9fc;
            --bg-card: #ffffff;
            --bg-sidebar: #0f2744;
            --text-primary: #0d1b2a;
            --text-secondary: #4f7396;
            --text-muted: #6b7280;
            --border-color: #e8edf2;
            --border-faint: #f0f4f8;
            --table-th-bg: #f8fafc;
            --table-td-text: #1f2937;
            --table-hover-bg: #f0f7ff;
            --btn-bg: #f0f4f8;
            --input-bg: #f9fafb;
            --input-focus-bg: #ffffff;
            --input-border: #e5e7eb;
        }

        [data-theme="dark"] {
            --bg-body: #0f172a;
            --bg-card: #1e293b;
            --bg-card-hover: #263348;
            --bg-input: #1e293b;
            --bg-table-head: #1a2744;
            --bg-row-hover: #1e2d44;
            --text-primary: #f1f5f9;
            --text-secondary: #94a3b8;
            --text-muted: #64748b;
            --text-heading: #e2e8f0;
            --border-color: #334155;
            --border-light: #1e293b;
            --bg-sidebar: #0a1628;
            --topbar-bg: #111827;
            --topbar-border: #1e293b;
            --table-th-bg: #1a2744;
            --table-td-text: #f1f5f9;
            --table-hover-bg: #1e2d44;
            --btn-bg: #1e293b;
            --input-bg: #1e293b;
            --input-focus-bg: #0f172a;
            --input-border: #334155;
            --border-faint: #1e293b;
        }

        [data-theme="dark"] .status-pill,
        [data-theme="dark"] .code-pill {
            opacity: 0.9;
        }

        [data-theme="dark"] .code-pill {
            background: #1e3a5f;
            color: #93c5fd;
            border-color: #1e40af;
        }

        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: var(--bg-body);
            min-height: 100vh;
            display: flex;
            transition: background 0.3s;
        }

        .sb, .sidebar {
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
            transition: background 0.3s;
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
        .logo-text .app-sub { font-size: 10px; color: rgba(255,255,255,0.4); }
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
            transition: background 0.15s, color 0.15s;
            letter-spacing: 0.01em;
        }
        .nav-item i { font-size: 13px; margin: 0; width: 16px; text-align: center; flex-shrink: 0; }
        .nav-item:hover { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.85); }
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

        .main {
            margin-left: 220px;
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            min-width: 0;
        }
        .topbar {
            background: var(--bg-card); height: 56px; padding: 0 24px;
            display: flex; align-items: center; justify-content: space-between;
            border-bottom: 1px solid var(--border-color); flex-shrink: 0;
            transition: background 0.3s, border-color 0.3s;
        }
        .topbar-title { font-size: 16px; font-weight: 600; color: var(--text-primary); letter-spacing: -0.3px; }
        .topbar-subtitle { font-size: 12.5px; color: var(--text-secondary); margin-top: 1px; }
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

        .alert-success {
            background: #f0fff4; border: 1px solid #9ae6b4; color: #276749;
            border-radius: 8px; padding: 10px 14px; margin-bottom: 16px;
            font-size: 13px; display: flex; align-items: center; gap: 8px;
        }
        .alert-error,
        .error-message {
            background: #fff0f0; border: 1px solid #f5c6cb; color: #c0392b;
            border-radius: 8px; padding: 10px 14px; margin-bottom: 16px;
            font-size: 13px; display: flex; align-items: center; gap: 8px;
        }

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
        .stat-body .stat-num { font-size: 26px; font-weight: 700; color: var(--text-primary); line-height: 1.1; letter-spacing: -0.5px; }
        .stat-body .stat-label { font-size: 12.5px; color: var(--text-muted); margin-top: 2px; letter-spacing: 0.01em; }

        .two-col {
            display: grid;
            grid-template-columns: 1fr 1.3fr;
            gap: 1.2rem;
            align-items: flex-start;
        }
        .section-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
            overflow: hidden;
            margin-bottom: 20px;
            transition: background 0.3s, border-color 0.3s;
        }
        .section-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 1.1rem 1.4rem; border-bottom: 1px solid var(--border-color);
            transition: border-color 0.3s; gap: 10px;
        }
        .section-header-left { display: flex; align-items: center; gap: 8px; }
        .section-title { font-size: 14px; font-weight: 600; color: var(--text-primary); }
        .count-pill {
            font-size: 11px; padding: 3px 9px; border-radius: 20px; font-weight: 500;
            background: #dbeafe; color: #1e40af;
        }
        .section-body { padding: 1.2rem; }

        label {
            display: block;
            margin-bottom: 6px;
            color: var(--text-primary);
            font-size: 12.5px;
            font-weight: 600;
            transition: color 0.3s;
        }
        .form-group { margin-bottom: 14px; }
        .req { color: #ef4444; }
        .opt-lbl { font-size: 11px; color: var(--text-secondary); background: var(--btn-bg); border-radius: 4px; padding: 1px 6px; }
        input,
        select,
        textarea {
            border: 1.5px solid #e2e8f0;
            border-radius: 7px;
            padding: 9px 12px;
            font-size: 13px;
            background: #f8fafc;
            width: 100%;
            color: var(--text-primary);
            font-family: inherit;
            outline: none;
        }
        input:focus,
        select:focus,
        textarea:focus {
            border-color: #3b82f6;
            background: var(--input-focus-bg);
            box-shadow: 0 0 0 3px rgba(59,130,246,.12);
        }
        textarea { resize: vertical; min-height: 86px; }
        .hint { font-size: 11px; color: var(--text-muted); margin-top: 2px; display: block; }
        .actions { display: flex; gap: 10px; margin-top: 14px; }
        .btn-submit {
            background: #0f1b2d;
            color: #fff;
            border: none;
            border-radius: 7px;
            padding: 10px 0;
            width: 100%;
            font-weight: 600;
            font-size: 13px;
            font-family: inherit;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 7px;
        }
        .btn-cancel {
            border: 1.5px solid #e2e8f0;
            background: #fff;
            color: #64748b;
            border-radius: 7px;
            padding: 10px 14px;
            font-size: 13px;
            font-weight: 600;
            font-family: inherit;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            text-decoration: none;
        }

        .data-table-container {
            width: 100%;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table thead tr { background: var(--table-th-bg); }
        .data-table th {
            font-size: 11px; color: var(--text-muted); text-transform: uppercase;
            letter-spacing: 0.06em; padding: .8rem 1.1rem; text-align: left;
            border-bottom: 1px solid var(--border-color); font-weight: 600;
            white-space: nowrap;
        }
        .data-table td {
            padding: 1rem 1.1rem; border-bottom: 1px solid var(--border-color);
            font-size: 13.5px; color: var(--table-td-text); line-height: 1.5;
            transition: background 0.3s; vertical-align: middle;
        }
        .data-table tbody tr:last-child td { border-bottom: none; }
        .data-table tbody tr:hover td { background: var(--table-hover-bg); }
        .td-subject { font-weight: 600; color: var(--text-primary); }
        .code-pill {
            background: #dbeafe;
            color: #1d4ed8;
            font-size: 11px;
            border-radius: 6px;
            padding: 3px 8px;
            font-weight: 500;
            display: inline-block;
        }
        .year-val { color: #c2410c; font-weight: 600; }
        .desc-cell {
            color: var(--text-muted);
            font-size: 12.5px;
            max-width: 160px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            display: inline-block;
        }
        .date-cell { font-size: 11.5px; color: var(--text-muted); white-space: nowrap; }
        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            border-radius: 20px;
            padding: 3px 10px;
            font-size: 11.5px;
            font-weight: 600;
        }
        .status-pill i { font-size: 12px; margin: 0; }
        .s-pending { background: #fef9c3; color: #92400e; }
        .s-completed { background: #e8f5e9; color: #1b5e20; }
        .s-rejected { background: #fee2e2; color: #991b1b; }
        .btn-delete {
            background: #fee2e2;
            color: #991b1b;
            border: none;
            border-radius: 6px;
            padding: 6px 10px;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 12px;
            font-weight: 600;
            font-family: inherit;
            cursor: pointer;
        }
        .empty-state { text-align: center; padding: 48px 20px; color: var(--text-muted); }
        .empty-state i { font-size: 36px; margin: 0 0 10px; display: block; color: var(--border-color); }
        .empty-state p { font-size: 13px; color: var(--text-primary); font-weight: 600; margin-bottom: 3px; }
        .empty-state span { font-size: 12px; color: var(--text-muted); }

        .pw-toast {
            background: #dcfce7;
            border: 1px solid #16a34a;
            color: #15803d;
            border-radius: 9px;
            padding: 9px 14px;
            font-size: 12.5px;
            font-weight: 500;
            display: none;
            align-items: center;
            gap: 6px;
            margin-bottom: 14px;
        }
        .pw-toast.show { display: flex; }

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

        [data-theme="dark"] .section-card,
        [data-theme="dark"] .section-header {
            background: var(--bg-card);
            border-color: var(--border-color);
        }
        [data-theme="dark"] .btn-cancel {
            background: var(--input-bg);
            color: #94a3b8;
            border-color: var(--input-border);
        }
        [data-theme="dark"] input,
        [data-theme="dark"] select,
        [data-theme="dark"] textarea {
            background: var(--input-bg);
            border-color: var(--input-border);
            color: #e2e8f0;
        }

        @media (max-width: 768px) {
            body { flex-direction: column; }
            .sidebar {
                position: fixed;
                left: -220px;
                top: 0;
                bottom: 0;
                z-index: 9999;
                box-shadow: 4px 0 15px rgba(0, 0, 0, 0.25);
                transition: left 0.3s ease;
            }
            .sidebar.open { left: 0; }
            .main { margin-left: 0; }
            .topbar { padding: 0 16px; }
            .menu-toggle { display: block !important; }
            .stats-grid { grid-template-columns: 1fr; }
            .two-col { grid-template-columns: 1fr; }
            .content { padding: 16px; }
            .actions { flex-direction: column-reverse; }
            .topbar-subtitle { display: none; }
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
        <a href="${pageContext.request.contextPath}/studentAllPapers" class="nav-item">
            <i class="ti ti-files"></i> All Papers
        </a>
        <a href="${pageContext.request.contextPath}/myMarked" class="nav-item">
            <i class="fa-solid fa-bookmark"></i> My Marked
        </a>
    </div>

    <div class="nav-section">
        <p class="nav-label">REQUESTS</p>
        <a href="${pageContext.request.contextPath}/requestPaper" class="nav-item active">
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

<div class="main">
    <div class="topbar">
        <div style="display:flex; align-items:center; gap:12px;">
            <button class="menu-toggle" onclick="toggleSidebar()"><i class="fa-solid fa-bars"></i></button>
            <div>
                <div class="topbar-title">My Paper Requests</div>
                <div class="topbar-subtitle">Submit a request and track your status</div>
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
                <i class="fa-regular fa-bell"></i>
            </button>
        </div>
    </div>

    <div class="content">
        

        

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon" style="background:#dbeafe;color:#2563eb;"><i class="fa-solid fa-paper-plane"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalRequests %></div>
                    <div class="stat-label">Total Requests</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background:#fef9c3;color:#ca8a04;"><i class="fa-solid fa-clock"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= pendingCount %></div>
                    <div class="stat-label">Pending</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background:#dcfce7;color:#16a34a;"><i class="fa-solid fa-check-circle"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= completedCount %></div>
                    <div class="stat-label">Completed</div>
                </div>
            </div>
        </div>

        <div class="two-col">
            <div class="section-card">
                <div class="section-header">
                    <div class="section-header-left">
                        <i class="fa-solid fa-plus-circle" style="color:#2563eb;"></i>
                        <span class="section-title">New Request</span>
                    </div>
                </div>
                <div class="section-body">
                    <form action="${pageContext.request.contextPath}/requestPaper" method="post">
                        <div class="form-group">
                            <label>Subject Name <span class="req">*</span></label>
                            <input type="text" name="subject_name"
                                   placeholder="e.g., Data Structures and Algorithms"
                                   value="<%= subjectName != null ? subjectName : "" %>"
                                   required>
                        </div>

                        <div class="form-group">
                            <label>Subject Code <span class="req">*</span></label>
                            <input type="text" name="subject_code"
                                   placeholder="e.g., CS201, MATH201"
                                   value="<%= subjectCode != null ? subjectCode : "" %>"
                                   required>
                        </div>

                        <div class="form-group">
                            <label>Year <span class="req">*</span></label>
                            <select name="year" required>
                                <% for (int y = currentYear; y >= minYear; y--) {
                                       String selected = (yearStr != null && yearStr.equals(String.valueOf(y))) ? "selected" : ""; %>
                                    <option value="<%= y %>" <%= selected %>><%= y %></option>
                                <% } %>
                            </select>
                            <span class="hint">Valid range: <%= minYear %> - <%= currentYear %></span>
                        </div>

                        <div class="form-group">
                            <label>Description <span class="opt-lbl">optional</span></label>
                            <textarea name="description"
                                      placeholder="Any additional details... e.g., sessional 1 only"><%= description != null ? description : "" %></textarea>
                        </div>

                        <div class="actions">
                            <a href="${pageContext.request.contextPath}/studentDashboard" class="btn-cancel">
                                <i class="fa-solid fa-xmark"></i> Cancel
                            </a>
                            <button type="submit" class="btn-submit">
                                <i class="fa-solid fa-paper-plane"></i> Submit Request
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="section-card">
                <div class="section-header">
                    <div class="section-header-left">
                        <i class="fa-solid fa-list" style="color:#2563eb;"></i>
                        <span class="section-title">My Requests</span>
                        <span class="count-pill"><%= totalRequests %></span>
                    </div>
                </div>

                <% if (myRequests == null || myRequests.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fa-solid fa-inbox"></i>
                        <p>No requests yet.</p>
                        <span>Submit your first request using the form.</span>
                    </div>
                <% } else { %>
                    <div style="overflow-x:auto">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Subject</th>
                                    <th>Code</th>
                                    <th>Year</th>
                                    <th>Description</th>
                                    <th>Status</th>
                                    <th>ADMIN MESSAGE</th>
                                    <th>Requested At</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% for (PaperRequest req : myRequests) {
                                String status = req.getStatus() != null ? req.getStatus().toLowerCase() : "pending";
                                if ("approved".equals(status) || "accepted".equals(status)) {
                                    status = "completed";
                                }
                                String statusClass = "s-pending";
                                String statusIcon = "fa-clock";
                                String statusLabel = "Pending";
                                if ("completed".equals(status)) {
                                    statusClass = "s-completed";
                                    statusIcon = "fa-circle-check";
                                    statusLabel = "Completed";
                                } else if ("rejected".equals(status)) {
                                    statusClass = "s-rejected";
                                    statusIcon = "fa-times-circle";
                                    statusLabel = "Rejected";
                                }

                                String dateStr = req.getCreatedAt() != null ? req.getCreatedAt().format(reqDtf) : "-";
                                String descStr = req.getDescription() != null ? req.getDescription() : "";
                            %>
                                <tr>
                                    <td><span class="td-subject"><%= req.getSubjectName() %></span></td>
                                    <td><span class="code-pill"><%= req.getSubjectCode() %></span></td>
                                    <td><span class="year-val"><%= req.getYear() %></span></td>
                                    <td><span class="desc-cell" title="<%= descStr %>"><%= descStr.isEmpty() ? "-" : descStr %></span></td>
                                    <td>
                                        <span class="status-pill <%= statusClass %>">
                                            <i class="fa-solid <%= statusIcon %>"></i> <%= statusLabel %>
                                        </span>
                                    </td>
                                    <td style="max-width:200px">
                                        <% if (req.getAdminMessage() != null && !req.getAdminMessage().isEmpty()) { %>
                                        <div style="background:#eff6ff;border:1px solid #bfdbfe;border-radius:7px;padding:7px 10px;font-size:12px;color:#1e40af;line-height:1.4">
                                            <div style="display:flex;align-items:center;gap:5px;margin-bottom:3px">
                                                <i class="fas fa-comment-dots" style="font-size:11px;color:#3b82f6"></i>
                                                <span style="font-size:10.5px;font-weight:600;color:#1d4ed8">Admin</span>
                                                <% if (req.getAdminMessageUpdatedAt() != null && !req.getAdminMessageUpdatedAt().isEmpty()) { %>
                                                <span style="font-size:10px;color:#93c5fd">· <%= req.getAdminMessageUpdatedAt() %></span>
                                                <% } %>
                                            </div>
                                            <div style="color:#1e3a8a"><%= req.getAdminMessage() %></div>
                                        </div>
                                        <% } else { %>
                                        <span style="color:#94a3b8;font-size:11.5px;font-style:italic">—</span>
                                        <% } %>
                                    </td>
                                    <td><span class="date-cell"><%= dateStr %></span></td>
                                    <td>
                                        <% if ("pending".equals(status) || "rejected".equals(status)) { %>
                                            <form method="post" action="${pageContext.request.contextPath}/deleteRequest"
                                                  onsubmit="return confirm('Delete this request?')" style="display:inline;">
                                                <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                                                <input type="hidden" name="redirectUrl"
                                                       value="${pageContext.request.contextPath}/requestPaper">
                                                <button type="submit" class="btn-delete">
                                                    <i class="fa-solid fa-trash"></i> Delete
                                                </button>
                                            </form>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<script>
(function() {
    const el = document.getElementById('pageDate');
    if (!el) return;
    el.textContent = new Date().toLocaleDateString('en-GB', {
        weekday: 'short', day: 'numeric', month: 'short', year: 'numeric'
    });
})();
</script>
<script>
function toggleSidebar() {
    const sb = document.querySelector('.sidebar');
    if (sb) {
        sb.classList.toggle('open');
    }
}
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

  if (p.get('request_deleted') === 'true') {
    showToast('Request deleted successfully.', 'info');
    return;
  }

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

<div id="pwToast"><i class="ti ti-circle-check"></i><span id="pwToastMsg"></span></div>
</body>
</html>
