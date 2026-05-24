<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.Paper" %>
<%
    Paper paper      = (Paper) request.getAttribute("paper");
    int   paperYear  = (paper != null) ? paper.getYear() : 0;
    int   currentYear = java.time.Year.now().getValue();

    String existingChapter  = (paper != null && paper.getChapter()  != null) ? paper.getChapter()  : "";
    String existingExamType = (paper != null && paper.getExamType() != null) ? paper.getExamType() : "";

    String errorMsg   = (String) session.getAttribute("errorMessage");
    if (errorMsg   != null) session.removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Paper - PaperWise</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/dist/tabler-icons.min.css">
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
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .card-top { display: flex; align-items: center; gap: 12px; margin-bottom: 4px; }

        .logo-box {
            width: 40px; height: 40px; background: #0f2744;
            border-radius: 10px; display: flex; align-items: center;
            justify-content: center; flex-shrink: 0;
        }

        .card-title { font-size: 20px; font-weight: 700; color: #0f2744; }
        .card-sub   { font-size: 13px; color: #8a97a8; margin-bottom: 1.3rem; }

        .info-bar {
            background: #eef6ff; border-left: 3px solid #3b82f6;
            border-radius: 0 8px 8px 0; padding: 9px 13px;
            font-size: 12.5px; color: #1d4ed8;
            display: flex; align-items: flex-start;
            gap: 8px; margin-bottom: 1.5rem; line-height: 1.5;
        }
        .info-bar i { font-size: 16px; flex-shrink: 0; margin-top: 1px; }

        .err-bar {
            background: #fef2f2; border-left: 3px solid #ef4444;
            border-radius: 0 8px 8px 0; padding: 9px 13px;
            font-size: 12.5px; color: #b91c1c;
            display: flex; align-items: flex-start;
            gap: 8px; margin-bottom: 1.2rem; line-height: 1.5;
        }
        .err-bar i { font-size: 16px; flex-shrink: 0; margin-top: 1px; }

        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem 1.2rem; }

        .fg { display: flex; flex-direction: column; gap: 5px; }
        .fg.full { grid-column: 1 / -1; }

        label {
            font-size: 12.5px; font-weight: 600; color: #374151;
            display: flex; align-items: center; gap: 5px;
        }
        .req { color: #ef4444; }
        .opt-badge {
            font-size: 11px; color: #9ca3af; font-weight: 400;
            background: #f3f4f6; border-radius: 4px; padding: 1px 6px;
        }

        .iw { position: relative; display: flex; align-items: center; }
        .iw .fi {
            position: absolute; left: 11px; font-size: 16px;
            color: #9ca3af; pointer-events: none; z-index: 1;
        }
        .iw input, .iw select { padding-left: 36px; }

        input, select {
            width: 100%; border: 1.5px solid #e5e7eb; border-radius: 9px;
            padding: 9px 11px; font-size: 13.5px; color: #111827;
            background: #f9fafb; font-family: inherit; outline: none;
            transition: border .18s, box-shadow .18s, background .18s;
        }
        input:focus, select:focus {
            border-color: #3b82f6; background: #fff;
            box-shadow: 0 0 0 3px rgba(59,130,246,.12);
        }
        select { appearance: none; cursor: pointer; padding-right: 32px; }

        .sw::after {
            content: ''; position: absolute; right: 11px; top: 50%;
            transform: translateY(-50%); border: 5px solid transparent;
            border-top-color: #9ca3af; pointer-events: none; margin-top: 3px;
        }

        .hint { font-size: 11px; color: #9ca3af; margin-top: 2px; }

        .tags-box {
            display: flex; flex-wrap: wrap; gap: 5px;
            border: 1.5px solid #e5e7eb; border-radius: 9px;
            padding: 7px 9px; background: #f9fafb;
            min-height: 42px; align-items: center; cursor: text;
            transition: border .18s, box-shadow .18s;
        }
        .tags-box:focus-within {
            border-color: #3b82f6; background: #fff;
            box-shadow: 0 0 0 3px rgba(59,130,246,.12);
        }
        .chip {
            background: #dbeafe; color: #1e40af; font-size: 12px;
            font-weight: 500; border-radius: 5px; padding: 2px 7px;
            display: flex; align-items: center; gap: 4px;
        }
        .chip button {
            background: none; border: none; color: #3b82f6;
            cursor: pointer; font-size: 14px; line-height: 1; padding: 0;
        }
        .tag-f {
            border: none; background: transparent; outline: none;
            font-size: 13px; font-family: inherit; color: #111827;
            min-width: 80px; flex: 1; padding: 2px;
        }

        hr.pw-div { border: none; border-top: 1px solid #f0f0f0; margin: 1.3rem 0; }

        .actions { display: flex; gap: 10px; }

        .btn-update {
            flex: 1; background: #0f2744; color: #fff; border: none;
            border-radius: 10px; padding: 11px; font-size: 14px;
            font-weight: 600; font-family: inherit; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            gap: 7px; transition: background .18s, transform .12s;
        }
        .btn-update:hover { background: #1a3a5c; }
        .btn-update:active { transform: scale(.98); }
        .btn-update i { font-size: 17px; }

        .btn-cancel {
            background: #f3f4f6; color: #374151;
            border: 1.5px solid #e5e7eb; border-radius: 10px;
            padding: 11px 20px; font-size: 13.5px; font-weight: 500;
            font-family: inherit; cursor: pointer;
            display: flex; align-items: center; gap: 6px;
            transition: background .18s; text-decoration: none;
        }
        .btn-cancel:hover { background: #e5e7eb; }
        .btn-cancel i { font-size: 16px; }

        .pw-toast {
            position: absolute; top: 14px; right: 14px;
            background: #dcfce7; border: 1px solid #16a34a; color: #15803d;
            border-radius: 9px; padding: 9px 14px; font-size: 12.5px;
            font-weight: 500; display: flex; align-items: center; gap: 6px;
            opacity: 0; transform: translateY(-6px);
            transition: all .28s; pointer-events: none;
        }
        .pw-toast i { font-size: 16px; }
        .pw-toast.show { opacity: 1; transform: translateY(0); }
    </style>
</head>
<body>

    <!-- Watermark SVGs -->
    <svg style="position:absolute;top:20px;left:30px;width:70px;height:80px;transform:rotate(-15deg);opacity:0.05;pointer-events:none"
         viewBox="0 0 70 80" fill="none">
        <rect x="5" y="5" width="55" height="70" rx="4" stroke="white" stroke-width="2"/>
        <line x1="15" y1="22" x2="50" y2="22" stroke="white" stroke-width="2"/>
        <line x1="15" y1="32" x2="50" y2="32" stroke="white" stroke-width="2"/>
        <line x1="15" y1="42" x2="38" y2="42" stroke="white" stroke-width="2"/>
    </svg>
    <svg style="position:absolute;top:30px;right:50px;width:70px;height:80px;transform:rotate(12deg);opacity:0.05;pointer-events:none"
         viewBox="0 0 70 80" fill="none">
        <rect x="5" y="5" width="55" height="70" rx="4" stroke="white" stroke-width="2"/>
        <line x1="15" y1="22" x2="50" y2="22" stroke="white" stroke-width="2"/>
        <line x1="15" y1="32" x2="50" y2="32" stroke="white" stroke-width="2"/>
        <line x1="15" y1="42" x2="38" y2="42" stroke="white" stroke-width="2"/>
    </svg>
    <svg style="position:absolute;bottom:40px;left:60px;width:70px;height:80px;transform:rotate(8deg);opacity:0.05;pointer-events:none"
         viewBox="0 0 70 80" fill="none">
        <rect x="5" y="5" width="55" height="70" rx="4" stroke="white" stroke-width="2"/>
        <line x1="15" y1="22" x2="50" y2="22" stroke="white" stroke-width="2"/>
        <line x1="15" y1="32" x2="50" y2="32" stroke="white" stroke-width="2"/>
        <line x1="15" y1="42" x2="38" y2="42" stroke="white" stroke-width="2"/>
    </svg>
    <svg style="position:absolute;bottom:40px;right:40px;width:70px;height:80px;transform:rotate(-10deg);opacity:0.05;pointer-events:none"
         viewBox="0 0 70 80" fill="none">
        <rect x="5" y="5" width="55" height="70" rx="4" stroke="white" stroke-width="2"/>
        <line x1="15" y1="22" x2="50" y2="22" stroke="white" stroke-width="2"/>
        <line x1="15" y1="32" x2="50" y2="32" stroke="white" stroke-width="2"/>
        <line x1="15" y1="42" x2="38" y2="42" stroke="white" stroke-width="2"/>
    </svg>

    <!-- CARD
         data-chapter  : pre-existing chapter value (passed from servlet)
         data-updated  : "true" when servlet redirects with ?updated=true
    -->
    <div class="pw-card"
         data-chapter="<%= existingChapter %>"
         data-updated="<%= "true".equals(request.getParameter("updated")) ? "true" : "false" %>">

        <!-- Toast -->
        <div class="pw-toast" id="pwToast">
            <i class="ti ti-circle-check"></i> Paper updated successfully!
        </div>

        <!-- HEADER -->
        <div class="card-top">
            <div class="logo-box">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
                     stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
                    <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
                </svg>
            </div>
            <div>
                <div class="card-title">Edit Paper</div>
            </div>
        </div>

        <div class="card-sub">Update paper metadata — the uploaded file cannot be changed.</div>

        <!-- ERROR BANNER -->
        <% if (errorMsg != null) { %>
        <div class="err-bar">
            <i class="ti ti-alert-circle"></i>
            <span><%= errorMsg %></span>
        </div>
        <% } %>

        <!-- INFO BANNER -->
        <div class="info-bar">
            <i class="ti ti-info-circle"></i>
            <span>You can only edit paper metadata. The uploaded file cannot be changed.</span>
        </div>

        <!-- FORM — posts to @WebServlet("/editPaper") -->
        <form method="post"
              action="${pageContext.request.contextPath}/editPaper"
              enctype="multipart/form-data">

            <input type="hidden" name="paperId"
                   value="<%= paper != null ? paper.getPaperId() : "" %>">

            <div class="form-grid">

                <!-- Subject Name -->
                <div class="fg">
                    <label>Subject Name <span class="req">*</span></label>
                    <div class="iw">
                        <i class="ti ti-book fi"></i>
                        <input type="text" name="subjectName"
                               value="<%= paper != null ? paper.getSubjectName() : "" %>"
                               placeholder="e.g., Data Structures" required>
                    </div>
                </div>

                <!-- Subject Code -->
                <div class="fg">
                    <label>Subject Code <span class="req">*</span></label>
                    <div class="iw">
                        <i class="ti ti-hash fi"></i>
                        <input type="text" name="subjectCode"
                               value="<%= paper != null ? paper.getSubjectCode() : "" %>"
                               placeholder="e.g., CS101" required>
                    </div>
                </div>

                <!-- Year -->
                <div class="fg">
                    <label>Year <span class="req">*</span></label>
                    <div class="iw sw">
                        <i class="ti ti-calendar fi"></i>
                        <select name="year">
                            <% for (int y = currentYear; y >= currentYear - 20; y--) { %>
                            <option value="<%= y %>" <%= (y == paperYear) ? "selected" : "" %>><%= y %></option>
                            <% } %>
                        </select>
                    </div>
                    <span class="hint">Valid range: <%= currentYear - 20 %> – <%= currentYear %></span>
                </div>

                <!-- Exam Type -->
                <div class="fg">
                    <label>Exam Type <span class="opt-badge">optional</span></label>
                    <div class="iw">
                        <i class="ti ti-file-description fi"></i>
                        <input type="text" name="examType"
                               value="<%= existingExamType %>"
                               placeholder="e.g., Sessional 2, Mid Term…"
                               list="examSuggestions">
                        <datalist id="examSuggestions">
                            <option value="Sessional 1">
                            <option value="Sessional 2">
                            <option value="Mid Term">
                            <option value="End Term">
                            <option value="Quiz">
                            <option value="Assignment">
                        </datalist>
                    </div>
                </div>

                <!-- Chapter tag input -->
                <div class="fg full">
                    <label>Chapter <span class="opt-badge">optional</span></label>
                    <div class="tags-box" id="tagsBox">
                        <input class="tag-f" id="tagInput"
                               placeholder="Type chapter &amp; press Enter…">
                    </div>
                    <input type="hidden" id="chapterHidden" name="chapter" value="">
                    <span class="hint">Press Enter or comma to add a chapter tag</span>
                </div>

            </div><!-- end form-grid -->

            <hr class="pw-div">

            <div class="actions">
                <a href="${pageContext.request.contextPath}/adminDashboard"
                   class="btn-cancel">
                    <i class="ti ti-x"></i> Cancel
                </a>
                <button type="submit" class="btn-update">
                    <i class="ti ti-edit"></i> Update Paper
                </button>
            </div>

        </form>

    </div><!-- end pw-card -->

    <script>
    (function () {

        var card = document.querySelector('.pw-card');

        // ── TOAST on ?updated=true ──────────────────────────────
        if (card.dataset.updated === 'true') {
            var toast = document.getElementById('pwToast');
            toast.classList.add('show');
            setTimeout(function () { toast.classList.remove('show'); }, 3000);
            // Clean URL so refresh doesn't re-show toast
            if (window.history.replaceState) {
                window.history.replaceState(null, '', window.location.pathname);
            }
        }

        // ── CHAPTER TAGS ────────────────────────────────────────
        var box     = document.getElementById('tagsBox');
        var tagInput  = document.getElementById('tagInput');
        var hidden    = document.getElementById('chapterHidden');

        function addChip(val) {
            var v = val.trim().replace(/,/g, '');
            if (!v) return;
            var chip = document.createElement('span');
            chip.className = 'chip';
            chip.dataset.val = v;
            chip.innerHTML = v + '<button type="button">\u00d7</button>';
            chip.querySelector('button').addEventListener('click', function () {
                chip.remove();
                updateHidden();
            });
            box.insertBefore(chip, tagInput);
            updateHidden();
        }

        function updateHidden() {
            var chips = box.querySelectorAll('.chip');
            hidden.value = Array.from(chips).map(function (c) { return c.dataset.val; }).join(', ');
        }

        // Pre-load existing chapters from data attribute
        var existing = (card.dataset.chapter || '').trim();
        if (existing) {
            existing.split(',').forEach(function (ch) { addChip(ch.trim()); });
        }

        tagInput.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' || e.key === ',') {
                e.preventDefault();
                var v = tagInput.value.trim().replace(/,$/, '');
                if (v) { addChip(v); tagInput.value = ''; }
            }
        });

        tagInput.addEventListener('blur', function () {
            if (tagInput.value.trim()) {
                addChip(tagInput.value);
                tagInput.value = '';
            }
        });

        box.addEventListener('click', function (e) {
            if (!e.target.closest('.chip')) tagInput.focus();
        });

        // ── DIFFICULTY TOGGLE ───────────────────────────────────
        var diffVal = document.getElementById('diffVal');
        var diffRow = document.getElementById('diffRow');
        var map     = { easy: 'easy', medium: 'med', hard: 'hard', med: 'med' };

        // No pre-selection — difficulty is not stored on the Paper model
        // (it is aggregated from difficulty_votes table, not editable here)

        diffRow.addEventListener('click', function (e) {
            var btn = e.target.closest('.db');
            if (!btn) return;
            var wasOn = btn.classList.contains('on');
            diffRow.querySelectorAll('.db').forEach(function (b) { b.classList.remove('on'); });
            if (!wasOn) {
                btn.classList.add('on');
                var d = btn.dataset.d;
                diffVal.value = d === 'easy' ? 'easy' : d === 'med' ? 'medium' : 'hard';
            } else {
                diffVal.value = '';
            }
        });

    })();
    </script>

</body>
</html>
