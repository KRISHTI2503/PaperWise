<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%@ page import="java.time.Year" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
    String subjectName = (String) request.getAttribute("subjectName");
    String subjectCode = (String) request.getAttribute("subjectCode");
    String yearStr = (String) request.getAttribute("year");
    String description = (String) request.getAttribute("description");

    int currentYear = Year.now().getValue();
    int minYear = currentYear - 20;

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
    <title>Request Paper - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <style>
        *{box-sizing:border-box;margin:0;padding:0}
        body{font-family:'Segoe UI',system-ui,sans-serif;background:#f1f4f9;display:flex;min-height:100vh}

        /* SIDEBAR */
        .sb{width:220px;flex-shrink:0;background:#0f2744;display:flex;flex-direction:column;min-height:100vh;position:fixed;top:0;left:0}
        .sb-logo{display:flex;align-items:center;gap:10px;padding:1.2rem 1.1rem 1rem;border-bottom:1px solid rgba(255,255,255,0.08)}
        .sb-lb{width:34px;height:34px;background:rgba(255,255,255,0.12);border-radius:8px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
        .sb-n{color:#fff;font-weight:700;font-size:15px;line-height:1}
        .sb-r{color:rgba(255,255,255,0.45);font-size:11px}
        .sb-sec{color:rgba(255,255,255,0.3);font-size:10px;font-weight:600;letter-spacing:.08em;padding:.9rem 1.1rem .35rem;text-transform:uppercase}
        .sb-item{display:flex;align-items:center;gap:9px;padding:.55rem 1.1rem;color:rgba(255,255,255,0.6);font-size:13px;cursor:pointer;transition:background .15s;text-decoration:none}
        .sb-item:hover{background:rgba(255,255,255,0.07);color:#fff}
        .sb-item.active{background:rgba(255,255,255,0.13);color:#fff;font-weight:500}
        .sb-item i{font-size:17px;width:20px;text-align:center}
        .sb-bottom{margin-top:auto;padding:.8rem 1.1rem;border-top:1px solid rgba(255,255,255,0.08)}
        .sb-user{display:flex;align-items:center;gap:9px}
        .sb-av{width:30px;height:30px;border-radius:50%;background:rgba(255,255,255,0.15);display:flex;align-items:center;justify-content:center;color:#fff;font-size:11px;font-weight:600;flex-shrink:0}
        .sb-un{color:#fff;font-size:12.5px;font-weight:500}
        .sb-ur{color:rgba(255,255,255,0.4);font-size:11px}
        .sb-out{display:flex;align-items:center;gap:6px;color:#f87171;font-size:12px;margin-top:.5rem;cursor:pointer;text-decoration:none;padding:.3rem 0}
        .sb-out i{font-size:15px}

        /* MAIN */
        .main{flex:1;margin-left:220px;display:flex;flex-direction:column;min-height:100vh}

        /* TOPBAR */
        .topbar{background:#fff;border-bottom:1px solid #e5e7eb;padding:.85rem 1.6rem;display:flex;align-items:center;justify-content:space-between;flex-shrink:0;position:sticky;top:0;z-index:10}
        .tb-left h1{font-size:17px;font-weight:700;color:#0f2744}
        .tb-left p{font-size:12.5px;color:#8a97a8;margin-top:1px}
        .tb-right{display:flex;align-items:center;gap:10px}
        .date-chip{background:#f3f4f6;border-radius:7px;padding:5px 10px;font-size:12px;color:#6b7280;display:flex;align-items:center;gap:5px}
        .date-chip i{font-size:14px}
        .bell-btn{width:34px;height:34px;border-radius:8px;background:#f3f4f6;border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;color:#6b7280;position:relative}
        .bell-btn i{font-size:18px}
        .notif-dot{width:7px;height:7px;background:#ef4444;border-radius:50%;position:absolute;top:6px;right:7px;border:1.5px solid #fff}

        /* CONTENT */
        .content{padding:1.4rem 1.6rem;display:flex;flex-direction:column;gap:1.2rem}

        /* FORM CARD */
        .form-card{background:#fff;border-radius:12px;border:1px solid #e5e7eb;padding:28px 28px 24px;max-width:600px;width:100%}
        .form-card-title{font-size:15px;font-weight:700;color:#0f2744;margin-bottom:4px}
        .form-card-sub{font-size:12.5px;color:#8a97a8;margin-bottom:22px}

        .error-message{background:#fef2f2;border:1px solid #fecaca;color:#b91c1c;border-radius:8px;padding:10px 14px;margin-bottom:16px;font-size:13px}

        .form-group{margin-bottom:16px}
        label{display:block;margin-bottom:6px;color:#374151;font-size:12.5px;font-weight:600}
        .required{color:#ef4444}

        input[type="text"],
        input[type="number"],
        textarea{
            width:100%;padding:9px 12px;border:1.5px solid #e5e7eb;border-radius:8px;
            font-size:13px;font-family:inherit;color:#111827;background:#f9fafb;
            transition:border-color .18s;outline:none
        }
        input[type="text"]:focus,
        input[type="number"]:focus,
        textarea:focus{border-color:#3b82f6;background:#fff}
        textarea{resize:vertical;min-height:90px}

        .year-info{font-size:11px;color:#9ca3af;margin-top:4px}

        .button-group{display:flex;gap:10px;margin-top:20px}
        .btn-submit{flex:1;padding:10px 20px;background:#0f2744;color:#fff;border:none;border-radius:8px;font-size:13px;font-weight:600;cursor:pointer;transition:background .15s}
        .btn-submit:hover{background:#1a3a5c}
        .btn-cancel{padding:10px 20px;background:#f3f4f6;color:#6b7280;border:none;border-radius:8px;font-size:13px;font-weight:500;cursor:pointer;transition:background .15s}
        .btn-cancel:hover{background:#e5e7eb}

        /* FORM FIELD GROUPS */
        .fg{display:flex;flex-direction:column;gap:5px;margin-bottom:.9rem}
        .fg:last-child{margin-bottom:0}
        .req{color:#ef4444}
        .opt-lbl{font-size:11px;color:#9ca3af;font-weight:400;background:#f3f4f6;border-radius:4px;padding:1px 6px}
        .iw{position:relative;display:flex;align-items:center}
        .iw .fi{position:absolute;left:11px;font-size:16px;color:#9ca3af;pointer-events:none;z-index:1}
        .iw input,.iw select,.iw textarea{padding-left:36px}
        input,select,textarea{width:100%;border:1.5px solid #e5e7eb;border-radius:9px;padding:9px 11px;font-size:13.5px;color:#111827;background:#f9fafb;font-family:inherit;outline:none;transition:border .18s,box-shadow .18s,background .18s}
        input:focus,select:focus,textarea:focus{border-color:#3b82f6;background:#fff;box-shadow:0 0 0 3px rgba(59,130,246,.12)}
        textarea{padding:9px 11px;resize:vertical;min-height:80px}
        .hint{font-size:11px;color:#9ca3af;margin-top:2px}
        .btn-submit-new{width:100%;background:#0f2744;color:#fff;border:none;border-radius:10px;padding:11px;font-size:14px;font-weight:600;font-family:inherit;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:7px;transition:background .18s;margin-bottom:.8rem}
        .btn-submit-new:hover{background:#1a3a5c}
        .btn-submit-new i{font-size:17px}
        .btn-back{width:100%;background:#f3f4f6;color:#374151;border:1.5px solid #e5e7eb;border-radius:10px;padding:9px;font-size:13px;font-weight:500;font-family:inherit;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;text-decoration:none;transition:background .18s}
        .btn-back:hover{background:#e5e7eb}
        .btn-back i{font-size:15px}

        /* TIPS CARD */
        .tips-card{background:#0f2744;border-radius:12px;padding:1rem 1.1rem;margin-top:1rem}
        .tips-title{color:#fff;font-size:13px;font-weight:700;display:flex;align-items:center;gap:6px;margin-bottom:.7rem}
        .tips-title i{font-size:15px;color:#fbbf24}
        .tip-item{display:flex;align-items:flex-start;gap:7px;color:rgba(255,255,255,0.7);font-size:12px;margin-bottom:.45rem;line-height:1.4}
        .tip-item i{font-size:13px;color:#60a5fa;flex-shrink:0;margin-top:1px}

        /* ACTION BUTTONS */
        hr.pw-div{border:none;border-top:1px solid #f0f0f0;margin:1.2rem 0}
        .actions{display:flex;gap:10px}
        .btn-submit{flex:1;background:#0f2744;color:#fff;border:none;border-radius:10px;padding:11px;font-size:14px;font-weight:600;font-family:inherit;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:7px;transition:background .18s}
        .btn-submit:hover{background:#1a3a5c}
        .btn-submit i{font-size:17px}
        .btn-cancel{background:#f3f4f6;color:#374151;border:1.5px solid #e5e7eb;border-radius:10px;padding:11px 20px;font-size:13.5px;font-weight:500;font-family:inherit;cursor:pointer;display:flex;align-items:center;gap:6px;transition:background .18s;text-decoration:none}
        .btn-cancel:hover{background:#e5e7eb}
        .btn-cancel i{font-size:16px}

        /* REQUESTS TABLE */
        table{width:100%;border-collapse:collapse}
        thead tr{background:#f8fafc}
        th{padding:.65rem 1rem;font-size:10.5px;font-weight:600;color:#6b7280;text-align:left;text-transform:uppercase;letter-spacing:.04em;border-bottom:1px solid #f0f0f0;white-space:nowrap}
        td{padding:.85rem 1rem;font-size:13px;color:#111827;border-bottom:1px solid #f7f8fa;vertical-align:middle}
        tr:last-child td{border-bottom:none}
        tr:hover td{background:#fafbff}
        .t-subj{font-weight:600;color:#0f2744}
        .t-code{background:#e0e7ff;color:#3730a3;font-size:11px;font-weight:600;border-radius:5px;padding:2px 7px;display:inline-block}
        .t-yr{color:#ef4444;font-weight:600;font-size:13px}
        .t-desc{color:#6b7280;font-size:12.5px;max-width:120px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;display:inline-block}
        .t-date{font-size:11.5px;color:#9ca3af;white-space:nowrap}
        .badge{display:inline-flex;align-items:center;gap:4px;border-radius:20px;padding:3px 10px;font-size:11.5px;font-weight:600}
        .badge i{font-size:13px}
        .b-pen{background:#fef3c7;color:#92400e}
        .b-app{background:#dcfce7;color:#065f46}
        .b-rej{background:#fee2e2;color:#7f1d1d}
        .b-com{background:#e0e7ff;color:#3730a3}
        .btn-del{width:30px;height:30px;border-radius:7px;background:#fee2e2;border:none;color:#dc2626;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:background .15s}
        .btn-del:hover{background:#fecaca}
        .btn-del i{font-size:15px}
        .empty-state{padding:3rem;text-align:center}
        .empty-state i{font-size:48px;color:#d1d5db;display:block;margin-bottom:.7rem}
        .empty-state p{font-size:13.5px;font-weight:600;color:#6b7280}
        .empty-state span{font-size:12px;color:#9ca3af;display:block;margin-top:3px}

        /* TOAST */
        .pw-toast{position:absolute;top:14px;right:14px;background:#dcfce7;border:1px solid #16a34a;color:#15803d;border-radius:9px;padding:9px 14px;font-size:12.5px;font-weight:500;display:flex;align-items:center;gap:6px;opacity:0;transform:translateY(-6px);transition:all .28s;pointer-events:none;z-index:99}
        .pw-toast i{font-size:16px}
        .pw-toast.show{opacity:1;transform:translateY(0)}

        /* STAT CARDS */
        .stats-row{display:grid;grid-template-columns:repeat(3,1fr);gap:12px}
        .sc{background:#fff;border-radius:12px;padding:1.1rem 1.2rem;border:1px solid #e9ecef;display:flex;align-items:center;gap:14px}
        .si{width:42px;height:42px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
        .si i{font-size:22px}
        .si-blue{background:#e0f0ff}.si-blue i{color:#3b82f6}
        .si-amber{background:#fef3c7}.si-amber i{color:#d97706}
        .si-green{background:#dcfce7}.si-green i{color:#16a34a}
        .sv{font-size:24px;font-weight:700;color:#0f2744;line-height:1}
        .sl{font-size:12px;color:#8a97a8;margin-top:3px}

        /* TWO-COLUMN LAYOUT */
        .two-col{display:grid;grid-template-columns:1fr 1.3fr;gap:1.2rem;align-items:flex-start}

        /* CARD STYLE */
        .pw-card{background:#fff;border-radius:14px;border:1px solid #e9ecef;overflow:hidden;position:relative}
        .pw-card-head{padding:1rem 1.2rem;border-bottom:1px solid #f0f0f0;display:flex;align-items:center;gap:8px}
        .pw-card-title{font-size:14.5px;font-weight:700;color:#0f2744;display:flex;align-items:center;gap:7px;flex:1}
        .pw-card-title i{font-size:18px;color:#6b7280}
        .cnt-pill{background:#dbeafe;color:#1e40af;font-size:11.5px;font-weight:600;border-radius:20px;padding:2px 9px}
        .pw-card-body{padding:1.2rem}
    </style>
</head>
<body>

<!-- SIDEBAR -->
<div class="sb">
    <div class="sb-logo">
        <div class="sb-lb">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
                <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
            </svg>
        </div>
        <div>
            <div class="sb-n">PaperWise</div>
            <div class="sb-r">Student Panel</div>
        </div>
    </div>

    <div class="sb-sec">Main</div>
    <a href="${pageContext.request.contextPath}/studentDashboard" class="sb-item">
        <i class="fa-solid fa-house"></i> Dashboard
    </a>
    <a href="${pageContext.request.contextPath}/studentDashboard" class="sb-item">
        <i class="fa-regular fa-file-lines"></i> All Papers
    </a>
    <a href="${pageContext.request.contextPath}/studentDashboard#marked" class="sb-item">
        <i class="fa-regular fa-bookmark"></i> My Marked
    </a>

    <div class="sb-sec">Requests</div>
    <a href="${pageContext.request.contextPath}/requestPaper" class="sb-item active">
        <i class="fa-regular fa-file"></i> My Requests
    </a>

    <div class="sb-bottom">
        <div class="sb-user">
            <div class="sb-av"><%= initials %></div>
            <div>
                <div class="sb-un"><%= username %></div>
                <div class="sb-ur">Student</div>
            </div>
        </div>
        <form action="${pageContext.request.contextPath}/logout" method="post" style="margin:0">
            <button type="submit" class="sb-out" style="background:none;border:none;width:100%;text-align:left;cursor:pointer;">
                <i class="ti ti-logout"></i> Logout
            </button>
        </form>
    </div>
</div>

<!-- MAIN -->
<div class="main">

    <!-- TOPBAR -->
    <div class="topbar">
        <div class="tb-left">
            <h1>My Paper Requests</h1>
            <p>Submit a request for papers you can't find, and track your request status.</p>
        </div>
        <div class="tb-right">
            <div class="date-chip">
                <i class="ti ti-calendar"></i>
                <%= new java.text.SimpleDateFormat("MMM yyyy").format(new java.util.Date()) %>
            </div>
            <button class="bell-btn" title="Notifications">
                <i class="ti ti-bell"></i>
            </button>
        </div>
    </div>

    <!-- CONTENT -->
    <div class="content">

        <!-- STAT CARDS -->
        <div class="stats-row">
            <div class="sc">
                <div class="si si-blue"><i class="ti ti-clipboard-list"></i></div>
                <div>
                    <div class="sv">${totalRequests}</div>
                    <div class="sl">Total Requests</div>
                </div>
            </div>
            <div class="sc">
                <div class="si si-amber"><i class="ti ti-clock"></i></div>
                <div>
                    <div class="sv">${pendingCount}</div>
                    <div class="sl">Pending</div>
                </div>
            </div>
            <div class="sc">
                <div class="si si-green"><i class="ti ti-circle-check"></i></div>
                <div>
                    <div class="sv">${completedCount}</div>
                    <div class="sl">Completed</div>
                </div>
            </div>
        </div>

        <div class="two-col">

            <!-- LEFT: New Request Form Card -->
            <div class="pw-card">
                <div class="pw-card-head">
                    <div class="pw-card-title">
                        <i class="ti ti-clipboard-plus"></i> New Request
                    </div>
                </div>
                <div class="pw-card-body">

                    <div class="pw-toast" id="pwToast">
                        <i class="ti ti-circle-check"></i> Request submitted successfully!
                    </div>

                    <% if (errorMessage != null) { %>
                        <div class="error-message"><%= errorMessage %></div>
                    <% } %>

                    <form action="${pageContext.request.contextPath}/requestPaper" method="post">
                        <div class="fg">
                            <label>Subject Name <span class="req">*</span></label>
                            <div class="iw">
                                <i class="ti ti-book fi"></i>
                                <input type="text" name="subject_name"
                                       placeholder="e.g., Data Structures and Algorithms"
                                       value="<%= subjectName != null ? subjectName : "" %>"
                                       required>
                            </div>
                        </div>

                        <div class="fg">
                            <label>Subject Code <span class="req">*</span></label>
                            <div class="iw">
                                <i class="ti ti-hash fi"></i>
                                <input type="text" name="subject_code"
                                       placeholder="e.g., CS201, MATH201"
                                       value="<%= subjectCode != null ? subjectCode : "" %>"
                                       required>
                            </div>
                        </div>

                        <div class="fg">
                            <label>Year <span class="req">*</span></label>
                            <div class="iw">
                                <i class="ti ti-calendar fi"></i>
                                <select name="year" style="padding-left:36px">
                                    <% for (int y = currentYear; y >= minYear; y--) {
                                           String sel = (yearStr != null && yearStr.equals(String.valueOf(y))) ? "selected" : ""; %>
                                    <option value="<%= y %>" <%= sel %>><%= y %></option>
                                    <% } %>
                                </select>
                            </div>
                            <span class="hint">Valid range: <%= minYear %> – <%= currentYear %></span>
                        </div>

                        <div class="fg">
                            <label>Description <span class="opt-lbl">optional</span></label>
                            <div class="iw" style="align-items:flex-start">
                                <i class="ti ti-notes fi" style="position:absolute;left:11px;top:10px"></i>
                                <textarea name="description"
                                          placeholder="Any additional details… e.g., by tomorrow, sessional 1 only"
                                          style="padding-left:36px"><%= description != null ? description : "" %></textarea>
                            </div>
                        </div>

                        <hr class="pw-div">
                        <div class="actions">
                            <a href="${pageContext.request.contextPath}/studentDashboard" class="btn-cancel">
                                <i class="ti ti-x"></i> Cancel
                            </a>
                            <button type="submit" class="btn-submit">
                                <i class="ti ti-send"></i> Submit Request
                            </button>
                        </div>
                    </form>

                    <div class="tips-card">
                        <div class="tips-title"><i class="ti ti-bulb"></i> Request Tips</div>
                        <div class="tip-item"><i class="ti ti-point"></i> Use the exact subject code from your syllabus.</div>
                        <div class="tip-item"><i class="ti ti-point"></i> Mention exam type (sessional, final, etc.).</div>
                        <div class="tip-item"><i class="ti ti-point"></i> Admins usually respond within 24 hours.</div>
                        <div class="tip-item"><i class="ti ti-point"></i> Avoid duplicate requests for the same subject.</div>
                    </div>

                </div>
            </div>

            <!-- RIGHT: My Requests Table Card -->
            <div class="pw-card">
                <div class="pw-card-head">
                    <div class="pw-card-title">
                        <i class="ti ti-clipboard-list"></i> My Requests
                        <span class="cnt-pill"><%= request.getAttribute("totalRequests") != null ? request.getAttribute("totalRequests") : 0 %></span>
                    </div>
                </div>
                <%
                    java.util.List<com.paperwise.model.PaperRequest> reqList =
                        (java.util.List<com.paperwise.model.PaperRequest>) request.getAttribute("myRequests");
                    java.time.format.DateTimeFormatter reqDtf =
                        java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy");
                %>
                <% if (reqList == null || reqList.isEmpty()) { %>
                <div class="empty-state">
                    <i class="ti ti-folder-open"></i>
                    <p>No Requests Yet</p>
                    <span>You have not submitted any paper requests yet.</span>
                </div>
                <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Subject</th>
                            <th>Code</th>
                            <th>Year</th>
                            <th>Description</th>
                            <th>Status</th>
                            <th>Requested At</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (com.paperwise.model.PaperRequest req : reqList) {
                           String st = req.getStatus() != null ? req.getStatus().toLowerCase() : "pending";
                           String badgeCls = "b-pen";
                           String badgeIcon = "ti-clock";
                           String badgeLabel = "Pending";
                           if ("approved".equals(st))  { badgeCls = "b-app"; badgeIcon = "ti-circle-check"; badgeLabel = "Approved"; }
                           else if ("rejected".equals(st))  { badgeCls = "b-rej"; badgeIcon = "ti-circle-x";    badgeLabel = "Rejected"; }
                           else if ("completed".equals(st)) { badgeCls = "b-com"; badgeIcon = "ti-flag";         badgeLabel = "Completed"; }
                           String dateStr = req.getCreatedAt() != null ? req.getCreatedAt().format(reqDtf) : "-";
                           String descStr = req.getDescription() != null ? req.getDescription() : "";
                    %>
                    <tr>
                        <td><span class="t-subj"><%= req.getSubjectName() %></span></td>
                        <td><span class="t-code"><%= req.getSubjectCode() %></span></td>
                        <td><span class="t-yr"><%= req.getYear() %></span></td>
                        <td><span class="t-desc" title="<%= descStr %>"><%= descStr.isEmpty() ? "—" : descStr %></span></td>
                        <td>
                            <span class="badge <%= badgeCls %>">
                                <i class="ti <%= badgeIcon %>"></i> <%= badgeLabel %>
                            </span>
                        </td>
                        <td><span class="t-date"><%= dateStr %></span></td>
                        <td>
                            <% if ("pending".equals(st)) { %>
                            <form method="post" action="${pageContext.request.contextPath}/deleteRequest"
                                  onsubmit="return confirm('Delete this request?')">
                                <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                                <button type="submit" class="btn-del">
                                    <i class="ti ti-trash"></i>
                                </button>
                            </form>
                            <% } else { %>
                            <span style="color:#d1d5db;font-size:13px;">—</span>
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>

        </div><!-- /two-col -->

    </div><!-- /content -->
</div><!-- /main -->

<script>
window.addEventListener('load', function () {
    const p = new URLSearchParams(window.location.search);
    if (p.get('submitted') === 'true') {
        const t = document.getElementById('pwToast');
        t.classList.add('show');
        setTimeout(() => t.classList.remove('show'), 3000);
    }
});
</script>

</body>
</html>
