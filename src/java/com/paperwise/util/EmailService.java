package com.paperwise.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EmailService {

    private static final Logger LOGGER = Logger.getLogger(EmailService.class.getName());

    // CONFIGURE THESE WITH YOUR GMAIL CREDENTIALS
    private static final String FROM_EMAIL =
            "your.gmail@gmail.com";
    private static final String APP_PASSWORD =
            "your-16-char-app-password";
    private static final String FROM_NAME = "PaperWise";

    public static boolean sendOtpEmail(
            String toEmail, String username, String otp) {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.ssl.trust", "smtp.gmail.com");

            Session session = Session.getInstance(props,
                    new Authenticator() {
                        @Override
                        protected PasswordAuthentication getPasswordAuthentication() {
                            return new PasswordAuthentication(
                                    FROM_EMAIL, APP_PASSWORD);
                        }
                    });

            Message message = new MimeMessage(session);
            message.setFrom(
                    new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(
                    Message.RecipientType.TO,
                    InternetAddress.parse(toEmail));
            message.setSubject("PaperWise — Password Reset OTP");

            String emailBody =
                    "<div style='font-family:Segoe UI,sans-serif;" +
                    "max-width:480px;margin:0 auto'>" +
                    "<div style='background:#0f2744;padding:24px;" +
                    "border-radius:12px 12px 0 0;text-align:center'>" +
                    "<h2 style='color:#fff;margin:0;font-size:22px'>" +
                    "PaperWise</h2>" +
                    "<p style='color:rgba(255,255,255,0.7);margin:4px 0 0'>" +
                    "Academic Paper Management</p></div>" +
                    "<div style='background:#fff;padding:32px;" +
                    "border:1px solid #e5e7eb;" +
                    "border-radius:0 0 12px 12px'>" +
                    "<h3 style='color:#0f2744;margin:0 0 8px'>" +
                    "Password Reset Request</h3>" +
                    "<p style='color:#6b7280;font-size:14px;margin:0 0 24px'>" +
                    "Hi <strong>" + username + "</strong>, use this OTP " +
                    "to reset your password. It expires in 10 minutes.</p>" +
                    "<div style='background:#f1f5f9;border-radius:12px;" +
                    "padding:20px;text-align:center;margin:0 0 24px'>" +
                    "<div style='font-size:36px;font-weight:800;" +
                    "letter-spacing:12px;color:#0f2744'>" + otp + "</div>" +
                    "<p style='color:#9ca3af;font-size:12px;margin:8px 0 0'>" +
                    "Valid for 10 minutes only</p></div>" +
                    "<p style='color:#9ca3af;font-size:12px;margin:0'>" +
                    "If you did not request this, ignore this email. " +
                    "Your password will not change.</p></div></div>";

            message.setContent(emailBody, "text/html; charset=utf-8");
            Transport.send(message);
            return true;

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Email send error: {0}", e.getMessage());
            return false;
        }
    }
}
