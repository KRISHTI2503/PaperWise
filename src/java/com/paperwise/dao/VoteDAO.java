package com.paperwise.dao;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;

public class VoteDAO {

    private static final String JNDI_DATASOURCE = "java:comp/env/jdbc/paperwise";

    private static final String SQL_CHECK_VOTE_EXISTS =
            "SELECT COUNT(*) FROM votes WHERE paper_id = ? AND user_id = ?";

    private static final String SQL_INSERT_VOTE =
            "INSERT INTO votes (paper_id, user_id) VALUES (?, ?) " +
            "ON CONFLICT (paper_id, user_id) DO NOTHING";

    private static final String SQL_GET_VOTE_COUNT =
            "SELECT COUNT(*) FROM votes WHERE paper_id = ?";

    private static final String SQL_GET_USER_VOTED_PAPERS =
            "SELECT paper_id FROM votes WHERE user_id = ?";

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

    public boolean hasUserVoted(int paperId, int userId) throws SQLException {
        if (paperId <= 0 || userId <= 0) {
            throw new IllegalArgumentException("Paper ID and User ID must be positive integers.");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_CHECK_VOTE_EXISTS)) {

            statement.setInt(1, paperId);
            statement.setInt(2, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    int count = resultSet.getInt(1);
                    return count > 0;
                }
            }

        } catch (SQLException e) {
            System.err.println("Database error while checking vote for paper ID: " + paperId + ", user ID: " + userId);
            e.printStackTrace();
            throw e;
        }

        return false;
    }

    public boolean hasUserMarked(int paperId, int userId) {
        try {
            return hasUserVoted(paperId, userId);
        } catch (SQLException e) {
            System.err.println("Error checking if user marked paper:");
            e.printStackTrace();
            return false;
        }
    }

    public boolean insertVote(int paperId, int userId) throws SQLException {
        if (paperId <= 0 || userId <= 0) {
            throw new IllegalArgumentException("Paper ID and User ID must be positive integers.");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_INSERT_VOTE)) {

            statement.setInt(1, paperId);
            statement.setInt(2, userId);

            int rowsAffected = statement.executeUpdate();

            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("SQL ERROR while adding vote for paper ID: " + paperId + ", user ID: " + userId);
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            throw e;
        }
    }

    public void addMark(int paperId, int userId) {
        try {
            insertVote(paperId, userId);
        } catch (SQLException e) {
            System.err.println("ERROR in addMark for paper " + paperId + ", user " + userId);
            e.printStackTrace();
        }
    }

    public int getVoteCount(int paperId) throws SQLException {
        if (paperId <= 0) {
            throw new IllegalArgumentException("Paper ID must be a positive integer.");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_GET_VOTE_COUNT)) {

            statement.setInt(1, paperId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt(1);
                }
            }

        } catch (SQLException e) {
            System.err.println("Database error while getting vote count for paper ID: " + paperId);
            e.printStackTrace();
            throw e;
        }

        return 0;
    }

    public Set<Integer> getUserVotedPapers(int userId) throws SQLException {
        if (userId <= 0) {
            throw new IllegalArgumentException("User ID must be a positive integer.");
        }

        Set<Integer> votedPapers = new HashSet<>();

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_GET_USER_VOTED_PAPERS)) {

            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    votedPapers.add(resultSet.getInt("paper_id"));
                }
            }

        } catch (SQLException e) {
            System.err.println("Database error while getting voted papers for user ID: " + userId);
            e.printStackTrace();
            throw e;
        }

        return votedPapers;
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