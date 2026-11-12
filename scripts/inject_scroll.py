#!/usr/bin/env python3
"""Inject scroll preservation script into JSP files."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / "web"

SCROLL = """
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
"""

FILES = [
    "studentAllPapers.jsp",
    "requestPaper.jsp",
    "WEB-INF/views/myMarked.jsp",
    "admin-dashboard.jsp",
    "allPapers.jsp",
    "adminRequests.jsp",
    "students.jsp",
    "analytics.jsp",
    "WEB-INF/views/uploadPaper.jsp",
]

MARKER = "scrollPos_' + window.location.pathname"

for rel in FILES:
    path = WEB / rel.replace("/", "\\") if False else WEB / rel
    if not path.exists():
        path = ROOT / "web" / rel.replace("\\", "/")
    if not path.exists():
        print("SKIP (missing):", rel)
        continue
    text = path.read_text(encoding="utf-8")
    if MARKER in text:
        print("OK (exists):", rel)
        continue
    if "</body>" not in text:
        print("SKIP (no body):", rel)
        continue
    text = text.replace("</body>", SCROLL + "\n</body>", 1)
    path.write_text(text, encoding="utf-8", newline="\n")
    print("Added:", rel)
