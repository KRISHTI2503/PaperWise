// ── Theme: apply immediately on every page load (before DOMContentLoaded) ──
(function () {
  var saved = localStorage.getItem('pw-theme') || 'light';
  document.documentElement.setAttribute('data-theme', saved);
})();

document.addEventListener('DOMContentLoaded', function () {
  // Sync icon after DOM is ready
  var saved = localStorage.getItem('pw-theme') || 'light';
  updateToggleIcon(saved);

  // Toggle button click — works for both #pwDarkToggle (navbar pages)
  // and any element with class .pw-dark-toggle
  var toggle = document.getElementById('pwDarkToggle');
  if (toggle) {
    toggle.addEventListener('click', function () {
      var current = document.documentElement.getAttribute('data-theme');
      var next = current === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', next);
      localStorage.setItem('pw-theme', next);
      updateToggleIcon(next);
    });
  }
});

function updateToggleIcon(theme) {
  var toggle = document.getElementById('pwDarkToggle');
  if (!toggle) return;
  toggle.innerHTML = theme === 'dark'
    ? '<i class="fa-solid fa-sun" style="font-size:14px"></i>'
    : '<i class="fa-solid fa-moon" style="font-size:14px"></i>';
}

// Shared toggleTheme() — called by analytics.jsp and students.jsp
// Keeps those pages in sync with the canonical pw-theme key
function toggleTheme() {
  var current = document.documentElement.getAttribute('data-theme');
  var next = current === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('pw-theme', next);
  // Update any icon with id="themeIcon"
  var icon = document.getElementById('themeIcon');
  if (icon) {
    icon.className = next === 'dark'
      ? 'fa-solid fa-sun'
      : 'fa-solid fa-moon';
  }
  updateToggleIcon(next);
}

function showToast(msg) {
  var t = document.getElementById('pwToast');
  var m = document.getElementById('pwToastMsg');
  if (!t || !m) return;
  m.textContent = msg;
  t.classList.add('show');
  setTimeout(function () { t.classList.remove('show'); }, 3000);
}
