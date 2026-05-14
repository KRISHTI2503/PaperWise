<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.PaperRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: #f0f4f8;
            min-height: 100vh;
            display: flex;
        }

        /* ── SIDEBAR ─────────────────────────────── */
        .sidebar {
            width: 220px; min-width: 220px; background: #0d1b2a;
            min-height: 100vh; position: sticky; top: 0; height: 100vh;
            display: flex; flex-direction: column; overflow-y: auto;
        }
        .sidebar-logo {
            display: flex; align-items: center; gap: 10px;
            padding: 20px 18px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
        }
        .logo-sq {
            width: 34px; height: 34px; background: #1a3a5c;
            border-radius: 9px; display: flex; align-items: center;
            justify-content: center; flex-shrink: 0;
        }
        .logo-sq i { font-size: 15px; color: #fff; margin: 0; }
        .logo-text .app-name { font-size: 16px; font-weight: 700; color: #fff; line-height: 1.2; }
        .logo-text .app-sub  { font-size: 10px; color: rgba(255,255,255,0.4); }

        .nav-section { padding: 14px 0 4px; }
        .nav-label {
            font-size: 10px; color: rgba(255,255,255,0.3);
            letter-spacing: 0.8px; text-transform: uppercase; padding: 0 18px 6px;
        }
        .nav-item {
            display: flex; align-items: center; gap: 10px;
            padding: 9px 14px; margin: 1px 8px; border-radius: 8px;
            font-size: 13px; color: rgba(255,255,255,0.55);
            text-decoration: none; transition: background 0.15s, color 0.15s;
        }
        .nav-item i { font-size: 13px; margin: 0; width: 16px; text-align: center; flex-shrink: 0; }
        .nav-item:hover  { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.85); }
        .nav-item.active { background: #1a3a5c; color: #fff; }
        .nav-badge {
            margin-left: auto; background: #e53e3e; color: #fff;
            font-size: 10px; border-radius: 10px; padding: 1px 6px; font-weight: 600;
        }
        .sidebar-bottom {
            margin-top: auto; border-top: 1px solid rgba(255,255,255,0.08); padding: 12px 8px;
        }
        .user-row { display: flex; align-items: center; gap: 9px; padding: 6px 10px 10px; }
        .avatar-sm {
            width: 32px; height: 32px; background: #1a3a5c; border-radius: 50%;
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

        /* ── MAIN ────────────────────────────────── */
        .main { flex: 1; display: flex; flex-direction: column; min-width: 0; }

        .topbar {
            background: #fff; height: 56px; padding: 0 24px;
            display: flex; align-items: center; justify-content: space-between;
            border-bottom: 1px solid #e8edf2; flex-shrink: 0;
        }
        .topbar-left { display: flex; flex-direction: column; }
        .topbar-title    { font-size: 16px; font-weight: 600; color: #0d1b2a; line-height: 1.2; }
        .topbar-subtitle { font-size: 11px; color: #9ca3af; }
        .topbar-right { display: flex; align-items: center; gap: 10px; }
        .pill-date {
            background: #fff4e0; color: #854f0b; font-size: 11px;
            padding: 4px 10px; border-radius: 20px; display: flex; align-items: center; gap: 5px;
        }
        .pill-date i { font-size: 11px; margin: 0; }
        .bell-btn {
            position: relative; width: 34px; height: 34px; background: #f0f4f8;
            border: none; border-radius: 8px; display: flex; align-items: center;
            justify-content: center; cursor: pointer; color: #4f7396;
        }
        .bell-btn i { font-size: 14px; margin: 0; }
        .bell-dot {
            position: absolute; top: 6px; right: 6px; width: 7px; height: 7px;
            background: #e53e3e; border-radius: 50%; border: 1.5px solid #fff;
        }

        .content { padding: 20px 24px; flex: 1; }

        /* ── STAT CARDS ──────────────────────────── */
        .stats-grid {
            display: grid; grid-template-columns: repeat(4, 1fr);
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
        .stat-icon.purple { background: #faf5ff; color: #7e22ce; }
        .stat-body .stat-num   { font-size: 22px; font-weight: 700; color: #0d1b2a; line-height: 1.1; }
        .stat-body .stat-label { font-size: 11px; color: #6b7280; margin-top: 2px; }

        /* ── SECTION CARD ────────────────────────── */
        .section-card {
            background: #fff; border-radius: 12px;
            border: 1px solid #e8edf2; overflow: hidden; margin-bottom: 20px;
        }
        .section-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 14px 18px; border-bottom: 1px solid #f0f4f8; flex-wrap: wrap; gap: 10px;
        }
        .section-header-left { display: flex; align-items: center; gap: 8px; }
        .section-title { font-size: 14px; font-weight: 600; color: #0d1b2a; }
        .count-pill {
            font-size: 11px; padding: 3px 9px; border-radius: 20px; font-weight: 500;
        }
        .count-pill.indigo { background: #eef2ff; color: #3730a3; }

        /* Search */
        .search-wrap { position: relative; }
        .search-wrap i { position: absolute; left: 9px; top: 50%; transform: translateY(-50%); font-size: 12px; color: #9ca3af; margin: 0; }
        .search-input {
            border: 1.5px solid #e5e7eb; border-radius: 8px;
            padding: 6px 10px 6px 30px; font-size: 12px; color: #111827;
            background: #f9fafb; outline: none; width: 240px;
            transition: border .18s, box-shadow .18s; font-family: inherit;
        }
        .search-input:focus { border-color: #3b82f6; background: #fff; box-shadow: 0 0 0 3px rgba(59,130,246,.1); }

        /* ── TABLE ───────────────────────────────── */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table thead tr { background: #f8fafc; }
        .data-table th {
            font-size: 11px; color: #6b7280; text-transform: uppercase;
            letter-spacing: 0.5px; padding: 10px 16px; text-align: left;
            border-bottom: 1px solid #e8edf2; font-weight: 600; white-space: nowrap;
        }
        .data-table td {
            padding: 12px 16px; border-bottom: 1px solid #f0f4f8;
            font-size: 13px; color: #1f2937; vertical-align: middle;
        }
        .data-table tbody tr:last-child td { border-bottom: none; }
        .data-table tbody tr:hover td { background: #f8fafc; }

        /* Row number */
        .td-num { color: #9ca3af; font-size: 12px; font-weight: 500; }

        /* Student cell */
        .student-cell { display: flex; align-items: center; gap: 10px; }
        .stu-avatar {
            width: 34px; height: 34px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 12px; font-weight: 700; color: #fff; flex-shrink: 0;
        }
        .stu-name  { font-size: 13px; font-weight: 600; color: #0d1b2a; }
        .stu-email { font-size: 11px; color: #9ca3af; margin-top: 1px; }

        /* Joined date */
        .td-date { font-size: 12px; color: #6b7280; }

        /* Status badges */
        .status-badge {
            font-size: 11px; font-weight: 600; padding: 3px 9px;
            border-radius: 20px; display: inline-block; white-space: nowrap;
        }
        .s-new      { background: #dcfce7; color: #166534; }
        .s-active   { background: #dbeafe; color: #1e40af; }
        .s-inactive { background: #f3f4f6; color: #6b7280; }

        /* Count cells */
        .count-cell { display: flex; align-items: center; gap: 5px; white-space: nowrap; }
        .count-cell i { font-size: 12px; margin: 0; }
        .count-cell .num { font-size: 13px; font-weight: 600; color: #0d1b2a; }
        .muted { color: #9ca3af; font-size: 12px; font-style: italic; }

        /* Empty state */
        .empty-state { text-align: center; padding: 56px 20px; color: #9ca3af; }
        .empty-state i { font-size: 44px; margin: 0 0 14px; display: block; color: #d1d5db; }
        .empty-state p { font-size: 13px; }

        /* Toast */
        .pw-toast {
            position: fixed; bottom: 20px; right: 20px; background: #0f2744; color: #fff;
            border-radius: 10px; padding: 10px 16px; font-size: 13px; font-weight: 500;
            display: flex; align-items: center; gap: 8px;
            opacity: 0; transform: translateY(8px); transition: all .25s;
            pointer-events: none; z-index: 999;
        }
        .pw-toast i { font-size: 16px; color: #4ade80; margin: 0; }
        .pw-toast.show { opacity: 1; transform: translateY(0); }
    </style>
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
        <p class="nav-label">Main</p>
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

    <div class="nav-section">
        <p class="nav-label">Manage</p>
        <a href="${pageContext.request.contextPath}/adminRequests" class="nav-item">
            <i class="fa-solid fa-clipboard-list"></i> Requests
            <% if (pendingCount > 0) { %>
                <span class="nav-badge"><%= pendingCount %></span>
            <% } %>
        </a>
        <a href="${pageContext.request.contextPath}/students" class="nav-item active">
            <i class="fa-solid fa-users"></i> Students
        </a>
        <a href="#" class="nav-item">
            <i class="fa-solid fa-chart-bar"></i> Analytics
        </a>
    </div>

    <div class="sidebar-bottom">
        <div class="user-row">
            <div class="avatar-sm"><%= adminInitials %></div>
            <div class="user-meta">
                <div class="u-name"><%= adminUsername %></div>
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
        <div class="topbar-left">
            <span class="topbar-title">Students</span>
            <span class="topbar-subtitle">Manage and monitor all registered students</span>
        </div>
        <div class="topbar-right">
            <span class="pill-date">
                <i class="fa-regular fa-calendar"></i> <%= currentMonthYear %>
            </span>
            <button class="bell-btn" title="Notifications">
                <i class="fa-regular fa-bell"></i>
                <% if (pendingCount > 0) { %><span class="bell-dot"></span><% } %>
            </button>
        </div>
    </div>

    <div class="content">

        <!-- ── STAT CARDS ── -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fa-solid fa-users"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalStudents %></div>
                    <div class="stat-label">Total Students</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="fa-solid fa-user-check"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= activeThisMonth %></div>
                    <div class="stat-label">Active This Month</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon orange"><i class="fa-solid fa-thumbs-up"></i></div>
                <div class="stat-body">
                    <div class="stat-num"><%= totalUsefulMarks %></div>
                    <div class="stat-label">Total Useful Marks</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon purple"><i class="fa-solid fa-paper-plane"></i></div>
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
                    <i class="fa-solid fa-users" style="font-size:14px;color:#4338ca;margin:0;"></i>
                    <span class="section-title">All Students</span>
                    <span class="count-pill indigo"><%= totalStudents %></span>
                </div>
                <div class="search-wrap">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="searchInput" class="search-input"
                           placeholder="Search by username or email…"
                           oninput="filterStudents()">
                </div>
            </div>

            <% if (students != null && !students.isEmpty()) { %>
            <div style="overflow-x:auto;">
            <table class="data-table" id="studentsTable">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Student</th>
                        <th>Joined</th>
                        <th>Status</th>
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

                        // Status logic
                        String statusClass, statusLabel;
                        if (joinedThisMonth) {
                            statusClass = "s-new";    statusLabel = "New";
                        } else if (student.getUsefulMarksGiven() > 0 || student.getRequestsMade() > 0) {
                            statusClass = "s-active"; statusLabel = "Active";
                        } else {
                            statusClass = "s-inactive"; statusLabel = "Inactive";
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
                    <td><span class="status-badge <%= statusClass %>"><%= statusLabel %></span></td>
                    <td>
                        <% if (student.getUsefulMarksGiven() > 0) { %>
                            <div class="count-cell">
                                <i class="fa-solid fa-thumbs-up" style="color:#f97316;"></i>
                                <span class="num"><%= student.getUsefulMarksGiven() %></span>
                            </div>
                        <% } else { %>
                            <span class="muted">—</span>
                        <% } %>
                    </td>
                    <td>
                        <% if (student.getRequestsMade() > 0) { %>
                            <div class="count-cell">
                                <i class="fa-solid fa-paper-plane" style="color:#7e22ce;"></i>
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

            <div id="noResults" style="display:none;text-align:center;padding:32px;color:#9ca3af;font-size:13px;">
                No students match your search.
            </div>

            <% } else { %>
            <div class="empty-state">
                <i class="fa-solid fa-users"></i>
                <p>No students registered yet.</p>
            </div>
            <% } %>
        </div>

    </div><!-- /.content -->
</div><!-- /.main -->

<!-- Toast -->
<div id="pwToast" class="pw-toast">
    <i class="fa-solid fa-circle-check"></i>
    <span id="pwToastMsg">Done!</span>
</div>

<script>
    function filterStudents() {
        var q    = document.getElementById('searchInput').value.toLowerCase().trim();
        var rows = document.querySelectorAll('#studentsBody tr');
        var vis  = 0;

        rows.forEach(function (row) {
            var uname = row.dataset.username || '';
            var email = row.dataset.email    || '';
            var match = !q || uname.includes(q) || email.includes(q);
            row.style.display = match ? '' : 'none';
            if (match) vis++;
        });

        var nr = document.getElementById('noResults');
        if (nr) nr.style.display = vis === 0 ? 'block' : 'none';
    }
</script>
</body>
</html>
