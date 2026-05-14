<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: #0d1b2a;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            position: relative;
            overflow-x: hidden;
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
            background: #ffffff;
            border-radius: 20px;
            padding: 40px 36px 32px;
            width: 100%;
            max-width: 420px;
            border: 1px solid rgba(255,255,255,0.12);
            box-shadow: 0 24px 64px rgba(0,0,0,0.45);
            animation: cardIn 0.45s ease-out both;
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
            color: #0d1b2a;
            letter-spacing: -0.3px;
        }
        .card-subtitle {
            font-size: 13px;
            color: #6b7280;
            margin-bottom: 16px;
        }

        /* ── Trust indicators ── */
        .trust-row {
            display: flex;
            justify-content: center;
            gap: 18px;
            border-top: 1px solid #f0f0f0;
            border-bottom: 1px solid #f0f0f0;
            padding: 10px 0;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }
        .trust-item {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 11px;
            color: #6b7280;
            white-space: nowrap;
        }
        .trust-item i {
            font-size: 11px;
            color: #4f7396;
            margin: 0;
            vertical-align: middle;
        }

        /* ── Error / success alerts ── */
        .alert-error {
            background: #fff0f0;
            border: 1px solid #f5c6cb;
            color: #c0392b;
            border-radius: 8px;
            padding: 10px 14px;
            margin-bottom: 16px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .alert-error i { color: #c0392b; font-size: 13px; margin: 0; flex-shrink: 0; }

        .alert-success {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            color: #166534;
            border-radius: 8px;
            padding: 10px 14px;
            margin-bottom: 16px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .alert-success i { color: #166534; font-size: 13px; margin: 0; flex-shrink: 0; }

        /* ── Form ── */
        .form-group { margin-bottom: 18px; }
        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: #374151;
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
            border: 1.5px solid #e5e7eb;
            border-radius: 10px;
            background: #f9fafb;
            font-size: 14px;
            color: #111827;
            transition: border-color 0.2s, background 0.2s, box-shadow 0.2s;
            outline: none;
        }
        .form-group input::placeholder { color: #9ca3af; }
        .form-group input:focus {
            border-color: #4f7396;
            background: #ffffff;
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
            color: #9ca3af;
            padding: 4px;
            line-height: 1;
            transition: color 0.2s;
        }
        .pwd-toggle:hover { color: #4f7396; }
        .pwd-toggle:focus { outline: none; }
        .pwd-toggle i { font-size: 13px; margin: 0; }

        .forgot-link {
            display: block;
            text-align: right;
            font-size: 12px;
            color: #4f7396;
            text-decoration: none;
            margin-top: 6px;
            transition: color 0.2s;
        }
        .forgot-link:hover { color: #1a3a5c; text-decoration: underline; }

        /* ── Buttons ── */
        .btn-signin {
            width: 100%;
            padding: 13px;
            background: #1a3a5c;
            color: #ffffff;
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
        .btn-signin:hover  { background: #0d2a45; }
        .btn-signin:active { transform: scale(0.98); }
        .btn-signin:focus  { outline: none; box-shadow: 0 0 0 3px rgba(26,58,92,0.25); }

        /* ── Divider ── */
        .divider {
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 20px 0 14px;
            color: #9ca3af;
            font-size: 12px;
        }
        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: #e5e7eb;
        }

        .btn-register {
            width: 100%;
            padding: 11px;
            background: transparent;
            color: #1a3a5c;
            border: 1.5px solid #d1d5db;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: border-color 0.2s, background 0.2s;
        }
        .btn-register:hover {
            border-color: #1a3a5c;
            background: #f0f5fa;
        }
        .btn-register:focus { outline: none; }

        /* ── Footer ── */
        .card-footer {
            text-align: center;
            font-size: 12px;
            color: #9ca3af;
            margin-top: 20px;
        }

        /* ── Responsive ── */
        @media (max-width: 375px) {
            .login-card { padding: 32px 20px 28px; }
            .brand-name { font-size: 21px; }
            .trust-row  { gap: 10px; }
        }
    </style>
</head>
<body>

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

        <%-- Error message from LoginServlet --%>
        <%
            String errorMessage = (String) request.getAttribute("errorMessage");
            if (errorMessage != null) {
        %>
            <div class="alert-error" role="alert">
                <i class="fa-solid fa-circle-exclamation"></i>
                <%= errorMessage %>
            </div>
        <% } %>

        <%-- Success message (e.g. after registration) --%>
        <%
            String successMessage = request.getParameter("success");
            if (successMessage != null) {
        %>
            <div class="alert-success" role="alert">
                <i class="fa-solid fa-circle-check"></i>
                <%= successMessage %>
            </div>
        <% } %>

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
                <a href="#" class="forgot-link">Forgot password?</a>
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
</body>
</html>
