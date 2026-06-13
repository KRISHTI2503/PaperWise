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

public class CommentDAO {
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

    public List<PaperComment> getCommentsByPaperId(int paperId) {
        List<PaperComment> topLevel = new ArrayList<>();
        Map<Integer, PaperComment> commentMap = new LinkedHashMap<>();

        String sql = "SELECT pc.*, u.username FROM paper_comments pc " +
                     "JOIN users u ON pc.user_id = u.user_id " +
                     "WHERE pc.paper_id = ? " +
                     "ORDER BY pc.created_at ASC";
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
        }
        return topLevel;
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
        }
        return -1;
    }

    public boolean deleteComment(int commentId, int userId) {
        String sql = "DELETE FROM paper_comments WHERE comment_id = ? AND user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            return false;
        }
    }
}
