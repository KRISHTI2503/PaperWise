<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.Announcement" %>
<%@ page import="com.paperwise.model.Notification" %>
<%@ page import="java.util.List" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"student".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Announcement> announcements = (List<Announcement>) request.getAttribute("announcements");

    int unreadCount = request.getAttribute("unreadCount") != null ? (int) request.getAttribute("unreadCount") : 0;
    @SuppressWarnings("unchecked")
    List<Notification> notificationsList = (List<Notification>) request.getAttribute("notificationsList");
    if (notificationsList == null) notificationsList = new java.util.ArrayList<>();

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
    <title>Announcements - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/paperwise.css">
    <script>(function(){var t=localStorage.getItem('pw-theme')||'light';document.documentElement.setAttribute('data-theme',t);})();</script>
    <script src="${pageContext.request.contextPath}/js/paperwise.js" defer></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/tabler-icons/css/tabler-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <style>
        :root {
            --bg-body: #f7f9fc; --bg-card: #ffffff; --bg-sidebar: #0f2744;
            --text-primary: #0d1b2a; --text-secondary: #4f7396; --text-muted: #6b7280;
            --border-color: #e8edf2; --border-faint: #f0f4f8;
            --btn-bg: #f0f4f8; --input-bg: #f9fafb; --input-focus-bg: #ffffff; --input-border: #e5e7eb;
        }
        [data-theme="dark"] {
            --bg-body: #0f172a; --bg-card: #1e293b; --bg-sidebar: #0a1628;
            --text-primary: #f1f5f9; --text-secondary: #94a3b8; --text-muted: #64748b;
            --border-color: #334155; --border-faint: #1e293b;
            --btn-bg: #1e293b; --input-bg: #1e293b; --input-focus-bg: #0f172a; --input-border: #334155;
        }
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: var(--bg-body); color: var(--text-primary);
            min-height: 100vh; display: flex; transition: background 0.3s;
        }
        /* ── SIDEBAR (identical to student-dashboard) ── */
        .sb, .sidebar {
            width: 220px; flex-shrink: 0; background: var(--bg-sidebar);
            display: flex; flex-direction: column; position: fixed;
            top: 0; left: 0; height: 100vh; overflow-y: auto; z-index: 100;
            transition: background 0.3s;
        }
        .sidebar-logo { display: flex; align-items: center; gap: 10px; padding: 20px 18px 16px;
                        border-bottom: 1px solid rgba(255,255,255,0.08); }
        .logo-sq { width: 34px; height: 34px; background: rgba(255,255,255,0.12); border-radius: 8px;
                   display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .logo-sq i { font-size: 15px; color: #fff; margin: 0; }
        .logo-text { display: flex; flex-direction: column; }
        .logo-text .app-name { font-size: 16px; font-weight: 700; color: #fff; line-height: 1.2; }
        .logo-text .app-sub  { font-size: 10px; color: rgba(255,255,255,0.4); }
        .nav-section { padding: 14px 0 4px; }
        .nav-label { font-size: 10px; color: rgba(255,255,255,0.3); letter-spacing: 0.8px;
                     text-transform: uppercase; padding: 0 18px 6px; }
        .nav-item { display: flex; align-items: center; gap: 10px; padding: 9px 14px;
                    margin: 1px 8px; border-radius: 8px; font-size: 13px;
                    color: rgba(255,255,255,0.55); text-decoration: none; cursor: pointer;
                    transition: background 0.15s, color 0.15s; letter-spacing: 0.01em; }
        .nav-item i { font-size: 13px; margin: 0; width: 16px; text-align: center; flex-shrink: 0; }
        .nav-item:hover  { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.85); }
        .nav-item.active { background: rgba(255,255,255,0.13); color: #fff; font-weight: 500; }
        .sidebar-bottom { margin-top: auto; border-top: 1px solid rgba(255,255,255,0.08); padding: 12px 8px; }
        .user-row { display: flex; align-items: center; gap: 9px; padding: 6px 10px 10px; }
        .avatar { width: 32px; height: 32px; background: rgba(255,255,255,0.15); border-radius: 50%;
                  display: flex; align-items: center; justify-content: center;
                  font-size: 11px; font-weight: 700; color: #fff; flex-shrink: 0; }
        .user-meta .u-name { font-size: 12px; font-weight: 700; color: #fff; }
        .user-meta .u-role { font-size: 10px; color: rgba(255,255,255,0.35); }
        .logout-btn { display: flex; align-items: center; gap: 8px; width: 100%; padding: 8px 14px;
                      border-radius: 8px; background: none; border: none; cursor: pointer;
                      font-size: 13px; color: rgba(255,100,100,0.7);
                      transition: background .15s, color .15s; text-align: left; }
        .logout-btn i { font-size: 13px; margin: 0; }
        .logout-btn:hover { background: rgba(255,80,80,0.1); color: #ff6b6b; }

        /* ── MAIN ── */
        .main { margin-left: 220px; flex: 1; display: flex; flex-direction: column; min-height: 100vh; min-width: 0; }
        .topbar { background: var(--bg-card); height: 56px; padding: 0 24px;
                  display: flex; align-items: center; justify-content: space-between;
                  border-bottom: 1px solid var(--border-color); flex-shrink: 0;
                  transition: background 0.3s, border-color 0.3s; }
        .topbar-title { font-size: 16px; font-weight: 600; color: var(--text-primary); letter-spacing: -0.3px; }
        .topbar-right { display: flex; align-items: center; gap: 10px; }
        /* date-chip, pw-dark-toggle, bell-btn styles moved to topbar-actions.jspf include */
        .content { padding: 1.6rem 2rem; flex: 1; }


        /* ── ANNOUNCEMENT CARDS ── */
        .ann-card {
            background: var(--bg-card); border: 1px solid var(--border-color);
            border-radius: 12px; padding: 16px 18px; margin-bottom: 12px;
            display: flex; align-items: flex-start; gap: 14px;
            box-shadow: 0 1px 4px rgba(15,39,68,0.06);
            transition: background 0.2s, border-color 0.2s;
        }
        .ann-card.pinned { border-left: 4px solid #d97706; }
        [data-theme="dark"] .ann-card.pinned { border-left-color: #fbbf24; }
        .ann-content { flex: 1; min-width: 0; }
        .ann-header { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; flex-wrap: wrap; }
        .ann-title { font-size: 14px; font-weight: 700; color: var(--text-primary); }
        .pin-badge { background: #fef3c7; color: #92400e; border: 1px solid #fcd34d;
                     font-size: 10px; font-weight: 700; border-radius: 20px;
                     padding: 2px 8px; display: inline-flex; align-items: center; gap: 3px; }
        .ann-body { font-size: 13px; color: var(--text-secondary); line-height: 1.55; }
        .ann-meta { font-size: 11px; color: var(--text-muted); margin-top: 7px;
                    display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .ann-meta i { font-size: 10px; margin-right: 2px; }
        .ann-expiry { color: #f97316; }
        .empty-state { text-align: center; padding: 60px 20px; color: var(--text-muted); }
        .empty-state i { font-size: 40px; display: block; margin-bottom: 12px; }
        .empty-state p { font-size: 13.5px; font-weight: 600; color: var(--text-primary); margin-bottom: 4px; }
        .empty-state span { font-size: 12.5px; }

        /* ── RESPONSIVE ── */
        .menu-toggle { display: none; background: none; border: none; font-size: 18px;
                       cursor: pointer; color: var(--text-primary); padding: 8px 0; margin-right: 12px; }
        @media (max-width: 768px) {
            .sidebar { position: fixed; left: -220px; z-index: 9999;
                       box-shadow: 4px 0 15px rgba(0,0,0,0.25); transition: left 0.3s ease; }
            .sidebar.open { left: 0; }
            .main { margin-left: 0; }
            .topbar { padding: 0 16px; }
            .menu-toggle { display: block !important; }
            .content { padding: 16px; }
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
        <a href="${pageContext.request.contextPath}/studentAnnouncements" class="nav-item active">
            <i class="fa-solid fa-bullhorn"></i> Announcements
        </a>
        <a href="${pageContext.request.contextPath}/studentExamSchedule" class="nav-item">
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
            <span class="topbar-title">Announcements</span>
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

        <% if (announcements == null || announcements.isEmpty()) { %>
        <div class="empty-state">
            <i class="fa-regular fa-bell-slash"></i>
            <p>No announcements right now.</p>
            <span>Check back later for updates from your teachers.</span>
        </div>
        <% } else { %>

        <% for (Announcement ann : announcements) { %>
        <div class="ann-card <%= ann.isPinned() ? "pinned" : "" %>">
            <div class="ann-content">
                <div class="ann-header">
                    <span class="ann-title"><%= ann.getTitle() %></span>
                    <% if (ann.isPinned()) { %>
                    <span class="pin-badge">
                        <i class="fa-solid fa-thumbtack" style="font-size:8px;"></i> Pinned
                    </span>
                    <% } %>
                </div>
                <div class="ann-body"><%= ann.getBody() %></div>
                <div class="ann-meta">
                    <span><i class="fa-regular fa-user"></i><%= ann.getCreatorUsername() != null ? ann.getCreatorUsername() : "Admin" %></span>
                    <span><i class="ti ti-calendar"></i><%= ann.getCreatedAtFormatted() %></span>
                    <% if (ann.getExpiresAt() != null) { %>
                    <span class="ann-expiry"><i class="fa-regular fa-clock"></i>Expires <%= ann.getExpiresAtFormatted() %></span>
                    <% } %>
                </div>
            </div>
        </div>
        <% } %>

        <% } %>

    </div><!-- /content -->
</div><!-- /main -->

<script>
function toggleSidebar() {
    document.getElementById('sidebarNav').classList.toggle('open');
}
</script>

<div class="pw-toast-container" id="pwToastContainer"></div>
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
</body>
</html>
