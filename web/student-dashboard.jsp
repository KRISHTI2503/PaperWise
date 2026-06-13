<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="com.paperwise.model.Paper" %>
<%@ page import="com.paperwise.model.PaperRequest" %>
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
    @SuppressWarnings("unchecked")
    List<PaperRequest> myRequests = (List<PaperRequest>) request.getAttribute("myRequests");
    @SuppressWarnings("unchecked")
    List<Integer> availableYears = (List<Integer>) request.getAttribute("availableYears");
    @SuppressWarnings("unchecked")
    Map<Integer, List<PaperComment>> commentsMap = (Map<Integer, List<PaperComment>>) request.getAttribute("commentsMap");

    int totalPapers      = request.getAttribute("totalPapers")      != null ? (int) request.getAttribute("totalPapers")      : 0;
    int totalUsefulMarks = request.getAttribute("totalUsefulMarks") != null ? (int) request.getAttribute("totalUsefulMarks") : 0;
    int myMarksCount     = request.getAttribute("myMarksCount")     != null ? (int) request.getAttribute("myMarksCount")     : 0;
    Integer selectedYear = (Integer) request.getAttribute("selectedYear");
    String searchQuery   = (String)  request.getAttribute("searchQuery");

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
    <title>Student Dashboard - PaperWise</title>
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
            /* Page background */
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
            --bg-sidebar: #0a1628;

            /* Topbar */
            --topbar-bg: #111827;
            --topbar-border: #1e293b;

            /* Old system mapping compatibility */
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

        [data-theme="dark"] .exam-pill {
            background: #1e293b;
            color: #94a3b8;
            border-color: #334155;
        }

        [data-theme="dark"] .year-val {
            color: #60a5fa;
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

        /* ── SIDEBAR ── */
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
            transition: background 0.15s, color 0.15s;
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
 
        /* ── MAIN ── */
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

        /* ── STAT CARDS ── */
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

        /* ── SECTION CARD ── */
        .section-card {
            background: var(--bg-card); border-radius: 16px;
            border: 1px solid var(--border-color); overflow: hidden; margin-bottom: 20px;
            transition: background 0.3s, border-color 0.3s;
            box-shadow: 0 1px 4px rgba(15,39,68,0.06);
        }
        .section-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 1.1rem 1.4rem; border-bottom: 1px solid var(--border-color);
            transition: border-color 0.3s;
        }
        .section-header-left { display: flex; align-items: center; gap: 8px; }
        .section-title { font-size: 14px; font-weight: 600; color: var(--text-primary); }
        .count-pill {
            font-size: 11px; padding: 3px 9px; border-radius: 20px; font-weight: 500;
        }
        .count-pill.indigo { background: #eef2ff; color: #3730a3; }
        .count-pill.amber  { background: #fff4e0; color: #854f0b; }

        /* ── FILTER BAR ── */
        .filter-bar {
            display: flex; align-items: center; gap: 10px;
            padding: 12px 18px; border-bottom: 1px solid var(--border-color); flex-wrap: wrap;
            transition: border-color 0.3s;
        }
        .search-input {
            flex: 1; min-width: 180px; max-width: 320px;
            border: 1.5px solid var(--input-border); border-radius: 10px;
            padding: 7px 12px 7px 32px; font-size: 13px; color: var(--text-primary);
            background: var(--input-bg) url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%239ca3af' stroke-width='2'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cpath d='m21 21-4.35-4.35'/%3E%3C/svg%3E") no-repeat 10px center;
            outline: none; transition: border .18s, background-color .18s;
        }
        .search-input:focus { border-color: #3b82f6; background-color: var(--input-focus-bg); }
        .year-select {
            border: 1.5px solid var(--input-border); border-radius: 10px;
            padding: 7px 28px 7px 10px; font-size: 13px; color: var(--text-primary);
            background: var(--input-bg); outline: none; cursor: pointer;
            appearance: none; transition: border .18s, background-color .18s;
        }
        .year-select:focus { border-color: #3b82f6; background-color: var(--input-focus-bg); }

        /* ── TABLE ── */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table thead tr { background: var(--table-th-bg); }
        .data-table th {
            font-size: 11px; color: var(--text-muted); text-transform: uppercase;
            letter-spacing: 0.06em; padding: .8rem 1.1rem; text-align: left;
            border-bottom: 1px solid var(--border-color); font-weight: 600;
        }
        .data-table td {
            padding: 1rem 1.1rem; border-bottom: 1px solid var(--border-color);
            font-size: 13.5px; color: var(--table-td-text); line-height: 1.5;
            transition: background 0.3s;
        }
        .data-table tbody tr:last-child td { border-bottom: none; }
        .data-table tbody tr:hover td { background: var(--table-hover-bg); }
        .td-subject { font-weight: 600; color: var(--text-primary); }
        .code-pill { background: #eef2ff; color: #3730a3; font-size: 11px; border-radius: 6px; padding: 3px 8px; font-weight: 500; }
        .year-pill  { background: #162636; color: #fff; font-size: 11px; border-radius: 6px; padding: 3px 8px; font-weight: 500; }

        /* Difficulty badge */
        .diff-badge {
            font-size: 11.5px;
            font-weight: 600;
            border-radius: 20px;
            padding: 3px 10px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .diff-badge i { font-size: 10px; margin: 0; }
        .diff-easy   { background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0; }
        .diff-medium { background: #fffbeb; color: #92400e; border: 1px solid #fde68a; }
        .diff-hard   { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }
        .diff-mixed  { background: #f5f3ff; color: #5b21b6; border: 1px solid #ddd6fe; }
        .diff-none   { background: #f9fafb; color: #6b7280; border: 1px solid #e5e7eb; }

        /* Action buttons */
        .action-btns { display: flex; gap: 5px; flex-wrap: wrap; }
        .act-btn {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 5px 10px; border-radius: 8px; font-size: 11px;
            font-weight: 500; border: 1.5px solid transparent; cursor: pointer;
            text-decoration: none; transition: opacity .15s, background .15s;
        }
        .act-btn i { font-size: 10px; margin: 0; }
        .act-btn:hover { opacity: 0.82; }
        .act-view     { background: #eff6ff; color: #1d4ed8; border-color: #bfdbfe; }
        .act-download { background: #f0fdf4; color: #166534; border-color: #bbf7d0; }
        .act-vote     { background: transparent; color: var(--text-primary); border-color: var(--border-color); }
        .act-vote:hover { background: var(--btn-bg); }
        .act-vote i   { color: #64748b; }
        .act-voted    { background: var(--btn-bg); color: var(--text-muted); border-color: transparent; cursor: not-allowed; }
        .act-marked   { background: #f1f5f9; color: #0f2744; border-color: transparent; font-weight: 600; }
        .act-easy     { background: #f0fdf4; color: #166534; border-color: transparent; }
        .act-medium   { background: #fff7ed; color: #9a3412; border-color: transparent; }
        .act-hard     { background: #fef2f2; color: #991b1b; border-color: transparent; }
        .act-diff-selected { outline: 2px solid currentColor; outline-offset: 1px; font-weight: 700; }
        .selected-diff { outline: 2px solid currentColor; outline-offset: 1px; font-weight: 700; }

        /* Popular badge */
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
            margin-left: 5px;
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

        /* Date cell */
        .date-cell { font-size: 11px; color: var(--text-muted); white-space: nowrap; }

        /* Empty state */
        .empty-state { text-align: center; padding: 48px 20px; color: var(--text-muted); }
        .empty-state i { font-size: 36px; margin: 0 0 10px; display: block; color: var(--border-color); }
        .empty-state p { font-size: 13px; color: var(--text-muted); }

        /* Useful count — blue bold */
        .useful-num { color: #0f2744; font-weight: 700; font-size: 13.5px; }

        /* Requests table */
        .status-pill {
            font-size: 11.5px;
            font-weight: 600;
            border-radius: 20px;
            padding: 3px 10px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .status-pill i { font-size: 10px; margin: 0; }
        .s-pending   { background: #fffbeb; color: #92400e; border: 1px solid #fde68a; }
        .s-completed { background: #e8f5e9; color: #1b5e20; border: 1px solid #a5d6a7; }
        .s-rejected  { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

        .act-delete-sm { background: #fef2f2; color: #991b1b; }

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

        /* Theme Toggle Button */
        .theme-toggle-btn {
            background: none;
            border: none;
            font-size: 16px;
            cursor: pointer;
            color: var(--text-secondary);
            width: 34px;
            height: 34px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.3s, color 0.3s;
        }
        .theme-toggle-btn:hover {
            background: var(--btn-bg);
            color: var(--text-primary);
        }

        /* ── REQUEST PAPER BUTTON ── */
        .btn-request-paper {
            display: inline-flex; align-items: center; gap: 6px;
            background: #1e3a5f; color: #fff; border: none;
            border-radius: 8px; padding: 7px 14px; font-size: 12px;
            font-weight: 500; cursor: pointer; transition: background .15s;
        }
        .btn-request-paper i { font-size: 11px; margin: 0; }
        .btn-request-paper:hover { background: #0d2a45; }

        /* ── MODAL OVERLAY ── */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,0.45); z-index: 1000;
            align-items: center; justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal-box {
            background: var(--bg-card); border-radius: 14px;
            width: 100%; max-width: 460px; padding: 28px 28px 24px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.18);
            position: relative; animation: modalIn .18s ease;
            color: var(--text-primary);
        }
        @keyframes modalIn {
            from { opacity: 0; transform: translateY(-12px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .modal-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 20px;
        }
        .modal-title { font-size: 15px; font-weight: 700; color: var(--text-primary); }
        .modal-close {
            background: none; border: none; cursor: pointer;
            color: var(--text-muted); font-size: 18px; line-height: 1;
            padding: 2px 6px; border-radius: 6px; transition: color .15s;
        }
        .modal-close:hover { color: var(--text-primary); }
        .form-group { margin-bottom: 14px; }
        .form-label {
            display: block; font-size: 12px; font-weight: 600;
            color: var(--text-primary); margin-bottom: 5px;
        }
        .form-label .req { color: #e53e3e; margin-left: 2px; }
        .form-input, .form-textarea {
            width: 100%; border: 1.5px solid var(--input-border); border-radius: 8px;
            padding: 8px 12px; font-size: 13px; color: var(--text-primary);
            background: var(--input-bg); outline: none; transition: border .18s, background-color .18s;
            font-family: inherit;
        }
        .form-input:focus, .form-textarea:focus { border-color: #3b82f6; background: var(--input-focus-bg); }
        .form-textarea { resize: vertical; min-height: 72px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .modal-error {
            background: #fff0f0; border: 1px solid #f5c6cb; color: #c0392b;
            border-radius: 8px; padding: 8px 12px; font-size: 12px;
            margin-bottom: 14px; display: none;
        }
        .modal-error.show { display: block; }
        .btn-submit-request {
            width: 100%; background: #1e3a5f; color: #fff; border: none;
            border-radius: 8px; padding: 10px; font-size: 13px; font-weight: 600;
            cursor: pointer; transition: background .15s; margin-top: 4px;
        }
        .btn-submit-request:hover { background: #0d2a45; }
        .btn-submit-request:disabled { background: #93c5fd; cursor: not-allowed; }

        @media (max-width: 768px) {
            body {
                flex-direction: column;
            }
            .sidebar {
                position: fixed;
                left: -220px;
                top: 0;
                bottom: 0;
                z-index: 9999;
                box-shadow: 4px 0 15px rgba(0, 0, 0, 0.25);
                transition: left 0.3s ease;
            }
            .sidebar.open {
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
        <a href="${pageContext.request.contextPath}/studentDashboard" class="nav-item active">
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
            <span class="topbar-title">Student Dashboard</span>
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


        <!-- ── PAPERS TABLE ── -->
        <div class="section-card" id="papersSection">
            <div class="section-header">
                <div class="section-header-left">
                    <span class="section-title">All Papers</span>
                </div>
            </div>

            <!-- Filter bar -->
            <div class="filter-bar">
                <input type="text"
                       id="searchInput"
                       class="search-input"
                       placeholder="Search subject, code, year…"
                       oninput="filterTable()"
                       value="<%= searchQuery != null ? searchQuery : "" %>">
                <select id="yearFilter" class="year-select"
                        onchange="filterTable()">
                    <option value="all" <%= selectedYear == null ? "selected" : "" %>>All Years</option>
                    <% if (availableYears != null) {
                           for (Integer yr : availableYears) { %>
                        <option value="<%= yr %>" <%= (selectedYear != null && selectedYear.equals(yr)) ? "selected" : "" %>><%= yr %></option>
                    <% } } %>
                </select>
            </div>

            <% if (papers != null && !papers.isEmpty()) { %>
            <div class="data-table-container">
            <table class="data-table" id="papersTable">
                <thead>
                    <tr>
                        <th>Subject</th>
                        <th>Code</th>
                        <th>Year</th>
                        <th>Chapter</th>
                        <th>Exam Type</th>
                        <th>Useful</th>
                        <th>Difficulty</th>
                        <th>Uploaded</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="papersTableBody">
                <%
                for (Paper paper : papers) {
                    pageContext.setAttribute("paper", paper);
                    String diffLabel = paper.getDifficultyLabel();
                    if (diffLabel == null || diffLabel.isEmpty()) diffLabel = "Not Rated";
                    String diffCls = "diff-none";
                    String diffIcon = "";
                    if ("Easy".equalsIgnoreCase(diffLabel))   { diffCls = "diff-easy";   diffIcon = "fa-solid fa-check"; }
                    else if ("Medium".equalsIgnoreCase(diffLabel)) { diffCls = "diff-medium"; diffIcon = "fa-solid fa-minus"; }
                    else if ("Hard".equalsIgnoreCase(diffLabel))   { diffCls = "diff-hard";   diffIcon = "fa-solid fa-exclamation"; }

                    // Derive file-type badge from fileUrl extension
                    String fileUrl = paper.getFileUrl() != null ? paper.getFileUrl().toLowerCase() : "";
                    String ftClass = "ft-other";
                    String ftLabel = "FILE";
                    if      (fileUrl.endsWith(".pdf"))                          { ftClass = "ft-pdf";  ftLabel = "PDF"; }
                    else if (fileUrl.endsWith(".doc") || fileUrl.endsWith(".docx")) { ftClass = "ft-doc";  ftLabel = "DOC"; }
                    else if (fileUrl.endsWith(".ppt") || fileUrl.endsWith(".pptx")) { ftClass = "ft-ppt";  ftLabel = "PPT"; }
                    else if (fileUrl.endsWith(".jpg") || fileUrl.endsWith(".jpeg") || fileUrl.endsWith(".png")) { ftClass = "ft-img"; ftLabel = "IMG"; }
                    else if (fileUrl.endsWith(".mp4") || fileUrl.endsWith(".mkv")) { ftClass = "ft-vid"; ftLabel = "VID"; }
                    else if (fileUrl.endsWith(".txt"))                          { ftClass = "ft-txt";  ftLabel = "TXT"; }

                    String uploadedDate = paper.getCreatedAt() != null
                        ? paper.getCreatedAt().format(dtf) : "-";

                    int ec = paper.getEasyCount(), mc = paper.getMediumCount(), hc = paper.getHardCount();
                    int totalVotes = ec + mc + hc;
                    String dom = "none";
                    if (totalVotes > 0) {
                        if (ec > mc && ec > hc)      dom = "easy";
                        else if (mc > ec && mc > hc) dom = "medium";
                        else if (hc > ec && hc > mc) dom = "hard";
                        else                          dom = "mixed";
                    }
                    String examAttr = paper.getExamType() != null ? paper.getExamType().toLowerCase() : "";
                %>
                <tr class="paper-row" data-subject="<%= paper.getSubjectName().toLowerCase() %>"
                    data-code="<%= paper.getSubjectCode().toLowerCase() %>"
                    data-year="<%= paper.getYear() %>"
                    data-yr="<%= paper.getYear() %>"
                    data-subj="<%= paper.getSubjectName().toLowerCase() %>"
                    data-diff="<%= dom %>"
                    data-exam="<%= examAttr %>">
                    <td class="td-subject">
                        <span class="ft-badge <%= ftClass %>"><%= ftLabel %></span><%= paper.getSubjectName() %>
                        <% if (paper.isPopular()) { %>
                            <span class="pop-badge"><i class="ti ti-flame" style="color:#ea580c;font-size:11px"></i> Popular</span>
                        <% } %>
                        <% if (paper.getDescription() != null && !paper.getDescription().isEmpty()) { %>
                            <div style="font-size:11px;color:#64748b;margin-top:3px;font-style:italic"><%= paper.getDescription() %></div>
                        <% } %>
                    </td>
                    <td><span class="code-pill"><%= paper.getSubjectCode() %></span></td>
                    <td class="year-cell"><span class="year-pill"><%= paper.getYear() %></span></td>
                    <td><%= paper.getChapter() != null ? paper.getChapter() : "-" %></td>
                    <td>
                        <% String examType = paper.getExamType();
                           if (examType != null && !examType.isEmpty()) {
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
                    <td><span class="useful-num"><%= paper.getUsefulCount() %></span></td>
                    <td>
                        <span class="diff-badge <%= diffCls %>">
                            <%= diffLabel %>
                        </span>
                        <br><small style="font-size:10px;color:#9ca3af;">
                            (<%= paper.getEasyCount() %> | <%= paper.getMediumCount() %> | <%= paper.getHardCount() %>)
                        </small>
                        <% if (paper.getEasyCount() == 0 && paper.getMediumCount() == 0 && paper.getHardCount() == 0) { %>
                        <div style="margin-top:4px">
                            <span style="background:#fff7ed;color:#c2410c;padding:2px 8px;border-radius:20px;font-size:10px;font-weight:600;display:inline-block;border:1px solid #fed7aa"><i class="ti ti-star"></i> Be first to rate!</span>
                        </div>
                        <% } %>
                    </td>
                    <td class="date-cell"><%= uploadedDate %></td>
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
                            <%-- Useful / Bookmark toggle --%>
                            <% boolean isMarked = votedPapers != null && votedPapers.contains(paper.getPaperId()); %>
                            <button type="button"
                                    class="act-btn btn-useful <%= isMarked ? "act-marked" : "act-vote" %>"
                                    data-paper-id="<%= paper.getPaperId() %>"
                                    data-ctx="${pageContext.request.contextPath}"
                                    title="<%= isMarked ? "Unmark" : "Mark as Useful" %>"
                                    style="color:<%= isMarked ? "#2563eb" : "#6c757d" %>">
                                <i class="fa-solid fa-bookmark"></i>
                                <span class="useful-label"><%= isMarked ? "Marked" : "Useful" %></span>
                                (<span class="useful-count"><%= paper.getUsefulCount() %></span>)
                            </button>
                        </div>
                        <div style="display:flex;align-items:center;gap:6px;flex-wrap:nowrap">
                            <button type="button"
                                    class="act-btn act-easy diff-easy"
                                    onclick="rateDiff(this, 'easy', <%= paper.getPaperId() %>)">
                                Easy (<%= paper.getEasyCount() %>)
                            </button>
                            <button type="button"
                                    class="act-btn act-medium diff-med"
                                    onclick="rateDiff(this, 'medium', <%= paper.getPaperId() %>)">
                                Med (<%= paper.getMediumCount() %>)
                            </button>
                            <button type="button"
                                    class="act-btn act-hard diff-hard"
                                    onclick="rateDiff(this, 'hard', <%= paper.getPaperId() %>)">
                                Hard (<%= paper.getHardCount() %>)
                            </button>
                        </div>
                    </td>
                </tr>
                <tr class="comments-row">
                    <td colspan="9" style="padding:0;border-bottom:1px solid #e2e8f0">
                        <div style="padding:0 16px 12px">
                            <%
                                List<PaperComment> commentList = commentsMap != null ? commentsMap.get(paper.getPaperId()) : null;
                                int commentCount = commentList != null ? commentList.size() : 0;
                            %>
                            <%-- Toggle button --%>
                            <button type="button"
                                    class="toggle-comments"
                                    onclick="toggleComments(<%= paper.getPaperId() %>)"
                                    style="background:none;border:none;color:#64748b;font-size:12px;font-weight:500;cursor:pointer;font-family:inherit;padding:6px 0;display:flex;align-items:center;gap:6px">
                                <i class="ti ti-message-circle" style="font-size:15px;color:#64748b"></i>
                                Comments
                                <span style="background:#e5e7eb;color:#374151;border-radius:50%;min-width:20px;height:20px;padding:0 6px;font-size:10px;font-weight:600;display:inline-flex;align-items:center;justify-content:center;line-height:1"><%= commentCount %></span>
                            </button>

                            <%-- Comments section --%>
                            <div id="comments<%= paper.getPaperId() %>" style="display:none;margin-top:8px;background:#ffffff;border:1px solid #e5e7eb;border-radius:8px;padding:12px 14px">
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
                                                    <input type="hidden" name="redirectUrl" value="<%= request.getContextPath() %>/studentDashboard">
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
                                                                <input type="hidden" name="redirectUrl" value="<%= request.getContextPath() %>/studentDashboard">
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
                                                <input type="hidden" name="redirectUrl" value="<%= request.getContextPath() %>/studentDashboard">
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
                                <form action="<%= request.getContextPath() %>/paperComment" method="post" style="display:flex;gap:6px;margin-top:8px;align-items:center">
                                    <input type="hidden" name="action" value="add">
                                    <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
                                    <input type="hidden" name="redirectUrl" value="<%= request.getContextPath() %>/studentDashboard">
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
            <% } else { %>
            <div class="empty-state">
                <i class="fa-regular fa-folder-open" style="color:#cbd5e0;"></i>
                <p>No papers available yet.</p>
            </div>
            <% } %>
        </div>


        <!-- ── MY REQUESTS TABLE ── -->
        <div class="section-card" id="myRequestsSection">
            <div class="section-header">
                <div class="section-header-left">
                    <span class="section-title">My Paper Requests</span>
                    <span class="count-pill amber" id="requestsCountPill"><%= myRequests != null ? myRequests.size() : 0 %></span>
                </div>
                <a href="${pageContext.request.contextPath}/requestPaper"
                   style="background:var(--bg-sidebar);color:#fff;border:none;border-radius:8px;padding:7px 14px;font-size:12.5px;font-weight:600;font-family:inherit;cursor:pointer;display:flex;align-items:center;gap:6px;text-decoration:none">
                    <i class="fa-solid fa-plus"></i> New Request
                </a>
            </div>

            <% if (myRequests != null && !myRequests.isEmpty()) { %>
            <div class="data-table-container">
            <table class="data-table" id="requestsTable">
                <thead>
                    <tr>
                        <th>Subject Name</th>
                        <th>Code</th>
                        <th>Year</th>
                        <th>Description</th>
                        <th>Status</th>
                        <th>ADMIN MESSAGE</th>
                        <th>Requested</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <% for (PaperRequest req : myRequests) {
                    String st = req.getStatus() != null ? req.getStatus().toLowerCase() : "pending";
                    if ("approved".equals(st) || "accepted".equals(st)) {
                        st = "completed";
                    }
                    String stCls = "s-pending";
                    String stIcon = "fa-regular fa-clock";
                    if ("rejected".equals(st))  { stCls = "s-rejected";  stIcon = "fa-solid fa-circle-xmark"; }
                    else if ("completed".equals(st)) { stCls = "s-completed"; stIcon = "fa-solid fa-circle-check"; }
                %>
                <tr id="req-row-<%= req.getRequestId() %>">
                    <td class="td-subject"><%= req.getSubjectName() %></td>
                    <td><span class="code-pill"><%= req.getSubjectCode() %></span></td>
                    <td><span class="year-pill"><%= req.getYear() %></span></td>
                    <td style="max-width:180px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
                        <%= req.getDescription() != null && !req.getDescription().isEmpty() ? req.getDescription() : "-" %>
                    </td>
                    <td>
                        <span class="status-pill <%= stCls %>">
                            <i class="<%= stIcon %>"></i> <%= st %>
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
                    <td style="font-size:12px; color:#6b7280;">
                        <%= req.getCreatedAt() != null ? req.getCreatedAt().format(dtf) : "-" %>
                    </td>
                    <td>
                        <form method="post"
                              action="${pageContext.request.contextPath}/student/deleteRequest"
                              style="display:inline"
                              onsubmit="return confirm('Delete this request?')">
                            <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                            <input type="hidden" name="redirectUrl"
                                   value="${pageContext.request.contextPath}/studentDashboard">
                            <button type="submit" class="act-btn act-delete-sm">
                                <i class="fa-solid fa-trash"></i> Delete
                            </button>
                        </form>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
            </div>
            <% } else { %>
            <div class="empty-state" id="requestsEmpty" style="padding:32px 20px;">
                <i class="fa-regular fa-folder-open" style="color:#cbd5e0; font-size:28px;"></i>
                <p>No requests yet. Click "New Request" to get started.</p>
            </div>
            <% } %>
        </div>

    </div><!-- /content -->
</div><!-- /main -->


<script>
const contextPath = '<%= request.getContextPath() %>';

function filterTable() {
  const searchEl = document.getElementById('searchInput');
  const yearEl = document.getElementById('yearFilter');
  const query = (searchEl ? searchEl.value : (document.querySelector('#papersSection input[type="text"]') || {}).value || '')
    .toLowerCase().trim();
  const yearVal = (yearEl ? yearEl.value : (document.querySelector('#papersSection select') || {}).value || '')
    .trim();

  const rows = document.querySelectorAll('#papersTable tbody tr.paper-row');

  rows.forEach(function(row) {
    const text = row.innerText.toLowerCase();
    const yearCell = row.querySelector('.year-cell');
    const rowYear = yearCell ? yearCell.innerText.trim() : '';

    const matchSearch = !query || text.includes(query);
    const matchYear = !yearVal || yearVal === 'all' || rowYear === yearVal;

    if (matchSearch && matchYear) {
      row.style.display = '';
      const next = row.nextElementSibling;
      if (next && next.classList.contains('comments-row')) {
        next.style.display = '';
      }
    } else {
      row.style.display = 'none';
      const next = row.nextElementSibling;
      if (next && next.classList.contains('comments-row')) {
        next.style.display = 'none';
      }
    }
  });
}

document.addEventListener('DOMContentLoaded', function () {
  filterTable();
});

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

    function toggleComments(paperId) {
        const div = document.getElementById('comments' + paperId);
        if (!div) return;
        const currentScroll = window.scrollY;
        div.style.display = div.style.display === 'none' ? 'block' : 'none';
        window.scrollTo(0, currentScroll);
    }

    function replyToComment(paperId, username) {
        const input = document.querySelector(`#comments${paperId} input[name="commentText"]`);
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


    // ── Useful mark toggle ──────────────────────────────────────────────────
    document.querySelectorAll('.btn-useful').forEach(btn => {
        btn.addEventListener('click', function () {
            const paperId = this.dataset.paperId;
            const ctx     = this.dataset.ctx;
            const self    = this;

            self.disabled = true;

            const body = new URLSearchParams({ paperId });

            fetch(ctx + '/student/markUseful', { method: 'POST', body, headers: { 'Content-Type': 'application/x-www-form-urlencoded' } })
                .then(r => r.json())
                .then(data => {
                    if (!data.success) { self.disabled = false; return; }

                    const label = self.querySelector('.useful-label');
                    const count = self.querySelector('.useful-count');

                    if (data.marked) {
                        self.classList.remove('act-vote');
                        self.classList.add('act-marked');
                        self.style.color = '#2563eb';
                        self.title = 'Unmark';
                        label.textContent = 'Marked';
                    } else {
                        self.classList.remove('act-marked');
                        self.classList.add('act-vote');
                        self.style.color = '#6c757d';
                        self.title = 'Mark as Useful';
                        label.textContent = 'Useful';
                    }
                    count.textContent = data.count;
                    self.dataset.marked = data.marked;
                    self.disabled = false;
                    showToast(data.marked ? 'Marked as useful!' : 'Removed from useful.', data.marked ? 'success' : 'info');
                })
                .catch(() => { self.disabled = false; });
        });
    });

    // ── Difficulty rating ───────────────────────────────────────────────────

    // ── Request Paper Modal ─────────────────────────────────────────────────
    const modal       = document.getElementById('requestModal');
    const openBtn     = document.getElementById('openRequestModal');
    const closeBtn    = document.getElementById('closeRequestModal');
    const submitBtn   = document.getElementById('submitRequestBtn');
    const modalError  = document.getElementById('modalError');

    function openModal() {
        modal.classList.add('open');
        document.getElementById('req-subject-name').focus();
    }
    function closeModal() {
        modal.classList.remove('open');
        modalError.classList.remove('show');
        modalError.textContent = '';
        document.getElementById('req-subject-name').value = '';
        document.getElementById('req-subject-code').value = '';
        document.getElementById('req-year').value = '';
        document.getElementById('req-description').value = '';
    }

    openBtn.addEventListener('click', openModal);
    closeBtn.addEventListener('click', closeModal);
    modal.addEventListener('click', e => { if (e.target === modal) closeModal(); });
    document.addEventListener('keydown', e => { if (e.key === 'Escape') closeModal(); });

    submitBtn.addEventListener('click', function () {
        const ctx         = this.dataset.ctx;
        const subjectName = document.getElementById('req-subject-name').value.trim();
        const subjectCode = document.getElementById('req-subject-code').value.trim();
        const year        = document.getElementById('req-year').value.trim();
        const description = document.getElementById('req-description').value.trim();

        // Client-side validation
        if (!subjectName) { showModalError('Subject Name is required.'); return; }
        if (!subjectCode) { showModalError('Subject Code is required.'); return; }
        if (!year)        { showModalError('Year is required.'); return; }
        const yr = parseInt(year);
        if (isNaN(yr) || yr < 2006 || yr > 2026) { showModalError('Year must be between 2006 and 2026.'); return; }

        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Submitting…';
        modalError.classList.remove('show');

        const body = new URLSearchParams({ subjectName, subjectCode, year, description });

        fetch(ctx + '/student/submitRequest', {
            method: 'POST', body,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        })
        .then(r => r.json())
        .then(data => {
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fa-solid fa-paper-plane"></i> Submit Request';
            if (!data.success) { showModalError(data.error || 'Submission failed.'); return; }

            closeModal();
            addRequestRow(data.request, ctx);
        })
        .catch(() => {
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fa-solid fa-paper-plane"></i> Submit Request';
            showModalError('Network error. Please try again.');
        });
    });

    function showModalError(msg) {
        modalError.textContent = msg;
        modalError.classList.add('show');
    }

    function addRequestRow(req, ctx) {
        // Update count pill
        const pill = document.getElementById('requestsCountPill');
        if (pill) pill.textContent = parseInt(pill.textContent || '0') + 1;

        // Hide empty state if visible
        const empty = document.getElementById('requestsEmpty');
        if (empty) empty.style.display = 'none';

        // Create table if it doesn't exist yet
        let tbody = document.querySelector('#requestsTable tbody');
        if (!tbody) {
            const card = document.getElementById('requests');
            const table = document.createElement('table');
            table.id = 'requestsTable';
            table.className = 'data-table';
            table.innerHTML = `<thead><tr>
                <th>Subject Name</th><th>Code</th><th>Year</th>
                <th>Description</th><th>Status</th><th>Requested</th><th>Action</th>
            </tr></thead><tbody></tbody>`;
            card.appendChild(table);
            tbody = table.querySelector('tbody');
        }

        const tr = document.createElement('tr');
        tr.id = 'req-row-' + req.requestId;
        tr.innerHTML = `
            <td class="td-subject">${escHtml(req.subjectName)}</td>
            <td><span class="code-pill">${escHtml(req.subjectCode)}</span></td>
            <td><span class="year-pill">${req.year}</span></td>
            <td style="max-width:180px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${req.description ? escHtml(req.description) : '-'}</td>
            <td><span class="status-pill s-pending"><i class="fa-regular fa-clock"></i> pending</span></td>
            <td style="font-size:12px;color:#6b7280;">${req.requestedAt}</td>
            <td><button class="act-btn act-delete-sm btn-delete-req"
                        data-request-id="${req.requestId}" data-ctx="${ctx}">
                    <i class="fa-solid fa-trash"></i> Delete
                </button></td>`;
        tbody.insertBefore(tr, tbody.firstChild);

        // Attach delete listener to the new button
        attachDeleteListener(tr.querySelector('.btn-delete-req'));
    }

    function escHtml(str) {
        return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    // ── Delete Request ──────────────────────────────────────────────────────
    function attachDeleteListener(btn) {
        btn.addEventListener('click', function () {
            if (!confirm('Delete this request?')) return;
            const requestId = this.dataset.requestId;
            const ctx       = this.dataset.ctx;
            const self      = this;
            self.disabled   = true;

            const redirectUrl = ctx + '/studentDashboard';
            fetch(ctx + '/student/deleteRequest', {
                method: 'POST',
                body: new URLSearchParams({ requestId: requestId, redirectUrl: redirectUrl }),
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-Requested-With': 'XMLHttpRequest'
                }
            })
            .then(r => r.json())
            .then(data => {
                if (!data.success) { self.disabled = false; return; }
                if (data.redirect) {
                    window.location.href = data.redirect;
                    return;
                }
                window.location.href = redirectUrl + '?request_deleted=true';
            })
            .catch(() => { self.disabled = false; });
        });
    }

    document.querySelectorAll('.btn-delete-req').forEach(attachDeleteListener);
</script>
<script>
(function() {
    const el = document.getElementById('pageDate');
    if (!el) return;
    el.textContent = new Date().toLocaleDateString('en-GB', {
        weekday: 'short', day: 'numeric', month: 'short', year: 'numeric'
    });
})();
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

  if (p.get('request_deleted') === 'true') {
    sessionStorage.removeItem('scrollPos_' + window.location.pathname);
    showToast('Request deleted successfully.', 'info');
    setTimeout(function() {
      var section = document.getElementById('myRequestsSection');
      if (section) section.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, 300);
    return;
  }

  if (p.get('voted') === 'true' || p.get('rated') === 'true') {
    showToast('Difficulty vote saved!', 'success');
    setTimeout(function() {
      var section = document.getElementById('papersSection');
      if (section) section.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, 300);
    return;
  }

  if (p.get('marked') === 'true') {
    showToast('Marked as useful!', 'success');
    setTimeout(function() {
      var section = document.getElementById('papersSection');
      if (section) section.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, 300);
    return;
  }

  if (p.get('unmarked') === 'true') {
    showToast('Removed from useful marks.', 'info');
    setTimeout(function() {
      var section = document.getElementById('papersSection');
      if (section) section.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, 300);
    return;
  }

  if (p.get('commented') === 'true') {
    showToast('Comment posted!', 'success');
    setTimeout(function() {
      var section = document.getElementById('papersSection');
      if (section) section.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, 300);
    return;
  }

  if (p.get('comment_deleted') === 'true') {
    showToast('Comment deleted.', 'info');
    setTimeout(function() {
      var section = document.getElementById('papersSection');
      if (section) section.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, 300);
    return;
  }

  const messages = {
    'uploaded':        ['Paper uploaded successfully!',    'success'],
    'updated':         ['Paper updated successfully!',     'success'],
    'deleted':         ['Paper deleted successfully!',     'success'],
    'submitted':       ['Request submitted successfully!', 'success'],
    'status_updated':  ['Status updated successfully!',    'success'],
    'logged_out':      ['You have been logged out.',       'info'],
    'registered':      ['Account created! Please log in.', 'success'],
    'error':           ['Something went wrong. Try again.', 'error'],
    'unauthorized':    ['Please log in to continue.',      'warning'],
    'invalid':         ['Invalid input. Please check your fields.', 'warning'],
  };

  for (const [param, pair] of Object.entries(messages)) {
    if (p.get(param) === 'true' || p.get(param) === '1') {
      showToast(pair[0], pair[1]);
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
    qs.indexOf('voted=true') !== -1 ||
    qs.indexOf('rated=true') !== -1 ||
    qs.indexOf('marked=true') !== -1 ||
    qs.indexOf('unmarked=true') !== -1 ||
    qs.indexOf('commented=true') !== -1 ||
    qs.indexOf('comment_deleted=true') !== -1 ||
    qs.indexOf('request_deleted=true') !== -1 ||
    qs.indexOf('submitted=true') !== -1 ||
    qs.indexOf('status_updated=true') !== -1 ||
    qs.indexOf('deleted=true') !== -1 ||
    qs.indexOf('updated=true') !== -1 ||
    qs.indexOf('msg_sent=true') !== -1 ||
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
