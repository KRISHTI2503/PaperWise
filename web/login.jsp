<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/paperwise.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/tabler-icons/css/tabler-icons.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <script>
        (function(){var t=localStorage.getItem('pw-theme')||'light';document.documentElement.setAttribute('data-theme',t);})();
    </script>
    <script src="${pageContext.request.contextPath}/js/paperwise.js" defer></script>
    <style>
        :root {
            --login-bg: #0d1b2a;
            --login-card-bg: #ffffff;
            --login-card-text: #0d1b2a;
            --login-card-subtitle: #6b7280;
            --login-trust-border: #f0f0f0;
            --login-trust-text: #6b7280;
            --login-trust-icon: #4f7396;
            --login-alert-err-bg: #fff0f0;
            --login-alert-err-border: #f5c6cb;
            --login-alert-err-text: #c0392b;
            --login-alert-suc-bg: #f0fdf4;
            --login-alert-suc-border: #bbf7d0;
            --login-alert-suc-text: #166534;
            --login-label: #374151;
            --login-input-bg: #f9fafb;
            --login-input-border: #e5e7eb;
            --login-input-text: #111827;
            --login-input-focus: #4f7396;
            --login-pwd-toggle: #9ca3af;
            --login-forgot: #4f7396;
            --login-btn-bg: #1a3a5c;
            --login-btn-text: #ffffff;
            --login-btn-hover: #0d2a45;
            --login-divider-text: #9ca3af;
            --login-divider-line: #e5e7eb;
            --login-btn-reg-border: #d1d5db;
            --login-btn-reg-text: #1a3a5c;
            --login-btn-reg-hover-bg: #f0f5fa;
            --login-footer: #9ca3af;
        }

        :root[data-theme="dark"] {
            --login-bg: #070e17;
            --login-card-bg: #131b2e;
            --login-card-text: #f8fafc;
            --login-card-subtitle: #94a3b8;
            --login-trust-border: #1e293b;
            --login-trust-text: #94a3b8;
            --login-trust-icon: #3b82f6;
            --login-alert-err-bg: rgba(239, 68, 68, 0.1);
            --login-alert-err-border: rgba(239, 68, 68, 0.2);
            --login-alert-err-text: #f87171;
            --login-alert-suc-bg: rgba(34, 197, 94, 0.1);
            --login-alert-suc-border: rgba(34, 197, 94, 0.2);
            --login-alert-suc-text: #4ade80;
            --login-label: #cbd5e1;
            --login-input-bg: #1e293b;
            --login-input-border: #334155;
            --login-input-text: #f8fafc;
            --login-input-focus: #3b82f6;
            --login-pwd-toggle: #64748b;
            --login-forgot: #3b82f6;
            --login-btn-bg: #3b82f6;
            --login-btn-text: #ffffff;
            --login-btn-hover: #2563eb;
            --login-divider-text: #64748b;
            --login-divider-line: #334155;
            --login-btn-reg-border: #334155;
            --login-btn-reg-text: #3b82f6;
            --login-btn-reg-hover-bg: rgba(59, 130, 246, 0.1);
            --login-footer: #64748b;
        }

        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: var(--login-bg);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            position: relative;
            overflow-x: hidden;
            transition: background 0.3s ease;
        }

        /* ── Floating background shapes ── */
        .bg-shapes { position: fixed; inset: 0; pointer-events: none; z-index: 0; }
        .bg-shape {
            position: absolute;
            opacity: 0.07;
            color: #a8c4e0;
        }
        .bg-shape svg { display: block; }
        .shape-1 { top: 4%;  left: 3%;   transform: rotate(-18deg); }
        .shape-2 { top: 6%;  right: 4%;  transform: rotate(12deg);  }
        .shape-3 { top: 42%; left: 1%;   transform: rotate(-8deg);  }
        .shape-4 { top: 44%; right: 2%;  transform: rotate(10deg);  }
        .shape-5 { bottom: 6%; left: 5%; transform: rotate(-14deg); }
        .shape-6 { bottom: 4%; right: 3%;transform: rotate(8deg);   }

        /* ── Card ── */
        .login-card {
            position: relative;
            z-index: 1;
            background: var(--login-card-bg);
            border-radius: 20px;
            padding: 40px 36px 32px;
            width: 100%;
            max-width: 420px;
            border: 1px solid var(--login-card-border);
            box-shadow: 0 24px 64px rgba(0,0,0,0.45);
            animation: cardIn 0.45s ease-out both;
            transition: background 0.3s ease, border-color 0.3s ease;
        }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(28px); }
            to   { opacity: 1; transform: translateY(0);    }
        }

        /* ── Header ── */
        .card-header { text-align: center; margin-bottom: 6px; }
        .brand-row {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 8px;
        }
        .logo-icon {
            width: 44px; height: 44px;
            background: #1a3a5c;
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .logo-icon i { font-size: 20px; color: #ffffff; margin: 0; }
        .brand-name {
            font-size: 24px;
            font-weight: 700;
            color: var(--login-card-text);
            letter-spacing: -0.3px;
        }
        .card-subtitle {
            font-size: 13px;
            color: var(--login-card-subtitle);
            margin-bottom: 16px;
        }

        /* ── Trust indicators ── */
        .trust-row {
            display: flex;
            justify-content: center;
            gap: 18px;
            border-top: 1px solid var(--login-trust-border);
            border-bottom: 1px solid var(--login-trust-border);
            padding: 10px 0;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }
        .trust-item {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 11px;
            color: var(--login-trust-text);
            white-space: nowrap;
        }
        .trust-item i {
            font-size: 11px;
            color: var(--login-trust-icon);
            margin: 0;
            vertical-align: middle;
        }

        /* ── Error / success alerts ── */
        .alert-error {
            background: var(--login-alert-err-bg);
            border: 1px solid var(--login-alert-err-border);
            color: var(--login-alert-err-text);
            border-radius: 8px;
            padding: 10px 14px;
            margin-bottom: 16px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .alert-error i { color: var(--login-alert-err-text); font-size: 13px; margin: 0; flex-shrink: 0; }

        .alert-success {
            background: var(--login-alert-suc-bg);
            border: 1px solid var(--login-alert-suc-border);
            color: var(--login-alert-suc-text);
            border-radius: 8px;
            padding: 10px 14px;
            margin-bottom: 16px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .alert-success i { color: var(--login-alert-suc-text); font-size: 13px; margin: 0; flex-shrink: 0; }

        /* ── Form ── */
        .form-group { margin-bottom: 18px; }
        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: var(--login-label);
            margin-bottom: 6px;
        }
        .input-wrap { position: relative; }
        .input-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #9ca3af;
            font-size: 13px;
            pointer-events: none;
            margin: 0;
        }
        .form-group input {
            width: 100%;
            padding: 11px 14px 11px 38px;
            border: 1.5px solid var(--login-input-border);
            border-radius: 10px;
            background: var(--login-input-bg);
            font-size: 14px;
            color: var(--login-input-text);
            transition: border-color 0.2s, background 0.2s, box-shadow 0.2s;
            outline: none;
        }
        .form-group input::placeholder { color: #9ca3af; }
        .form-group input:focus {
            border-color: var(--login-input-focus);
            background: var(--login-card-bg);
            box-shadow: 0 0 0 3px rgba(79,115,150,0.12);
        }
        /* password field needs right padding for toggle */
        #password { padding-right: 42px; }

        .pwd-toggle {
            position: absolute;
            right: 11px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: var(--login-pwd-toggle);
            padding: 4px;
            line-height: 1;
            transition: color 0.2s;
        }
        .pwd-toggle:hover { color: var(--login-input-focus); }
        .pwd-toggle:focus { outline: none; }
        .pwd-toggle i { font-size: 13px; margin: 0; }

        .forgot-link {
            display: block;
            text-align: right;
            font-size: 12px;
            color: var(--login-forgot);
            text-decoration: none;
            margin-top: 6px;
            transition: color 0.2s;
        }
        .forgot-link:hover { color: var(--login-btn-bg); text-decoration: underline; }

        /* ── Buttons ── */
        .btn-signin {
            width: 100%;
            padding: 13px;
            background: var(--login-btn-bg);
            color: var(--login-btn-text);
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: background 0.2s, transform 0.15s;
            margin-top: 22px;
        }
        .btn-signin i { font-size: 14px; margin: 0; }
        .btn-signin:hover  { background: var(--login-btn-hover); }
        .btn-signin:active { transform: scale(0.98); }
        .btn-signin:focus  { outline: none; box-shadow: 0 0 0 3px rgba(26,58,92,0.25); }

        /* ── Divider ── */
        .divider {
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 20px 0 14px;
            color: var(--login-divider-text);
            font-size: 12px;
        }
        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--login-divider-line);
        }

        .btn-register {
            width: 100%;
            padding: 11px;
            background: transparent;
            color: var(--login-btn-reg-text);
            border: 1.5px solid var(--login-btn-reg-border);
            border-radius: 10px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: border-color 0.2s, background 0.2s;
        }
        .btn-register:hover {
            border-color: var(--login-btn-reg-text);
            background: var(--login-btn-reg-hover-bg);
        }
        .btn-register:focus { outline: none; }

        /* ── Footer ── */
        .card-footer {
            text-align: center;
            font-size: 12px;
            color: var(--login-footer);
            margin-top: 20px;
        }

        /* ── Theme Toggle — fixed top-right ── */
        #pwDarkToggle {
            position: fixed;
            top: 16px;
            right: 20px;
            z-index: 9999;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.18);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: background 0.2s, transform 0.15s;
        }
        #pwDarkToggle:hover {
            background: rgba(255, 255, 255, 0.15);
            transform: scale(1.05);
        }
        #pwDarkToggle:active { transform: scale(0.95); }
        [data-theme="dark"] #pwDarkToggle {
            background: rgba(255, 255, 255, 0.07);
            border-color: rgba(255, 255, 255, 0.10);
        }

        /* ── Responsive ── */
        @media (max-width: 375px) {
            .login-card { padding: 32px 20px 28px; }
            .brand-name { font-size: 21px; }
            .trust-row  { gap: 10px; }
        }
    
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
</style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/ui-consistency.css">
</head>
<body>

    <!-- Theme Toggle — fixed top-right corner -->
    <button id="pwDarkToggle" title="Toggle dark mode" aria-label="Toggle dark/light mode">
      <i class="fa-solid fa-moon" style="font-size:14px"></i>
    </button>

    <!-- Floating background document shapes -->
    <div class="bg-shapes" aria-hidden="true">
        <!-- Shape 1: top-left, large doc with lines -->
        <div class="bg-shape shape-1">
            <svg width="90" height="112" viewBox="0 0 90 112" fill="currentColor">
                <rect x="4" y="0" width="72" height="92" rx="6"/>
                <rect x="14" y="14" width="44" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="14" y="26" width="36" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="14" y="38" width="40" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="14" y="50" width="28" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="14" y="64" width="44" height="16" rx="3" fill="#0d1b2a"/>
            </svg>
        </div>
        <!-- Shape 2: top-right, doc with chart block -->
        <div class="bg-shape shape-2">
            <svg width="80" height="100" viewBox="0 0 80 100" fill="currentColor">
                <rect x="0" y="0" width="68" height="88" rx="6"/>
                <rect x="10" y="12" width="38" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="24" width="30" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="36" width="34" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="50" width="40" height="22" rx="3" fill="#0d1b2a"/>
                <rect x="14" y="60" width="6" height="8"  rx="1" fill="currentColor"/>
                <rect x="24" y="55" width="6" height="13" rx="1" fill="currentColor"/>
                <rect x="34" y="58" width="6" height="10" rx="1" fill="currentColor"/>
            </svg>
        </div>
        <!-- Shape 3: middle-left, slim doc -->
        <div class="bg-shape shape-3">
            <svg width="70" height="90" viewBox="0 0 70 90" fill="currentColor">
                <rect x="0" y="0" width="60" height="80" rx="6"/>
                <rect x="10" y="12" width="36" height="4" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="22" width="28" height="4" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="32" width="32" height="4" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="42" width="20" height="4" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="54" width="36" height="4" rx="2" fill="#0d1b2a"/>
            </svg>
        </div>
        <!-- Shape 4: middle-right, doc with table -->
        <div class="bg-shape shape-4">
            <svg width="85" height="106" viewBox="0 0 85 106" fill="currentColor">
                <rect x="0" y="0" width="74" height="96" rx="6"/>
                <rect x="10" y="12" width="46" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="24" width="38" height="5" rx="2" fill="#0d1b2a"/>
                <!-- table grid -->
                <rect x="10" y="38" width="52" height="38" rx="3" fill="#0d1b2a"/>
                <rect x="10" y="50" width="52" height="1.5" fill="currentColor"/>
                <rect x="10" y="62" width="52" height="1.5" fill="currentColor"/>
                <rect x="28" y="38" width="1.5" height="38" fill="currentColor"/>
                <rect x="44" y="38" width="1.5" height="38" fill="currentColor"/>
            </svg>
        </div>
        <!-- Shape 5: bottom-left, folded-corner doc -->
        <div class="bg-shape shape-5">
            <svg width="78" height="96" viewBox="0 0 78 96" fill="currentColor">
                <path d="M6 0 H56 L72 16 V86 Q72 92 66 92 H6 Q0 92 0 86 V6 Q0 0 6 0Z"/>
                <path d="M56 0 L56 16 L72 16Z" fill="#0d1b2a"/>
                <rect x="12" y="24" width="40" height="4" rx="2" fill="#0d1b2a"/>
                <rect x="12" y="34" width="32" height="4" rx="2" fill="#0d1b2a"/>
                <rect x="12" y="44" width="36" height="4" rx="2" fill="#0d1b2a"/>
                <rect x="12" y="54" width="24" height="4" rx="2" fill="#0d1b2a"/>
            </svg>
        </div>
        <!-- Shape 6: bottom-right, doc with lines + small chart -->
        <div class="bg-shape shape-6">
            <svg width="82" height="102" viewBox="0 0 82 102" fill="currentColor">
                <rect x="0" y="0" width="70" height="90" rx="6"/>
                <rect x="10" y="12" width="42" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="24" width="34" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="36" width="38" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="50" width="46" height="24" rx="3" fill="#0d1b2a"/>
                <rect x="14" y="62" width="7" height="8"  rx="1" fill="currentColor"/>
                <rect x="25" y="57" width="7" height="13" rx="1" fill="currentColor"/>
                <rect x="36" y="60" width="7" height="10" rx="1" fill="currentColor"/>
                <rect x="47" y="55" width="7" height="15" rx="1" fill="currentColor"/>
            </svg>
        </div>
    </div>

    <!-- Login card -->
    <div class="login-card">

        <!-- Header -->
        <div class="card-header">
            <div class="brand-row">
                <div class="logo-icon">
                    <i class="fa-solid fa-book-open"></i>
                </div>
                <span class="brand-name">PaperWise</span>
            </div>
            <p class="card-subtitle">Your academic paper management portal</p>
        </div>

        <!-- Trust indicators -->
        <div class="trust-row">
            <span class="trust-item">
                <i class="fa-solid fa-shield-halved"></i> Secure login
            </span>
            <span class="trust-item">
                <i class="fa-regular fa-file"></i> Verified papers
            </span>
            <span class="trust-item">
                <i class="fa-solid fa-users"></i> Students &amp; Admins
            </span>
        </div>

        

        

        <!-- Form — action/names unchanged so LoginServlet keeps working -->
        <form action="${pageContext.request.contextPath}/login" method="post" novalidate>

            <div class="form-group">
                <label for="username">Username</label>
                <div class="input-wrap">
                    <i class="fa-solid fa-user input-icon"></i>
                    <input
                        type="text"
                        id="username"
                        name="username"
                        placeholder="Enter your username"
                        required
                        autofocus
                        autocomplete="username"
                    />
                </div>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <div class="input-wrap">
                    <i class="fa-solid fa-lock input-icon"></i>
                    <input
                        type="password"
                        id="password"
                        name="password"
                        placeholder="Enter your password"
                        required
                        autocomplete="current-password"
                    />
                    <button
                        type="button"
                        class="pwd-toggle"
                        onclick="togglePassword()"
                        aria-label="Toggle password visibility"
                    >
                        <i id="toggleIcon" class="fa-regular fa-eye"></i>
                    </button>
                </div>
                <a href="${pageContext.request.contextPath}/forgotPassword"
                   class="forgot-link"
                   style="font-size:13px;color:#3b82f6;text-decoration:none;float:right">
                    Forgot password?
                </a>
            </div>

            <button type="submit" class="btn-signin">
                <i class="fa-solid fa-right-to-bracket"></i>
                Sign In
            </button>
        </form>

        <!-- Divider -->
        <div class="divider">New to PaperWise?</div>

        <!-- Register button -->
        <button
            type="button"
            class="btn-register"
            onclick="window.location.href='${pageContext.request.contextPath}/register.jsp'"
        >
            Create an account
        </button>

        <!-- Footer -->
        <p class="card-footer">&copy; 2026 PaperWise. All rights reserved.</p>

    </div><!-- /.login-card -->

    <script>
        function togglePassword() {
            const pwd  = document.getElementById('password');
            const icon = document.getElementById('toggleIcon');
            if (pwd.type === 'password') {
                pwd.type = 'text';
                icon.className = 'fa-regular fa-eye-slash';
            } else {
                pwd.type = 'password';
                icon.className = 'fa-regular fa-eye';
            }
        }

        // Prevent form re-submission on back-button
        if (window.history.replaceState) {
            window.history.replaceState(null, null, window.location.href);
        }

    </script>

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
    'password_reset':  ['Password reset successfully! Please log in.', 'success'],
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

<div id="pwToast"><i class="ti ti-circle-check"></i><span id="pwToastMsg"></span></div>
</body>
</html>
