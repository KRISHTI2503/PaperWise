#!/usr/bin/env python3
"""Apply unified filter JS, date chip, and related JSP fixes."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / "web"
FILTER_JS = (ROOT / "web/resources/js/filter-table.js").read_text(encoding="utf-8")

DATE_CSS = """
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
.date-chip i {
  font-size: 15px;
  color: #f59e0b;
}
[data-theme="dark"] .date-chip {
  background: #1e293b;
  color: #94a3b8;
  border: 1px solid #334155;
}
[data-theme="dark"] .date-chip i {
  color: #fbbf24;
}
"""

DATE_HTML = """<div class="date-chip">
                <i class="ti ti-calendar"></i>
                <span id="pageDate"></span>
              </div>"""

DATE_JS = """(function() {
  const el = document.getElementById('pageDate');
  if (!el) return;
  const now = new Date();
  const options = { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' };
  el.textContent = now.toLocaleDateString('en-GB', options);
})();"""

SKIP_DATE = {"login.jsp", "register.jsp", "index.html"}


def apply_date_chip(path, text):
    if path.name in SKIP_DATE:
        return text
    if "topbar" not in text and "topbar-right" not in text:
        return text
    if "background: #f3f4f6" not in text or ".date-chip {" not in text.split("background: #f3f4f6")[0][-500:]:
        if ".date-chip {" not in text or "background: #f3f4f6" not in text:
            if "</style>" in text and DATE_CSS.strip() not in text:
                text = text.replace("</style>", DATE_CSS + "\n    </style>", 1)
    if 'id="pageDate"' not in text:
        for pat in [
            r'<div class="pill-date"[^>]*>.*?</div>\s*',
            r'<span class="pill-date"[^>]*>.*?</span>\s*',
            r'<button[^>]*(?:id="topbarDate"|class="pill-date")[^>]*>.*?</button>\s*',
        ]:
            if re.search(pat, text, re.DOTALL):
                text = re.sub(pat, DATE_HTML + "\n            ", text, count=1)
                break
        else:
            m = re.search(r'(<div class="topbar-right"[^>]*>)', text)
            if m:
                text = text[:m.end()] + "\n            " + DATE_HTML + "\n            " + text[m.end():]
    if "getElementById('pageDate')" not in text and "getElementById(\"pageDate\")" not in text:
        if "</body>" in text:
            text = text.replace("</body>", "<script>\n" + DATE_JS + "\n</script>\n</body>", 1)
    text = re.sub(
        r"<script>\s*\(function\(\)\s*\{\s*var days=\['Sun'.*?</script>\s*",
        "",
        text,
        count=0,
        flags=re.DOTALL,
    )
    return text


def inject_filter_block(text, marker_start, marker_end, replacement):
    if marker_start in text and marker_end in text:
        i = text.index(marker_start)
        j = text.index(marker_end, i) + len(marker_end)
        return text[:i] + replacement + text[j:]
    return text


def main():
    # --- allPapers exam options ---
    ap = WEB / "allPapers.jsp"
    t = ap.read_text(encoding="utf-8")
    t = t.replace('value="Mid Term"', 'value="mid term"')
    t = t.replace('>Mid Term</option>', '>Mid Term</option>')
    t = t.replace('value="End Term"', 'value="end term"')
    t = t.replace('value="Quiz"', 'value="quiz"')
    t = t.replace('value="Sessional 1"', 'value="sessional 1"')
    t = t.replace('value="Sessional 2"', 'value="sessional 2"')
    t = t.replace('value="Assignment"', 'value="assignment"')
    t = t.replace(
        'data-examtype="<%= paper.getExamType() != null ? paper.getExamType().toLowerCase() : "" %>"',
        'data-yr="<%= paper.getYear() %>"\n'
        '                    data-exam="<%= paper.getExamType() != null ? paper.getExamType().toLowerCase() : "" %>"\n'
        '                    data-examtype="<%= paper.getExamType() != null ? paper.getExamType().toLowerCase() : "" %>"',
    )
    old_filter = re.search(
        r"<script>\s*function filterTable\(\) \{.*?function toggleSidebar\(\)",
        t,
        re.DOTALL,
    )
    if old_filter:
        t = t[: old_filter.start()] + "<script>\n" + FILTER_JS + "\n\n    function toggleSidebar()" + t[old_filter.end() - len("function toggleSidebar()") :]
    t = apply_date_chip(ap, t)
    ap.write_text(t, encoding="utf-8", newline="\n")
    print("allPapers.jsp")

    # --- adminRequests ---
    ar = WEB / "adminRequests.jsp"
    t = ar.read_text(encoding="utf-8")
    t = t.replace('<tr data-status="<%= st %>">', '<tr data-status="<%= st %>" data-yr="<%= req.getYear() %>">')
    t = re.sub(
        r"function filterRows\(\) \{.*?\}\s*document\.getElementById\('searchIn'\).*?filterRows\);\s*",
        FILTER_JS + "\n    function filterRows() { filterTable(); }\n    ",
        t,
        flags=re.DOTALL,
    )
    t = apply_date_chip(ar, t)
    ar.write_text(t, encoding="utf-8", newline="\n")
    print("adminRequests.jsp")

    # --- students ---
    st = WEB / "students.jsp"
    t = st.read_text(encoding="utf-8")
    t = re.sub(
        r"function filterStudents\(\) \{.*?\}\s*\n\s*function toggleSidebar",
        "function filterStudents() { filterTable(); }\n\n    function toggleSidebar",
        t,
        flags=re.DOTALL,
    )
    if "function filterTable()" not in t:
        t = t.replace(
            "<!-- Toast -->\n<script>",
            "<!-- Toast -->\n<script>\n" + FILTER_JS + "\n</script>\n<script>",
            1,
        )
    t = apply_date_chip(st, t)
    st.write_text(t, encoding="utf-8", newline="\n")
    print("students.jsp")

    # --- studentAllPapers ---
    sap = WEB / "studentAllPapers.jsp"
    t = sap.read_text(encoding="utf-8")
    if 'id="examF"' not in t:
        t = t.replace(
            '<select class="fsel" id="diffF" onchange="filterRows()">',
            '<select class="fsel" id="examF" onchange="filterTable()">\n'
            '                        <option value="">All Exam Types</option>\n'
            '                        <option value="mid term">Mid Term</option>\n'
            '                        <option value="end term">End Term</option>\n'
            '                        <option value="sessional 1">Sessional 1</option>\n'
            '                        <option value="sessional 2">Sessional 2</option>\n'
            '                        <option value="quiz">Quiz</option>\n'
            '                    </select>\n'
            '                    <select class="fsel" id="diffF" onchange="filterTable()">',
        )
    t = t.replace('oninput="filterRows()"', 'oninput="filterTable()"')
    t = t.replace('onchange="filterRows()"', 'onchange="filterTable()"')
    t = re.sub(
        r"function filterRows\(\) \{.*?\}\s*\n\s*function replyToComment",
        FILTER_JS + "\n    function filterRows() { filterTable(); }\n\n    function replyToComment",
        t,
        flags=re.DOTALL,
    )
    t = t.replace(
        'data-diff="<%= dom %>">',
        'data-diff="<%= dom %>"\n'
        '                    data-exam="<%= examType != null ? examType.toLowerCase() : "" %>">',
    )
    t = apply_date_chip(sap, t)
    sap.write_text(t, encoding="utf-8", newline="\n")
    print("studentAllPapers.jsp")

    # Date chip on remaining JSPs
    for path in WEB.rglob("*.jsp"):
        if path.name in SKIP_DATE:
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        new = apply_date_chip(path, text)
        if new != text:
            path.write_text(new, encoding="utf-8", newline="\n")
            print("date:", path.relative_to(ROOT))


if __name__ == "__main__":
    main()
