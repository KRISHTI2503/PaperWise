package com.paperwise.dao;

import com.paperwise.model.PaperRequest;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Year;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PaperRequestDAO {

    private static final Logger LOGGER = Logger.getLogger(PaperRequestDAO.class.getName());
    private static final String JNDI_DATASOURCE = "java:comp/env/jdbc/paperwise";

    private static final int VALID_YEARS_BACK = 20;

    private static final String SQL_INSERT_REQUEST =
            "INSERT INTO paper_requests (user_id, subject_name, subject_code, year, description) " +
            "VALUES (?, ?, ?, ?, ?)";

    private static final String SQL_FIND_ALL_REQUESTS =
            "SELECT pr.*, u.username " +
            "FROM paper_requests pr " +
            "LEFT JOIN users u ON pr.user_id = u.user_id " +
            "ORDER BY pr.requested_at DESC";

    private static final String SQL_UPDATE_STATUS =
            "UPDATE paper_requests SET status = ? WHERE request_id = ?";

    private static final String SQL_FIND_BY_USER =
            "SELECT request_id, subject_name, subject_code, year, description, status, requested_at " +
            "FROM paper_requests " +
            "WHERE user_id = ? " +
            "ORDER BY requested_at DESC";

    private static final String SQL_DELETE_REQUEST =
            "DELETE FROM paper_requests " +
            "WHERE request_id = ? AND user_id = ?";

    private DataSource dataSource;

    private DataSource getDataSource() {
        if (dataSource == null) {
            try {
                Context initContext = new InitialContext();
                dataSource = (DataSource) initContext.lookup(JNDI_DATASOURCE);
            } catch (NamingException e) {
                LOGGER.log(Level.SEVERE, "JNDI lookup failed for resource: " + JNDI_DATASOURCE, e);
                throw new DAOException(
                        "Unable to locate DataSource via JNDI. " +
                        "Verify that '" + JNDI_DATASOURCE + "' is declared in context.xml.", e);
            }
        }
        return dataSource;
    }

    public boolean isValidYear(int year) {
        int currentYear = Year.now().getValue();
        int minYear = currentYear - VALID_YEARS_BACK;
        return year >= minYear && year <= currentYear;
    }

    public String getValidYearRange() {
        int currentYear = Year.now().getValue();
        int minYear = currentYear - VALID_YEARS_BACK;
        return minYear + " - " + currentYear;
    }

    public boolean saveRequest(PaperRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("PaperRequest must not be null.");
        }

        int currentYear = Year.now().getValue();
        int minYear = currentYear - VALID_YEARS_BACK;
        int year = request.getYear();

        if (year < minYear || year > currentYear) {
            String errorMsg = "Year must be between " + minYear + " and " + currentYear + ".";
            throw new IllegalArgumentException(errorMsg);
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_INSERT_REQUEST)) {

            statement.setInt(1, request.getRequestedBy());
            statement.setString(2, request.getSubjectName());
            statement.setString(3, request.getSubjectCode());
            statement.setInt(4, request.getYear());
            statement.setString(5, request.getDescription());

            int rowsAffected = statement.executeUpdate();

            if (rowsAffected > 0) {
                LOGGER.log(Level.INFO, "Paper request saved successfully: {0}", request);
                return true;
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while saving paper request.", e);
            e.printStackTrace();
            throw new DAOException("Failed to save paper request.", e);
        }

        return false;
    }

    public List<PaperRequest> getAllRequests() {
        List<PaperRequest> requests = new ArrayList<>();

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_FIND_ALL_REQUESTS);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                PaperRequest request = new PaperRequest();
                request.setRequestId(resultSet.getInt("request_id"));
                request.setSubjectName(resultSet.getString("subject_name"));
                request.setSubjectCode(resultSet.getString("subject_code"));
                request.setYear(resultSet.getInt("year"));
                request.setDescription(resultSet.getString("description"));
                request.setRequestedBy(resultSet.getInt("user_id"));
                request.setStatus(resultSet.getString("status"));
                request.setCreatedAt(resultSet.getTimestamp("requested_at").toLocalDateTime());
                request.setRequesterUsername(resultSet.getString("username"));
                requests.add(request);
            }

            LOGGER.log(Level.INFO, "Retrieved {0} paper requests.", requests.size());

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while retrieving paper requests.", e);
            throw new DAOException("Failed to retrieve paper requests.", e);
        }

        return requests;
    }

    public List<PaperRequest> getRequestsByUserId(int userId) {
        List<PaperRequest> requests = new ArrayList<>();

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_FIND_BY_USER)) {

            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    PaperRequest req = new PaperRequest();
                    req.setRequestId(resultSet.getInt("request_id"));
                    req.setSubjectName(resultSet.getString("subject_name"));
                    req.setSubjectCode(resultSet.getString("subject_code"));
                    req.setYear(resultSet.getInt("year"));
                    req.setDescription(resultSet.getString("description"));
                    req.setStatus(resultSet.getString("status"));
                    java.sql.Timestamp ts = resultSet.getTimestamp("requested_at");
                    if (ts != null) {
                        req.setCreatedAt(ts.toLocalDateTime());
                    }
                    requests.add(req);
                }
            }

            LOGGER.log(Level.INFO, "Retrieved {0} requests for user ID {1}.",
                    new Object[]{requests.size(), userId});

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while retrieving requests for user ID: " + userId, e);
            e.printStackTrace();
            throw new DAOException("Failed to retrieve requests for user.", e);
        }

        return requests;
    }

    public boolean updateStatus(int requestId, String status) {
        if (requestId <= 0) {
            throw new IllegalArgumentException("Request ID must be a positive integer.");
        }
        if (status == null || status.trim().isEmpty()) {
            throw new IllegalArgumentException("Status must not be null or empty.");
        }

        String normalizedStatus = status.trim().toLowerCase();
        if (!normalizedStatus.equals("pending") &&
            !normalizedStatus.equals("approved") &&
            !normalizedStatus.equals("rejected") &&
            !normalizedStatus.equals("completed")) {
            throw new IllegalArgumentException(
                    "Invalid status. Must be one of: pending, approved, rejected, completed");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_UPDATE_STATUS)) {

            statement.setString(1, normalizedStatus);
            statement.setInt(2, requestId);

            int rowsAffected = statement.executeUpdate();

            if (rowsAffected > 0) {
                LOGGER.log(Level.INFO, "Updated request {0} status to: {1}",
                        new Object[]{requestId, normalizedStatus});
                return true;
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Database error while updating request status for ID: " + requestId, e);
            e.printStackTrace();
            throw new DAOException("Failed to update request status: " + e.getMessage(), e);
        }

        return false;
    }

    public boolean deleteRequest(int requestId, int userId) {
        if (requestId <= 0 || userId <= 0) {
            throw new IllegalArgumentException("Request ID and User ID must be positive integers.");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_DELETE_REQUEST)) {

            statement.setInt(1, requestId);
            statement.setInt(2, userId);

            int rowsAffected = statement.executeUpdate();

            if (rowsAffected > 0) {
                LOGGER.log(Level.INFO, "Deleted request {0} for user {1}.",
                        new Object[]{requestId, userId});
                return true;
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Database error while deleting request ID: " + requestId, e);
            e.printStackTrace();
            throw new DAOException("Failed to delete request: " + e.getMessage(), e);
        }

        return false;
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