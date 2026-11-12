package com.paperwise.dao;

import com.paperwise.model.Announcement;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AnnouncementDAO {

    private static final Logger LOGGER = Logger.getLogger(AnnouncementDAO.class.getName());
    private static final String JNDI_DATASOURCE = "java:comp/env/jdbc/paperwise";

    private static final String SQL_INSERT =
            "INSERT INTO announcements (title, body, created_by, is_pinned, expires_at) " +
            "VALUES (?, ?, ?, ?, ?)";

    private static final String SQL_SELECT_ALL =
            "SELECT a.id, a.title, a.body, a.created_by::integer AS created_by, " +
            "       a.created_at, a.expires_at, a.is_pinned, " +
            "       u.username AS creator_username " +
            "FROM announcements a " +
            "LEFT JOIN users u ON a.created_by::integer = u.user_id " +
            "ORDER BY a.is_pinned DESC, a.created_at DESC";

    private static final String SQL_SELECT_ACTIVE =
            "SELECT a.id, a.title, a.body, a.created_by::integer AS created_by, " +
            "       a.created_at, a.expires_at, a.is_pinned, " +
            "       u.username AS creator_username " +
            "FROM announcements a " +
            "LEFT JOIN users u ON a.created_by::integer = u.user_id " +
            "WHERE a.expires_at IS NULL OR a.expires_at::timestamp > NOW() " +
            "ORDER BY a.is_pinned DESC, a.created_at DESC";

    private static final String SQL_DELETE =
            "DELETE FROM announcements WHERE id = ?";

    private static final String SQL_UPDATE =
            "UPDATE announcements SET title = ?, body = ?, is_pinned = ?, expires_at = ? " +
            "WHERE id = ?";

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
     * Create a new announcement.
     *
     * @param title      short heading (required)
     * @param body       announcement body text (required)
     * @param createdBy  userId of the admin creating this
     * @param isPinned   whether to pin at the top
     * @param expiresAt  optional expiry timestamp; pass null to never expire
     */
    public boolean createAnnouncement(String title, String body, int createdBy,
                                      boolean isPinned, Timestamp expiresAt) {
        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("Announcement title must not be empty.");
        }
        if (body == null || body.trim().isEmpty()) {
            throw new IllegalArgumentException("Announcement body must not be empty.");
        }

        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT)) {

            ps.setString(1, title.trim());
            ps.setString(2, body.trim());
            ps.setString(3, String.valueOf(createdBy));   // created_by is VARCHAR in DB
            ps.setBoolean(4, isPinned);
            if (expiresAt != null) {
                ps.setTimestamp(5, expiresAt);
            } else {
                ps.setNull(5, Types.TIMESTAMP);
            }

            int rows = ps.executeUpdate();
            LOGGER.log(Level.INFO, "Announcement created by userId={0}: {1}", new Object[]{createdBy, title});
            return rows > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating announcement.", e);
            throw new DAOException("Failed to create announcement.", e);
        }
    }

    /**
     * Returns all announcements (admin view — includes expired ones).
     * Pinned first, then newest first.
     */
    public List<Announcement> getAllAnnouncements() {
        List<Announcement> list = new ArrayList<>();
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_ALL);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching all announcements.", e);
            throw new DAOException("Failed to fetch announcements.", e);
        }
        return list;
    }

    /**
     * Returns only non-expired announcements (student view).
     * Pinned first, then newest first.
     */
    public List<Announcement> getActiveAnnouncements() {
        List<Announcement> list = new ArrayList<>();
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_ACTIVE);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching active announcements.", e);
            throw new DAOException("Failed to fetch active announcements.", e);
        }
        return list;
    }

    /**
     * Delete an announcement by its primary key.
     */
    public boolean deleteAnnouncement(int id) {
        if (id <= 0) {
            throw new IllegalArgumentException("Announcement ID must be positive.");
        }
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_DELETE)) {

            ps.setInt(1, id);
            int rows = ps.executeUpdate();
            LOGGER.log(Level.INFO, "Deleted announcement id={0}", id);
            return rows > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting announcement id={0}", id);
            throw new DAOException("Failed to delete announcement.", e);
        }
    }

    /**
     * Update an existing announcement.
     *
     * @param id         announcement ID to update
     * @param title      new title (required)
     * @param body       new body text (required)
     * @param isPinned   whether to pin at the top
     * @param expiresAt  optional expiry timestamp; pass null to never expire
     */
    public boolean updateAnnouncement(int id, String title, String body,
                                     boolean isPinned, Timestamp expiresAt) {
        if (id <= 0) {
            throw new IllegalArgumentException("Announcement ID must be positive.");
        }
        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("Announcement title must not be empty.");
        }
        if (body == null || body.trim().isEmpty()) {
            throw new IllegalArgumentException("Announcement body must not be empty.");
        }

        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_UPDATE)) {

            ps.setString(1, title.trim());
            ps.setString(2, body.trim());
            ps.setBoolean(3, isPinned);
            if (expiresAt != null) {
                ps.setTimestamp(4, expiresAt);
            } else {
                ps.setNull(4, Types.TIMESTAMP);
            }
            ps.setInt(5, id);

            int rows = ps.executeUpdate();
            LOGGER.log(Level.INFO, "Updated announcement id={0}: {1}",
                    new Object[]{id, title});
            return rows > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating announcement id={0}", id);
            throw new DAOException("Failed to update announcement.", e);
        }
    }

    private Announcement mapRow(ResultSet rs) throws SQLException {
        Announcement a = new Announcement();
        a.setId(rs.getInt("id"));
        a.setTitle(rs.getString("title"));
        a.setBody(rs.getString("body"));
        a.setCreatedBy(rs.getInt("created_by"));
        a.setCreatorUsername(rs.getString("creator_username"));
        a.setPinned(rs.getBoolean("is_pinned"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            a.setCreatedAt(ts.toLocalDateTime());
        }
        Timestamp exp = rs.getTimestamp("expires_at");
        if (exp != null) {
            a.setExpiresAt(exp.toLocalDateTime());
        }
        return a;
    }

    public static class DAOException extends RuntimeException {
        public DAOException(String message) { super(message); }
        public DAOException(String message, Throwable cause) { super(message, cause); }
    }
}
