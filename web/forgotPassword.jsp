<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Forgot Password - PaperWise</title>
      <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/tabler-icons/css/tabler-icons.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/fontawesome/css/all.min.css">
  <script>
    (function(){var t=localStorage.getItem('pw-theme')||'light';document.documentElement.setAttribute('data-theme',t);})();
  </script>
  <script src="${pageContext.request.contextPath}/js/paperwise.js" defer></script>
  <style>
    *{box-sizing:border-box;margin:0;padding:0}

    :root {
      --fp-bg: #0d1b2a;
      --fp-card-bg: #ffffff;
      --fp-text: #0f2744;
      --fp-sub: #8a97a8;
      --fp-label: #374151;
      --fp-input-bg: #f9fafb;
      --fp-input-border: #e5e7eb;
      --fp-input-text: #111827;
      --fp-input-focus: #3b82f6;
      --fp-otp-text: #0f2744;
      --fp-timer-accent: #0f2744;
      --fp-err-bg: #fef2f2;
      --fp-err-border: #fecaca;
      --fp-err-text: #991b1b;
      --fp-suc-bg: #f0fdf4;
      --fp-suc-border: #bbf7d0;
      --fp-suc-text: #15803d;
    }
    [data-theme="dark"] {
      --fp-bg: #070e17;
      --fp-card-bg: #131b2e;
      --fp-text: #f8fafc;
      --fp-sub: #64748b;
      --fp-label: #cbd5e1;
      --fp-input-bg: #1e293b;
      --fp-input-border: #334155;
      --fp-input-text: #f8fafc;
      --fp-input-focus: #3b82f6;
      --fp-otp-text: #f8fafc;
      --fp-timer-accent: #93c5fd;
      --fp-err-bg: rgba(239,68,68,0.1);
      --fp-err-border: rgba(239,68,68,0.2);
      --fp-err-text: #f87171;
      --fp-suc-bg: rgba(34,197,94,0.1);
      --fp-suc-border: rgba(34,197,94,0.2);
      --fp-suc-text: #4ade80;
    }

    body{
      min-height:100vh;background:var(--fp-bg);
      display:flex;align-items:center;
      justify-content:center;padding:2rem;
      font-family:'Segoe UI',system-ui,sans-serif;
      position:relative;overflow:hidden;
      transition:background 0.3s;
    }

    /* Theme toggle button — fixed top-right */
    #pwDarkToggle {
      position: fixed;
      top: 16px;
      right: 20px;
      z-index: 9999;
      width: 36px;
      height: 36px;
      border-radius: 50%;
      background: rgba(255,255,255,0.08);
      border: 1px solid rgba(255,255,255,0.18);
      color: #ffffff;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: background 0.2s, transform 0.15s;
    }
    #pwDarkToggle:hover { background: rgba(255,255,255,0.15); transform: scale(1.05); }
    #pwDarkToggle:active { transform: scale(0.95); }
    [data-theme="dark"] #pwDarkToggle { background: rgba(255,255,255,0.07); border-color: rgba(255,255,255,0.10); }

    .fp{position:absolute;opacity:0.05;pointer-events:none}
    .card{
      background:var(--fp-card-bg);border-radius:20px;
      width:100%;max-width:460px;
      padding:2.5rem 2.5rem;position:relative;
      animation:slideUp .4s cubic-bezier(.16,1,.3,1) both;
      transition:background 0.3s;
    }
    @keyframes slideUp{
      from{opacity:0;transform:translateY(20px)}
      to{opacity:1;transform:translateY(0)}
    }
    .logo{display:flex;align-items:center;
      justify-content:center;gap:10px;margin-bottom:8px}
    .logo-box{
      width:44px;height:44px;background:#0f2744;
      border-radius:12px;display:flex;
      align-items:center;justify-content:center;
    }
    .logo-name{font-size:22px;font-weight:700;color:var(--fp-text)}
    .card-sub{text-align:center;font-size:13px;
      color:var(--fp-sub);margin-bottom:1.8rem}
    .step-title{font-size:16px;font-weight:700;
      color:var(--fp-text);margin-bottom:4px;text-align:center}
    .step-desc{font-size:12.5px;color:var(--fp-sub);
      text-align:center;margin-bottom:1.5rem}
    .fg{display:flex;flex-direction:column;gap:5px;margin-bottom:1rem}
    label{font-size:12.5px;font-weight:600;color:var(--fp-label);
      display:flex;align-items:center;gap:5px}
    .iw{position:relative;display:flex;align-items:center}
    .iw i.fi{position:absolute;left:11px;font-size:16px;
      color:#9ca3af;pointer-events:none;z-index:1}
    .iw input{padding-left:36px}
    input{
      width:100%;border:1.5px solid var(--fp-input-border);border-radius:10px;
      padding:10px 11px;font-size:13.5px;color:var(--fp-input-text);
      background:var(--fp-input-bg);font-family:inherit;outline:none;
      transition:border .18s,box-shadow .18s,background .18s;
    }
    input:focus{border-color:var(--fp-input-focus);background:var(--fp-card-bg);
      box-shadow:0 0 0 3px rgba(59,130,246,.12)}
    .hint{font-size:11px;color:var(--fp-sub);margin-top:3px}
    .btn-primary{
      width:100%;background:#0f2744;color:#fff;border:none;
      border-radius:10px;padding:12px;font-size:14px;
      font-weight:600;font-family:inherit;cursor:pointer;
      display:flex;align-items:center;justify-content:center;
      gap:8px;transition:background .18s;margin-bottom:.8rem;
    }
    .btn-primary:hover{background:#1a3a5c}
    .btn-primary i{font-size:17px}
    .btn-primary:disabled{background:#9ca3af;cursor:not-allowed}
    .back-link{
      display:flex;align-items:center;justify-content:center;
      gap:5px;font-size:13px;color:#3b82f6;
      text-decoration:none;margin-top:.5rem;
    }
    .back-link:hover{text-decoration:underline}
    .back-link i{font-size:15px}
    .error-msg{
      background:var(--fp-err-bg);border:1px solid var(--fp-err-border);
      border-radius:8px;padding:10px 14px;
      font-size:13px;color:var(--fp-err-text);
      display:flex;align-items:center;gap:7px;
      margin-bottom:1rem;
    }
    .error-msg i{font-size:16px;flex-shrink:0}
    .success-msg{
      background:var(--fp-suc-bg);border:1px solid var(--fp-suc-border);
      border-radius:8px;padding:10px 14px;
      font-size:13px;color:var(--fp-suc-text);
      display:flex;align-items:center;gap:7px;
      margin-bottom:1rem;
    }
    .success-msg i{font-size:16px;flex-shrink:0}
    .otp-inputs{
      display:flex;gap:10px;justify-content:center;
      margin-bottom:1rem;
    }
    .otp-input{
      width:52px;height:56px;text-align:center;
      font-size:22px;font-weight:700;color:var(--fp-otp-text);
      border:1.5px solid var(--fp-input-border);border-radius:10px;
      background:var(--fp-input-bg);outline:none;padding:0;
      transition:border .18s,box-shadow .18s;
    }
    .otp-input:focus{border-color:var(--fp-input-focus);background:var(--fp-card-bg);
      box-shadow:0 0 0 3px rgba(59,130,246,.12)}
    .timer{text-align:center;font-size:12.5px;
      color:var(--fp-sub);margin-bottom:1rem}
    .timer span{color:var(--fp-timer-accent);font-weight:600}
    .resend-btn{
      background:none;border:none;color:#3b82f6;
      font-size:12.5px;font-weight:600;cursor:pointer;
      font-family:inherit;
    }
    .resend-btn:disabled{color:#9ca3af;cursor:not-allowed}
    .pw-strength{margin-top:6px}
    .pw-bar{height:4px;border-radius:20px;
      background:#f0f0f0;overflow:hidden;margin-bottom:4px}
    .pw-fill{height:100%;border-radius:20px;
      transition:width .3s,background .3s}
    .pw-text{font-size:11px;color:#9ca3af}
    .copyright{text-align:center;font-size:12px;
      color:var(--fp-sub);margin-top:1.2rem}
  </style>
</head>
<body>

<!-- Theme Toggle — fixed top-right corner -->
<button id="pwDarkToggle" title="Toggle dark mode" aria-label="Toggle dark/light mode">
  <i class="fa-solid fa-moon" style="font-size:14px"></i>
</button>

<svg class="fp" style="top:20px;left:30px;width:70px;height:80px;transform:rotate(-15deg)" viewBox="0 0 70 80" fill="none">
  <rect x="5" y="5" width="55" height="70" rx="4" stroke="white" stroke-width="2"/>
  <line x1="15" y1="22" x2="50" y2="22" stroke="white" stroke-width="2"/>
  <line x1="15" y1="32" x2="50" y2="32" stroke="white" stroke-width="2"/>
  <line x1="15" y1="42" x2="38" y2="42" stroke="white" stroke-width="2"/>
</svg>
<svg class="fp" style="top:30px;right:50px;width:70px;height:80px;transform:rotate(12deg)" viewBox="0 0 70 80" fill="none">
  <rect x="5" y="5" width="55" height="70" rx="4" stroke="white" stroke-width="2"/>
  <line x1="15" y1="22" x2="50" y2="22" stroke="white" stroke-width="2"/>
  <line x1="15" y1="32" x2="50" y2="32" stroke="white" stroke-width="2"/>
  <line x1="15" y1="42" x2="38" y2="42" stroke="white" stroke-width="2"/>
</svg>
<svg class="fp" style="bottom:40px;left:60px;width:70px;height:80px;transform:rotate(8deg)" viewBox="0 0 70 80" fill="none">
  <rect x="5" y="5" width="55" height="70" rx="4" stroke="white" stroke-width="2"/>
  <line x1="15" y1="22" x2="50" y2="22" stroke="white" stroke-width="2"/>
  <line x1="15" y1="32" x2="50" y2="32" stroke="white" stroke-width="2"/>
  <line x1="15" y1="42" x2="38" y2="42" stroke="white" stroke-width="2"/>
</svg>
<svg class="fp" style="bottom:40px;right:40px;width:70px;height:80px;transform:rotate(-10deg)" viewBox="0 0 70 80" fill="none">
  <rect x="5" y="5" width="55" height="70" rx="4" stroke="white" stroke-width="2"/>
  <line x1="15" y1="22" x2="50" y2="22" stroke="white" stroke-width="2"/>
  <line x1="15" y1="32" x2="50" y2="32" stroke="white" stroke-width="2"/>
  <line x1="15" y1="42" x2="38" y2="42" stroke="white" stroke-width="2"/>
</svg>

<div class="card">

  <div class="logo">
    <div class="logo-box">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
        stroke="white" stroke-width="2" stroke-linecap="round"
        stroke-linejoin="round">
        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
        <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
      </svg>
    </div>
    <span class="logo-name">PaperWise</span>
  </div>
  <div class="card-sub">Reset your account password</div>

  <% if (request.getAttribute("error") != null) { %>
    <div class="error-msg">
      <i class="fa-solid fa-circle-exclamation"></i>
      <%= request.getAttribute("error") %>
    </div>
  <% } %>
  <% if (request.getAttribute("success") != null) { %>
    <div class="success-msg">
      <i class="fa-solid fa-circle-check"></i>
      <%= request.getAttribute("success") %>
    </div>
  <% } %>

  <% if (request.getAttribute("step") == null ||
         request.getAttribute("step").equals("1")) { %>
    <div class="step-title">Forgot your password?</div>
    <div class="step-desc">
      Enter your username and we'll send an OTP to your email.
    </div>
    <form method="post"
      action="${pageContext.request.contextPath}/forgotPassword">
      <input type="hidden" name="step" value="1">
      <div class="fg">
        <label>Username</label>
        <div class="iw">
          <i class="fa-solid fa-user fi"></i>
          <input type="text" name="username"
            placeholder="Enter your username" required
            autofocus>
        </div>
      </div>
      <button type="submit" class="btn-primary">
        <i class="fa-solid fa-paper-plane"></i>
        Send OTP to Email
      </button>
    </form>
  <% } %>

  <% if ("2".equals(request.getAttribute("step"))) { %>
    <div class="step-title">Check your email</div>
    <div class="step-desc">
      We sent a 6-digit OTP to your email.<br>
      Enter it below. Expires in 10 minutes.
    </div>
    <form method="post"
      action="${pageContext.request.contextPath}/forgotPassword"
      id="otpForm">
      <input type="hidden" name="step" value="2">
      <input type="hidden" name="username"
        value="<%= request.getAttribute("username") %>">
      <div class="otp-inputs">
        <input type="text" class="otp-input" maxlength="1"
          id="o1" name="d1" inputmode="numeric">
        <input type="text" class="otp-input" maxlength="1"
          id="o2" name="d2" inputmode="numeric">
        <input type="text" class="otp-input" maxlength="1"
          id="o3" name="d3" inputmode="numeric">
        <input type="text" class="otp-input" maxlength="1"
          id="o4" name="d4" inputmode="numeric">
        <input type="text" class="otp-input" maxlength="1"
          id="o5" name="d5" inputmode="numeric">
        <input type="text" class="otp-input" maxlength="1"
          id="o6" name="d6" inputmode="numeric">
      </div>
      <input type="hidden" name="otp" id="otpHidden">
      <div class="timer">
        Code expires in <span id="timerDisplay">10:00</span>
      </div>
      <button type="submit" class="btn-primary"
        id="verifyBtn">
        <i class="fa-solid fa-shield-halved"></i>
        Verify OTP
      </button>
    </form>
    <div style="text-align:center;margin-top:.5rem">
      <button class="resend-btn" id="resendBtn" disabled>
        Resend OTP
      </button>
    </div>
  <% } %>

  <% if ("3".equals(request.getAttribute("step"))) { %>
    <div class="step-title">Set new password</div>
    <div class="step-desc">
      Choose a strong new password for your account.
    </div>
    <form method="post"
      action="${pageContext.request.contextPath}/forgotPassword">
      <input type="hidden" name="step" value="3">
      <input type="hidden" name="username"
        value="<%= request.getAttribute("username") %>">
      <input type="hidden" name="token"
        value="<%= request.getAttribute("token") %>">
      <div class="fg">
        <label>New Password</label>
        <div class="iw">
          <i class="fa-solid fa-lock fi"></i>
          <input type="password" name="newPassword"
            id="newPass"
            placeholder="At least 8 characters"
            required minlength="8"
            oninput="checkStrength(this.value)">
        </div>
        <div class="pw-strength">
          <div class="pw-bar">
            <div class="pw-fill" id="pwFill"
              style="width:0%"></div>
          </div>
          <div class="pw-text" id="pwText"></div>
        </div>
      </div>
      <div class="fg">
        <label>Confirm Password</label>
        <div class="iw">
          <i class="fa-solid fa-lock fi"></i>
          <input type="password" name="confirmPassword"
            id="confPass"
            placeholder="Re-enter your password"
            required>
        </div>
        <div class="hint" id="matchHint"></div>
      </div>
      <button type="submit" class="btn-primary">
        <i class="fa-solid fa-key"></i>
        Reset Password
      </button>
    </form>
  <% } %>

  <a href="${pageContext.request.contextPath}/login.jsp"
    class="back-link">
    <i class="fa-solid fa-arrow-left"></i> Back to Sign In
  </a>

  <div class="copyright">&copy; 2026 PaperWise. All rights reserved.</div>
</div>

<script>
document.querySelectorAll('.otp-input').forEach((input, idx, inputs) => {
  input.addEventListener('input', function() {
    this.value = this.value.replace(/[^0-9]/g,'');
    if (this.value && idx < inputs.length - 1) {
      inputs[idx + 1].focus();
    }
    updateOtpHidden();
  });
  input.addEventListener('keydown', function(e) {
    if (e.key === 'Backspace' && !this.value && idx > 0) {
      inputs[idx - 1].focus();
    }
  });
});

function updateOtpHidden() {
  const otp = Array.from(document.querySelectorAll('.otp-input'))
    .map(i => i.value).join('');
  const h = document.getElementById('otpHidden');
  if (h) h.value = otp;
}

let timeLeft = 600;
const timerEl = document.getElementById('timerDisplay');
const resendBtn = document.getElementById('resendBtn');

if (timerEl) {
  const interval = setInterval(() => {
    timeLeft--;
    const m = Math.floor(timeLeft / 60);
    const s = timeLeft % 60;
    timerEl.textContent =
      m + ':' + (s < 10 ? '0' : '') + s;
    if (timeLeft <= 0) {
      clearInterval(interval);
      timerEl.textContent = 'Expired';
      timerEl.style.color = '#dc2626';
      if (resendBtn) resendBtn.disabled = false;
    }
  }, 1000);
}

if (resendBtn) {
  resendBtn.addEventListener('click', function() {
    window.location.href =
      '${pageContext.request.contextPath}/forgotPassword?resend=true&username=' +
      encodeURIComponent('<%=request.getAttribute("username")%>');
  });
}

function checkStrength(pw) {
  const fill = document.getElementById('pwFill');
  const text = document.getElementById('pwText');
  if (!fill) return;
  let score = 0;
  if (pw.length >= 8) score++;
  if (/[A-Z]/.test(pw)) score++;
  if (/[0-9]/.test(pw)) score++;
  if (/[^A-Za-z0-9]/.test(pw)) score++;
  const levels = [
    {w:'25%', c:'#dc2626', t:'Weak'},
    {w:'50%', c:'#d97706', t:'Fair'},
    {w:'75%', c:'#2563eb', t:'Good'},
    {w:'100%',c:'#16a34a', t:'Strong'},
  ];
  const lv = levels[Math.max(0, score-1)];
  fill.style.width = lv.w;
  fill.style.background = lv.c;
  text.textContent = lv.t;
  text.style.color = lv.c;
}

const confPass = document.getElementById('confPass');
const newPass = document.getElementById('newPass');
const matchHint = document.getElementById('matchHint');
if (confPass && newPass) {
  confPass.addEventListener('input', function() {
    if (!matchHint) return;
    if (this.value === newPass.value) {
      matchHint.textContent = '\u2713 Passwords match';
      matchHint.style.color = '#16a34a';
    } else {
      matchHint.textContent = '\u2717 Passwords do not match';
      matchHint.style.color = '#dc2626';
    }
  });
}
</script>
</body>
</html>
