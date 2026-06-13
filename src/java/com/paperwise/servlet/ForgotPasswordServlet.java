package com.paperwise.servlet;

import com.paperwise.dao.PasswordResetDAO;
import com.paperwise.util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.security.SecureRandom;

@WebServlet("/forgotPassword")
public class ForgotPasswordServlet extends HttpServlet {

    private PasswordResetDAO resetDAO = new PasswordResetDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String resend = request.getParameter("resend");
        String username = request.getParameter("username");

        if ("true".equals(resend) && username != null) {
            sendOtp(username, request, response);
            return;
        }

        request.setAttribute("step", "1");
        request.getRequestDispatcher("/forgotPassword.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String step = request.getParameter("step");

        if ("1".equals(step)) {
            handleStep1(request, response);
        } else if ("2".equals(step)) {
            handleStep2(request, response);
        } else if ("3".equals(step)) {
            handleStep3(request, response);
        } else {
            response.sendRedirect(
                    request.getContextPath() + "/forgotPassword");
        }
    }

    private void handleStep1(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("step", "1");
            request.setAttribute("error", "Please enter your username.");
            request.getRequestDispatcher("/forgotPassword.jsp")
                    .forward(request, response);
            return;
        }
        username = username.trim().toLowerCase();
        sendOtp(username, request, response);
    }

    private void sendOtp(String username,
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String email = resetDAO.getEmailByUsername(username);
        if (email == null) {
            request.setAttribute("step", "1");
            request.setAttribute("error",
                    "No account found with that username.");
            request.getRequestDispatcher("/forgotPassword.jsp")
                    .forward(request, response);
            return;
        }

        String otp = String.format("%06d",
                new SecureRandom().nextInt(1000000));

        resetDAO.deleteExpiredTokens();

        boolean saved = resetDAO.saveToken(username, email, otp);
        if (!saved) {
            request.setAttribute("step", "1");
            request.setAttribute("error",
                    "Could not generate OTP. Try again.");
            request.getRequestDispatcher("/forgotPassword.jsp")
                    .forward(request, response);
            return;
        }

        boolean sent = EmailService.sendOtpEmail(
                email, username, otp);

        if (!sent) {
            request.setAttribute("step", "1");
            request.setAttribute("error",
                    "Could not send email. Check email configuration.");
            request.getRequestDispatcher("/forgotPassword.jsp")
                    .forward(request, response);
            return;
        }

        String maskedEmail = maskEmail(email);

        request.setAttribute("step", "2");
        request.setAttribute("username", username);
        request.setAttribute("success",
                "OTP sent to " + maskedEmail);
        request.getRequestDispatcher("/forgotPassword.jsp")
                .forward(request, response);
    }

    private void handleStep2(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String otp = request.getParameter("otp");

        if (otp == null || otp.trim().isEmpty()) {
            StringBuilder sb = new StringBuilder();
            for (int i = 1; i <= 6; i++) {
                String d = request.getParameter("d" + i);
                if (d != null) {
                    sb.append(d.trim());
                }
            }
            otp = sb.toString();
        }

        if (otp.length() != 6) {
            request.setAttribute("step", "2");
            request.setAttribute("username", username);
            request.setAttribute("error",
                    "Please enter the complete 6-digit OTP.");
            request.getRequestDispatcher("/forgotPassword.jsp")
                    .forward(request, response);
            return;
        }

        boolean valid = resetDAO.verifyToken(username, otp);
        if (!valid) {
            request.setAttribute("step", "2");
            request.setAttribute("username", username);
            request.setAttribute("error",
                    "Invalid or expired OTP. Please try again.");
            request.getRequestDispatcher("/forgotPassword.jsp")
                    .forward(request, response);
            return;
        }

        request.setAttribute("step", "3");
        request.setAttribute("username", username);
        request.setAttribute("token", otp);
        request.getRequestDispatcher("/forgotPassword.jsp")
                .forward(request, response);
    }

    private void handleStep3(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (newPassword == null || newPassword.length() < 8) {
            request.setAttribute("step", "3");
            request.setAttribute("username", username);
            request.setAttribute("token", token);
            request.setAttribute("error",
                    "Password must be at least 8 characters.");
            request.getRequestDispatcher("/forgotPassword.jsp")
                    .forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("step", "3");
            request.setAttribute("username", username);
            request.setAttribute("token", token);
            request.setAttribute("error",
                    "Passwords do not match.");
            request.getRequestDispatcher("/forgotPassword.jsp")
                    .forward(request, response);
            return;
        }

        boolean valid = resetDAO.verifyToken(username, token);
        if (!valid) {
            request.setAttribute("step", "1");
            request.setAttribute("error",
                    "Session expired. Please start again.");
            request.getRequestDispatcher("/forgotPassword.jsp")
                    .forward(request, response);
            return;
        }

        String hashedPassword = hashPassword(newPassword);

        boolean updated = resetDAO.updatePassword(
                username, hashedPassword);

        if (!updated) {
            request.setAttribute("step", "3");
            request.setAttribute("username", username);
            request.setAttribute("token", token);
            request.setAttribute("error",
                    "Could not update password. Try again.");
            request.getRequestDispatcher("/forgotPassword.jsp")
                    .forward(request, response);
            return;
        }

        resetDAO.markTokenUsed(username, token);

        response.sendRedirect(
                request.getContextPath() +
                        "/login.jsp?password_reset=true");
    }

    /**
     * Matches RegisterServlet — passwords are stored as plain text in users.password.
     */
    private String hashPassword(String password) {
        return password;
    }

    private String maskEmail(String email) {
        try {
            String[] parts = email.split("@");
            String local = parts[0];
            String domain = parts[1];
            String maskedLocal = local.charAt(0) +
                    "***" + local.charAt(local.length() - 1);
            String[] domParts = domain.split("\\.");
            String maskedDomain = domParts[0].charAt(0) +
                    "***." + domParts[domParts.length - 1];
            return maskedLocal + "@" + maskedDomain;
        } catch (Exception e) {
            return "your email";
        }
    }
}
