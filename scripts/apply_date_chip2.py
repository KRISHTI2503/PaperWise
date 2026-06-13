#!/usr/bin/env python3
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

HTML = """<div class="date-chip">
                <i class="ti ti-calendar"></i>
                <span id="pageDate"></span>
              </div>"""

JS = """(function() {
  const el = document.getElementById('pageDate');
  if (!el) return;
  el.textContent = new Date().toLocaleDateString('en-GB', {
    weekday: 'short', day: 'numeric', month: 'short', year: 'numeric'
  });
})();"""

SKIP = {"login.jsp", "register.jsp", "index.html"}


def fix(path):
    t = path.read_text(encoding="utf-8", errors="replace")
    orig = t
    if "topbar" not in t:
        return False
    if "background: #f3f4f6" not in t and "</style>" in t:
        t = t.replace("</style>", DATE_CSS + "\n    </style>", 1)
    if 'id="pageDate"' not in t:
        for pat in [
            r'<div class="pill-date"[^>]*>\s*<i[^>]*></i>\s*<span id="topbarDate"></span>\s*</div>',
            r'<span class="pill-date"[^>]*>.*?</span>',
            r'<button[^>]*pill-date[^>]*>.*?</button>',
        ]:
            m = re.search(pat, t, re.DOTALL | re.IGNORECASE)
            if m:
                t = t[:m.start()] + HTML + t[m.end():]
                break
    t = re.sub(
        r"<script>\s*\(function\(\)\s*\{\s*var days=\[.*?</script>\s*",
        "",
        t,
        flags=re.DOTALL,
    )
    if "getElementById('pageDate')" not in t and "</body>" in t:
        t = t.replace("</body>", "<script>\n" + JS + "\n</script>\n</body>", 1)
    if t != orig:
        path.write_text(t, encoding="utf-8", newline="\n")
        return True
    return False


for p in WEB.rglob("*.jsp"):
    if p.name in SKIP:
        continue
    if fix(p):
        print(p.relative_to(ROOT))
