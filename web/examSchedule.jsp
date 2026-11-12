<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.ExamSchedule" %>
<%@ page import="java.util.List" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"admin".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<ExamSchedule> exams = (List<ExamSchedule>) request.getAttribute("exams");

    String username = loggedInUser.getUsername();
    String initials = username.length() >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();

    int pendingCount = request.getAttribute("pendingRequestsCount") != null
        ? (int) request.getAttribute("pendingRequestsCount") : 0;
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
            --bg-body:#f8fafc; --bg-card:#ffffff; --bg-sidebar:#0f2744;
            --text-primary:#0f2744; --text-secondary:#475569; --text-muted:#64748b;
            --border-color:#e2e8f0; --border-faint:#f1f5f9;
            --btn-bg:#f1f5f9; --input-bg:#ffffff; --input-border:#cbd5e1;
            --input-focus-bg:#ffffff; --topbar-bg:#ffffff; --bell-dot-border:#ffffff;
        }
        :root[data-theme="dark"] {
            --bg-body:#0f172a; --bg-card:#1e293b; --bg-sidebar:#0a1628;
            --text-primary:#f1f5f9; --text-secondary:#94a3b8; --text-muted:#64748b;
            --border-color:#334155; --border-faint:#1e293b;
            --btn-bg:#1e293b; --input-bg:#1e293b; --input-border:#475569;
            --input-focus-bg:#0f172a; --topbar-bg:#111827; --bell-dot-border:#1e293b;
        }
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;
               background:var(--bg-body); color:var(--text-primary);
               min-height:100vh; display:flex; transition:background .3s,color .3s; }

        /* ── SIDEBAR ── */
        .sidebar { width:220px; flex-shrink:0; background:var(--bg-sidebar); display:flex;
                   flex-direction:column; position:fixed; top:0; left:0; height:100vh;
                   overflow-y:auto; z-index:100; border-right:1px solid var(--border-color);
                   transition:background .3s,border-color .3s,left .3s ease; }
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
                    margin:1px 8px; border-radius:8px; font-size:13px; color:rgba(255,255,255,.55);
                    text-decoration:none; cursor:pointer; transition:background .15s,color .15s; }
        .nav-item i { font-size:14px; margin:0; width:16px; text-align:center; flex-shrink:0; }
        .nav-item:hover  { background:rgba(255,255,255,.06); color:rgba(255,255,255,.85); }
        .nav-item.active { background:rgba(255,255,255,.13); color:#fff; font-weight:500; }
        .nav-badge { margin-left:auto; background:#e53e3e; color:#fff; font-size:10px;
                     border-radius:10px; padding:1px 6px; font-weight:600; }
        .sidebar-bottom { margin-top:auto; border-top:1px solid rgba(255,255,255,.08); padding:12px 8px; }
        .user-row { display:flex; align-items:center; gap:9px; padding:6px 10px 10px; }
        .avatar { width:32px; height:32px; background:rgba(255,255,255,.15); border-radius:50%;
                  display:flex; align-items:center; justify-content:center;
                  font-size:11px; font-weight:700; color:#fff; flex-shrink:0; }
        .user-meta .u-name { font-size:12px; font-weight:700; color:#fff; }
        .user-meta .u-role { font-size:10px; color:rgba(255,255,255,.35); }
        .logout-btn { display:flex; align-items:center; gap:8px; width:100%; padding:8px 14px;
                      border-radius:8px; background:none; border:none; cursor:pointer;
                      font-size:13px; color:rgba(255,100,100,.7); transition:background .15s,color .15s; text-align:left; }
        .logout-btn i { font-size:13px; margin:0; }
        .logout-btn:hover { background:rgba(255,80,80,.1); color:#ff6b6b; }

        /* ── MAIN ── */
        .main { margin-left:220px; flex:1; display:flex; flex-direction:column; min-height:100vh; min-width:0; }
        .topbar { background:var(--topbar-bg); height:56px; padding:0 24px;
                  display:flex; align-items:center; justify-content:space-between;
                  border-bottom:1px solid var(--border-color); flex-shrink:0;
                  transition:background .3s,border-color .3s; }
        .topbar-title { font-size:18px; font-weight:700; letter-spacing:-.3px; color:var(--text-primary); }
        .topbar-right { display:flex; align-items:center; gap:10px; }
        /* date-chip, pw-dark-toggle, bell-btn styles moved to topbar-actions.jspf include */

        /* ── NOTIFICATION DROPDOWN ── */
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
        .notif-item { display: flex; align-items: flex-start; gap: 10px;
                      padding: 10px 16px; border-bottom: 1px solid var(--border-faint);
                      text-decoration: none; cursor: pointer; transition: background .15s;
                      width: 100%; text-align: left; border: none; font-family: inherit; }
        .notif-item:last-child { border-bottom: none; }
        .notif-item.unread { background: #eff6ff; }
        [data-theme="dark"] .notif-item.unread { background: #1e3a5f22; }
        .notif-item:hover { background: var(--border-faint); }
        .notif-icon { width: 30px; height: 30px; border-radius: 50%; background: #dbeafe;
                      display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .notif-icon i { font-size: 13px; color: #2563eb; margin: 0; }
        .notif-msg { font-size: 12.5px; color: var(--text-primary); line-height: 1.4; flex: 1; }
        .notif-time { font-size: 10.5px; color: var(--text-muted); margin-top: 3px; }
        .notif-empty { text-align: center; padding: 28px 16px; color: var(--text-muted);
                       font-size: 12.5px; }

        .content { padding:1.6rem 2rem; flex:1; }


        /* ── SECTION CARD ── */
        .section-card { background:var(--bg-card); border-radius:16px; border:1px solid var(--border-color);
                        overflow:hidden; margin-bottom:20px;
                        box-shadow:0 1px 4px rgba(15,39,68,.06); transition:background .3s,border-color .3s; }
        .section-header { display:flex; align-items:center; justify-content:space-between;
                          padding:1.1rem 1.4rem; border-bottom:1px solid var(--border-color); }
        .section-header-left { display:flex; align-items:center; gap:8px; }
        .section-title { font-size:14.5px; font-weight:700; color:var(--text-primary); }

        /* ── CREATE FORM ── */
        .form-grid { padding:1.4rem; display:grid; gap:14px; }
        .form-group { display:flex; flex-direction:column; gap:5px; }
        .form-group label { font-size:12.5px; font-weight:600; color:var(--text-primary); }
        .form-group input[type=text],
        .form-group input[type=date],
        .form-group select {
            border:1.5px solid var(--input-border); border-radius:9px;
            padding:8px 12px; font-size:13px; color:var(--text-primary);
            background:var(--input-bg); font-family:inherit; outline:none;
            transition:border .18s,box-shadow .18s; width:100%;
        }
        .form-group input:focus, .form-group select:focus {
            border-color:#3b82f6; background:var(--input-focus-bg);
            box-shadow:0 0 0 3px rgba(59,130,246,.1);
        }
        .form-row { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
        .btn-primary { background:#0f2744; color:#fff; border:none; border-radius:9px;
                       padding:9px 20px; font-size:13px; font-weight:600; font-family:inherit;
                       cursor:pointer; display:inline-flex; align-items:center; gap:6px;
                       transition:background .18s; }
        .btn-primary:hover { background:#1a3a5c; }

        /* ── TABLE ── */
        .data-table-wrap { overflow-x:auto; }
        .data-table { width:100%; border-collapse:collapse; }
        .data-table thead tr { background:var(--bg-body); }
        .data-table th { font-size:11px; color:var(--text-muted); text-transform:uppercase;
                         letter-spacing:.06em; padding:.8rem 1.1rem; text-align:left;
                         border-bottom:1px solid var(--border-color); font-weight:600; }
        .data-table td { padding:1rem 1.1rem; border-bottom:1px solid var(--border-faint);
                         font-size:13.5px; color:var(--text-secondary); line-height:1.5;
                         transition:background .3s; }
        .data-table tbody tr:last-child td { border-bottom:none; }
        .data-table tbody tr:hover td { background:var(--border-faint); }
        .td-subject { font-weight:600; color:var(--text-primary); }
        .code-pill { background:#eef2ff; color:#3730a3; font-size:11px; border-radius:6px; padding:3px 8px; font-weight:500; }
        [data-theme="dark"] .code-pill { background:#1e3a5f; color:#93c5fd; }
        .exam-type-pill { font-size:11px; border-radius:6px; padding:3px 8px; font-weight:500;
                          background:#f0fdf4; color:#166534; }
        .btn-delete { background:#fef2f2; color:#991b1b; border:1.5px solid #fecaca;
                      border-radius:7px; padding:5px 11px; font-size:11.5px; font-weight:600;
                      cursor:pointer; display:inline-flex; align-items:center; gap:4px;
                      font-family:inherit; transition:background .15s; }
        .btn-delete:hover { background:#fee2e2; }
        .btn-edit { background:#eff6ff; color:#1e40af; border:1.5px solid #bfdbfe;
                    border-radius:7px; padding:5px 11px; font-size:11.5px; font-weight:600;
                    cursor:pointer; display:inline-flex; align-items:center; gap:4px;
                    font-family:inherit; transition:background .15s; margin-right:6px; }
        .btn-edit:hover { background:#dbeafe; }
        .empty-state { text-align:center; padding:40px 20px; color:var(--text-muted); }
        .empty-state i { font-size:36px; display:block; margin-bottom:10px; }

        /* ── RESPONSIVE ── */
        .menu-toggle { display:none; background:none; border:none; font-size:18px; cursor:pointer;
                       color:var(--text-primary); padding:8px 0; margin-right:12px; }
        @media(max-width:768px) {
            .sidebar { position:fixed; left:-220px; top:0; bottom:0; z-index:9999;
                       box-shadow:4px 0 15px rgba(0,0,0,.25); transition:left .3s ease; }
            .sidebar.open { left:0; }
            .main { margin-left:0; }
            .topbar { padding:0 16px; }
            .menu-toggle { display:block !important; }
            .content { padding:16px; }
            .form-row { grid-template-columns:1fr; }
        }

        /* ── TOAST ── */
        #pwToast {
            position:fixed; bottom:24px; left:50%;
            transform:translateX(-50%) translateY(30px);
            background:var(--bg-sidebar, #0f2744); color:#fff;
            border-radius:10px; padding:10px 22px; font-size:13px; font-weight:500;
            display:flex; align-items:center; gap:8px;
            opacity:0; transition:opacity .3s ease,transform .3s ease;
            pointer-events:none; z-index:9999; white-space:nowrap;
        }
        #pwToast i { font-size:16px; color:#4ade80; }

        /* ── MODAL ── */
        .modal { display:none; position:fixed; top:0; left:0; width:100%; height:100%;
                 background:rgba(15,39,68,0.4); z-index:10000; align-items:center; justify-content:center; }
        .modal.show { display:flex; }
        .modal-box { background:var(--bg-card); border-radius:12px; width:90%; max-width:480px;
                     box-shadow:0 10px 40px rgba(0,0,0,0.2); animation:modalSlideIn 0.2s ease; }
        @keyframes modalSlideIn { from { transform:translateY(-20px); opacity:0; } to { transform:translateY(0); opacity:1; } }
        .modal-header { padding:16px 20px; border-bottom:1px solid var(--border-color);
                        display:flex; align-items:center; justify-content:space-between; }
        .modal-title { font-size:16px; font-weight:600; color:var(--text-primary); }
        .modal-close { background:none; border:none; font-size:20px; cursor:pointer;
                       color:var(--text-muted); padding:0; width:24px; height:24px; }
        .modal-body { padding:20px; }
        .modal-footer { padding:14px 20px; border-top:1px solid var(--border-color);
                        display:flex; gap:10px; justify-content:flex-end; }
        .btn-primary { background:#2563eb; color:#fff; border:none; border-radius:7px;
                       padding:8px 16px; font-size:13px; font-weight:600; cursor:pointer;
                       font-family:inherit; transition:background .15s; }
        .btn-primary:hover { background:#1d4ed8; }
        .btn-secondary { background:var(--btn-bg); color:var(--text-primary); border:1px solid var(--border-color);
                         border-radius:7px; padding:8px 16px; font-size:13px; font-weight:600; cursor:pointer;
                         font-family:inherit; transition:background .15s; }
        .btn-secondary:hover { background:var(--border-color); }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/ui-consistency.css">
</head>
<body>

<!-- ═══════════ SIDEBAR ═══════════ -->
<nav class="sidebar" id="sidebarNav">
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
        <a href="${pageContext.request.contextPath}/analytics" class="nav-item">
            <i class="ti ti-chart-bar"></i> Analytics
        </a>
        <a href="${pageContext.request.contextPath}/announcements" class="nav-item">
            <i class="fa-solid fa-bullhorn"></i> Announcements
        </a>
        <a href="${pageContext.request.contextPath}/examSchedule" class="nav-item active">
            <i class="fa-solid fa-calendar"></i> Exam Schedule
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
            <% if (request.getAttribute("unreadCount") != null) { %>
                <div class="notif-dropdown" id="notifDropdown">
                <div class="notif-header">
                    <span class="notif-header-title">Notifications</span>
                    <%
                    @SuppressWarnings("unchecked")
                    java.util.List<com.paperwise.model.Notification> adminNotificationsList =
                        (java.util.List<com.paperwise.model.Notification>) request.getAttribute("notificationsList");
                    if (adminNotificationsList == null) adminNotificationsList = new java.util.ArrayList<>();
                    %>
                    <% if (!adminNotificationsList.isEmpty()) { %>
                    <form action="${pageContext.request.contextPath}/notifications" method="post" style="margin:0;">
                        <input type="hidden" name="action" value="markAllRead">
                        <button type="submit" class="notif-mark-all">Mark all read</button>
                    </form>
                    <% } %>
                </div>
                <div class="notif-list">
                    <% if (adminNotificationsList.isEmpty()) { %>
                    <div class="notif-empty">No notifications yet</div>
                    <% } else { for (com.paperwise.model.Notification n : adminNotificationsList) { %>
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
        <% } %>
    </div><!-- close notif-wrap -->
    </div><!-- close topbar-right -->
    </div><!-- close topbar -->

    <div class="content">

        <!-- ── CREATE FORM ── -->
        <div class="section-card">
            <div class="section-header">
                <div class="section-header-left">
                    <i class="fa-solid fa-calendar-plus" style="color:#0f2744;font-size:14px;"></i>
                    <span class="section-title">Add Exam</span>
                </div>
            </div>
            <form action="${pageContext.request.contextPath}/examSchedule" method="post">
                <div class="form-grid">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="subjectName">Subject Name <span style="color:#ef4444">*</span></label>
                            <input type="text" id="subjectName" name="subjectName" maxlength="100"
                                   placeholder="e.g., Data Structures" required>
                        </div>
                        <div class="form-group">
                            <label for="subjectCode">Subject Code <span style="color:#ef4444">*</span></label>
                            <input type="text" id="subjectCode" name="subjectCode" maxlength="50"
                                   placeholder="e.g., CS301" required>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="examType">Exam Type <span style="color:#ef4444">*</span></label>
                            <input type="text" id="examType" name="examType" maxlength="50"
                                   placeholder="e.g., Mid Term, Lab Exam, Quiz..." required>
                        </div>
                        <div class="form-group">
                            <label for="examDate">Exam Date <span style="color:#ef4444">*</span></label>
                            <input type="date" id="examDate" name="examDate" required>
                        </div>
                    </div>
                    <div>
                        <button type="submit" class="btn-primary">
                            <i class="fa-solid fa-plus"></i> Add Exam
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!-- ── EXAMS TABLE ── -->
        <div class="section-card">
            <div class="section-header">
                <div class="section-header-left">
                    <i class="fa-solid fa-list" style="color:#64748b;font-size:14px;"></i>
                    <span class="section-title">All Scheduled Exams</span>
                    <span style="background:#eef2ff;color:#3730a3;font-size:11px;padding:3px 9px;border-radius:20px;font-weight:600;">
                        <%= exams != null ? exams.size() : 0 %>
                    </span>
                </div>
            </div>

            <% if (exams == null || exams.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fa-regular fa-calendar-xmark"></i>
                    <p style="font-size:13px;font-weight:600;color:var(--text-primary);">No exams scheduled yet.</p>
                    <p style="font-size:12px;margin-top:4px;">Use the form above to add one.</p>
                </div>
            <% } else { %>
            <div class="data-table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Subject</th>
                        <th>Code</th>
                        <th>Exam Type</th>
                        <th>Date</th>
                        <th>Added By</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <% for (ExamSchedule exam : exams) { %>
                <tr>
                    <td class="td-subject"><%= exam.getSubjectName() %></td>
                    <td><span class="code-pill"><%= exam.getSubjectCode() %></span></td>
                    <td><span class="exam-type-pill"><%= exam.getExamType() %></span></td>
                    <td><%= exam.getExamDateFormatted() %></td>
                    <td style="font-size:12.5px;color:var(--text-muted);"><%= exam.getCreatedBy() %></td>
                    <td>
                        <button type="button" class="btn-edit"
                                onclick="openEditModal(<%= exam.getId() %>, '<%= exam.getSubjectName().replace("'", "\\'") %>', '<%= exam.getSubjectCode() %>', '<%= exam.getExamType() %>', '<%= exam.getExamDateIso() %>')">
                            <i class="ti ti-edit"></i> Edit
                        </button>
                        <form action="${pageContext.request.contextPath}/examSchedule" method="post"
                              onsubmit="return confirm('Delete this exam entry?')" style="display:inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%= exam.getId() %>">
                            <button type="submit" class="btn-delete">
                                <i class="ti ti-trash"></i> Delete
                            </button>
                        </form>
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

<!-- Edit Modal -->
<div class="modal" id="editModal">
    <div class="modal-box">
        <div class="modal-header">
            <span class="modal-title">Edit Exam Schedule</span>
            <button type="button" class="modal-close" onclick="closeEditModal()">×</button>
        </div>
        <form action="${pageContext.request.contextPath}/examSchedule" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="editId">
            <div class="modal-body">
                <div class="form-group">
                    <label for="editSubjectName" class="form-label">Subject Name</label>
                    <input type="text" id="editSubjectName" name="subjectName" class="form-input" required>
                </div>
                <div class="form-group">
                    <label for="editSubjectCode" class="form-label">Subject Code</label>
                    <input type="text" id="editSubjectCode" name="subjectCode" class="form-input" required>
                </div>
                <div class="form-group">
                    <label for="editExamType" class="form-label">Exam Type</label>
                    <input type="text" id="editExamType" name="examType" class="form-input" placeholder="e.g. Mid-Sem, End-Sem" required>
                </div>
                <div class="form-group">
                    <label for="editExamDate" class="form-label">Exam Date</label>
                    <input type="date" id="editExamDate" name="examDate" class="form-input" required>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary" onclick="closeEditModal()">Cancel</button>
                <button type="submit" class="btn-primary">Update Exam</button>
            </div>
        </form>
    </div>
</div>

<script>
function toggleSidebar() {
    document.getElementById('sidebarNav').classList.toggle('open');
}
(function() {
    var d = new Date();
    var el = document.getElementById('pageDate');
})();
</script>

<div id="pwToast"><i class="ti ti-circle-check"></i><span id="pwToastMsg"></span></div>
<script>
function showSimpleToast(msg) {
    var t = document.getElementById('pwToast');
    var m = document.getElementById('pwToastMsg');
    if (!t || !m) return;
    m.textContent = msg;
    t.style.opacity = '1';
    t.style.transform = 'translateX(-50%) translateY(0)';
    setTimeout(function () {
        t.style.opacity = '0';
        t.style.transform = 'translateX(-50%) translateY(30px)';
    }, 3000);
}

window.addEventListener('load', function () {
    var p = new URLSearchParams(window.location.search);
    if (p.get('created') === 'true')        showSimpleToast('Exam added successfully!');
    else if (p.get('updated') === 'true')   showSimpleToast('Exam updated successfully!');
    else if (p.get('deleted') === 'true')   showSimpleToast('Exam deleted.');
    else if (p.get('error') === 'invalid')  showSimpleToast('All fields are required.');
    else if (p.get('error') === 'true')     showSimpleToast('Something went wrong. Please try again.');
});

function openEditModal(id, subjectName, subjectCode, examType, examDate) {
    document.getElementById('editId').value = id;
    document.getElementById('editSubjectName').value = subjectName;
    document.getElementById('editSubjectCode').value = subjectCode;
    document.getElementById('editExamType').value = examType;
    document.getElementById('editExamDate').value = examDate;
    document.getElementById('editModal').classList.add('show');
}

function closeEditModal() {
    document.getElementById('editModal').classList.remove('show');
}

// Close modal when clicking outside
document.addEventListener('click', function(e) {
    var modal = document.getElementById('editModal');
    if (e.target === modal) {
        closeEditModal();
    }
});
</script>
</body>
</html>
>

<script>
// Notification dropdown toggle
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
