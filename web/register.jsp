<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: #0d1b2a;
            min-height: 100vh;
            display: flex;
            align-items: flex-start;
            justify-content: center;
            padding: 28px 20px;
            position: relative;
            overflow-x: hidden;
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
        .brand-name  { font-size: 24px; font-weight: 700; color: #0d1b2a; letter-spacing: -0.3px; }
        .card-subtitle { font-size: 13px; color: #6b7280; }

        /* ── Alerts ── */
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
            background: #f0fff4;
            border: 1px solid #9ae6b4;
            color: #276749;
            border-radius: 8px;
            padding: 10px 14px;
            margin-bottom: 16px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .alert-success i { color: #276749; font-size: 13px; margin: 0; flex-shrink: 0; }

        /* ── Form ── */
        .form-group { margin-bottom: 16px; }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: #374151;
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
            color: #9ca3af;
            padding: 4px;
            line-height: 1;
            transition: color 0.2s;
        }
        .pwd-toggle:hover  { color: #4f7396; }
        .pwd-toggle:focus  { outline: none; }
        .pwd-toggle i      { font-size: 13px; margin: 0; }

        .helper-text {
            font-size: 11px;
            color: #9ca3af;
            margin-top: 5px;
            line-height: 1.5;
        }

        /* ── Create Account button ── */
        .btn-create {
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
            margin-top: 20px;
        }
        .btn-create i      { font-size: 14px; margin: 0; }
        .btn-create:hover  { background: #0d2a45; }
        .btn-create:active { transform: scale(0.98); }
        .btn-create:focus  { outline: none; box-shadow: 0 0 0 3px rgba(26,58,92,0.25); }

        /* ── Sign-in link ── */
        .signin-link {
            text-align: center;
            font-size: 13px;
            color: #6b7280;
            margin-top: 16px;
        }
        .signin-link a {
            color: #4f7396;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.2s;
        }
        .signin-link a:hover { color: #1a3a5c; text-decoration: underline; }

        /* ── Footer ── */
        .card-footer {
            text-align: center;
            font-size: 12px;
            color: #9ca3af;
            margin-top: 16px;
        }

        /* ── Responsive ── */
        @media (max-width: 375px) {
            .register-card { padding: 32px 18px 28px; }
            .brand-name    { font-size: 21px; }
        }
    </style>
</head>
<body>

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

        <%-- Error message from RegisterServlet --%>
        <%
            String errorMessage = (String) request.getAttribute("errorMessage");
            if (errorMessage != null) {
        %>
            <div class="alert-error" role="alert">
                <i class="fa-solid fa-circle-exclamation"></i>
                <%= errorMessage %>
            </div>
        <% } %>

        <%-- Success message (if any) --%>
        <%
            String successMessage = (String) request.getAttribute("successMessage");
            if (successMessage != null) {
        %>
            <div class="alert-success" role="alert">
                <i class="fa-solid fa-circle-check"></i>
                <%= successMessage %>
            </div>
        <% } %>

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

        // Client-side password match validation
        function validateForm() {
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
</body>
</html>
