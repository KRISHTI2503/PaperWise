<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.PaperRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"admin".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<User> students = (List<User>) request.getAttribute("students");

    int totalStudents    = request.getAttribute("totalStudents")    != null ? (int) request.getAttribute("totalStudents")    : 0;
    int activeThisMonth  = request.getAttribute("activeThisMonth")  != null ? (int) request.getAttribute("activeThisMonth")  : 0;
    int totalUsefulMarks = request.getAttribute("totalUsefulMarks") != null ? (int) request.getAttribute("totalUsefulMarks") : 0;
    int totalRequests    = request.getAttribute("totalRequests")    != null ? (int) request.getAttribute("totalRequests")    : 0;
    int pendingCount     = request.getAttribute("pendingRequestsCount") != null ? (int) request.getAttribute("pendingRequestsCount") : 0;

    String adminUsername = loggedInUser.getUsername();
    String adminInitials = adminUsername.length() >= 2
        ? adminUsername.substring(0, 2).toUpperCase()
        : adminUsername.toUpperCase();
    String username = adminUsername;
    String initials = adminInitials;

    String currentMonthYear = DateTimeFormatter.ofPattern("MMM yyyy").format(LocalDate.now());
    DateTimeFormatter dtf   = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    LocalDate now           = LocalDate.now();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Students - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/paperwise.css">
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
        .avatar-sm,
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
        .topbar-left .topbar-title { font-size: 18px; font-weight: 700; letter-spacing: -0.3px; color: var(--text-primary); }
        .topbar-left .topbar-subtitle { font-size: 11px; color: var(--text-secondary); margin-top: 2px; }
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
            width: 36px; height: 36px;
            background: var(--btn-bg); border: 1px solid var(--border-color); border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; color: var(--text-secondary);
            transition: background 0.3s, color 0.3s;
        }
        .bell-btn i { font-size: 16px; margin: 0; }
        .bell-dot {
            position: absolute; top: 8px; right: 8px;
            width: 8px; height: 8px;
            background: #ef4444; border-radius: 50%;
            border: 2px solid var(--bg-card);
        }

        /* Content */
        .content { padding: 2rem; flex: 1; }

        /* ═══════════ STAT CARDS ═══════════ */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
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
        .stat-icon.orange { background: #fff7ed; color: #f97316; }
        .stat-icon.purple { background: #faf5ff; color: #a855f7; }
        .stat-body { display: flex; flex-direction: column; }
        .stat-num   { font-size: 24px; font-weight: 700; color: var(--text-primary); line-height: 1.1; letter-spacing: -0.5px; }
        .stat-label { font-size: 11.5px; color: var(--text-muted); margin-top: 3px; font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; }

        /* ═══════════ SECTION CARD ═══════════ */
        .section-card {
            background: var(--bg-card);
            border-radius: 14px;
            border: 1px solid var(--border-color);
            overflow: hidden;
            box-shadow: var(--shadow-sm);
            transition: background 0.3s, border-color 0.3s;
        }
        .section-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 1.2rem 1.5rem;
            border-bottom: 1px solid var(--border-color);
            flex-wrap: wrap; gap: 12px;
        }
        .section-header-left { display: flex; align-items: center; gap: 10px; }
        .section-header-left i { font-size: 20px; color: #3b82f6; margin: 0; }
        .section-title { font-size: 16px; font-weight: 700; color: var(--text-primary); letter-spacing: -0.2px; }
        
        /* Search */
        .search-wrap {
            display: flex; align-items: center; gap: 8px;
            border: 1px solid var(--border-color); border-radius: 10px;
            background: var(--input-bg); padding: 6px 12px;
            transition: all 0.3s;
            box-shadow: var(--shadow-sm);
        }
        .search-wrap:focus-within { border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15); }
        .search-wrap i { font-size: 14px; color: var(--text-muted); margin: 0; flex-shrink: 0; }
        .search-input {
            border: none; background: transparent; outline: none;
            font-size: 13px; color: var(--text-primary); width: 240px;
            font-family: inherit;
        }
        .search-input::placeholder { color: var(--text-muted); }

        /* ═══════════ TABLE ═══════════ */
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

        /* Row number */
        .td-num { color: var(--text-muted); font-size: 12.5px; font-weight: 600; }

        /* Student cell */
        .student-cell { display: flex; align-items: center; gap: 10px; }
        .stu-avatar {
            width: 32px; height: 32px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 11px; font-weight: 700; color: #fff; flex-shrink: 0;
            border: 1px solid rgba(255, 255, 255, 0.15);
        }
        .stu-name  { font-size: 13.5px; font-weight: 600; color: var(--text-primary); }
        .stu-email { font-size: 11.5px; color: var(--text-muted); margin-top: 1px; }

        /* Joined date */
        .td-date { font-size: 12.5px; color: var(--text-muted); }

        /* Count cells */
        .count-cell { display: flex; align-items: center; gap: 6px; white-space: nowrap; }
        .count-cell i { font-size: 14px; margin: 0; }
        .count-cell .num { font-size: 13.5px; font-weight: 600; color: var(--text-primary); }
        .muted { color: var(--text-muted); font-size: 12.5px; font-style: italic; }

        /* Empty state */
        .empty-state { text-align: center; padding: 60px 20px; color: var(--text-muted); }
        .empty-state i { font-size: 44px; margin: 0 0 16px; display: block; color: var(--border-color); }
        .empty-state p { font-size: 13.5px; }

        /* Toast */
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

<!-- ── SIDEBAR ──────────────────────────────────────── -->
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
        <a href="${pageContext.request.contextPath}/adminRequests" class="nav-item">
            <i class="ti ti-inbox"></i> Requests
            <% if (pendingCount > 0) { %>
                <span class="nav-badge"><%= pendingCount %></span>
            <% } %>
        </a>
        <a href="${pageContext.request.contextPath}/students" class="nav-item active">
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

<!-- ── MAIN ──────────────────────────────────────────── -->
<div class="main">

    <!-- Topbar -->
    <div class="topbar">
        <div style="display: flex; align-items: center; gap: 12px;">
            <button type="button" class="menu-toggle" onclick="toggleSidebar()" style="background: none; border: none; font-size: 20px; cursor: pointer; color: var(--text-primary); display: none; align-items: center; justify-content: center; padding: 4px;">
                <i class="ti ti-menu-2"></i>
            </button>
            <div class="topbar-left">
                <span class="topbar-title">Students</span>
                <span class="topbar-subtitle">Manage and monitor all registered students</span>
            </div>
        </div>
        <div class="topbar-right">
            <div class="date-chip">
                <i class="ti ti-calendar"></i>
                <span id="pageDate"></span>
            </div>
            <button type="button" class="theme-toggle-btn bell-btn" onclick="toggleTheme()" title="Toggle Theme">
                <i id="themeIcon" class="fa-solid fa-moon"></i>
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
                <div class="stat-icon blue"><i class="ti ti-users"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalStudents %></div>
                    <div class="stat-label">Total Students</div>
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
                <div class="stat-icon purple"><i class="ti ti-send"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalRequests %></div>
                    <div class="stat-label">Total Requests</div>
                </div>
            </div>
        </div>

        <!-- ── STUDENTS TABLE CARD ── -->
        <div class="section-card">
            <div class="section-header">
                <div class="section-header-left">
                    <i class="ti ti-users-group"></i>
                    <span class="section-title">All Students</span>
                </div>
                <div class="search-wrap">
                    <i class="ti ti-search"></i>
                    <input type="text" id="searchInput" class="search-input"
                           placeholder="Search by username or email…"
                           oninput="filterStudents()">
                </div>
            </div>

            <% if (students != null && !students.isEmpty()) { %>
            <div class="data-table-container">
            <table class="data-table" id="studentsTable">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Student</th>
                        <th>Joined</th>
                        <th>Useful Marks Given</th>
                        <th>Requests Made</th>
                    </tr>
                </thead>
                <tbody id="studentsBody">
                <%
                    int rowNum = 0;
                    for (User student : students) {
                        rowNum++;

                        // Avatar color by first letter
                        String uname = student.getUsername() != null ? student.getUsername() : "?";
                        char firstChar = Character.toUpperCase(uname.charAt(0));
                        String avatarColor;
                        if      (firstChar >= 'A' && firstChar <= 'E') avatarColor = "#1e4d8c";
                        else if (firstChar >= 'F' && firstChar <= 'J') avatarColor = "#0f766e";
                        else if (firstChar >= 'K' && firstChar <= 'O') avatarColor = "#7e22ce";
                        else if (firstChar >= 'P' && firstChar <= 'T') avatarColor = "#b45309";
                        else                                            avatarColor = "#0369a1";

                        String avatarText = uname.length() >= 2
                            ? uname.substring(0, 2).toUpperCase()
                            : uname.toUpperCase();

                        // Joined date
                        String joinedStr = "-";
                        boolean joinedThisMonth = false;
                        if (student.getCreatedAt() != null) {
                            joinedStr = student.getCreatedAt().format(dtf);
                            joinedThisMonth = student.getCreatedAt().getYear() == now.getYear()
                                           && student.getCreatedAt().getMonthValue() == now.getMonthValue();
                        }

                        String emailVal = student.getEmail() != null ? student.getEmail() : "";
                %>
                <tr data-username="<%= uname.toLowerCase() %>"
                    data-email="<%= emailVal.toLowerCase() %>">
                    <td class="td-num"><%= rowNum %></td>
                    <td>
                        <div class="student-cell">
                            <div class="stu-avatar" style="background:<%= avatarColor %>;">
                                <%= avatarText %>
                            </div>
                            <div>
                                <div class="stu-name"><%= uname %></div>
                                <div class="stu-email"><%= emailVal %></div>
                            </div>
                        </div>
                    </td>
                    <td class="td-date"><%= joinedStr %></td>
                    <td>
                        <% if (student.getUsefulMarksGiven() > 0) { %>
                            <div class="count-cell">
                                <i class="ti ti-thumb-up" style="color:#f97316;"></i>
                                <span class="num"><%= student.getUsefulMarksGiven() %></span>
                            </div>
                        <% } else { %>
                            <span class="muted">—</span>
                        <% } %>
                    </td>
                    <td>
                        <% if (student.getRequestsMade() > 0) { %>
                            <div class="count-cell">
                                <i class="ti ti-send" style="color:#a855f7;"></i>
                                <span class="num"><%= student.getRequestsMade() %></span>
                            </div>
                        <% } else { %>
                            <span class="muted">—</span>
                        <% } %>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
            </div>

            <div id="noResults" style="display:none;text-align:center;padding:32px;color:var(--text-muted);font-size:13.5px;">
                No students match your search.
            </div>

            <% } else { %>
            <div class="empty-state">
                <i class="ti ti-users"></i>
                <p>No students registered yet.</p>
            </div>
            <% } %>
        </div>

    </div><!-- /.content -->
</div><!-- /.main -->

<div id="pwToast"><i class="ti ti-circle-check"></i><span id="pwToastMsg"></span></div>

<script>
    function filterTable() {
        var searchInput = document.getElementById('searchInput');
        var q = searchInput ? searchInput.value.toLowerCase().trim() : '';
        var rows = document.querySelectorAll('#studentsBody tr');
        var vis = 0;
        rows.forEach(function (row) {
            var uname = (row.dataset.username || '').toLowerCase();
            var email = (row.dataset.email || '').toLowerCase();
            var match = !q || uname.includes(q) || email.includes(q) || row.textContent.toLowerCase().includes(q);
            row.style.display = match ? '' : 'none';
            if (match) vis++;
        });
        var nr = document.getElementById('noResults');
        if (nr) nr.style.display = vis === 0 ? 'block' : 'none';
    }
    function filterStudents() { filterTable(); }
    document.addEventListener('DOMContentLoaded', function () {
        var el = document.getElementById('searchInput');
        if (el) {
            el.addEventListener('input', filterTable);
            el.addEventListener('change', filterTable);
        }
        filterTable();
    });

    function toggleSidebar() {
        var sb = document.querySelector('.sidebar');
        if (sb) {
            sb.classList.toggle('open');
        }
    }

    window.addEventListener('load', () => {
        const savedTheme = localStorage.getItem('pw-theme') || 'light';
        const icon = document.getElementById('themeIcon');
        if (icon) icon.className = savedTheme === 'dark' ? 'fa-solid fa-sun' : 'fa-solid fa-moon';
    });
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
