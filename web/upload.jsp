<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"admin".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Paper - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/dist/tabler-icons.min.css">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            min-height: 100vh;
            background: #0d1b2a;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            font-family: 'Segoe UI', system-ui, sans-serif;
            position: relative;
            overflow-x: hidden;
        }
        .pw-card {
            background: #fff;
            border-radius: 20px;
            width: 100%;
            max-width: 620px;
            padding: 2.2rem 2.5rem;
            position: relative;
            animation: slideUp .4s cubic-bezier(.16,1,.3,1) both;
        }
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(22px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        i.fa-solid, i.fa-regular {
            margin-bottom: 32px;
        }

        .header h1 {
            font-size: 28px;
            color: #1a202c;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .header p {
            color: #718096;
            font-size: 14px;
        }

        .error-message {
            background: #fee;
            border-left: 4px solid #e53e3e;
            color: #c53030;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 14px;
            display: flex;
            align-items: center;
        }

        .form-group {
            margin-bottom: 24px;
        }

        .form-group label {
            display: block;
            color: #2d3748;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .form-group label .required {
            color: #e53e3e;
            margin-left: 2px;
        }

        .form-group input[type="text"],
        .form-group input[type="number"] {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 15px;
            color: #2d3748;
            transition: all 0.3s ease;
            background: #f7fafc;
        }

        .form-group input:focus {
            outline: none;
            border-color: #667eea;
            background: white;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .file-upload-wrapper {
            position: relative;
            overflow: hidden;
            display: inline-block;
            width: 100%;
        }

        .file-upload-input {
            position: absolute;
            left: -9999px;
        }

        .file-upload-label {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            border: 2px dashed #cbd5e0;
            border-radius: 8px;
            background: #f7fafc;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .file-upload-label:hover {
            border-color: #667eea;
            background: #edf2f7;
        }

        .file-upload-label.has-file {
            border-color: #48bb78;
            background: #f0fff4;
        }

        .file-upload-icon {
            font-size: 48px;
            margin-bottom: 12px;
        }

        .file-upload-text {
            text-align: center;
        }

        .file-upload-text .main {
            color: #2d3748;
            font-weight: 600;
            margin-bottom: 4px;
        }

        .file-upload-text .sub {
            color: #718096;
            font-size: 13px;
        }

        .file-name-display {
            margin-top: 12px;
            padding: 8px 12px;
            background: #edf2f7;
            border-radius: 6px;
            font-size: 14px;
            color: #2d3748;
            display: none;
        }

        .file-name-display.show {
            display: block;
        }

        .info-box {
            background: #ebf8ff;
            border-left: 4px solid #4299e1;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 14px;
            color: #2c5282;
        }

        @media (max-width: 768px) {
            .pw-card {
                padding: 1.4rem 1.2rem;
            }
        }

        .card-top { display:flex; align-items:center; gap:12px; margin-bottom:4px; }
        .logo-box  { width:40px; height:40px; background:#0f2744; border-radius:10px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
        .card-title { font-size:20px; font-weight:700; color:#0f2744; }
        .card-sub   { font-size:13px; color:#8a97a8; margin-bottom:1.3rem; }
        .info-bar   { background:#eef6ff; border-left:3px solid #3b82f6; border-radius:0 8px 8px 0; padding:9px 13px; font-size:12.5px; color:#1d4ed8; display:flex; align-items:flex-start; gap:8px; margin-bottom:1.5rem; line-height:1.5; }
        .info-bar i { font-size:16px; flex-shrink:0; margin-top:1px; }

        .form-grid { display:grid; grid-template-columns:1fr 1fr; gap:1rem 1.2rem; }
        .fg        { display:flex; flex-direction:column; gap:5px; }
        .fg.full   { grid-column:1/-1; }
        label      { font-size:12.5px; font-weight:600; color:#374151; display:flex; align-items:center; gap:5px; }
        .req       { color:#ef4444; }
        .opt-badge { font-size:11px; color:#9ca3af; font-weight:400; background:#f3f4f6; border-radius:4px; padding:1px 6px; }
        .iw        { position:relative; display:flex; align-items:center; }
        .iw .fi    { position:absolute; left:11px; font-size:16px; color:#9ca3af; pointer-events:none; z-index:1; }
        .iw input, .iw select { padding-left:36px; }
        input, select { width:100%; border:1.5px solid #e5e7eb; border-radius:9px; padding:9px 11px; font-size:13.5px; color:#111827; background:#f9fafb; font-family:inherit; outline:none; transition:border .18s,box-shadow .18s,background .18s; }
        input:focus, select:focus { border-color:#3b82f6; background:#fff; box-shadow:0 0 0 3px rgba(59,130,246,.12); }
        select { appearance:none; cursor:pointer; padding-right:32px; }
        .sw::after { content:''; position:absolute; right:11px; top:50%; transform:translateY(-50%); border:5px solid transparent; border-top-color:#9ca3af; pointer-events:none; margin-top:3px; }
        .hint { font-size:11px; color:#9ca3af; margin-top:2px; }

        .drop-zone { border:2px dashed #d1d5db; border-radius:12px; padding:2rem 1rem; text-align:center; cursor:pointer; transition:all .2s; background:#fafafa; position:relative; }
        .drop-zone:hover, .drop-zone.over { border-color:#3b82f6; background:#eff6ff; }
        .drop-zone input[type=file] { position:absolute; inset:0; opacity:0; cursor:pointer; width:100%; height:100%; padding:0; border:none; background:transparent; box-shadow:none; border-radius:0; }
        .drop-icon { width:52px; height:52px; border-radius:12px; background:#e0e7ff; display:flex; align-items:center; justify-content:center; margin:0 auto .8rem; transition:background .2s; }
        .drop-icon i { font-size:26px; color:#3b82f6; }
        .drop-zone:hover .drop-icon, .drop-zone.over .drop-icon { background:#bfdbfe; }
        .drop-title { font-size:14px; font-weight:600; color:#0f2744; }
        .drop-sub   { font-size:12px; color:#9ca3af; margin-top:3px; }
        .drop-types { display:flex; flex-wrap:wrap; justify-content:center; gap:5px; margin-top:.9rem; }
        .type-pill  { background:#f3f4f6; color:#6b7280; font-size:11px; font-weight:500; border-radius:5px; padding:2px 8px; border:1px solid #e5e7eb; }
        .file-selected { display:none; align-items:center; gap:12px; background:#f0fdf4; border:1.5px solid #16a34a; border-radius:10px; padding:10px 14px; margin-top:.8rem; }
        .file-selected.show { display:flex; }
        .file-icon-box { width:36px; height:36px; border-radius:8px; background:#dcfce7; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
        .file-icon-box i { font-size:20px; color:#16a34a; }
        .file-name { font-size:13px; font-weight:600; color:#15803d; flex:1; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .file-size-txt { font-size:11px; color:#86efac; }
        .file-remove { background:none; border:none; color:#dc2626; cursor:pointer; font-size:18px; display:flex; align-items:center; }

        hr.pw-divider { border:none; border-top:1px solid #f0f0f0; margin:1.3rem 0; }
        .actions    { display:flex; gap:10px; margin-top:0; }
        .btn-upload { flex:1; background:#0f2744; color:#fff; border:none; border-radius:10px; padding:11px; font-size:14px; font-weight:600; font-family:inherit; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:7px; transition:background .18s,transform .12s; }
        .btn-upload:hover  { background:#1a3a5c; }
        .btn-upload:active { transform:scale(.98); }
        .btn-upload i { font-size:17px; }
        .btn-cancel { background:#f3f4f6; color:#374151; border:1.5px solid #e5e7eb; border-radius:10px; padding:11px 20px; font-size:13.5px; font-weight:500; font-family:inherit; cursor:pointer; display:flex; align-items:center; gap:6px; transition:background .18s; text-decoration:none; }
        .btn-cancel:hover { background:#e5e7eb; }
        .btn-cancel i { font-size:16px; }
        .pw-toast { position:absolute; top:14px; right:14px; background:#dcfce7; border:1px solid #16a34a; color:#15803d; border-radius:9px; padding:9px 14px; font-size:12.5px; font-weight:500; display:flex; align-items:center; gap:6px; opacity:0; transform:translateY(-6px); transition:all .28s; pointer-events:none; z-index:99; }
        .pw-toast i { font-size:16px; }
        .pw-toast.show { opacity:1; transform:translateY(0); }
    </style>
</head>
<body>

    <!-- Decorative watermark icons -->
    <svg style="position:absolute;top:24px;left:24px;opacity:0.05;transform:rotate(-15deg)" width="70" height="80" viewBox="0 0 70 80" fill="none" stroke="white" stroke-width="3" stroke-linecap="round">
        <rect x="10" y="8" width="50" height="64" rx="5"/>
        <line x1="22" y1="30" x2="48" y2="30"/>
        <line x1="22" y1="42" x2="48" y2="42"/>
        <line x1="22" y1="54" x2="40" y2="54"/>
    </svg>
    <svg style="position:absolute;top:24px;right:24px;opacity:0.05;transform:rotate(12deg)" width="70" height="80" viewBox="0 0 70 80" fill="none" stroke="white" stroke-width="3" stroke-linecap="round">
        <rect x="10" y="8" width="50" height="64" rx="5"/>
        <line x1="22" y1="30" x2="48" y2="30"/>
        <line x1="22" y1="42" x2="48" y2="42"/>
        <line x1="22" y1="54" x2="40" y2="54"/>
    </svg>
    <svg style="position:absolute;bottom:24px;left:24px;opacity:0.05;transform:rotate(8deg)" width="70" height="80" viewBox="0 0 70 80" fill="none" stroke="white" stroke-width="3" stroke-linecap="round">
        <rect x="10" y="8" width="50" height="64" rx="5"/>
        <line x1="22" y1="30" x2="48" y2="30"/>
        <line x1="22" y1="42" x2="48" y2="42"/>
        <line x1="22" y1="54" x2="40" y2="54"/>
    </svg>
    <svg style="position:absolute;bottom:24px;right:24px;opacity:0.05;transform:rotate(-10deg)" width="70" height="80" viewBox="0 0 70 80" fill="none" stroke="white" stroke-width="3" stroke-linecap="round">
        <rect x="10" y="8" width="50" height="64" rx="5"/>
        <line x1="22" y1="30" x2="48" y2="30"/>
        <line x1="22" y1="42" x2="48" y2="42"/>
        <line x1="22" y1="54" x2="40" y2="54"/>
    </svg>

    <div class="pw-card">

        <div class="pw-toast" id="pwToast">
            <i class="ti ti-circle-check"></i> Paper uploaded successfully!
        </div>

        <div class="card-top">
            <div class="logo-box">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white"
                     stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
                    <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
                </svg>
            </div>
            <div>
                <div class="card-title">Upload Paper</div>
            </div>
        </div>
        <div class="card-sub">Upload academic papers for students to access</div>

        <div class="info-bar">
            <i class="ti ti-info-circle"></i>
            <span>Allowed file types: <strong>PDF, DOC, DOCX, PPT, PPTX, TXT, JPG, PNG, MP4, MKV</strong>&nbsp;·&nbsp; Max size: <strong>200MB</strong></span>
        </div>

        <%
            String errorMessage = (String) request.getAttribute("errorMessage");
            if (errorMessage != null) {
        %>
            <div class="error-message">
                <%= errorMessage %>
            </div>
        <% } %>

            <form action="${pageContext.request.contextPath}/uploadPaper"
                  method="post"
                  enctype="multipart/form-data"
                  onsubmit="return validateForm()">

                <div class="form-grid">

                    <%-- Row 1: Subject Name + Subject Code --%>
                    <div class="fg">
                        <label for="subjectName">Subject Name <span class="req">*</span></label>
                        <div class="iw">
                            <i class="ti ti-book fi"></i>
                            <input type="text"
                                   id="subjectName"
                                   name="subjectName"
                                   placeholder="e.g., Data Structures and Algorithms"
                                   value="<%= request.getParameter("subjectName") != null ? request.getParameter("subjectName") : "" %>"
                                   required
                                   maxlength="150"/>
                        </div>
                    </div>

                    <div class="fg">
                        <label for="subjectCode">Subject Code <span class="req">*</span></label>
                        <div class="iw">
                            <i class="ti ti-hash fi"></i>
                            <input type="text"
                                   id="subjectCode"
                                   name="subjectCode"
                                   placeholder="e.g., CS101, MATH201"
                                   value="<%= request.getParameter("subjectCode") != null ? request.getParameter("subjectCode") : "" %>"
                                   required
                                   maxlength="50"/>
                        </div>
                    </div>

                    <%-- Row 2: Year + Exam Type --%>
                    <div class="fg">
                        <label for="year">Year <span class="req">*</span></label>
                        <div class="iw sw">
                            <i class="ti ti-calendar fi"></i>
                            <select id="year" name="year" required>
                                <% for (int y = 2026; y >= 2006; y--) { %>
                                <option value="<%= y %>"
                                    <%= (request.getParameter("year") != null && request.getParameter("year").equals(String.valueOf(y))) ? "selected" : "" %>>
                                    <%= y %>
                                </option>
                                <% } %>
                            </select>
                        </div>
                        <span class="hint">Valid range: 2006 – 2026</span>
                    </div>

                    <div class="fg">
                        <label for="examType">Exam Type <span class="opt-badge">optional</span></label>
                        <div class="iw sw">
                            <i class="ti ti-file-description fi"></i>
                            <input type="text"
                                   id="examType"
                                   name="examType"
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

                    <%-- Row 3: Chapter (full width) --%>
                    <div class="fg full">
                        <label for="chapter">Chapter <span class="opt-badge">optional</span></label>
                        <div class="iw">
                            <i class="ti ti-list fi"></i>
                            <input type="text"
                                   id="chapter"
                                   name="chapter"
                                   placeholder="e.g., ch 4, ch 5, ch 6"
                                   value="<%= request.getParameter("chapter") != null ? request.getParameter("chapter") : "" %>"
                                   maxlength="100"/>
                        </div>
                        <span class="hint">Comma separated — e.g., ch 4, ch 5</span>
                    </div>

                </div><!-- /form-grid -->

                <div class="fg full">
                    <label>Upload File <span class="req">*</span></label>
                    <div class="drop-zone" id="dropZone">
                        <input type="file"
                               id="fileIn"
                               name="file"
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

                <hr class="pw-divider">
                <div class="actions">
                    <a href="${pageContext.request.contextPath}/adminDashboard" class="btn-cancel">
                        <i class="ti ti-x"></i> Cancel
                    </a>
                    <button type="submit" class="btn-upload">
                        <i class="ti ti-upload"></i> Upload Paper
                    </button>
                </div>
            </form>
    </div><!-- /pw-card -->

    <script>
        function onFileSelect(input) {
            const f = input.files[0];
            if (!f) return;
            document.getElementById('fileName').textContent = f.name;
            const mb = f.size / 1048576;
            document.getElementById('fileSize').textContent =
                mb >= 1 ? mb.toFixed(1) + ' MB' : (f.size / 1024).toFixed(0) + ' KB';
            document.getElementById('fileInfo').classList.add('show');
            const dz = document.getElementById('dropZone');
            dz.style.borderColor = '#16a34a';
            dz.style.background  = '#f0fdf4';
        }

        function clearFile() {
            document.getElementById('fileIn').value = '';
            document.getElementById('fileInfo').classList.remove('show');
            const dz = document.getElementById('dropZone');
            dz.style.borderColor = '';
            dz.style.background  = '';
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

        if (window.history.replaceState) {
            window.history.replaceState(null, null, window.location.href);
        }

        window.addEventListener('load', function() {
            const p = new URLSearchParams(window.location.search);
            if (p.get('uploaded') === 'true') {
                const t = document.getElementById('pwToast');
                t.classList.add('show');
                setTimeout(() => t.classList.remove('show'), 3000);
            }
        });
    </script>
</body>
</html>
