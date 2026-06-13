<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.Paper" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"admin".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Paper> recentPapers = (List<Paper>) request.getAttribute("recentPapers");

    int pendingCount = request.getAttribute("pendingRequestsCount") != null
        ? (int) request.getAttribute("pendingRequestsCount") : 0;

    String username = loggedInUser.getUsername();
    String initials = username.length() >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();

    DateTimeFormatter uploadDtf = DateTimeFormatter.ofPattern("MMM dd, yyyy");

    String requestId   = request.getParameter("requestId");
    String subjectName = request.getParameter("subjectName");
    String subjectCode = request.getParameter("subjectCode");
    String yearParam   = request.getParameter("year");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Paper - PaperWise</title>
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
            --drop-zone-bg: #f8fafc;
            --drop-zone-hover: #eff6ff;
            --drop-zone-border: #cbd5e1;
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
            --drop-zone-bg: #1e293b;
            --drop-zone-hover: #263348;
            --drop-zone-border: #475569;
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

        .main {
            margin-left: 220px;
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            min-width: 0;
        }
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
        .topbar-title {
            font-size: 18px;
            font-weight: 700;
            letter-spacing: -0.3px;
            color: var(--text-primary);
            line-height: 1.2;
        }
        .topbar-subtitle {
            font-size: 12px;
            color: var(--text-secondary);
            margin-top: 1px;
            font-weight: 400;
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
            position: relative;
            width: 34px; height: 34px;
            background: var(--btn-bg);
            border: none;
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer;
            color: var(--text-secondary);
            transition: background 0.3s, color 0.3s;
        }
        .bell-btn i { font-size: 14px; margin: 0; }
        .bell-dot {
            position: absolute;
            top: 6px; right: 6px;
            width: 7px; height: 7px;
            background: #e53e3e;
            border-radius: 50%;
            border: 1.5px solid var(--bell-dot-border);
        }
        .content { padding: 1.6rem 2rem; flex: 1; }

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
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1.1rem 1.4rem;
            border-bottom: 1px solid var(--border-color);
        }
        .section-header-left { display: flex; align-items: center; gap: 8px; }
        .section-title { font-size: 14.5px; font-weight: 700; color: var(--text-primary); }
        .section-body { padding: 1.2rem 1.4rem; }

        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem 1.2rem; }
        .fg { display: flex; flex-direction: column; gap: 5px; margin-bottom: 0; }
        .fg.full { grid-column: 1 / -1; }
        label { font-size: 12.5px; font-weight: 600; color: var(--text-primary); display: flex; align-items: center; gap: 5px; }
        .req { color: #ef4444; }
        .opt-badge { font-size: 11px; color: var(--text-muted); font-weight: 400; background: var(--btn-bg); border-radius: 4px; padding: 1px 6px; }
        .iw { position: relative; display: flex; align-items: center; }
        .iw .fi { position: absolute; left: 11px; font-size: 16px; color: var(--text-muted); pointer-events: none; z-index: 1; }
        .iw input, .iw select { padding-left: 36px; }
        input, select, textarea {
            width: 100%;
            border: 1.5px solid var(--input-border);
            border-radius: 9px;
            padding: 9px 11px;
            font-size: 13.5px;
            color: var(--text-primary);
            background: var(--input-bg);
            font-family: inherit;
            outline: none;
            transition: border .18s, box-shadow .18s, background .18s;
        }
        input:focus, select:focus, textarea:focus {
            border-color: #3b82f6;
            background: var(--input-focus-bg);
            box-shadow: 0 0 0 3px rgba(59,130,246,.12);
        }
        select { appearance: none; cursor: pointer; padding-right: 32px; }
        .sw::after {
            content: '';
            position: absolute;
            right: 11px;
            top: 50%;
            transform: translateY(-50%);
            border: 5px solid transparent;
            border-top-color: var(--text-muted);
            pointer-events: none;
            margin-top: 3px;
        }
        .hint { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

        .info-bar {
            background: #eef6ff;
            border-left: 3px solid #3b82f6;
            border-radius: 0 8px 8px 0;
            padding: 9px 13px;
            font-size: 12.5px;
            color: #1d4ed8;
            display: flex;
            align-items: flex-start;
            gap: 8px;
            margin-bottom: 1rem;
            line-height: 1.5;
        }
        [data-theme="dark"] .info-bar {
            background: #1e3a5f;
            border-left-color: #3b82f6;
            color: #93c5fd;
        }
        .info-bar i { font-size: 16px; flex-shrink: 0; margin-top: 1px; }

        .drop-zone {
            border: 2px dashed var(--drop-zone-border);
            border-radius: 12px;
            padding: 2rem 1rem;
            text-align: center;
            cursor: pointer;
            transition: all .2s;
            background: var(--drop-zone-bg);
            position: relative;
        }
        .drop-zone:hover, .drop-zone.over {
            border-color: #3b82f6;
            background: var(--drop-zone-hover);
        }
        .drop-zone input[type=file] {
            position: absolute;
            inset: 0;
            opacity: 0;
            cursor: pointer;
            width: 100%;
            height: 100%;
            padding: 0;
            border: none;
            background: transparent;
            box-shadow: none;
        }
        .drop-icon {
            width: 52px; height: 52px;
            border-radius: 12px;
            background: #e0e7ff;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto .8rem;
        }
        [data-theme="dark"] .drop-icon { background: #1e3a5f; }
        .drop-icon i { font-size: 26px; color: #3b82f6; }
        .drop-title { font-size: 14px; font-weight: 600; color: var(--text-primary); }
        .drop-sub { font-size: 12px; color: var(--text-muted); margin-top: 3px; }
        .drop-types { display: flex; flex-wrap: wrap; justify-content: center; gap: 5px; margin-top: .9rem; }
        .type-pill {
            background: var(--btn-bg);
            color: var(--text-secondary);
            font-size: 11px;
            font-weight: 500;
            border-radius: 5px;
            padding: 2px 8px;
            border: 1px solid var(--border-color);
        }
        .file-selected {
            display: none;
            align-items: center;
            gap: 12px;
            background: #f0fdf4;
            border: 1.5px solid #16a34a;
            border-radius: 10px;
            padding: 10px 14px;
            margin-top: .8rem;
        }
        [data-theme="dark"] .file-selected { background: #132d21; border-color: #16a34a; }
        .file-selected.show { display: flex; }
        .file-icon-box {
            width: 36px; height: 36px;
            border-radius: 8px;
            background: #dcfce7;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        [data-theme="dark"] .file-icon-box { background: #163522; }
        .file-icon-box i { font-size: 20px; color: #16a34a; }
        .file-name { font-size: 13px; font-weight: 600; color: #15803d; flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        [data-theme="dark"] .file-name { color: #4ade80; }
        .file-size-txt { font-size: 11px; color: #86efac; }
        .file-remove { background: none; border: none; color: #dc2626; cursor: pointer; font-size: 18px; display: flex; align-items: center; }

        .actions { display: flex; gap: 10px; margin-top: 1.2rem; }
        .btn-upload-submit {
            flex: 1;
            background: #1a3a5c;
            color: #fff;
            border: none;
            border-radius: 8px;
            padding: 10px 16px;
            font-size: 12px;
            font-weight: 600;
            font-family: inherit;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            transition: background 0.15s;
        }
        .btn-upload-submit:hover { background: #0d2a45; }
        .btn-cancel {
            background: var(--btn-bg);
            color: var(--text-primary);
            border: 1.5px solid var(--border-color);
            border-radius: 8px;
            padding: 10px 16px;
            font-size: 12px;
            font-weight: 500;
            font-family: inherit;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            text-decoration: none;
            transition: background 0.15s;
        }
        .btn-cancel:hover { background: var(--border-color); }

        .guideline-item {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #e2e8f0;
            font-size: 12.5px;
            margin-bottom: 8px;
        }
        .guideline-item:last-child { margin-bottom: 0; }
        .guideline-item i { color: #4ade80; font-size: 11px; flex-shrink: 0; }

        .recent-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid var(--border-faint);
            gap: 10px;
        }
        .recent-row:last-child { border-bottom: none; }
        .recent-subject { font-size: 13px; font-weight: 600; color: var(--text-primary); }
        .recent-date { font-size: 11px; color: var(--text-muted); white-space: nowrap; }
        .recent-empty { font-size: 12.5px; color: var(--text-muted); font-style: italic; padding: 4px 0; }

        .menu-toggle { display: none; }

        @media (max-width: 900px) {
            .upload-two-col {
                grid-template-columns: 1fr !important;
            }
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
            }
            .sidebar.open { left: 0; }
            .main { margin-left: 0; }
            .topbar { padding: 0 16px; }
            .menu-toggle { display: block !important; }
            .content { padding: 16px; }
            .form-grid { grid-template-columns: 1fr; }
            .topbar-subtitle { display: none; }
            .actions { flex-direction: column-reverse; }
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
        <a href="${pageContext.request.contextPath}/uploadPaper" class="nav-item active">
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

<div class="main">
    <div class="topbar">
        <div style="display: flex; align-items: center; gap: 12px;">
            <button type="button" class="menu-toggle" onclick="toggleSidebar()"
                    style="background: none; border: none; font-size: 20px; cursor: pointer; color: var(--text-primary); display: none; align-items: center; justify-content: center; padding: 4px;">
                <i class="ti ti-menu-2"></i>
            </button>
            <div>
                <div class="topbar-title">Upload Paper</div>
                <div class="topbar-subtitle">Upload academic papers for students to access</div>
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
        
        

        <div class="upload-two-col" style="display:grid;grid-template-columns:1.4fr 1fr;gap:20px;align-items:start">

            <!-- LEFT: Upload form -->
            <div class="section-card" style="margin-bottom:0">
                <div class="section-header">
                    <div class="section-header-left">
                        <i class="fas fa-upload" style="color:#1d4ed8;font-size:14px"></i>
                        <span class="section-title">Upload Paper</span>
                    </div>
                </div>
                <div class="section-body">
                    <form action="${pageContext.request.contextPath}/uploadPaper"
                          method="post"
                          enctype="multipart/form-data"
                          onsubmit="return validateForm()">

                        <input type="hidden" name="requestId"
                               value="<%= requestId != null ? requestId : "" %>">

                        <% if (requestId != null && !requestId.trim().isEmpty()) { %>
                        <div style="background:#e3f2fd;border:1.5px solid #90caf9;border-radius:8px;padding:10px 16px;font-size:13px;color:#1565c0;margin-bottom:16px;display:flex;align-items:center;gap:8px">
                            <i class="fas fa-info-circle"></i>
                            Uploading paper for a student request.
                            This request will be marked as Completed after upload.
                        </div>
                        <% } %>

                        <div class="form-grid">
                            <div class="fg">
                                <label for="subjectName">Subject Name <span class="req">*</span></label>
                                <div class="iw">
                                    <i class="ti ti-book fi"></i>
                                    <input type="text" id="subjectName" name="subjectName"
                                           placeholder="e.g., Data Structures and Algorithms"
                                           value="<%= subjectName != null ? subjectName : "" %>"
                                           required maxlength="150"/>
                                </div>
                            </div>

                            <div class="fg">
                                <label for="subjectCode">Subject Code <span class="req">*</span></label>
                                <div class="iw">
                                    <i class="ti ti-hash fi"></i>
                                    <input type="text" id="subjectCode" name="subjectCode"
                                           placeholder="e.g., CS101, MATH201"
                                           value="<%= subjectCode != null ? subjectCode : "" %>"
                                           required maxlength="50"/>
                                </div>
                            </div>

                            <div class="fg">
                                <label for="year">Year <span class="req">*</span></label>
                                <div class="iw sw">
                                    <i class="ti ti-calendar fi"></i>
                                    <select id="year" name="year" required>
                                        <% for (int y = 2026; y >= 2006; y--) { %>
                                        <option value="<%= y %>"
                                            <%= (yearParam != null && yearParam.equals(String.valueOf(y))) ? "selected" : "" %>>
                                            <%= y %>
                                        </option>
                                        <% } %>
                                    </select>
                                </div>
                                <span class="hint">Valid range: 2006 – 2026</span>
                            </div>

                            <div class="fg">
                                <label for="examType">Exam Type <span class="opt-badge">optional</span></label>
                                <div class="iw">
                                    <i class="ti ti-file-description fi"></i>
                                    <input type="text" id="examType" name="examType"
                                           placeholder="e.g., Sessional 2, Mid Term, End Term, Quiz..."
                                           list="examTypeSuggestions"
                                           value="<%= request.getParameter("examType") != null ? request.getParameter("examType") : "" %>"
                                           maxlength="100"/>
                                    <datalist id="examTypeSuggestions">
                                        <option value="Sessional 1">
                                        <option value="Sessional 2">
                                        <option value="Mid Term">
                                        <option value="End Term">
                                        <option value="Quiz">
                                        <option value="Assignment">
                                    </datalist>
                                </div>
                                <span class="hint">Type any exam name — suggestions shown as you type</span>
                            </div>

                            <div class="fg full">
                                <label for="chapter">Chapter <span class="opt-badge">optional</span></label>
                                <div class="iw">
                                    <i class="ti ti-list fi"></i>
                                    <input type="text" id="chapter" name="chapter"
                                           placeholder="e.g., ch 4, ch 5, ch 6"
                                           value="<%= request.getParameter("chapter") != null ? request.getParameter("chapter") : "" %>"
                                           maxlength="100"/>
                                </div>
                                <span class="hint">Comma separated — e.g., ch 4, ch 5</span>
                            </div>

                            <div class="fg full">
                                <label for="description">Description <span class="opt-badge">optional</span></label>
                                <div class="iw" style="align-items:flex-start">
                                    <i class="ti ti-notes fi" style="position:absolute;left:11px;top:11px;font-size:16px;color:var(--text-muted);z-index:1"></i>
                                    <textarea id="description" name="description"
                                              placeholder="Describe what this paper covers, which exam it is from, any notes for students..."
                                              style="padding:9px 11px 9px 36px;min-height:80px;resize:vertical;width:100%"
                                              maxlength="1000"><%= request.getParameter("description") != null ? request.getParameter("description") : "" %></textarea>
                                </div>
                                <span class="hint">Students will see this when browsing papers</span>
                            </div>
                        </div>

                        <div class="fg full" style="margin-top:1rem">
                            <label>Upload File <span class="req">*</span></label>
                            <div class="drop-zone" id="dropZone">
                                <input type="file" id="fileIn" name="file"
                                       accept=".pdf,.doc,.docx,.ppt,.pptx,.txt,.jpg,.png,.mp4,.mkv"
                                       onchange="onFileSelect(this)">
                                <div class="drop-icon"><i class="ti ti-cloud-upload"></i></div>
                                <div class="drop-title">Click to select a file</div>
                                <div class="drop-sub">or drag and drop here</div>
                                <div class="drop-types">
                                    <span class="type-pill">PDF</span>
                                    <span class="type-pill">DOC</span>
                                    <span class="type-pill">DOCX</span>
                                    <span class="type-pill">PPT</span>
                                    <span class="type-pill">PPTX</span>
                                    <span class="type-pill">TXT</span>
                                    <span class="type-pill">JPG</span>
                                    <span class="type-pill">PNG</span>
                                    <span class="type-pill">MP4</span>
                                    <span class="type-pill">MKV</span>
                                </div>
                            </div>
                            <div class="file-selected" id="fileInfo">
                                <div class="file-icon-box"><i class="ti ti-file-check"></i></div>
                                <div style="flex:1;min-width:0">
                                    <div class="file-name" id="fileName">filename.pdf</div>
                                    <div class="file-size-txt" id="fileSize">0 KB</div>
                                </div>
                                <button class="file-remove" type="button" onclick="clearFile()">
                                    <i class="ti ti-x"></i>
                                </button>
                            </div>
                        </div>

                        <div class="actions">
                            <a href="${pageContext.request.contextPath}/adminDashboard" class="btn-cancel">
                                <i class="ti ti-x"></i> Cancel
                            </a>
                            <button type="submit" class="btn-upload-submit">
                                <i class="ti ti-upload"></i> Upload Paper
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- RIGHT: Guidelines + Recent -->
            <div>
                <div class="section-card">
                    <div class="section-header">
                        <div class="section-header-left">
                            <i class="fas fa-info-circle" style="color:#1d4ed8;font-size:14px"></i>
                            <span class="section-title">Upload Guidelines</span>
                        </div>
                    </div>
                    <div class="section-body">
                        <div class="info-bar">
                            <i class="ti ti-info-circle"></i>
                            <span>Allowed file types: <strong>PDF, DOC, DOCX, PPT, PPTX, TXT, JPG, PNG, MP4, MKV</strong>&nbsp;·&nbsp; Max size: <strong>200MB</strong></span>
                        </div>

                        <div style="font-size:12.5px;color:var(--text-secondary);margin-bottom:14px">
                            Follow these guidelines when uploading papers to ensure students can access them properly.
                        </div>

                        <div style="background:#0f1b2d;border-radius:10px;padding:16px 18px">
                            <div class="guideline-item"><i class="fas fa-check"></i> Use clear subject names</div>
                            <div class="guideline-item"><i class="fas fa-check"></i> Enter the correct subject code</div>
                            <div class="guideline-item"><i class="fas fa-check"></i> Select the right exam type</div>
                            <div class="guideline-item"><i class="fas fa-check"></i> PDF format is recommended</div>
                            <div class="guideline-item"><i class="fas fa-check"></i> Max file size is 200MB</div>
                            <div class="guideline-item"><i class="fas fa-check"></i> Add description to help students</div>
                        </div>
                    </div>
                </div>

                <div class="section-card">
                    <div class="section-header">
                        <div class="section-header-left">
                            <i class="fas fa-clock" style="color:#1d4ed8;font-size:14px"></i>
                            <span class="section-title">Recent Uploads</span>
                        </div>
                    </div>
                    <div class="section-body">
                        <% if (recentPapers != null && !recentPapers.isEmpty()) {
                               for (Paper p : recentPapers) {
                                   String uploadedOn = p.getCreatedAt() != null
                                       ? p.getCreatedAt().format(uploadDtf) : "—";
                        %>
                            <div class="recent-row">
                                <span class="recent-subject"><%= p.getSubjectName() %></span>
                                <span class="recent-date"><%= uploadedOn %></span>
                            </div>
                        <%   }
                           } else { %>
                            <p class="recent-empty">No papers uploaded yet.</p>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function onFileSelect(input) {
        const f = input.files[0];
        if (!f) return;
        document.getElementById('fileName').textContent = f.name;
        const mb = f.size / 1048576;
        document.getElementById('fileSize').textContent =
            mb >= 1 ? mb.toFixed(1) + ' MB' : (f.size / 1024).toFixed(0) + ' KB';
        document.getElementById('fileInfo').classList.add('show');
    }

    function clearFile() {
        document.getElementById('fileIn').value = '';
        document.getElementById('fileInfo').classList.remove('show');
    }

    const dz = document.getElementById('dropZone');
    dz.addEventListener('dragover', e => { e.preventDefault(); dz.classList.add('over'); });
    dz.addEventListener('dragleave', () => dz.classList.remove('over'));
    dz.addEventListener('drop', e => {
        e.preventDefault();
        dz.classList.remove('over');
        const f = e.dataTransfer.files[0];
        if (f) {
            const dt = new DataTransfer();
            dt.items.add(f);
            document.getElementById('fileIn').files = dt.files;
            onFileSelect(document.getElementById('fileIn'));
        }
    });

    function validateForm() {
        const fileInput = document.getElementById('fileIn');
        if (!fileInput.files || fileInput.files.length === 0) {
            alert('Please select a file to upload.');
            return false;
        }
        const file = fileInput.files[0];
        if (file.size > 200 * 1024 * 1024) {
            alert('File size exceeds 200MB limit.');
            return false;
        }
        const allowed = ['.pdf','.doc','.docx','.ppt','.pptx','.txt','.jpg','.jpeg','.png','.mp4','.mkv'];
        if (!allowed.some(ext => file.name.toLowerCase().endsWith(ext))) {
            alert('Invalid file type.');
            return false;
        }
        return true;
    }

    </script>

<div id="pwToast"><i class="ti ti-circle-check"></i><span id="pwToastMsg"></span></div>

<script>
function toggleSidebar() {
    const sb = document.querySelector('.sidebar');
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
