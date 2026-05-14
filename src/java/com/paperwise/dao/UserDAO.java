package com.paperwise.dao;

import com.paperwise.model.User;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import jakarta.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO {

    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    private static final String JNDI_DATASOURCE = "java:comp/env/jdbc/paperwise";

    private static final String SQL_FIND_BY_USERNAME =
            "SELECT user_id, username, email, password, role, created_at " +
            "FROM users " +
            "WHERE username = ?";

    private static final String SQL_FIND_BY_ID =
            "SELECT user_id, username, email, password, role, created_at " +
            "FROM users " +
            "WHERE user_id = ?";

    private static final String SQL_VALIDATE_LOGIN =
            "SELECT 1 " +
            "FROM users " +
            "WHERE username = ? AND password = ?";

    private static final String SQL_USERNAME_EXISTS =
            "SELECT 1 " +
            "FROM users " +
            "WHERE username = ?";

    private static final String SQL_INSERT_USER =
            "INSERT INTO users (username, email, password, role, created_at) " +
            "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";

    private static final String SQL_COUNT_STUDENTS =
            "SELECT COUNT(*) FROM users WHERE role = 'student'";

    private static final String SQL_FIND_ALL_STUDENTS =
            "SELECT u.user_id, u.username, u.email, u.role, u.created_at, " +
            "       COALESCE((SELECT COUNT(*) FROM votes v " +
            "                 WHERE v.user_id = u.user_id), 0) AS useful_marks_given, " +
            "       COALESCE((SELECT COUNT(*) FROM paper_requests pr " +
            "                 WHERE pr.user_id = u.user_id), 0) AS requests_made " +
            "FROM users u " +
            "WHERE u.role = 'student' " +
            "ORDER BY u.created_at DESC";

    private static final String SQL_COUNT_ACTIVE_THIS_MONTH =
            "SELECT COUNT(DISTINCT u.user_id) " +
            "FROM users u " +
            "WHERE u.role = 'student' " +
            "  AND ( " +
            "    EXISTS (SELECT 1 FROM votes v " +
            "            WHERE v.user_id = u.user_id " +
            "              AND DATE_TRUNC('month', CURRENT_DATE) <= CURRENT_DATE) " +
            "    OR " +
            "    EXISTS (SELECT 1 FROM paper_requests pr " +
            "            WHERE pr.user_id = u.user_id " +
            "              AND DATE_TRUNC('month', pr.requested_at) = DATE_TRUNC('month', CURRENT_DATE)) " +
            "  )";

    private DataSource dataSource;

    private DataSource getDataSource() {
        if (dataSource == null) {
            try {
                Context initContext = new InitialContext();
                dataSource = (DataSource) initContext.lookup(JNDI_DATASOURCE);
            } catch (NamingException e) {
                LOGGER.log(Level.SEVERE,
                        "JNDI lookup failed for resource: " + JNDI_DATASOURCE, e);
                throw new DAOException(
                        "Unable to locate DataSource via JNDI. " +
                        "Verify that '" + JNDI_DATASOURCE + "' is declared in context.xml.", e);
            }
        }
        return dataSource;
    }

    public int getStudentCount() {
        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_COUNT_STUDENTS);
             ResultSet resultSet = statement.executeQuery()) {
            if (resultSet.next()) return resultSet.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while counting students.", e);
            throw new DAOException("Failed to count students.", e);
        }
        return 0;
    }

    /**
     * Returns all student-role users with their useful marks given and requests made counts.
     */
    public List<User> getAllStudents() {
        List<User> students = new ArrayList<>();

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_FIND_ALL_STUDENTS);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                User user = new User();
                user.setUserId(resultSet.getInt("user_id"));
                user.setUsername(resultSet.getString("username"));
                user.setEmail(resultSet.getString("email"));
                user.setRole(resultSet.getString("role"));

                java.sql.Timestamp createdAt = resultSet.getTimestamp("created_at");
                if (createdAt != null) {
                    user.setCreatedAt(createdAt.toLocalDateTime());
                }

                user.setUsefulMarksGiven(resultSet.getInt("useful_marks_given"));
                user.setRequestsMade(resultSet.getInt("requests_made"));
                students.add(user);
            }

            LOGGER.log(Level.INFO, "Retrieved {0} students.", students.size());

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while fetching all students.", e);
            throw new DAOException("Failed to retrieve students.", e);
        }

        return students;
    }

    /**
     * Returns count of students who have at least 1 vote OR 1 request in the current calendar month.
     */
    public int getActiveStudentsThisMonth() {
        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_COUNT_ACTIVE_THIS_MONTH);
             ResultSet resultSet = statement.executeQuery()) {
            if (resultSet.next()) return resultSet.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while counting active students this month.", e);
            throw new DAOException("Failed to count active students.", e);
        }
        return 0;
    }

    public User getUserByUsername(String username) {
        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException("Username must not be null or blank.");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_FIND_BY_USERNAME)) {

            statement.setString(1, username);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapRow(resultSet);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Database error while fetching user by username: " + username, e);
            throw new DAOException("Failed to retrieve user by username.", e);
        }

        return null;
    }

    public User getUserById(int userId) {
        if (userId <= 0) {
            throw new IllegalArgumentException("userId must be a positive integer.");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_FIND_BY_ID)) {

            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapRow(resultSet);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Database error while fetching user by id: " + userId, e);
            throw new DAOException("Failed to retrieve user by id.", e);
        }

        return null;
    }

    public boolean validateLogin(String username, String password) {
        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException("Username must not be null or blank.");
        }
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("Password must not be null or empty.");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_VALIDATE_LOGIN)) {

            statement.setString(1, username);
            statement.setString(2, password);

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Database error during login validation for username: " + username, e);
            throw new DAOException("Failed to validate login credentials.", e);
        }
    }

    public boolean usernameExists(String username) {
        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException("Username must not be null or blank.");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_USERNAME_EXISTS)) {

            statement.setString(1, username);

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Database error while checking username existence: " + username, e);
            throw new DAOException("Failed to check username existence.", e);
        }
    }

    public boolean registerUser(User user) {
        if (user == null) {
            throw new IllegalArgumentException("User must not be null.");
        }
        if (user.getUsername() == null || user.getUsername().isBlank()) {
            throw new IllegalArgumentException("Username must not be null or blank.");
        }
        if (user.getEmail() == null || user.getEmail().isBlank()) {
            throw new IllegalArgumentException("Email must not be null or blank.");
        }
        if (user.getPassword() == null || user.getPassword().isEmpty()) {
            throw new IllegalArgumentException("Password must not be null or empty.");
        }

        String role = (user.getRole() == null || user.getRole().isBlank())
                      ? "student"
                      : user.getRole();

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_INSERT_USER)) {

            statement.setString(1, user.getUsername());
            statement.setString(2, user.getEmail());
            statement.setString(3, user.getPassword());
            statement.setString(4, role);

            int rowsAffected = statement.executeUpdate();

            if (rowsAffected > 0) {
                LOGGER.log(Level.INFO,
                        "User ''{0}'' registered successfully with role ''{1}''.",
                        new Object[]{user.getUsername(), role});
                return true;
            }

            return false;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Database error during user registration for username: " + user.getUsername(), e);
            throw new DAOException("Failed to register user.", e);
        }
    }

    private User mapRow(ResultSet resultSet) throws SQLException {
        User user = new User();
        user.setUserId(resultSet.getInt("user_id"));
        user.setUsername(resultSet.getString("username"));
        user.setEmail(resultSet.getString("email"));
        user.setPassword(resultSet.getString("password"));
        user.setRole(resultSet.getString("role"));

        java.sql.Timestamp createdAt = resultSet.getTimestamp("created_at");
        if (createdAt != null) {
            user.setCreatedAt(createdAt.toLocalDateTime());
        }

        return user;
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