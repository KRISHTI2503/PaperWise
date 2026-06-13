#!/usr/bin/env python3
"""Apply unified date-chip CSS/HTML/JS to JSP files with topbars."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / "web"

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

DATE_JS = """
(function() {
  const el = document.getElementById('pageDate');
  if (!el) return;
  const now = new Date();
  const options = { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' };
  el.textContent = now.toLocaleDateString('en-GB', options);
})();
"""

SKIP = {"login.jsp", "register.jsp", "index.html"}

def has_topbar(content):
    return "topbar" in content or "topbar-right" in content

def inject_css(content):
    if ".date-chip {" in content and "background: #f3f4f6" in content:
        return content
    if "</style>" in content:
        return content.replace("</style>", DATE_CSS + "\n    </style>", 1)
    return content

def replace_date_in_topbar(content):
    # Replace pill-date / button topbarDate blocks in topbar-right
    patterns = [
        (r'<div class="pill-date"[^>]*>.*?</div>\s*', DATE_HTML + "\n            "),
        (r'<span class="pill-date"[^>]*>.*?</span>\s*', DATE_HTML + "\n            "),
        (r'<button[^>]*id="topbarDate"[^>]*>.*?</button>\s*', DATE_HTML + "\n            "),
    ]
    for pat, repl in patterns:
        if re.search(pat, content, re.DOTALL):
            content = re.sub(pat, repl, content, count=1)
            return content, True
    # Insert before theme toggle in topbar-right if no date found
    if 'id="pageDate"' not in content and "topbar-right" in content:
        m = re.search(r'(<div class="topbar-right"[^>]*>)', content)
        if m:
            content = content[:m.end()] + "\n            " + DATE_HTML + "\n            " + content[m.end():]
            return content, True
    return content, False

def inject_js(content):
    if "getElementById('pageDate')" in content:
        return content
    if "</body>" in content:
        return content.replace("</body>", "<script>\n" + DATE_JS + "\n</script>\n</body>", 1)
    return content

def main():
    files = list(WEB.rglob("*.jsp"))
    for path in files:
        if path.name in SKIP:
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        if not has_topbar(text):
            continue
        orig = text
        text = inject_css(text)
        text, _ = replace_date_in_topbar(text)
        text = inject_js(text)
        if text != orig:
            path.write_text(text, encoding="utf-8", newline="\n")
            print("Updated", path.relative_to(ROOT))

if __name__ == "__main__":
    main()
