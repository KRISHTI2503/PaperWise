package com.paperwise.dao;

import com.paperwise.model.Paper;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PaperDAO {

    private static final Logger LOGGER = Logger.getLogger(PaperDAO.class.getName());

    private static final String JNDI_DATASOURCE = "java:comp/env/jdbc/paperwise";

    private static final String SQL_INSERT_PAPER =
            "INSERT INTO papers (subject_name, subject_code, year, chapter, file_url, uploaded_by) " +
            "VALUES (?, ?, ?, ?, ?, ?)";

    private static final String SQL_FIND_ALL_PAPERS =
            "SELECT p.paper_id, p.subject_name, p.subject_code, p.year, p.chapter, p.file_url, " +
            "       p.uploaded_by, p.created_at, u.username " +
            "FROM papers p " +
            "LEFT JOIN users u ON p.uploaded_by = u.user_id " +
            "ORDER BY p.created_at DESC";

    private static final String SQL_FIND_ALL_PAPERS_WITH_VOTES =
            "SELECT p.*, " +
            "       COUNT(DISTINCT v.id) AS useful_count, " +
            "       COUNT(*) FILTER (WHERE d.difficulty_level = 'easy') AS easy_count, " +
            "       COUNT(*) FILTER (WHERE d.difficulty_level = 'medium') AS medium_count, " +
            "       COUNT(*) FILTER (WHERE d.difficulty_level = 'hard') AS hard_count, " +
            "       u.username " +
            "FROM papers p " +
            "LEFT JOIN users u ON p.uploaded_by = u.user_id " +
            "LEFT JOIN votes v ON p.paper_id = v.paper_id " +
            "LEFT JOIN difficulty_votes d ON p.paper_id = d.paper_id " +
            "GROUP BY p.paper_id, u.username " +
            "ORDER BY useful_count DESC, p.created_at DESC";

    private static final String SQL_GET_VOTE_COUNT =
            "SELECT COUNT(*) FROM votes WHERE paper_id = ?";

    private static final String SQL_FIND_BY_ID =
            "SELECT p.paper_id, p.subject_name, p.subject_code, p.year, p.chapter, p.file_url, " +
            "       p.uploaded_by, p.created_at, u.username " +
            "FROM papers p " +
            "LEFT JOIN users u ON p.uploaded_by = u.user_id " +
            "WHERE p.paper_id = ?";

    private static final String SQL_DELETE_PAPER =
            "DELETE FROM papers WHERE paper_id = ?";

    private static final String SQL_UPDATE_PAPER =
            "UPDATE papers SET subject_name = ?, subject_code = ?, year = ?, chapter = ? " +
            "WHERE paper_id = ?";

    private static final String SQL_GET_DISTINCT_YEARS =
            "SELECT DISTINCT year FROM papers ORDER BY year DESC";

    private static final String SQL_FIND_PAPERS_BY_YEAR =
            "SELECT p.*, " +
            "       COUNT(DISTINCT v.id) AS useful_count, " +
            "       COUNT(*) FILTER (WHERE d.difficulty_level = 'easy') AS easy_count, " +
            "       COUNT(*) FILTER (WHERE d.difficulty_level = 'medium') AS medium_count, " +
            "       COUNT(*) FILTER (WHERE d.difficulty_level = 'hard') AS hard_count, " +
            "       u.username " +
            "FROM papers p " +
            "LEFT JOIN users u ON p.uploaded_by = u.user_id " +
            "LEFT JOIN votes v ON p.paper_id = v.paper_id " +
            "LEFT JOIN difficulty_votes d ON p.paper_id = d.paper_id " +
            "WHERE p.year = ? " +
            "GROUP BY p.paper_id, u.username " +
            "ORDER BY useful_count DESC, p.created_at DESC";

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

    public boolean savePaper(Paper paper) {
        if (paper == null) {
            throw new IllegalArgumentException("Paper must not be null.");
        }
        if (paper.getSubjectName() == null || paper.getSubjectName().isBlank()) {
            throw new IllegalArgumentException("Subject name must not be null or blank.");
        }
        if (paper.getSubjectCode() == null || paper.getSubjectCode().isBlank()) {
            throw new IllegalArgumentException("Subject code must not be null or blank.");
        }
        if (paper.getYear() <= 0) {
            throw new IllegalArgumentException("Year must be a positive integer.");
        }
        if (paper.getFileUrl() == null || paper.getFileUrl().isBlank()) {
            throw new IllegalArgumentException("File URL must not be null or blank.");
        }
        if (paper.getUploadedBy() <= 0) {
            throw new IllegalArgumentException("Uploaded by must be a valid user ID.");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_INSERT_PAPER)) {

            statement.setString(1, paper.getSubjectName());
            statement.setString(2, paper.getSubjectCode());
            statement.setInt(3, paper.getYear());

            if (paper.getChapter() != null && !paper.getChapter().isBlank()) {
                statement.setString(4, paper.getChapter());
            } else {
                statement.setNull(4, java.sql.Types.VARCHAR);
            }

            statement.setString(5, paper.getFileUrl());
            statement.setInt(6, paper.getUploadedBy());

            int rowsAffected = statement.executeUpdate();

            if (rowsAffected > 0) {
                LOGGER.log(Level.INFO,
                        "Paper ''{0}'' uploaded successfully by user ID {1}.",
                        new Object[]{paper.getSubjectName(), paper.getUploadedBy()});
                return true;
            }

            return false;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Database error while saving paper: " + paper.getSubjectName(), e);
            throw new DAOException("Failed to save paper.", e);
        }
    }

    public List<Paper> getAllPapers() {
        List<Paper> papers = new ArrayList<>();

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_FIND_ALL_PAPERS);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                papers.add(mapRow(resultSet));
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while fetching all papers.", e);
            throw new DAOException("Failed to retrieve papers.", e);
        }

        return papers;
    }

    public List<Paper> getAllPapersWithVotes() {
        List<Paper> papers = new ArrayList<>();

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_FIND_ALL_PAPERS_WITH_VOTES);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                Paper paper = mapRow(resultSet);
                paper.setUsefulCount(resultSet.getInt("useful_count"));
                paper.setEasyCount(resultSet.getInt("easy_count"));
                paper.setMediumCount(resultSet.getInt("medium_count"));
                paper.setHardCount(resultSet.getInt("hard_count"));
                paper.calculateDifficulty();
                papers.add(paper);
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while fetching papers with votes.", e);
            throw new DAOException("Failed to retrieve papers with votes.", e);
        }

        return papers;
    }

    public int getVoteCount(int paperId) {
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
            LOGGER.log(Level.SEVERE,
                    "Database error while getting vote count for paper ID: " + paperId, e);
            throw new DAOException("Failed to get vote count.", e);
        }

        return 0;
    }

    public List<Integer> getDistinctYears() {
        List<Integer> years = new ArrayList<>();

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_GET_DISTINCT_YEARS);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                years.add(resultSet.getInt("year"));
            }

            LOGGER.log(Level.INFO, "Retrieved {0} distinct years from papers table.", years.size());

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while retrieving distinct years.", e);
            throw new DAOException("Failed to retrieve distinct years.", e);
        }

        return years;
    }

    public List<Paper> getPapersByYear(int year) {
        List<Paper> papers = new ArrayList<>();

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_FIND_PAPERS_BY_YEAR)) {

            statement.setInt(1, year);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    Paper paper = mapRow(resultSet);
                    paper.setUploaderUsername(resultSet.getString("username"));
                    paper.setUsefulCount(resultSet.getInt("useful_count"));
                    paper.setEasyCount(resultSet.getInt("easy_count"));
                    paper.setMediumCount(resultSet.getInt("medium_count"));
                    paper.setHardCount(resultSet.getInt("hard_count"));
                    paper.calculateDifficulty();
                    papers.add(paper);
                }
            }

            LOGGER.log(Level.INFO, "Retrieved {0} papers for year {1}.",
                    new Object[]{papers.size(), year});

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while retrieving papers for year: " + year, e);
            throw new DAOException("Failed to retrieve papers for year " + year + ".", e);
        }

        return papers;
    }

    public Paper getPaperById(int paperId) {
        if (paperId <= 0) {
            throw new IllegalArgumentException("Paper ID must be a positive integer.");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_FIND_BY_ID)) {

            statement.setInt(1, paperId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapRow(resultSet);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Database error while fetching paper by ID: " + paperId, e);
            throw new DAOException("Failed to retrieve paper by ID.", e);
        }

        return null;
    }

    public boolean deletePaper(int paperId) {
        if (paperId <= 0) {
            throw new IllegalArgumentException("Paper ID must be a positive integer.");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_DELETE_PAPER)) {

            statement.setInt(1, paperId);
            int rowsAffected = statement.executeUpdate();

            if (rowsAffected > 0) {
                LOGGER.log(Level.INFO, "Paper with ID {0} deleted successfully.", paperId);
                return true;
            }

            return false;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Database error while deleting paper ID: " + paperId, e);
            throw new DAOException("Failed to delete paper.", e);
        }
    }

    public boolean updatePaper(Paper paper) {
        if (paper == null) {
            throw new IllegalArgumentException("Paper must not be null.");
        }
        if (paper.getPaperId() <= 0) {
            throw new IllegalArgumentException("Paper ID must be a positive integer.");
        }
        if (paper.getSubjectName() == null || paper.getSubjectName().isBlank()) {
            throw new IllegalArgumentException("Subject name must not be null or blank.");
        }
        if (paper.getSubjectCode() == null || paper.getSubjectCode().isBlank()) {
            throw new IllegalArgumentException("Subject code must not be null or blank.");
        }
        if (paper.getYear() <= 0) {
            throw new IllegalArgumentException("Year must be a positive integer.");
        }

        try (Connection connection = getDataSource().getConnection();
             PreparedStatement statement = connection.prepareStatement(SQL_UPDATE_PAPER)) {

            statement.setString(1, paper.getSubjectName());
            statement.setString(2, paper.getSubjectCode());
            statement.setInt(3, paper.getYear());

            if (paper.getChapter() != null && !paper.getChapter().isBlank()) {
                statement.setString(4, paper.getChapter());
            } else {
                statement.setNull(4, java.sql.Types.VARCHAR);
            }

            statement.setInt(5, paper.getPaperId());

            int rowsAffected = statement.executeUpdate();

            if (rowsAffected > 0) {
                LOGGER.log(Level.INFO,
                        "Paper ID {0} updated successfully.",
                        paper.getPaperId());
                return true;
            }

            return false;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Database error while updating paper ID: " + paper.getPaperId(), e);
            throw new DAOException("Failed to update paper.", e);
        }
    }

    private Paper mapRow(ResultSet resultSet) throws SQLException {
        Paper paper = new Paper();
        paper.setPaperId(resultSet.getInt("paper_id"));
        paper.setSubjectName(resultSet.getString("subject_name"));
        paper.setSubjectCode(resultSet.getString("subject_code"));
        paper.setYear(resultSet.getInt("year"));

        String chapter = resultSet.getString("chapter");
        paper.setChapter(chapter);

        paper.setFileUrl(resultSet.getString("file_url"));
        paper.setUploadedBy(resultSet.getInt("uploaded_by"));

        java.sql.Timestamp createdAt = resultSet.getTimestamp("created_at");
        if (createdAt != null) {
            paper.setCreatedAt(createdAt.toLocalDateTime());
        }

        String uploaderUsername = resultSet.getString("username");
        if (uploaderUsername != null) {
            paper.setUploaderUsername(uploaderUsername);
        }

        return paper;
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