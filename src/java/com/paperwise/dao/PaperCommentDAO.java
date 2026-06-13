package com.paperwise.dao;

import com.paperwise.model.PaperComment;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class PaperCommentDAO {

    private static final String JNDI_DATASOURCE = "java:comp/env/jdbc/paperwise";
    private DataSource dataSource;

    private DataSource getDataSource() {
        if (dataSource == null) {
            try {
                Context initContext = new InitialContext();
                dataSource = (DataSource) initContext.lookup(JNDI_DATASOURCE);
            } catch (NamingException e) {
                throw new RuntimeException("JNDI lookup failed for resource: " + JNDI_DATASOURCE, e);
            }
        }
        return dataSource;
    }

    private Connection getConnection() throws SQLException {
        return getDataSource().getConnection();
    }

    public boolean addComment(int paperId, int userId, String commentText, Integer parentCommentId) {
        String sql = "INSERT INTO paper_comments (paper_id, user_id, comment_text, parent_comment_id) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paperId);
            ps.setInt(2, userId);
            ps.setString(3, commentText);
            if (parentCommentId != null) {
                ps.setInt(4, parentCommentId);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            return false;
        }
    }

    public int getCommentAuthorId(int commentId) {
        String sql = "SELECT user_id FROM paper_comments WHERE comment_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        } catch (SQLException e) {
            // ignore
        }
        return -1;
    }

    /**
     * Returns the role of the comment author ("admin" or "student"), or null if not found.
     */
    public String getCommentAuthorRole(int commentId) {
        String sql = "SELECT u.role FROM paper_comments pc "
                   + "JOIN users u ON pc.user_id = u.user_id "
                   + "WHERE pc.comment_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("role");
                }
            }
        } catch (SQLException e) {
            // ignore
        }
        return null;
    }

    /**
     * Role-based delete:
     *   - ADMIN can delete own comments and any STUDENT comment, but NOT another admin's comment.
     *   - STUDENT can delete only their own comment.
     *
     * Returns true if deleted, false if permission denied or not found.
     */
    public boolean deleteComment(int commentId, int requestingUserId, String requestingUserRole) {
        // Fetch the comment author's userId and role
        int authorId   = -1;
        String authorRole = null;
        String lookupSql = "SELECT pc.user_id, u.role FROM paper_comments pc "
                         + "JOIN users u ON pc.user_id = u.user_id "
                         + "WHERE pc.comment_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(lookupSql)) {
            ps.setInt(1, commentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    authorId   = rs.getInt("user_id");
                    authorRole = rs.getString("role");
                }
            }
        } catch (SQLException e) {
            return false;
        }

        if (authorId == -1) {
            // comment not found
            return false;
        }

        boolean isAdmin = "admin".equalsIgnoreCase(requestingUserRole);

        // Permission check
        if (isAdmin) {
            // Admin can delete own comments OR any student's comment,
            // but CANNOT delete another admin's comment
            if (requestingUserId != authorId && "admin".equalsIgnoreCase(authorRole)) {
                return false; // 403 — admin trying to delete another admin's comment
            }
        } else {
            // Student can only delete their own comment
            if (requestingUserId != authorId) {
                return false; // 403
            }
        }

        // Permission granted — execute delete (cascades to replies via FK or deletes by id)
        String deleteSql = "DELETE FROM paper_comments WHERE comment_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(deleteSql)) {
            ps.setInt(1, commentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            return false;
        }
    }

    /**
     * Legacy method kept for backward compatibility (used by DeleteCommentServlet which uses username).
     * Routes to the new role-based method by looking up the user's id and role from the username.
     */
    public boolean deleteComment(int commentId, String username, boolean isAdmin) {
        // Look up userId for the given username
        String sql = "SELECT user_id, role FROM users WHERE username = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int uid  = rs.getInt("user_id");
                    String role = rs.getString("role");
                    return deleteComment(commentId, uid, role);
                }
            }
        } catch (SQLException e) {
            // ignore
        }
        return false;
    }

    public List<PaperComment> getCommentsByPaperId(int paperId) {
        List<PaperComment> topLevel = new ArrayList<>();
        Map<Integer, PaperComment> commentMap = new LinkedHashMap<>();

        // Join with users to get both username AND role
        String sql = "SELECT pc.*, u.username, u.role FROM paper_comments pc "
                + "JOIN users u ON pc.user_id = u.user_id "
                + "WHERE pc.paper_id = ? "
                + "ORDER BY pc.created_at ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paperId);
            try (ResultSet rs = ps.executeQuery()) {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm");
                while (rs.next()) {
                    PaperComment c = new PaperComment();
                    c.setCommentId(rs.getInt("comment_id"));
                    c.setPaperId(rs.getInt("paper_id"));
                    c.setUserId(rs.getInt("user_id"));
                    c.setUsername(rs.getString("username"));
                    c.setUserRole(rs.getString("role"));     // populate userRole
                    c.setCommentText(rs.getString("comment_text"));
                    if (rs.getTimestamp("created_at") != null) {
                        c.setCreatedAt(sdf.format(rs.getTimestamp("created_at")));
                    }
                    int parentId = rs.getInt("parent_comment_id");
                    if (!rs.wasNull()) {
                        c.setParentCommentId(parentId);
                    }
                    commentMap.put(c.getCommentId(), c);
                }
            }

            for (PaperComment c : commentMap.values()) {
                if (c.getParentCommentId() == null) {
                    topLevel.add(c);
                } else {
                    PaperComment parent = commentMap.get(c.getParentCommentId());
                    if (parent != null) {
                        parent.getReplies().add(c);
                    }
                }
            }
        } catch (SQLException e) {
            // ignore
        }
        return topLevel;
    }
}
