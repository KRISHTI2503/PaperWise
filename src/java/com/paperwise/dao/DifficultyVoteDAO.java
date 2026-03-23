package com.paperwise.dao;

import com.paperwise.model.DifficultyStats;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class DifficultyVoteDAO {

    private static final String JNDI_DATASOURCE = "java:comp/env/jdbc/paperwise";

    private static final String SQL_UPSERT_DIFFICULTY_VOTE =
            "INSERT INTO difficulty_votes (paper_id, user_id, difficulty_level) " +
            "VALUES (?, ?, ?) " +
            "ON CONFLICT (paper_id, user_id) " +
            "DO UPDATE SET difficulty_level = EXCLUDED.difficulty_level";

    private static final String SQL_GET_DIFFICULTY_STATS =
            "SELECT difficulty_level, COUNT(*) as count " +
            "FROM difficulty_votes WHERE paper_id = ? " +
            "GROUP BY difficulty_level";

    private static final String SQL_GET_USER_DIFFICULTY_VOTE =
            "SELECT difficulty_level FROM difficulty_votes " +
            "WHERE paper_id = ? AND user_id = ?";

    private DataSource dataSource;

    private DataSource getDataSource() {
        if (dataSource == null) {
            try {
                Context initContext = new InitialContext();
                dataSource = (DataSource) initContext.lookup(JNDI_DATASOURCE);
            } catch (NamingException e) {
                System.err.println("JNDI lookup failed for resource: " + JNDI_DATASOURCE);
                e.printStackTrace();
                throw new DAOException(
                        "Unable to locate DataSource via JNDI. " +
                        "Verify that '" + JNDI_DATASOURCE + "' is declared in context.xml.", e);
            }
        }
        return dataSource;
    }

    public void addOrUpdateDifficultyVote(int paperId, int userId, String level) {
        if (paperId <= 0 || userId <= 0) {
            throw new IllegalArgumentException("Paper ID and User ID must be positive integers.");
        }
        if (level == null || level.trim().isEmpty()) {
            throw new IllegalArgumentException("Difficulty level must not be null or empty.");
        }

        String normalizedLevel = level.trim().toLowerCase();
        if (!isValidDifficultyLevel(normalizedLevel)) {
            throw new IllegalArgumentException(
                    "Invalid difficulty level. Must be one of: easy, medium, hard");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_UPSERT_DIFFICULTY_VOTE)) {

            statement.setInt(1, paperId);
            statement.setInt(2, userId);
            statement.setString(3, normalizedLevel);

            int rowsAffected = statement.executeUpdate();

            if (rowsAffected > 0) {
                System.out.println("Difficulty vote added/updated for paper ID " + paperId +
                                   " by user ID " + userId + ": " + normalizedLevel);
            }

        } catch (SQLException e) {
            System.err.println("Database error while adding/updating difficulty vote for paper ID: " +
                               paperId + ", user ID: " + userId);
            e.printStackTrace();
            throw new DAOException("Failed to add or update difficulty vote.", e);
        }
    }

    @Deprecated
    public Map<String, Integer> getDifficultyStats(int paperId) {
        if (paperId <= 0) {
            throw new IllegalArgumentException("Paper ID must be a positive integer.");
        }

        Map<String, Integer> stats = new HashMap<>();

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_GET_DIFFICULTY_STATS)) {

            statement.setInt(1, paperId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    String level = resultSet.getString("difficulty_level");
                    int count = resultSet.getInt("count");
                    stats.put(level, count);
                }
            }

        } catch (SQLException e) {
            System.err.println("Database error while getting difficulty stats for paper ID: " + paperId);
            e.printStackTrace();
            throw new DAOException("Failed to retrieve difficulty statistics.", e);
        }

        return stats;
    }

    public DifficultyStats getDifficultyStatsObject(int paperId) {
        if (paperId <= 0) {
            throw new IllegalArgumentException("Paper ID must be a positive integer.");
        }

        DifficultyStats stats = new DifficultyStats();

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_GET_DIFFICULTY_STATS)) {

            statement.setInt(1, paperId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    String level = resultSet.getString("difficulty_level");
                    int count = resultSet.getInt("count");

                    switch (level.toLowerCase()) {
                        case "easy":
                            stats.setEasyCount(count);
                            break;
                        case "medium":
                            stats.setMediumCount(count);
                            break;
                        case "hard":
                            stats.setHardCount(count);
                            break;
                        default:
                            System.err.println("Unknown difficulty level: " + level);
                    }
                }
            }

        } catch (SQLException e) {
            System.err.println("Database error while getting difficulty stats for paper ID: " + paperId);
            e.printStackTrace();
            throw new DAOException("Failed to retrieve difficulty statistics.", e);
        }

        return stats;
    }

    public String getUserDifficultyVote(int paperId, int userId) {
        if (paperId <= 0 || userId <= 0) {
            throw new IllegalArgumentException("Paper ID and User ID must be positive integers.");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_GET_USER_DIFFICULTY_VOTE)) {

            statement.setInt(1, paperId);
            statement.setInt(2, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getString("difficulty_level");
                }
            }

        } catch (SQLException e) {
            System.err.println("Database error while getting user difficulty vote for paper ID: " +
                               paperId + ", user ID: " + userId);
            e.printStackTrace();
            throw new DAOException("Failed to retrieve user difficulty vote.", e);
        }

        return null;
    }

    private boolean isValidDifficultyLevel(String level) {
        return "Easy".equalsIgnoreCase(level) ||
               "Medium".equalsIgnoreCase(level) ||
               "Hard".equalsIgnoreCase(level);
    }

    public static class DAOException extends RuntimeException {

        public DAOException(String message) {
            super(message);
        }

        public DAOException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}