/* ==========================================================================
   THEME AND RESPONSIVE LAYOUT ENGINE (theme.js)
   Handles dark/light mode toggle state, local storage cache, and mobile menus.
   ========================================================================== */

// Immediately check and apply the cached theme before the DOM is painted (prevents flash of unstyled content)
(function() {
    const theme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', theme);
})();

/**
 * Toggles between light and dark themes.
 */
function toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    
    updateThemeIcons(newTheme);
}

/**
 * Updates all theme toggle icons across the active page viewport.
 * @param {string} theme - The new theme name ('light' or 'dark').
 */
function updateThemeIcons(theme) {
    const icons = document.querySelectorAll('.theme-toggle-btn i');
    icons.forEach(icon => {
        if (theme === 'dark') {
            icon.className = 'fa-solid fa-sun'; // Show sun to toggle to light mode
            icon.setAttribute('title', 'Switch to Light Mode');
        } else {
            icon.className = 'fa-solid fa-moon'; // Show moon to toggle to dark mode
            icon.setAttribute('title', 'Switch to Dark Mode');
        }
    });
}

/**
 * Toggles the responsive sidebar navigation slide-in visibility state.
 */
function toggleSidebar() {
    const sidebar = document.querySelector('.sidebar') || document.querySelector('.sb');
    if (sidebar) {
        sidebar.classList.toggle('open');
    }
}

// Bind initialization elements when DOM content completes loading
window.addEventListener('DOMContentLoaded', () => {
    const currentTheme = localStorage.getItem('theme') || 'light';
    updateThemeIcons(currentTheme);

    // Auto-close slide-out mobile sidebar if clicking outside of it
    document.addEventListener('click', (e) => {
        const sidebar = document.querySelector('.sidebar') || document.querySelector('.sb');
        const toggle = document.querySelector('.menu-toggle');
        if (sidebar && sidebar.classList.contains('open')) {
            if (!sidebar.contains(e.target) && toggle && !toggle.contains(e.target)) {
                sidebar.classList.remove('open');
            }
        }
    });
});
