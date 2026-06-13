<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    // Auth guard — AnalyticsServlet already checks, but JSP guard as fallback
    com.paperwise.model.User loggedInUser =
        (com.paperwise.model.User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"admin".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String username = (String) request.getAttribute("username");
    if (username == null) username = loggedInUser.getUsername();
    String initials = (String) request.getAttribute("initials");
    if (initials == null) {
        initials = username.length() >= 2
            ? username.substring(0, 2).toUpperCase()
            : username.toUpperCase();
    }

    int totalPapers      = request.getAttribute("totalPapers")      != null ? (int) request.getAttribute("totalPapers")      : 0;
    int totalStudents    = request.getAttribute("totalStudents")     != null ? (int) request.getAttribute("totalStudents")    : 0;
    int totalDiffVotes   = request.getAttribute("totalDiffVotes")    != null ? (int) request.getAttribute("totalDiffVotes")   : 0;
    int totalUsefulMarks = request.getAttribute("totalUsefulMarks")  != null ? (int) request.getAttribute("totalUsefulMarks") : 0;
    int pendingCount     = request.getAttribute("pendingRequestsCount") != null ? (int) request.getAttribute("pendingRequestsCount") : 0;

    int easyCount   = request.getAttribute("easyCount")   != null ? (int) request.getAttribute("easyCount")   : 0;
    int mediumCount = request.getAttribute("mediumCount") != null ? (int) request.getAttribute("mediumCount") : 0;
    int hardCount   = request.getAttribute("hardCount")   != null ? (int) request.getAttribute("hardCount")   : 0;
    int totalDiff   = request.getAttribute("totalDiff")   != null ? (int) request.getAttribute("totalDiff")   : 0;
    int easyPct     = request.getAttribute("easyPct")     != null ? (int) request.getAttribute("easyPct")     : 0;
    int mediumPct   = request.getAttribute("mediumPct")   != null ? (int) request.getAttribute("mediumPct")   : 0;
    int hardPct     = request.getAttribute("hardPct")     != null ? (int) request.getAttribute("hardPct")     : 0;

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> papersBySubject =
        (List<Map<String, Object>>) request.getAttribute("papersBySubject");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> topPapers =
        (List<Map<String, Object>>) request.getAttribute("topPapers");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> monthlyUploads =
        (List<Map<String, Object>>) request.getAttribute("monthlyUploads");

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics - PaperWise</title>
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

        .content { padding: 2rem; }

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
        .stat-icon.green  { background: #f0fdf4; color: #166534; }
        .stat-icon.orange { background: #fff7ed; color: #f97316; }
        .stat-icon.purple { background: #faf5ff; color: #a855f7; }
        .stat-icon.pink   { background: #fff1f2; color: #f43f5e; }
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
            margin-bottom: 2rem;
            transition: background 0.3s, border-color 0.3s;
        }
        .section-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 1.2rem 1.5rem;
            border-bottom: 1px solid var(--border-color);
        }
        .section-header i { font-size: 18px; color: #3b82f6; margin-right: 8px; vertical-align: middle; }
        .section-title { font-size: 16px; font-weight: 700; color: var(--text-primary); letter-spacing: -0.2px; }
        
        .section-body { padding: 1.5rem; }

        /* ═══════════ TABLE ═══════════ */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table thead tr { background: var(--table-th-bg); }
        .data-table th {
            font-size: 11px; font-weight: 600; color: var(--text-muted);
            text-transform: uppercase; letter-spacing: 0.06em;
            padding: 12px 18px; text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        .data-table td {
            padding: 12px 18px;
            border-bottom: 1px solid var(--border-faint);
            font-size: 13.5px; color: var(--text-secondary);
            vertical-align: middle;
        }
        .data-table tbody tr:last-child td { border-bottom: none; }
        .data-table tbody tr:hover td { background: var(--table-hover-bg); }

        /* ═══════════ BADGES ═══════════ */
        .code-pill {
            background: #eef2ff; color: #3730a3; font-size: 11px;
            border-radius: 6px; padding: 3px 8px; font-weight: 600;
        }
        [data-theme="dark"] .code-pill { background: #1c2e4a; color: #a5b4fc; }

        .diff-badge { font-size: 11px; padding: 3px 10px; border-radius: 20px; font-weight: 600; display: inline-flex; align-items: center; }
        .diff-easy   { background: #dcfce7; color: #15803d; }
        .diff-medium { background: #fef9c3; color: #a16207; }
        .diff-hard   { background: #fee2e2; color: #b91c1c; }
        .diff-none   { background: #f1f5f9; color: #475569; }

        /* ═══════════ POPULAR PAPERS ═══════════ */
        .popular-grid {
            display: grid; grid-template-columns: repeat(3, 1fr);
            gap: 16px; padding: 1.5rem;
        }
        .popular-card {
            background: var(--table-th-bg); border-radius: 12px; padding: 16px;
            border: 1px solid var(--border-color);
            transition: all 0.3s ease;
        }
        .popular-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-sm); }
        .popular-rank {
            font-size: 10px; font-weight: 700; color: var(--text-muted);
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px;
        }
        .popular-name { font-size: 14px; font-weight: 700; color: var(--text-primary); margin-bottom: 6px; }
        .popular-meta { font-size: 11.5px; display: flex; align-items: center; gap: 8px; }
        .popular-count {
            margin-top: 12px; font-size: 18px; font-weight: 700; color: #f43f5e;
            display: flex; align-items: center; gap: 6px;
        }
        .popular-count i { font-size: 16px; }

        /* ═══════════ ALERT ═══════════ */
        .alert-error {
            background: #fee2e2; border: 1px solid #fca5a5; color: #991b1b;
            border-radius: 10px; padding: 12px 16px; margin-bottom: 1.5rem;
            font-size: 13.5px; display: flex; align-items: center; gap: 8px;
            font-weight: 500;
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
            .popular-grid {
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
            .popular-grid {
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

<!-- ── SIDEBAR ── -->
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
        <a href="${pageContext.request.contextPath}/students" class="nav-item">
            <i class="ti ti-users"></i> Students
        </a>
        <a href="${pageContext.request.contextPath}/analytics" class="nav-item active">
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

<!-- ── MAIN ── -->
<div class="main">

    <!-- Topbar -->
    <div class="topbar">
        <div style="display: flex; align-items: center; gap: 12px;">
            <button type="button" class="menu-toggle" onclick="toggleSidebar()" style="background: none; border: none; font-size: 20px; cursor: pointer; color: var(--text-primary); display: none; align-items: center; justify-content: center; padding: 4px;">
                <i class="ti ti-menu-2"></i>
            </button>
            <span class="topbar-title">Analytics</span>
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
            </button>
        </div>
    </div>

    <div class="content">

        <!-- ── SECTION 1: Summary Cards ──
            <div class="stat-card">
                <div class="stat-icon blue"><i class="ti ti-files"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalPapers %></div>
                    <div class="stat-label">Total Papers</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="ti ti-users"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalStudents %></div>
                    <div class="stat-label">Total Students</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon purple"><i class="ti ti-chart-bar"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalDiffVotes %></div>
                    <div class="stat-label">Difficulty Votes</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon pink"><i class="ti ti-thumb-up"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalUsefulMarks %></div>
                    <div class="stat-label">Useful Marks</div>
                </div>
            </div>
        </div>

        <!-- ── SECTION 2: Difficulty Distribution ── -->
        <div class="section-card">
            <div class="section-header">
                <div>
                    <i class="ti ti-chart-pie" style="color:var(--text-muted); margin-right: 6px;"></i>
                    <span class="section-title">Difficulty Distribution</span>
                </div>
                <span style="font-size:11px;color:var(--text-muted);"><%= totalDiff %> total votes</span>
            </div>
            <% if (totalDiff == 0) { %>
            <p style="color:var(--text-muted);font-size:13.5px;text-align:center;padding:20px 0 24px;">No difficulty votes recorded yet.</p>
            <% } else { %>
            <div style="display:flex;gap:1.5rem;padding:1.5rem;flex-wrap:wrap">
                <div style="display:flex;align-items:center;gap:12px;background:#dcfce7;border-radius:10px;padding:.75rem 1.25rem;flex:1;min-width:200px">
                    <i class="fa-solid fa-check-circle" style="font-size:24px;color:#15803d"></i>
                    <div>
                        <div style="font-size:20px;font-weight:700;color:#15803d"><%= easyCount %></div>
                        <div style="font-size:11.5px;color:#16a34a;font-weight:600">Easy votes (<%= easyPct %>%)</div>
                    </div>
                </div>
                <div style="display:flex;align-items:center;gap:12px;background:#fef9c3;border-radius:10px;padding:.75rem 1.25rem;flex:1;min-width:200px">
                    <i class="fa-solid fa-minus-circle" style="font-size:24px;color:#a16207"></i>
                    <div>
                        <div style="font-size:20px;font-weight:700;color:#a16207"><%= mediumCount %></div>
                        <div style="font-size:11.5px;color:#d97706;font-weight:600">Medium votes (<%= mediumPct %>%)</div>
                    </div>
                </div>
                <div style="display:flex;align-items:center;gap:12px;background:#fee2e2;border-radius:10px;padding:.75rem 1.25rem;flex:1;min-width:200px">
                    <i class="fa-solid fa-times-circle" style="font-size:24px;color:#b91c1c"></i>
                    <div>
                        <div style="font-size:20px;font-weight:700;color:#b91c1c"><%= hardCount %></div>
                        <div style="font-size:11.5px;color:#dc2626;font-weight:600">Hard votes (<%= hardPct %>%)</div>
                    </div>
                </div>
            </div>
            <% } %>
        </div>

        <!-- ── SECTION 3: Papers by Subject Code ── -->
        <div class="section-card">
            <div class="section-header">
                <div>
                    <i class="ti ti-table" style="color:var(--text-muted); margin-right: 6px;"></i>
                    <span class="section-title">Papers by Subject Code</span>
                </div>
            </div>
            <% if (papersBySubject == null || papersBySubject.isEmpty()) { %>
            <p style="color:var(--text-muted);font-size:13.5px;text-align:center;padding:32px;">No data available.</p>
            <% } else { %>
            <div class="data-table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Subject Code</th>
                        <th>Papers</th>
                        <th>Useful Marks</th>
                        <th>Dominant Difficulty</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Map<String, Object> row : papersBySubject) {
                    String dom = (String) row.get("dominantDiff");
                    String diffCls = "diff-none";
                    if ("Easy".equals(dom))   diffCls = "diff-easy";
                    else if ("Medium".equals(dom)) diffCls = "diff-medium";
                    else if ("Hard".equals(dom))   diffCls = "diff-hard";
                %>
                <tr>
                    <td><span class="code-pill"><%= row.get("subjectCode") %></span></td>
                    <td style="font-weight:600;color:var(--text-primary);"><%= row.get("paperCount") %></td>
                    <td><%= row.get("totalUseful") %></td>
                    <td><span class="diff-badge <%= diffCls %>"><%= dom %></span></td>
                </tr>
                <% } %>
                </tbody>
            </table>
            </div>
            <% } %>
        </div>

        <!-- ── SECTION 4: Most Popular Papers ── -->
        <div class="section-card">
            <div class="section-header">
                <div>
                    <i class="ti ti-flame" style="color:#f43f5e; margin-right: 6px;"></i>
                    <span class="section-title">Most Popular Papers</span>
                </div>
                <span style="font-size:11px;color:var(--text-muted);">Top 5 by useful marks</span>
            </div>
            <% if (topPapers == null || topPapers.isEmpty()) { %>
            <p style="color:var(--text-muted);font-size:13.5px;text-align:center;padding:32px;">No papers found.</p>
            <% } else { %>
            <div class="popular-grid">
            <% int rank = 1; for (Map<String, Object> p : topPapers) { %>
                <div class="popular-card">
                    <div class="popular-rank">#<%= rank++ %></div>
                    <div class="popular-name"><%= p.get("subjectName") %></div>
                    <div class="popular-meta">
                        <span class="code-pill"><%= p.get("subjectCode") %></span>
                        <span style="color:var(--text-muted);"><%= p.get("year") %></span>
                    </div>
                    <div class="popular-count">
                        <i class="ti ti-thumb-up"></i> <%= p.get("usefulCount") %>
                    </div>
                </div>
            <% } %>
            </div>
            <% } %>
        </div>

        <!-- ── SECTION 5: Monthly Upload Activity ── -->
        <div class="section-card">
            <div class="section-header">
                <div>
                    <i class="ti ti-calendar" style="color:var(--text-muted); margin-right: 6px;"></i>
                    <span class="section-title">Monthly Upload Activity</span>
                </div>
                <span style="font-size:11px;color:var(--text-muted);">Last 12 months</span>
            </div>
            <% if (monthlyUploads == null || monthlyUploads.isEmpty()) { %>
            <p style="color:var(--text-muted);font-size:13.5px;text-align:center;padding:32px;">No upload data available.</p>
            <% } else { %>
            <div class="data-table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Month</th>
                        <th>Papers Uploaded</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Map<String, Object> m : monthlyUploads) {
                    int cnt = (int) m.get("uploadCount");
                %>
                <tr>
                    <td style="font-weight:500"><%= m.get("monthLabel") %></td>
                    <td>
                        <span style="font-weight:700;color:var(--text-primary)"><%= cnt %></span>
                        <span style="font-size:12px;color:var(--text-muted);margin-left:4px">paper<%= cnt != 1 ? "s" : "" %></span>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
            </div>
            <% } %>
        </div>

    </div><!-- /content -->
</div><!-- /main -->

<div id="pwToast"><i class="ti ti-circle-check"></i><span id="pwToastMsg"></span></div>

<script>
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
    var days   = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var now    = new Date();
    var el     = document.getElementById('pageDate');
    if (el) el.textContent = now.toLocaleDateString('en-GB', { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' });
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
