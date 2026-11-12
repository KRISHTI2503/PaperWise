<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/paperwise.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/tabler-icons/css/tabler-icons.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <script>
        (function(){var t=localStorage.getItem('pw-theme')||'light';document.documentElement.setAttribute('data-theme',t);})();
    </script>
    <script src="${pageContext.request.contextPath}/js/paperwise.js" defer></script>
    <style>
        :root {
            --reg-bg: #0d1b2a;
            --reg-card-bg: #ffffff;
            --reg-card-text: #0d1b2a;
            --reg-card-subtitle: #6b7280;
            --reg-alert-err-bg: #fff0f0;
            --reg-alert-err-border: #f5c6cb;
            --reg-alert-err-text: #c0392b;
            --reg-alert-suc-bg: #f0fff4;
            --reg-alert-suc-border: #9ae6b4;
            --reg-alert-suc-text: #276749;
            --reg-label: #374151;
            --reg-input-bg: #f9fafb;
            --reg-input-border: #e5e7eb;
            --reg-input-text: #111827;
            --reg-input-focus: #4f7396;
            --reg-pwd-toggle: #9ca3af;
            --reg-helper-text: #9ca3af;
            --reg-btn-bg: #1a3a5c;
            --reg-btn-text: #ffffff;
            --reg-btn-hover: #0d2a45;
            --reg-signin-text: #6b7280;
            --reg-signin-link: #4f7396;
            --reg-signin-link-hover: #1a3a5c;
            --reg-footer: #9ca3af;
        }

        :root[data-theme="dark"] {
            --reg-bg: #070e17;
            --reg-card-bg: #131b2e;
            --reg-card-text: #f8fafc;
            --reg-card-subtitle: #94a3b8;
            --reg-alert-err-bg: rgba(239, 68, 68, 0.1);
            --reg-alert-err-border: rgba(239, 68, 68, 0.2);
            --reg-alert-err-text: #f87171;
            --reg-alert-suc-bg: rgba(34, 197, 94, 0.1);
            --reg-alert-suc-border: rgba(34, 197, 94, 0.2);
            --reg-alert-suc-text: #4ade80;
            --reg-label: #cbd5e1;
            --reg-input-bg: #1e293b;
            --reg-input-border: #334155;
            --reg-input-text: #f8fafc;
            --reg-input-focus: #3b82f6;
            --reg-pwd-toggle: #64748b;
            --reg-helper-text: #64748b;
            --reg-btn-bg: #3b82f6;
            --reg-btn-text: #ffffff;
            --reg-btn-hover: #2563eb;
            --reg-signin-text: #94a3b8;
            --reg-signin-link: #3b82f6;
            --reg-signin-link-hover: #60a5fa;
            --reg-footer: #64748b;
        }

        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: var(--reg-bg);
            min-height: 100vh;
            display: flex;
            align-items: flex-start;
            justify-content: center;
            padding: 28px 20px;
            position: relative;
            overflow-x: hidden;
            transition: background 0.3s ease;
        }

        /* ── Floating background shapes (identical set to login) ── */
        .bg-shapes { position: fixed; inset: 0; pointer-events: none; z-index: 0; }
        .bg-shape  { position: absolute; opacity: 0.07; color: #a8c4e0; }
        .bg-shape svg { display: block; }
        .shape-1 { top: 4%;    left: 3%;   transform: rotate(-18deg); }
        .shape-2 { top: 6%;    right: 4%;  transform: rotate(12deg);  }
        .shape-3 { top: 42%;   left: 1%;   transform: rotate(-8deg);  }
        .shape-4 { top: 44%;   right: 2%;  transform: rotate(10deg);  }
        .shape-5 { bottom: 6%; left: 5%;   transform: rotate(-14deg); }
        .shape-6 { bottom: 4%; right: 3%;  transform: rotate(8deg);   }

        /* ── Card ── */
        .register-card {
            position: relative;
            z-index: 1;
            background: var(--reg-card-bg);
            border-radius: 20px;
            padding: 40px 36px 32px;
            width: 100%;
            max-width: 420px;
            border: 1px solid var(--reg-card-border);
            box-shadow: 0 24px 64px rgba(0,0,0,0.45);
            animation: cardIn 0.45s ease-out both;
            transition: background 0.3s ease, border-color 0.3s ease;
        }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(28px); }
            to   { opacity: 1; transform: translateY(0);    }
        }

        /* ── Header ── */
        .card-header { text-align: center; margin-bottom: 24px; }
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
        .brand-name  { font-size: 24px; font-weight: 700; color: var(--reg-card-text); letter-spacing: -0.3px; }
        .card-subtitle { font-size: 13px; color: var(--reg-card-subtitle); }

        /* ── Alerts ── */
        .alert-error {
            background: var(--reg-alert-err-bg);
            border: 1px solid var(--reg-alert-err-border);
            color: var(--reg-alert-err-text);
            border-radius: 8px;
            padding: 10px 14px;
            margin-bottom: 16px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .alert-error i { color: var(--reg-alert-err-text); font-size: 13px; margin: 0; flex-shrink: 0; }

        .alert-success {
            background: var(--reg-alert-suc-bg);
            border: 1px solid var(--reg-alert-suc-border);
            color: var(--reg-alert-suc-text);
            border-radius: 8px;
            padding: 10px 14px;
            margin-bottom: 16px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .alert-success i { color: var(--reg-alert-suc-text); font-size: 13px; margin: 0; flex-shrink: 0; }

        /* ── Form ── */
        .form-group { margin-bottom: 16px; }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: var(--reg-label);
            margin-bottom: 6px;
        }
        .form-group label .req { color: #e53e3e; margin-left: 2px; }

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
            border: 1.5px solid var(--reg-input-border);
            border-radius: 10px;
            background: var(--reg-input-bg);
            font-size: 14px;
            color: var(--reg-input-text);
            transition: border-color 0.2s, background 0.2s, box-shadow 0.2s;
            outline: none;
        }
        .form-group input::placeholder { color: #9ca3af; }
        .form-group input:focus {
            border-color: var(--reg-input-focus);
            background: var(--reg-card-bg);
            box-shadow: 0 0 0 3px rgba(79,115,150,0.12);
        }
        /* fields with eye toggle need right padding */
        #password, #confirmPassword { padding-right: 42px; }

        .pwd-toggle {
            position: absolute;
            right: 11px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: var(--reg-pwd-toggle);
            padding: 4px;
            line-height: 1;
            transition: color 0.2s;
        }
        .pwd-toggle:hover  { color: var(--reg-input-focus); }
        .pwd-toggle:focus  { outline: none; }
        .pwd-toggle i      { font-size: 13px; margin: 0; }

        .helper-text {
            font-size: 11px;
            color: var(--reg-helper-text);
            margin-top: 5px;
            line-height: 1.5;
        }

        /* ── Create Account button ── */
        .btn-create {
            width: 100%;
            padding: 13px;
            background: var(--reg-btn-bg);
            color: var(--reg-btn-text);
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
            margin-top: 20px;
        }
        .btn-create i      { font-size: 14px; margin: 0; }
        .btn-create:hover  { background: var(--reg-btn-hover); }
        .btn-create:active { transform: scale(0.98); }
        .btn-create:focus  { outline: none; box-shadow: 0 0 0 3px rgba(26,58,92,0.25); }

        /* ── Sign-in link ── */
        .signin-link {
            text-align: center;
            font-size: 13px;
            color: var(--reg-signin-text);
            margin-top: 16px;
        }
        .signin-link a {
            color: var(--reg-signin-link);
            text-decoration: none;
            font-weight: 500;
            transition: color 0.2s;
        }
        .signin-link a:hover { color: var(--reg-signin-link-hover); text-decoration: underline; }

        /* ── Footer ── */
        .card-footer {
            text-align: center;
            font-size: 12px;
            color: var(--reg-footer);
            margin-top: 16px;
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
            .register-card { padding: 32px 18px 28px; }
            .brand-name    { font-size: 21px; }
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

    <!-- Floating background document shapes (same as login) -->
    <div class="bg-shapes" aria-hidden="true">
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
        <div class="bg-shape shape-2">
            <svg width="80" height="100" viewBox="0 0 80 100" fill="currentColor">
                <rect x="0" y="0" width="68" height="88" rx="6"/>
                <rect x="10" y="12" width="38" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="24" width="30" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="36" width="34" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="50" width="40" height="22" rx="3" fill="#0d1b2a"/>
                <rect x="14" y="60" width="6"  height="8"  rx="1" fill="currentColor"/>
                <rect x="24" y="55" width="6"  height="13" rx="1" fill="currentColor"/>
                <rect x="34" y="58" width="6"  height="10" rx="1" fill="currentColor"/>
            </svg>
        </div>
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
        <div class="bg-shape shape-4">
            <svg width="85" height="106" viewBox="0 0 85 106" fill="currentColor">
                <rect x="0" y="0" width="74" height="96" rx="6"/>
                <rect x="10" y="12" width="46" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="24" width="38" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="38" width="52" height="38" rx="3" fill="#0d1b2a"/>
                <rect x="10" y="50" width="52" height="1.5" fill="currentColor"/>
                <rect x="10" y="62" width="52" height="1.5" fill="currentColor"/>
                <rect x="28" y="38" width="1.5" height="38" fill="currentColor"/>
                <rect x="44" y="38" width="1.5" height="38" fill="currentColor"/>
            </svg>
        </div>
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
        <div class="bg-shape shape-6">
            <svg width="82" height="102" viewBox="0 0 82 102" fill="currentColor">
                <rect x="0" y="0" width="70" height="90" rx="6"/>
                <rect x="10" y="12" width="42" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="24" width="34" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="36" width="38" height="5" rx="2" fill="#0d1b2a"/>
                <rect x="10" y="50" width="46" height="24" rx="3" fill="#0d1b2a"/>
                <rect x="14" y="62" width="7"  height="8"  rx="1" fill="currentColor"/>
                <rect x="25" y="57" width="7"  height="13" rx="1" fill="currentColor"/>
                <rect x="36" y="60" width="7"  height="10" rx="1" fill="currentColor"/>
                <rect x="47" y="55" width="7"  height="15" rx="1" fill="currentColor"/>
            </svg>
        </div>
    </div>

    <!-- Registration card -->
    <div class="register-card">

        <!-- Header -->
        <div class="card-header">
            <div class="brand-row">
                <div class="logo-icon">
                    <i class="fa-solid fa-book-open"></i>
                </div>
                <span class="brand-name">PaperWise</span>
            </div>
            <p class="card-subtitle">Create your account</p>
        </div>

        

        

        <!-- Form — action and all field names unchanged so RegisterServlet keeps working -->
        <form action="${pageContext.request.contextPath}/register" method="post" novalidate
              onsubmit="return validateForm()">

            <!-- Username -->
            <div class="form-group">
                <label for="username">Username<span class="req">*</span></label>
                <div class="input-wrap">
                    <i class="fa-solid fa-user input-icon"></i>
                    <input
                        type="text"
                        id="username"
                        name="username"
                        placeholder="Choose a username"
                        value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>"
                        required
                        autofocus
                        minlength="3"
                        pattern="[a-zA-Z0-9_]+"
                        title="Username can only contain letters, numbers, and underscores"
                        autocomplete="username"
                    />
                </div>
                <p class="helper-text">At least 3 characters, letters, numbers, and underscores only</p>
            </div>

            <!-- Email -->
            <div class="form-group">
                <label for="email">Email<span class="req">*</span></label>
                <div class="input-wrap">
                    <i class="fa-solid fa-envelope input-icon"></i>
                    <input
                        type="email"
                        id="email"
                        name="email"
                        placeholder="your.email@example.com"
                        value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>"
                        required
                        autocomplete="email"
                    />
                </div>
            </div>

            <!-- Password -->
            <div class="form-group">
                <label for="password">Password<span class="req">*</span></label>
                <div class="input-wrap">
                    <i class="fa-solid fa-lock input-icon"></i>
                    <input
                        type="password"
                        id="password"
                        name="password"
                        placeholder="Create a strong password"
                        required
                        minlength="8"
                        pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$"
                        title="Password must be at least 8 characters and contain: uppercase, lowercase, digit, and special character (!@#$%^&*)"
                        autocomplete="new-password"
                    />
                    <button type="button" class="pwd-toggle"
                            onclick="togglePwd('password','icon1')"
                            aria-label="Toggle password visibility">
                        <i id="icon1" class="fa-regular fa-eye"></i>
                    </button>
                </div>
                <p class="helper-text">At least 8 characters with uppercase, lowercase, digit, and special character (!@#$%^&amp;*)</p>
            </div>

            <!-- Confirm Password -->
            <div class="form-group">
                <label for="confirmPassword">Confirm Password<span class="req">*</span></label>
                <div class="input-wrap">
                    <i class="fa-solid fa-lock input-icon"></i>
                    <input
                        type="password"
                        id="confirmPassword"
                        name="confirmPassword"
                        placeholder="Re-enter your password"
                        required
                        minlength="8"
                        autocomplete="new-password"
                    />
                    <button type="button" class="pwd-toggle"
                            onclick="togglePwd('confirmPassword','icon2')"
                            aria-label="Toggle confirm password visibility">
                        <i id="icon2" class="fa-regular fa-eye"></i>
                    </button>
                </div>
            </div>

            <button type="submit" class="btn-create">
                <i class="fa-solid fa-user-plus"></i>
                Create Account
            </button>

        </form>

        <p class="signin-link">
            Already have an account?
            <a href="${pageContext.request.contextPath}/login.jsp">Sign in</a>
        </p>

        <p class="card-footer">&copy; 2026 PaperWise. All rights reserved.</p>

    </div><!-- /.register-card -->

    <script>
        // Independent toggle for each password field
        function togglePwd(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon  = document.getElementById(iconId);
            if (input.type === 'password') {
                input.type    = 'text';
                icon.className = 'fa-regular fa-eye-slash';
            } else {
                input.type    = 'password';
                icon.className = 'fa-regular fa-eye';
            }
        }

        function validateEmail(email) {
            const regex = /^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/;
            if (!regex.test(email)) return false;
            const parts = email.split('@');
            if (parts.length !== 2) return false;
            const domainParts = parts[1].split('.');
            if (domainParts.length < 2) return false;
            for (const part of domainParts) {
                if (part.length === 0) return false;
            }
            const tld = domainParts[domainParts.length - 1];
            if (tld.length < 2) return false;
            const domainName = domainParts[domainParts.length - 2];
            if (domainName.length < 2) return false;
            return true;
        }

        const emailInput = document.getElementById('email')
            || document.querySelector('input[name="email"]');

        function showEmailError(msg) {
            let err = document.getElementById('emailError');
            if (!err && emailInput) {
                err = document.createElement('div');
                err.id = 'emailError';
                err.style.cssText = 'color:#dc2626;font-size:11.5px;margin-top:4px';
                const parent = emailInput.parentNode && emailInput.parentNode.parentNode
                    ? emailInput.parentNode.parentNode : emailInput.parentNode;
                if (parent) parent.appendChild(err);
            }
            if (err) err.textContent = msg;
        }

        function hideEmailError() {
            const err = document.getElementById('emailError');
            if (err) err.remove();
        }

        if (emailInput) {
            emailInput.addEventListener('blur', function() {
                const val = this.value.trim();
                if (val && !validateEmail(val)) {
                    this.style.borderColor = '#dc2626';
                    showEmailError('Please enter a valid email address (e.g. user@gmail.com)');
                } else {
                    this.style.borderColor = '';
                    hideEmailError();
                }
            });
        }

        // Client-side password match validation
        function validateForm() {
            const email = emailInput ? emailInput.value.trim() : '';
            if (email && !validateEmail(email)) {
                emailInput.style.borderColor = '#dc2626';
                showEmailError('Please enter a valid email (e.g. user@gmail.com)');
                emailInput.focus();
                return false;
            }
            const pwd     = document.getElementById('password').value;
            const confirm = document.getElementById('confirmPassword').value;
            if (pwd !== confirm) {
                alert('Passwords do not match. Please try again.');
                return false;
            }
            return true;
        }

        // Prevent re-submission on back-button
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
