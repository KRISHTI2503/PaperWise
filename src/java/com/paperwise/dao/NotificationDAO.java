package com.paperwise.dao;

import com.paperwise.model.Notification;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class NotificationDAO {

    private static final Logger LOGGER = Logger.getLogger(NotificationDAO.class.getName());
    private static final String JNDI_DATASOURCE = "java:comp/env/jdbc/paperwise";

    private static final String SQL_INSERT =
            "INSERT INTO notifications (user_id, message, link) VALUES (?, ?, ?)";

    private static final String SQL_SELECT_FOR_USER =
            "SELECT id, user_id, message, link, is_read, created_at " +
            "FROM notifications " +
            "WHERE user_id = ? " +
            "ORDER BY created_at DESC " +
            "LIMIT 10";

    private static final String SQL_UNREAD_COUNT =
            "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = FALSE";

    private static final String SQL_MARK_ALL_READ =
            "UPDATE notifications SET is_read = TRUE WHERE user_id = ? AND is_read = FALSE";

    private static final String SQL_MARK_ONE_READ =
            "UPDATE notifications SET is_read = TRUE WHERE id = ?";

    private static final String SQL_GET_ALL_STUDENT_IDS =
            "SELECT user_id FROM users WHERE role = 'student'";

    private static final String SQL_GET_ALL_ADMIN_IDS =
            "SELECT user_id FROM users WHERE role = 'admin'";

    private DataSource dataSource;

    private DataSource getDataSource() {
        if (dataSource == null) {
            try {
                Context initContext = new InitialContext();
                dataSource = (DataSource) initContext.lookup(JNDI_DATASOURCE);
            } catch (NamingException e) {
                LOGGER.log(Level.SEVERE, "JNDI lookup failed for resource: {0}", JNDI_DATASOURCE);
                throw new DAOException(
                        "Unable to locate DataSource via JNDI. " +
                        "Verify that '" + JNDI_DATASOURCE + "' is declared in context.xml.", e);
            }
        }
        return dataSource;
    }

    /**
     * Create a single notification for a specific user.
     *
     * @param userId  the recipient's user_id (integer PK from users table)
     * @param message notification text (max 255 chars)
     * @param link    optional relative URL to navigate to when clicked (may be null)
     */
    public boolean createNotification(int userId, String message, String link) {
        if (message == null || message.trim().isEmpty()) {
            throw new IllegalArgumentException("Notification message must not be empty.");
        }
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT)) {

            ps.setInt(1, userId);
            ps.setString(2, message.trim());
            if (link != null && !link.trim().isEmpty()) {
                ps.setString(3, link.trim());
            } else {
                ps.setNull(3, Types.VARCHAR);
            }
            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating notification for userId={0}", userId);
            throw new DAOException("Failed to create notification.", e);
        }
    }

    /**
     * Notify all students in bulk — used when a paper is uploaded or an announcement is posted.
     * Fetches all user_ids WHERE role = 'student' and inserts one notification per student.
     */
    public void notifyAllStudents(String message, String link) {
        if (message == null || message.trim().isEmpty()) return;

        List<Integer> studentIds = new ArrayList<>();
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_GET_ALL_STUDENT_IDS);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                studentIds.add(rs.getInt("user_id"));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching student IDs for bulk notification.", e);
            throw new DAOException("Failed to fetch student IDs.", e);
        }

        if (studentIds.isEmpty()) return;

        // Batch insert for efficiency
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT)) {

            String trimmedMsg  = message.trim();
            String trimmedLink = (link != null && !link.trim().isEmpty()) ? link.trim() : null;

            for (int uid : studentIds) {
                ps.setInt(1, uid);
                ps.setString(2, trimmedMsg);
                if (trimmedLink != null) {
                    ps.setString(3, trimmedLink);
                } else {
                    ps.setNull(3, Types.VARCHAR);
                }
                ps.addBatch();
            }
            ps.executeBatch();
            LOGGER.log(Level.INFO, "Notified {0} students: {1}", new Object[]{studentIds.size(), message});

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error sending bulk notifications.", e);
            throw new DAOException("Failed to send bulk notifications.", e);
        }
    }

    /**
     * Notify all admins in bulk — used when a student submits a paper request.
     * Fetches all user_ids WHERE role = 'admin' and inserts one notification per admin.
     * Excludes a specific user_id if provided (to prevent self-notification).
     *
     * @param message      notification text
     * @param link         relative URL to navigate to
     * @param excludeUserId optional user_id to exclude (pass null or 0 to notify all admins)
     */
    public void notifyAllAdmins(String message, String link, Integer excludeUserId) {
        if (message == null || message.trim().isEmpty()) return;

        List<Integer> adminIds = new ArrayList<>();
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_GET_ALL_ADMIN_IDS);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int adminId = rs.getInt("user_id");
                // Exclude the specified user if provided (prevent self-notification)
                if (excludeUserId == null || excludeUserId == 0 || adminId != excludeUserId) {
                    adminIds.add(adminId);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching admin IDs for bulk notification.", e);
            throw new DAOException("Failed to fetch admin IDs.", e);
        }

        if (adminIds.isEmpty()) return;

        // Batch insert for efficiency
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT)) {

            String trimmedMsg  = message.trim();
            String trimmedLink = (link != null && !link.trim().isEmpty()) ? link.trim() : null;

            for (int uid : adminIds) {
                ps.setInt(1, uid);
                ps.setString(2, trimmedMsg);
                if (trimmedLink != null) {
                    ps.setString(3, trimmedLink);
                } else {
                    ps.setNull(3, Types.VARCHAR);
                }
                ps.addBatch();
            }
            ps.executeBatch();
            LOGGER.log(Level.INFO, "Notified {0} admins: {1}", new Object[]{adminIds.size(), message});

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error sending bulk admin notifications.", e);
            throw new DAOException("Failed to send bulk admin notifications.", e);
        }
    }

    /**
     * Returns last 10 notifications for a user, newest first.
     */
    public List<Notification> getNotificationsForUser(int userId) {
        List<Notification> list = new ArrayList<>();
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_FOR_USER)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching notifications for userId={0}", userId);
            throw new DAOException("Failed to fetch notifications.", e);
        }
        return list;
    }

    /**
     * Returns count of unread notifications for a user.
     */
    public int getUnreadCount(int userId) {
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_UNREAD_COUNT)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting unread notifications for userId={0}", userId);
            throw new DAOException("Failed to count unread notifications.", e);
        }
        return 0;
    }

    /**
     * Marks all unread notifications as read for a user.
     */
    public void markAllAsRead(int userId) {
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_MARK_ALL_READ)) {

            ps.setInt(1, userId);
            ps.executeUpdate();
            LOGGER.log(Level.INFO, "Marked all notifications read for userId={0}", userId);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error marking all notifications read for userId={0}", userId);
            throw new DAOException("Failed to mark notifications as read.", e);
        }
    }

    /**
     * Marks a single notification as read.
     */
    public void markOneAsRead(int notificationId) {
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_MARK_ONE_READ)) {

            ps.setInt(1, notificationId);
            ps.executeUpdate();

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error marking notification id={0} as read", notificationId);
            throw new DAOException("Failed to mark notification as read.", e);
        }
    }

    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getInt("id"));
        n.setUserId(rs.getInt("user_id"));
        n.setMessage(rs.getString("message"));
        n.setLink(rs.getString("link"));
        n.setRead(rs.getBoolean("is_read"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            n.setCreatedAt(ts.toLocalDateTime());
        }
        return n;
    }

    public static class DAOException extends RuntimeException {
        public DAOException(String message) { super(message); }
        public DAOException(String message, Throwable cause) { super(message, cause); }
    }
}
