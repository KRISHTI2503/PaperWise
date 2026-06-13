#!/usr/bin/env python3
"""Inject unified pw-toast system into all JSP files under web/."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / "web"

TOAST_CSS = r"""
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
"""

TOAST_FOOTER = r"""
<div class="pw-toast-container" id="pwToastContainer"></div>
<script>
function showToast(message, type, duration) {
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

  const messages = {
    'uploaded':        ['Paper uploaded successfully!',    'success'],
    'updated':         ['Paper updated successfully!',     'success'],
    'deleted':         ['Paper deleted successfully!',     'success'],
    'marked':          ['Marked as useful!',               'success'],
    'unmarked':        ['Removed from useful marks.',      'info'],
    'voted':           ['Difficulty vote saved!',          'success'],
    'rated':           ['Difficulty vote saved!',          'success'],
    'commented':       ['Comment posted!',                 'success'],
    'comment_deleted': ['Comment deleted.',                'info'],
    'submitted':       ['Request submitted successfully!', 'success'],
    'request_deleted': ['Request deleted.',                'info'],
    'status_updated':  ['Status updated successfully!',    'success'],
    'logged_out':      ['You have been logged out.',       'info'],
    'registered':      ['Account created! Please log in.', 'success'],
    'error':           ['Something went wrong. Try again.', 'error'],
    'unauthorized':    ['Please log in to continue.',      'warning'],
    'invalid':         ['Invalid input. Please check your fields.', 'warning'],
  };

  for (const [param, [msg, type]] of Object.entries(messages)) {
    if (p.get(param) === 'true' || p.get(param) === '1') {
      showToast(msg, type);
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
"""

# Patterns to remove
REMOVE_BLOCKS = [
    # Session flash success/error banners (scriptlet blocks)
    re.compile(
        r"<%\s*String successMsg = \(String\) session\.getAttribute\(\"successMessage\"\);.*?<%\s*\}\s*%>",
        re.DOTALL,
    ),
    re.compile(
        r"<%\s*String successMessage = \(String\) session\.getAttribute\(\"successMessage\"\);.*?<%\s*\}\s*%>",
        re.DOTALL,
    ),
    re.compile(
        r"<% if \(successMessage != null\) \{ %>.*?<% \}\s*%>",
        re.DOTALL,
    ),
    re.compile(
        r"<%-- Error message.*?<% \}\s*%>",
        re.DOTALL,
    ),
    re.compile(
        r"<%-- Success message.*?<% \}\s*%>",
        re.DOTALL,
    ),
    re.compile(
        r"<%\s*String errorMessage = \(String\) request\.getAttribute\(\"errorMessage\"\);.*?<%\s*\}\s*%>",
        re.DOTALL,
    ),
    re.compile(
        r"<% if \(errorMessage != null\) \{ %>.*?<% \}\s*%>",
        re.DOTALL,
    ),
    re.compile(
        r"<div class=\"alert alert-success\">.*?</div>\s*",
        re.DOTALL,
    ),
    re.compile(
        r"<div class=\"alert alert-danger\">.*?</div>\s*",
        re.DOTALL,
    ),
    re.compile(
        r"<div class=\"alert alert-info\">.*?</div>\s*",
        re.DOTALL,
    ),
    re.compile(
        r"<div class=\"alert-success\"[^>]*>.*?</div>\s*",
        re.DOTALL,
    ),
    re.compile(
        r"<div class=\"alert-error\"[^>]*>.*?</div>\s*",
        re.DOTALL,
    ),
    re.compile(
        r"<div class=\"alert-error\" role=\"alert\">.*?</div>\s*",
        re.DOTALL,
    ),
    re.compile(
        r"<div class=\"alert-success\" role=\"alert\">.*?</div>\s*",
        re.DOTALL,
    ),
]

# Old toast CSS (legacy single toast)
OLD_TOAST_CSS = re.compile(
    r"\s*\.pw-toast\s*\{[^}]*\}[^.]*(?:\.pw-toast[^\{]*\{[^}]*\})*",
    re.DOTALL,
)

# Old static toast divs
OLD_TOAST_DIV = re.compile(
    r'<div[^>]*id=["\']pwToast["\'][^>]*>.*?</div>\s*',
    re.DOTALL,
)
OLD_TOAST_DIV2 = re.compile(
    r'<div[^>]*id=["\']pw-toast["\'][^>]*>.*?</div>\s*',
    re.DOTALL,
)

# Old showToast function blocks
OLD_SHOW_TOAST = re.compile(
    r"function showToast\([^)]*\)\s*\{[^}]*(?:\{[^}]*\}[^}]*)*\}\s*",
    re.DOTALL,
)

# Old load listener for uploaded param only
OLD_UPLOAD_LISTENER = re.compile(
    r"window\.addEventListener\('load',\s*function\(\)\s*\{\s*const p = new URLSearchParams.*?pwToast.*?\}\);\s*",
    re.DOTALL,
)


def inject_css(content: str) -> str:
    if ".pw-toast-container" in content:
        return content
    # Insert before first </style>
    idx = content.lower().find("</style>")
    if idx == -1:
        return content + "\n<style>" + TOAST_CSS + "\n</style>\n"
    return content[:idx] + TOAST_CSS + content[idx:]


def inject_footer(content: str) -> str:
    if 'id="pwToastContainer"' in content:
        # Update footer if old script exists without container
        pass
    if 'id="pwToastContainer"' not in content:
        body_end = content.lower().rfind("</body>")
        if body_end == -1:
            content = content + TOAST_FOOTER
        else:
            content = content[:body_end] + TOAST_FOOTER + "\n" + content[body_end:]
    else:
        # Replace old unified script if duplicated
        if "const messages = {" not in content:
            # Remove old showToast-only script before body and append footer script only
            content = OLD_SHOW_TOAST.sub("", content)
            body_end = content.lower().rfind("</body>")
            if body_end != -1 and "const messages = {" not in content[:body_end]:
                content = content[:body_end] + TOAST_FOOTER + "\n" + content[body_end:]
    return content


def clean(content: str) -> str:
    for pat in REMOVE_BLOCKS:
        content = pat.sub("", content)
    content = OLD_TOAST_DIV.sub("", content)
    content = OLD_TOAST_DIV2.sub("", content)
    content = OLD_SHOW_TOAST.sub("", content)
    content = OLD_UPLOAD_LISTENER.sub("", content)
    # Remove top session scriptlet at top of adminRequests
    content = re.sub(
        r"<%\s*String successMessage = \(String\) session\.getAttribute\(\"successMessage\"\);\s*"
        r"String errorMessage = \(String\) session\.getAttribute\(\"errorMessage\"\);\s*"
        r"session\.removeAttribute\(\"successMessage\"\);\s*"
        r"session\.removeAttribute\(\"errorMessage\"\);\s*%>\s*",
        "",
        content,
    )
    return content


def main():
    jsp_files = list(WEB.rglob("*.jsp"))
    updated = []
    for path in jsp_files:
        text = path.read_text(encoding="utf-8", errors="replace")
        original = text
        text = clean(text)
        text = inject_css(text)
        text = inject_footer(text)
        if text != original:
            path.write_text(text, encoding="utf-8", newline="\n")
            updated.append(str(path.relative_to(ROOT)))
    print(f"Updated {len(updated)} files:")
    for f in updated:
        print(f"  - {f}")


if __name__ == "__main__":
    main()
