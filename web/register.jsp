<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - PaperWise</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .register-container {
            background: white;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            width: 100%;
            max-width: 480px;
            padding: 48px 40px;
            animation: slideUp 0.5s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .logo-section {
            text-align: center;
            margin-bottom: 32px;
        }

        .logo-icon {
            width: 64px;
            height: 64px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 16px;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }

        .logo-section h1 {
            font-size: 28px;
            color: #1a202c;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .logo-section p {
            color: #718096;
            font-size: 14px;
        }

        .error-message {
            background: #fee;
            border-left: 4px solid #e53e3e;
            color: #c53030;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 14px;
            display: flex;
            align-items: center;
            animation: shake 0.4s ease-in-out;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-8px); }
            75% { transform: translateX(8px); }
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            color: #2d3748;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .form-group label .required {
            color: #e53e3e;
            margin-left: 2px;
        }

        .input-wrapper {
            position: relative;
        }

        .form-group input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 15px;
            color: #2d3748;
            transition: all 0.3s ease;
            background: #f7fafc;
        }

        .form-group input:focus {
            outline: none;
            border-color: #667eea;
            background: white;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .form-group input::placeholder {
            color: #a0aec0;
        }

        .password-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #718096;
            cursor: pointer;
            padding: 4px 8px;
            font-size: 20px;
            transition: color 0.2s ease;
            user-select: none;
        }

        .password-toggle:hover {
            color: #667eea;
        }

        .password-toggle:focus {
            outline: none;
        }

        .password-requirements {
            font-size: 12px;
            color: #718096;
            margin-top: 6px;
            line-height: 1.5;
        }

        .register-button {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
            margin-top: 8px;
        }

        .register-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
        }

        .register-button:active {
            transform: translateY(0);
        }

        .register-button:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.3);
        }

        .login-link {
            text-align: center;
            margin-top: 24px;
            color: #718096;
            font-size: 14px;
        }

        .login-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            transition: color 0.2s ease;
        }

        .login-link a:hover {
            color: #764ba2;
            text-decoration: underline;
        }

        .footer-text {
            text-align: center;
            margin-top: 24px;
            color: #718096;
            font-size: 13px;
        }

        @media (max-width: 480px) {
            .register-container {
                padding: 32px 24px;
            }

            .logo-section h1 {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="logo-section">
            <div class="logo-icon"></div>
            <h1>Create Account</h1>
            <p>Join PaperWise today</p>
        </div>

        <% 
            String errorMessage = (String) request.getAttribute("errorMessage");
            if (errorMessage != null) {
        %>
            <div class="error-message">
                <%= errorMessage %>
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/register" method="post" onsubmit="return validateForm()">
            <div class="form-group">
                <label for="username">
                    Username<span class="required">*</span>
                </label>
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
                />
                <div class="password-requirements">
                    At least 3 characters, letters, numbers, and underscores only
                </div>
            </div>

            <div class="form-group">
                <label for="email">
                    Email<span class="required">*</span>
                </label>
                <input 
                    type="email" 
                    id="email" 
                    name="email" 
                    placeholder="your.email@example.com"
                    value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>"
                    required 
                />
            </div>

            <div class="form-group">
                <label for="password">
                    Password<span class="required">*</span>
                </label>
                <div class="input-wrapper">
                    <input 
                        type="password" 
                        id="password" 
                        name="password" 
                        placeholder="Create a strong password"
                        required 
                        minlength="8"
                        pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$"
                        title="Password must be at least 8 characters and contain: uppercase, lowercase, digit, and special character (!@#$%^&*)"
                    />
                    <button 
                        type="button" 
                        class="password-toggle" 
                        onclick="togglePassword('password', 'toggleIcon1')"
                        aria-label="Toggle password visibility"
                    >
                        <span id="toggleIcon1">&#128065;</span>
                    </button>
                </div>
                <div class="password-requirements">
                    At least 8 characters with uppercase, lowercase, digit, and special character (!@#$%^&*)
                </div>
            </div>

            <div class="form-group">
                <label for="confirmPassword">
                    Confirm Password<span class="required">*</span>
                </label>
                <div class="input-wrapper">
                    <input 
                        type="password" 
                        id="confirmPassword" 
                        name="confirmPassword" 
                        placeholder="Re-enter your password"
                        required 
                        minlength="8"
                    />
                    <button 
                        type="button" 
                        class="password-toggle" 
                        onclick="togglePassword('confirmPassword', 'toggleIcon2')"
                        aria-label="Toggle password visibility"
                    >
                        <span id="toggleIcon2">&#128065;</span>
                    </button>
                </div>
            </div>

            <button type="submit" class="register-button">
                Create Account
            </button>
        </form>

        <div class="login-link">
            Already have an account? <a href="${pageContext.request.contextPath}/login.jsp">Sign in</a>
        </div>

        <div class="footer-text">
            &copy; 2026 PaperWise. All rights reserved.
        </div>
    </div>

    <script>
        function togglePassword(inputId, iconId) {
            const passwordInput = document.getElementById(inputId);
            const toggleIcon = document.getElementById(iconId);
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                toggleIcon.innerHTML = '&#128584;';
            } else {
                passwordInput.type = 'password';
                toggleIcon.innerHTML = '&#128065;';
            }
        }

        function validateForm() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password !== confirmPassword) {
                alert('Passwords do not match!');
                return false;
            }
            
            return true;
        }

        if (window.history.replaceState) {
            window.history.replaceState(null, null, window.location.href);
        }
    </script>
</body>
</html>