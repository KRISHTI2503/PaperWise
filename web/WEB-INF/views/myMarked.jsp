<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.Paper" %>
<%@ page import="java.util.List" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"student".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Paper> markedPapers = (List<Paper>) request.getAttribute("markedPapers");

    int markedCount = request.getAttribute("markedCount") != null ? (int) request.getAttribute("markedCount") : 0;
    int totalUsefulMarks = request.getAttribute("totalUsefulMarks") != null ? (int) request.getAttribute("totalUsefulMarks") : 0;
    int yourMarksCount = request.getAttribute("yourMarksCount") != null ? (int) request.getAttribute("yourMarksCount") : 0;

    String username = loggedInUser.getUsername();
    String initials = username.length() >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Marked Papers - PaperWise</title>
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

        [data-theme="dark"] .badge,
        [data-theme="dark"] .diff-badge,
        [data-theme="dark"] .code-pill,
        [data-theme="dark"] .exam-pill {
            opacity: 0.9;
        }

        [data-theme="dark"] .code-pill {
            background: #1e3a5f;
            color: #93c5fd;
            border-color: #1e40af;
        }

        [data-theme="dark"] .year-pill,
        [data-theme="dark"] .exam-pill {
            background: #1e293b;
            color: #94a3b8;
            border-color: #334155;
        }

        [data-theme="dark"] .subj-name,
        [data-theme="dark"] .card-title {
            color: #e2e8f0;
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
        .alert-error {
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

        .section-card {
            background: var(--bg-card); border-radius: 16px;
            border: 1px solid var(--border-color); overflow: hidden; margin-bottom: 20px;
            transition: background 0.3s, border-color 0.3s;
            box-shadow: 0 1px 4px rgba(15,39,68,0.06);
        }
        .section-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 1.1rem 1.4rem; border-bottom: 1px solid var(--border-color);
            transition: border-color 0.3s; gap: 12px; flex-wrap: wrap;
        }
        .section-header-left { display: flex; align-items: center; gap: 8px; }
        .section-title { font-size: 14px; font-weight: 600; color: var(--text-primary); }
        .search-input {
            min-width: 220px;
            border: 1.5px solid var(--input-border); border-radius: 10px;
            padding: 7px 12px 7px 32px; font-size: 13px; color: var(--text-primary);
            background: var(--input-bg) url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%239ca3af' stroke-width='2'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cpath d='m21 21-4.35-4.35'/%3E%3C/svg%3E") no-repeat 10px center;
            outline: none; transition: border .18s, background-color .18s;
        }
        .search-input:focus { border-color: #3b82f6; background-color: var(--input-focus-bg); }

        .data-table-container { width: 100%; overflow-x: auto; }
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
        .td-desc { font-size: 11px; color: #64748b; margin-top: 3px; font-style: italic; font-weight: 400; }
        .code-pill { background: #dbeafe; color: #1d4ed8; font-size: 11px; border-radius: 6px; padding: 3px 8px; font-weight: 500; }
        .year-pill { background: #1a2740; color: #fff; font-size: 11px; border-radius: 6px; padding: 3px 8px; font-weight: 500; }
        .exam-pill {
            font-size: 11px; border-radius: 20px; padding: 3px 10px;
            font-weight: 600; display: inline-flex; align-items: center;
        }
        .exam-mid { background: #f3e8ff; color: #7e22ce; }
        .exam-end { background: #dcfce7; color: #166534; }
        .exam-quiz { background: #fefce8; color: #854d0e; }
        .exam-session { background: #dbeafe; color: #1d4ed8; }
        .exam-other { background: #f1f5f9; color: #475569; }
        .useful-num { color: #f97316; font-weight: 700; font-size: 13.5px; }
        .muted-dash { color: #94a3b8; font-size: 12px; }
        .date-cell { font-size: 11.5px; color: var(--text-muted); white-space: nowrap; }

        .diff-badge {
            font-size: 11.5px;
            font-weight: 600;
            border-radius: 20px;
            padding: 3px 10px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .diff-easy { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .diff-medium { background: #fff7ed; color: #c2410c; border: 1px solid #fed7aa; }
        .diff-hard { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        .diff-mixed { background: #f1f5f9; color: #475569; border: 1px solid #e2e8f0; }
        .diff-none-text { color: #94a3b8; font-size: 12px; font-style: italic; }

        .action-btns { display: flex; gap: 5px; flex-wrap: wrap; align-items: center; }
        .act-btn {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 5px 10px; border-radius: 8px; font-size: 11px;
            font-weight: 500; border: 1.5px solid transparent; cursor: pointer;
            text-decoration: none; transition: opacity .15s, background .15s;
            font-family: inherit;
        }
        .act-btn i { font-size: 10px; margin: 0; }
        .act-btn:hover { opacity: 0.82; }
        .act-view { background: #dbeafe; color: #1d4ed8; border-color: #bfdbfe; }
        .act-download { background: #dcfce7; color: #166534; border-color: #bbf7d0; }
        .act-unmark { background: #fff; color: #ef4444; border-color: #fecaca; }

        .empty-state { text-align: center; padding: 48px 20px; color: var(--text-muted); }
        .empty-state i { font-size: 36px; margin: 0 0 10px; display: block; color: #e2e8f0; }
        .empty-state p { font-size: 13px; color: var(--text-primary); font-weight: 600; margin-bottom: 3px; }
        .empty-state span { font-size: 12px; color: var(--text-muted); }

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
            .content { padding: 16px; }
            .section-header { align-items: stretch; }
            .search-input { width: 100%; min-width: 0; }
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
        <a href="${pageContext.request.contextPath}/myMarked" class="nav-item active">
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

<div class="main">
    <div class="topbar">
        <div style="display:flex; align-items:center; gap:12px;">
            <button class="menu-toggle" onclick="toggleSidebar()"><i class="fa-solid fa-bars"></i></button>
            <div>
                <div class="topbar-title">My Marked Papers</div>
                <div class="topbar-subtitle">Papers you have marked as useful</div>
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
                <div class="stat-icon" style="background:#dbeafe;color:#2563eb;"><i class="fa-solid fa-bookmark"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= markedCount %></div>
                    <div class="stat-label">Papers Marked</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background:#dbeafe;color:#2563eb;"><i class="fa-solid fa-thumbs-up"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalUsefulMarks %></div>
                    <div class="stat-label">Total Useful Marks</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background:#dcfce7;color:#16a34a;"><i class="fa-solid fa-star"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= yourMarksCount %></div>
                    <div class="stat-label">Your Marks</div>
                </div>
            </div>
        </div>

        <div class="section-card">
            <div class="section-header">
                <div class="section-header-left">
                    <i class="fa-solid fa-bookmark" style="color:#2563eb;"></i>
                    <span class="section-title">My Marked Papers</span>
                </div>
                <input type="text" id="searchInput" class="search-input" placeholder="Search subject, code..." oninput="filterTable()">
            </div>

            <% if (markedPapers == null || markedPapers.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fa-regular fa-bookmark"></i>
                    <p>No marked papers yet.</p>
                    <span>Mark papers as useful from the dashboard to see them here.</span>
                </div>
            <% } else { %>
                <div class="data-table-container" style="overflow-x: auto;">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Subject</th>
                                <th>Code</th>
                                <th>Year</th>
                                <th>Exam Type</th>
                                <th>Useful</th>
                                <th>Difficulty</th>
                                <th>Marked On</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="markedTableBody">
                        <% for (Paper paper : markedPapers) {
                            String examType = paper.getExamType() != null ? paper.getExamType().trim() : "";
                            String examClass = "exam-other";
                            if ("Mid Term".equalsIgnoreCase(examType)) {
                                examClass = "exam-mid";
                            } else if ("End Term".equalsIgnoreCase(examType)) {
                                examClass = "exam-end";
                            } else if ("Quiz".equalsIgnoreCase(examType)) {
                                examClass = "exam-quiz";
                            } else if ("Sessional 1".equalsIgnoreCase(examType) || "Sessional 2".equalsIgnoreCase(examType)) {
                                examClass = "exam-session";
                            }
                            String examLabel = examType.isEmpty() ? "Other" : examType;

                            String difficulty = paper.getDifficultyLabel() != null ? paper.getDifficultyLabel() : "Not Rated";
                            String diffClass = "diff-mixed";
                            if ("Easy".equalsIgnoreCase(difficulty)) {
                                diffClass = "diff-easy";
                            } else if ("Medium".equalsIgnoreCase(difficulty)) {
                                diffClass = "diff-medium";
                            } else if ("Hard".equalsIgnoreCase(difficulty)) {
                                diffClass = "diff-hard";
                            } else if ("Mixed".equalsIgnoreCase(difficulty)) {
                                diffClass = "diff-mixed";
                            }
                        %>
                            <tr>
                                <td>
                                    <div class="td-subject"><%= paper.getSubjectName() %></div>
                                    <% if (paper.getDescription() != null && !paper.getDescription().trim().isEmpty()) { %>
                                        <div class="td-desc"><%= paper.getDescription() %></div>
                                    <% } %>
                                </td>
                                <td><span class="code-pill"><%= paper.getSubjectCode() %></span></td>
                                <td><span class="year-pill"><%= paper.getYear() %></span></td>
                                <td><span class="exam-pill <%= examClass %>"><%= examLabel %></span></td>
                                <td>
                                    <% if (paper.getUsefulCount() > 0) { %>
                                        <span class="useful-num"><%= paper.getUsefulCount() %></span>
                                    <% } else { %>
                                        <span class="muted-dash">&mdash;</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if ("Not Rated".equalsIgnoreCase(difficulty)) { %>
                                        <span class="diff-none-text">Not Rated</span>
                                    <% } else { %>
                                        <span class="diff-badge <%= diffClass %>"><%= difficulty %></span>
                                    <% } %>
                                </td>
                                <td class="date-cell"><%= paper.getMarkedAt() != null ? paper.getMarkedAt() : "&mdash;" %></td>
                                <td>
                                    <div class="action-btns">
                                        <a class="act-btn act-view" href="${pageContext.request.contextPath}/viewFile?paperId=<%= paper.getPaperId() %>" target="_blank">
                                            <i class="fa-solid fa-eye"></i> View
                                        </a>
                                        <a class="act-btn act-download" href="${pageContext.request.contextPath}/downloadPaper?paperId=<%= paper.getPaperId() %>">
                                            <i class="fa-solid fa-download"></i>
                                        </a>
                                        <form action="${pageContext.request.contextPath}/unmarkPaper" method="post" style="display:inline;">
                                            <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                            <input type="hidden" name="action" value="unmark">
                                            <button type="submit" class="act-btn act-unmark">
                                                <i class="fa-solid fa-bookmark" style="color:#2563eb"></i> Unmark
                                            </button>
                                        </form>
                                    </div>
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

<script>
function filterTable() {
    const val = document.getElementById('searchInput')
        .value.toLowerCase().trim();
    const rows = document.querySelectorAll('#markedTableBody tr');
    rows.forEach(function(row) {
        const text = row.innerText.toLowerCase();
        row.style.display = text.includes(val) ? '' : 'none';
    });
}
</script>
<script>
(function() {
    var days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var now = new Date();
    var formatted = days[now.getDay()] + ', ' + now.getDate() + ' ' + months[now.getMonth()] + ' ' + now.getFullYear();
    var el = document.getElementById('pageDate');
    if (el) el.textContent = formatted;
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
<div id="pwToast"><i class="ti ti-circle-check"></i><span id="pwToastMsg"></span></div>

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
