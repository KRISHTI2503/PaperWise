package com.paperwise.dao;

import java.sql.*;
import java.time.LocalDateTime;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class PasswordResetDAO {

    private Connection getConnection() throws Exception {
        InitialContext ctx = new InitialContext();
        DataSource ds = (DataSource) ctx.lookup(
                "java:comp/env/jdbc/paperwise");
        return ds.getConnection();
    }

    public boolean saveToken(
            String username, String email, String token) {
        String sql =
                "INSERT INTO password_reset_tokens " +
                "(username, email, token, expires_at) " +
                "VALUES (?, ?, ?, ?)";
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, token);
            ps.setTimestamp(4, Timestamp.valueOf(
                    LocalDateTime.now().plusMinutes(10)));
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            return false;
        }
    }

    public boolean verifyToken(String username, String token) {
        String sql =
                "SELECT id FROM password_reset_tokens " +
                "WHERE username = ? AND token = ? " +
                "AND used = FALSE " +
                "AND expires_at > NOW()";
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, token);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            return false;
        }
    }

    public boolean markTokenUsed(
            String username, String token) {
        String sql =
                "UPDATE password_reset_tokens SET used = TRUE " +
                "WHERE username = ? AND token = ?";
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, token);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            return false;
        }
    }

    public void deleteExpiredTokens() {
        String sql =
                "DELETE FROM password_reset_tokens " +
                "WHERE expires_at < NOW() OR used = TRUE";
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (Exception e) {
        }
    }

    public String getEmailByUsername(String username) {
        String sql =
                "SELECT email FROM users WHERE username = ?";
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("email");
            }
        } catch (Exception e) {
        }
        return null;
    }

    public boolean updatePassword(
            String username, String newHashedPassword) {
        String sql =
                "UPDATE users SET password = ? WHERE username = ?";
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, newHashedPassword);
            ps.setString(2, username);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            return false;
        }
    }
}
