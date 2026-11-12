<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.ExamSchedule" %>
<%@ page import="com.paperwise.model.Notification" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"student".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<ExamSchedule> upcomingExams = (List<ExamSchedule>) request.getAttribute("upcomingExams");

    int unreadCount = request.getAttribute("unreadCount") != null ? (int) request.getAttribute("unreadCount") : 0;
    @SuppressWarnings("unchecked")
    List<Notification> notificationsList = (List<Notification>) request.getAttribute("notificationsList");
    if (notificationsList == null) notificationsList = new java.util.ArrayList<>();

    String username = loggedInUser.getUsername();
    String initials = username.length() >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();

    LocalDate today = LocalDate.now();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Schedule - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/paperwise.css">
    <script>(function(){var t=localStorage.getItem('pw-theme')||'light';document.documentElement.setAttribute('data-theme',t);})();</script>
    <script src="${pageContext.request.contextPath}/js/paperwise.js" defer></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/tabler-icons/css/tabler-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <style>
        :root {
            --bg-body:#f7f9fc; --bg-card:#ffffff; --bg-sidebar:#0f2744;
            --text-primary:#0d1b2a; --text-secondary:#4f7396; --text-muted:#6b7280;
            --border-color:#e8edf2; --border-faint:#f0f4f8;
            --btn-bg:#f0f4f8; --input-bg:#f9fafb; --input-focus-bg:#ffffff; --input-border:#e5e7eb;
        }
        [data-theme="dark"] {
            --bg-body:#0f172a; --bg-card:#1e293b; --bg-sidebar:#0a1628;
            --text-primary:#f1f5f9; --text-secondary:#94a3b8; --text-muted:#64748b;
            --border-color:#334155; --border-faint:#1e293b;
            --btn-bg:#1e293b; --input-bg:#1e293b; --input-focus-bg:#0f172a; --input-border:#334155;
        }
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
        body {
            font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Arial,sans-serif;
            background:var(--bg-body); color:var(--text-primary);
            min-height:100vh; display:flex; transition:background .3s;
        }

        /* ── SIDEBAR ── */
        .sb, .sidebar {
            width:220px; flex-shrink:0; background:var(--bg-sidebar);
            display:flex; flex-direction:column; position:fixed;
            top:0; left:0; height:100vh; overflow-y:auto; z-index:100;
            transition:background .3s;
        }
        .sidebar-logo { display:flex; align-items:center; gap:10px; padding:20px 18px 16px;
                        border-bottom:1px solid rgba(255,255,255,0.08); }
        .logo-sq { width:34px; height:34px; background:rgba(255,255,255,0.12); border-radius:8px;
                   display:flex; align-items:center; justify-content:center; flex-shrink:0; }
        .logo-sq i { font-size:15px; color:#fff; margin:0; }
        .logo-text { display:flex; flex-direction:column; }
        .logo-text .app-name { font-size:16px; font-weight:700; color:#fff; line-height:1.2; }
        .logo-text .app-sub  { font-size:10px; color:rgba(255,255,255,0.4); }
        .nav-section { padding:14px 0 4px; }
        .nav-label { font-size:10px; color:rgba(255,255,255,0.3); letter-spacing:.8px;
                     text-transform:uppercase; padding:0 18px 6px; }
        .nav-item { display:flex; align-items:center; gap:10px; padding:9px 14px;
                    margin:1px 8px; border-radius:8px; font-size:13px;
                    color:rgba(255,255,255,0.55); text-decoration:none; cursor:pointer;
                    transition:background .15s,color .15s; letter-spacing:.01em; }
        .nav-item i { font-size:13px; margin:0; width:16px; text-align:center; flex-shrink:0; }
        .nav-item:hover  { background:rgba(255,255,255,0.06); color:rgba(255,255,255,0.85); }
        .nav-item.active { background:rgba(255,255,255,0.13); color:#fff; font-weight:500; }
        .sidebar-bottom { margin-top:auto; border-top:1px solid rgba(255,255,255,0.08); padding:12px 8px; }
        .user-row { display:flex; align-items:center; gap:9px; padding:6px 10px 10px; }
        .avatar { width:32px; height:32px; background:rgba(255,255,255,0.15); border-radius:50%;
                  display:flex; align-items:center; justify-content:center;
                  font-size:11px; font-weight:700; color:#fff; flex-shrink:0; }
        .user-meta .u-name { font-size:12px; font-weight:700; color:#fff; }
        .user-meta .u-role { font-size:10px; color:rgba(255,255,255,0.35); }
        .logout-btn { display:flex; align-items:center; gap:8px; width:100%; padding:8px 14px;
                      border-radius:8px; background:none; border:none; cursor:pointer;
                      font-size:13px; color:rgba(255,100,100,0.7);
                      transition:background .15s,color .15s; text-align:left; }
        .logout-btn i { font-size:13px; margin:0; }
        .logout-btn:hover { background:rgba(255,80,80,0.1); color:#ff6b6b; }

        /* ── MAIN ── */
        .main { margin-left:220px; flex:1; display:flex; flex-direction:column; min-height:100vh; min-width:0; }
        .topbar { background:var(--bg-card); height:56px; padding:0 24px;
                  display:flex; align-items:center; justify-content:space-between;
                  border-bottom:1px solid var(--border-color); flex-shrink:0;
                  transition:background .3s,border-color .3s; }
        .topbar-title { font-size:16px; font-weight:600; color:var(--text-primary); letter-spacing:-.3px; }
        .topbar-right { display:flex; align-items:center; gap:10px; }
        /* date-chip, pw-dark-toggle, bell-btn styles moved to topbar-actions.jspf include */
        .content { padding:1.6rem 2rem; flex:1; }


        /* ── EXAM CARDS ── */
        .exams-grid {
            display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:14px;
        }
        .exam-card {
            background:var(--bg-card); border:1px solid var(--border-color);
            border-radius:14px; padding:18px 20px;
            box-shadow:0 1px 4px rgba(15,39,68,0.06);
            transition:background .2s,border-color .2s;
            display:flex; flex-direction:column; gap:10px;
        }
        .exam-card-top { display:flex; align-items:flex-start; justify-content:space-between; gap:10px; }
        .exam-subject { font-size:14px; font-weight:700; color:var(--text-primary); line-height:1.3; }
        .days-badge { flex-shrink:0; border-radius:20px; padding:4px 12px;
                      font-size:12px; font-weight:700; white-space:nowrap; }
        .days-green  { background:#dcfce7; color:#15803d; }
        .days-amber  { background:#fef9c3; color:#92400e; }
        .days-red    { background:#fee2e2; color:#991b1b; }
        [data-theme="dark"] .days-green  { background:#052e16; color:#4ade80; }
        [data-theme="dark"] .days-amber  { background:#431407; color:#fbbf24; }
        [data-theme="dark"] .days-red    { background:#450a0a; color:#f87171; }
        .exam-meta { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
        .exam-meta-item { display:flex; align-items:center; gap:5px; font-size:12px; color:var(--text-muted); }
        .exam-meta-item i { font-size:11px; }
        .code-pill { background:#eef2ff; color:#3730a3; font-size:11px; border-radius:6px; padding:2px 8px; font-weight:600; }
        [data-theme="dark"] .code-pill { background:#1e3a5f; color:#93c5fd; }
        .exam-type-pill { background:#f0fdf4; color:#166534; font-size:11px; border-radius:6px; padding:2px 8px; font-weight:600; }

        .empty-state { text-align:center; padding:60px 20px; color:var(--text-muted); }
        .empty-state i { font-size:40px; display:block; margin-bottom:12px; }
        .empty-state p { font-size:13.5px; font-weight:600; color:var(--text-primary); margin-bottom:4px; }
        .empty-state span { font-size:12.5px; }

        .section-heading { font-size:14px; font-weight:700; color:var(--text-primary);
                           margin-bottom:14px; display:flex; align-items:center; gap:8px; }
        .section-heading i { font-size:15px; color:var(--text-muted); }

        /* ── ADD TO CALENDAR BUTTON ── */
        .gcal-btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 12px;
            border-radius: 8px;
            font-size: 11.5px;
            font-weight: 600;
            font-family: inherit;
            cursor: pointer;
            border: 1.5px solid #bfdbfe;
            background: #eff6ff;
            color: #1d4ed8;
            transition: background .2s, color .2s, border-color .2s, box-shadow .2s;
            margin-top: 2px;
        }
        .gcal-btn i { font-size: 13px; margin: 0; }
        .gcal-btn:hover {
            background: rgba(29, 78, 216, 0.08);
            color: #1d4ed8;
            border-color: #2563eb;
            box-shadow: 0 2px 4px rgba(29, 78, 216, 0.12);
        }
        [data-theme="dark"] .gcal-btn {
            background: #1e3a5f;
            color: #93c5fd;
            border-color: #1e40af;
        }
        [data-theme="dark"] .gcal-btn:hover {
            background: rgba(37, 99, 235, 0.15);
            color: #93c5fd;
            border-color: #3b82f6;
            box-shadow: 0 2px 4px rgba(37, 99, 235, 0.2);
        }

        /* ── RESPONSIVE ── */
        .menu-toggle { display:none; background:none; border:none; font-size:18px;
                       cursor:pointer; color:var(--text-primary); padding:8px 0; margin-right:12px; }
        @media(max-width:768px) {
            .sidebar { position:fixed; left:-220px; z-index:9999;
                       box-shadow:4px 0 15px rgba(0,0,0,0.25); transition:left .3s ease; }
            .sidebar.open { left:0; }
            .main { margin-left:0; }
            .topbar { padding:0 16px; }
            .menu-toggle { display:block !important; }
            .content { padding:16px; }
            .exams-grid { grid-template-columns:1fr; }
        }
        /* ── NOTIFICATION BELL & DROPDOWN ── */
        .notif-wrap { position: relative; }
        .notif-dot { position: absolute; top: 5px; right: 5px; min-width: 16px; height: 16px;
                     background: #e53e3e; border-radius: 50%; border: 2px solid var(--bg-card);
                     font-size: 9px; font-weight: 700; color: #fff;
                     display: flex; align-items: center; justify-content: center; line-height: 1; }
        .notif-dropdown { display: none; position: absolute; top: calc(100% + 8px); right: 0;
                          width: 320px; background: var(--bg-card); border: 1px solid var(--border-color);
                          border-radius: 14px; box-shadow: 0 8px 32px rgba(15,39,68,0.16);
                          z-index: 9998; overflow: hidden; }
        .notif-dropdown.open { display: block; }
        .notif-header { display: flex; align-items: center; justify-content: space-between;
                        padding: 12px 16px; border-bottom: 1px solid var(--border-color); }
        .notif-header-title { font-size: 13px; font-weight: 700; color: var(--text-primary); }
        .notif-mark-all { font-size: 11.5px; color: #3b82f6; background: none; border: none;
                          cursor: pointer; font-family: inherit; padding: 0; }
        .notif-mark-all:hover { text-decoration: underline; }
        .notif-list { max-height: 340px; overflow-y: auto; }
        .notif-item { display: flex; align-items: flex-start; gap: 10px; width: 100%;
                      padding: 10px 16px; border-bottom: 1px solid var(--border-faint);
                      cursor: pointer; transition: background .15s;
                      background: none; border-left: none; border-right: none; border-top: none;
                      font-family: inherit; text-align: left; }
        .notif-item:last-child { border-bottom: none; }
        .notif-item.unread { background: #eff6ff; }
        [data-theme="dark"] .notif-item.unread { background: rgba(30,58,95,0.3); }
        .notif-item:hover { background: var(--border-faint); }
        .notif-icon { width: 30px; height: 30px; border-radius: 50%; background: #dbeafe;
                      display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .notif-msg { font-size: 12.5px; color: var(--text-primary); line-height: 1.4; flex: 1; }
        .notif-time { font-size: 10.5px; color: var(--text-muted); margin-top: 3px; }
        .notif-empty { text-align: center; padding: 28px 16px; color: var(--text-muted); font-size: 12.5px; }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/ui-consistency.css">
</head>
<body>

<!-- ═══════════ SIDEBAR ═══════════ -->
<nav class="sb sidebar" id="sidebarNav">
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
        <a href="${pageContext.request.contextPath}/studentAnnouncements" class="nav-item">
            <i class="fa-solid fa-bullhorn"></i> Announcements
        </a>
        <a href="${pageContext.request.contextPath}/studentExamSchedule" class="nav-item active">
            <i class="fa-solid fa-calendar"></i> Exam Schedule
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

<!-- ═══════════ MAIN ═══════════ -->
<div class="main">

    <!-- Topbar -->
    <div class="topbar">
        <div style="display:flex;align-items:center;gap:12px;">
            <button class="menu-toggle" onclick="toggleSidebar()"><i class="fa-solid fa-bars"></i></button>
            <span class="topbar-title">Exam Schedule</span>
        </div>
        <div class="topbar-right">
            <%@ include file="/WEB-INF/includes/topbar-actions.jspf" %>
            <div class="notif-dropdown" id="notifDropdown">
                    <div class="notif-header">
                        <span class="notif-header-title">Notifications</span>
                        <% if (!notificationsList.isEmpty()) { %>
                        <form action="${pageContext.request.contextPath}/notifications" method="post" style="margin:0;">
                            <input type="hidden" name="action" value="markAllRead">
                            <button type="submit" class="notif-mark-all">Mark all read</button>
                        </form>
                        <% } %>
                    </div>
                    <div class="notif-list">
                        <% if (notificationsList.isEmpty()) { %>
                        <div class="notif-empty">No notifications yet</div>
                        <% } else { for (com.paperwise.model.Notification n : notificationsList) { %>
                        <form action="${pageContext.request.contextPath}/notifications" method="post" style="margin:0;">
                            <input type="hidden" name="action" value="markRead">
                            <input type="hidden" name="id" value="<%= n.getId() %>">
                            <input type="hidden" name="link" value="<%= n.getLink() != null ? n.getLink() : "" %>">
                            <button type="submit" class="notif-item <%= n.isRead() ? "" : "unread" %>">
                                <div class="notif-icon"><i class="fa-solid fa-bell" style="font-size:12px;color:#2563eb;"></i></div>
                                <div>
                                    <div class="notif-msg"><%= n.getMessage() %></div>
                                    <div class="notif-time"><%= n.getRelativeTime() %></div>
                                </div>
                            </button>
                        </form>
                        <% } } %>
                    </div>
                </div>
            </div><!-- close notif-wrap -->
        </div><!-- close topbar-right -->
    </div><!-- close topbar -->

    <div class="content">

        <% if (upcomingExams == null || upcomingExams.isEmpty()) { %>
        <div class="empty-state">
            <i class="fa-regular fa-calendar-xmark"></i>
            <p>No upcoming exams scheduled.</p>
            <span>Check back later for updates from your teachers.</span>
        </div>
        <% } else { %>

        <div class="section-heading">
            <i class="fa-solid fa-calendar-days"></i>
            Upcoming Exams (<%= upcomingExams.size() %>)
        </div>

        <div class="exams-grid">
        <% for (ExamSchedule exam : upcomingExams) {
            long days = ChronoUnit.DAYS.between(today, exam.getExamDate());
            String badgeClass = days > 14 ? "days-green" : (days >= 7 ? "days-amber" : "days-red");
            String daysLabel;
            if (days == 0)      daysLabel = "Today!";
            else if (days == 1) daysLabel = "Tomorrow!";
            else                daysLabel = days + " days";
        %>
        <div class="exam-card">
            <div class="exam-card-top">
                <div class="exam-subject"><%= exam.getSubjectName() %></div>
                <span class="days-badge <%= badgeClass %>"><%= daysLabel %></span>
            </div>
            <div class="exam-meta">
                <span class="code-pill"><%= exam.getSubjectCode() %></span>
                <span class="exam-type-pill"><%= exam.getExamType() %></span>
            </div>
            <div class="exam-meta">
                <div class="exam-meta-item">
                    <i class="ti ti-calendar"></i>
                    <%= exam.getExamDateFormatted() %>
                </div>
            </div>
            <div>
                <button
                    onclick="addToGoogleCalendar('<%= exam.getSubjectName().replace("'", "\\'") %>','<%= exam.getSubjectCode().replace("'", "\\'") %>','<%= exam.getExamType().replace("'", "\\'") %>','<%= exam.getExamDateIso() %>')"
                    class="gcal-btn"
                    title="Add this exam to Google Calendar">
                    <i class="ti ti-calendar-plus"></i>
                    Add to Calendar
                </button>
            </div>
        </div>
        <% } %>
        </div>

        <% } %>

    </div><!-- /content -->
</div><!-- /main -->

<script>
function toggleSidebar() {
    document.getElementById('sidebarNav').classList.toggle('open');
}
</script>
<script>
function toggleNotifDropdown(e) {
    e.stopPropagation();
    document.getElementById('notifDropdown').classList.toggle('open');
}
document.addEventListener('click', function(e) {
    var wrap = document.getElementById('notifWrap');
    if (wrap && !wrap.contains(e.target)) {
        var dd = document.getElementById('notifDropdown');
        if (dd) dd.classList.remove('open');
    }
});
</script>
<script>
function addToGoogleCalendar(subjectName, subjectCode, examType, examDateStr) {
    // examDateStr is ISO format "yyyy-MM-dd" from exam.getExamDateIso()
    // Append T00:00:00 to force local-date interpretation (avoid UTC offset issues)
    var examDate = new Date(examDateStr + 'T00:00:00');
    if (isNaN(examDate.getTime())) {
        alert('Invalid exam date. Cannot add to calendar.');
        return;
    }

    function formatGCal(d) {
        var y = d.getFullYear();
        var m = String(d.getMonth() + 1).padStart(2, '0');
        var day = String(d.getDate()).padStart(2, '0');
        return y + m + day;
    }

    var startDate = formatGCal(examDate);
    // All-day event: end date is the following day
    var endDateObj = new Date(examDate);
    endDateObj.setDate(endDateObj.getDate() + 1);
    var endDate = formatGCal(endDateObj);

    var title   = encodeURIComponent(subjectName + ' Exam (' + examType + ')');
    var details = encodeURIComponent(
        'Subject: ' + subjectName + '\n' +
        'Code: '    + subjectCode + '\n' +
        'Type: '    + examType    + '\n\n' +
        'Reminders:\n' +
        '- Start studying 7 days before\n' +
        '- Serious revision 3 days before\n' +
        '- Final revision 1 day before\n' +
        '- Exam starts today!\n\n' +
        'Added from PaperWise'
    );

    var gcalUrl =
        'https://calendar.google.com/calendar/render?action=TEMPLATE' +
        '&text='  + title +
        '&dates=' + startDate + 'T090000/' + startDate + 'T110000' +
        '&details=' + details +
        '&sf=true&output=xml';

    window.open(gcalUrl, '_blank');
}
</script>
</body>
</html>
