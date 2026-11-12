<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 - Server Error | PaperWise</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/tabler-icons/css/tabler-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/paperwise.css">
    <script>(function(){var t=localStorage.getItem('pw-theme')||'light';document.documentElement.setAttribute('data-theme',t);})();</script>
    <style>
        body { min-height: 100vh; display: flex; align-items: center; justify-content: center;
               background: var(--bg-page); font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
        .error-wrap { text-align: center; padding: 40px 20px; }
        .error-code { font-size: 96px; font-weight: 800; color: var(--red); line-height: 1; margin-bottom: 8px; }
        .error-title { font-size: 24px; font-weight: 700; color: var(--text-primary); margin-bottom: 10px; }
        .error-msg { font-size: 15px; color: var(--text-secondary); margin-bottom: 32px; }
        .btn-home { display: inline-flex; align-items: center; gap: 8px; background: var(--accent);
                    color: #fff; padding: 12px 24px; border-radius: 10px; text-decoration: none;
                    font-weight: 600; font-size: 14px; transition: background 0.2s; }
        .btn-home:hover { background: var(--accent-hover); }
    </style>
</head>
<body>
    <div class="error-wrap">
        <div class="error-code">500</div>
        <h1 class="error-title">Internal Server Error</h1>
        <p class="error-msg">Something went wrong on our end. Please try again or contact support.</p>
        <a href="${pageContext.request.contextPath}/login.jsp" class="btn-home">
            <i class="fa-solid fa-house"></i> Back to Home
        </a>
    </div>
</body>
</html>
