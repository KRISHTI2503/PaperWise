package com.paperwise.dao;

import com.paperwise.model.ExamSchedule;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ExamScheduleDAO {

    private static final Logger LOGGER = Logger.getLogger(ExamScheduleDAO.class.getName());
    private static final String JNDI_DATASOURCE = "java:comp/env/jdbc/paperwise";

    private static final String SQL_INSERT =
            "INSERT INTO exam_schedule (subject_name, subject_code, exam_type, exam_date, created_by) " +
            "VALUES (?, ?, ?, ?, ?)";

    private static final String SQL_SELECT_ALL =
            "SELECT id, subject_code, subject_name, exam_type, exam_date, created_by, created_at " +
            "FROM exam_schedule " +
            "ORDER BY exam_date ASC";

    private static final String SQL_SELECT_UPCOMING =
            "SELECT id, subject_code, subject_name, exam_type, exam_date, created_by, created_at " +
            "FROM exam_schedule " +
            "WHERE exam_date >= CURRENT_DATE " +
            "ORDER BY exam_date ASC";

    private static final String SQL_DELETE =
            "DELETE FROM exam_schedule WHERE id = ?";

    private static final String SQL_UPDATE =
            "UPDATE exam_schedule SET subject_name = ?, subject_code = ?, exam_type = ?, exam_date = ? " +
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
     * Add a new exam schedule entry.
     */
    public boolean addExam(String subjectName, String subjectCode,
                           String examType, LocalDate examDate, String createdBy) {
        if (subjectName == null || subjectName.trim().isEmpty()) {
            throw new IllegalArgumentException("Subject name must not be empty.");
        }
        if (subjectCode == null || subjectCode.trim().isEmpty()) {
            throw new IllegalArgumentException("Subject code must not be empty.");
        }
        if (examType == null || examType.trim().isEmpty()) {
            throw new IllegalArgumentException("Exam type must not be empty.");
        }
        if (examDate == null) {
            throw new IllegalArgumentException("Exam date must not be null.");
        }

        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT)) {

            ps.setString(1, subjectName.trim());
            ps.setString(2, subjectCode.trim());
            ps.setString(3, examType.trim());
            ps.setDate(4, Date.valueOf(examDate));
            ps.setString(5, createdBy != null ? createdBy.trim() : "admin");

            int rows = ps.executeUpdate();
            LOGGER.log(Level.INFO, "Exam added: {0} ({1}) on {2}", new Object[]{subjectName, examType, examDate});
            return rows > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error adding exam schedule entry.", e);
            throw new DAOException("Failed to add exam schedule entry.", e);
        }
    }

    /**
     * Returns all exam schedule entries ordered by exam_date ASC.
     */
    public List<ExamSchedule> getAllExams() {
        List<ExamSchedule> list = new ArrayList<>();
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_ALL);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching all exam schedule entries.", e);
            throw new DAOException("Failed to fetch exam schedule.", e);
        }
        return list;
    }

    /**
     * Returns only upcoming exams (exam_date >= today) ordered by exam_date ASC.
     */
    public List<ExamSchedule> getUpcomingExams() {
        List<ExamSchedule> list = new ArrayList<>();
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_UPCOMING);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching upcoming exam schedule entries.", e);
            throw new DAOException("Failed to fetch upcoming exams.", e);
        }
        return list;
    }

    /**
     * Delete an exam schedule entry by its primary key.
     */
    public boolean deleteExam(int id) {
        if (id <= 0) {
            throw new IllegalArgumentException("Exam ID must be positive.");
        }
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_DELETE)) {

            ps.setInt(1, id);
            int rows = ps.executeUpdate();
            LOGGER.log(Level.INFO, "Deleted exam schedule id={0}", id);
            return rows > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting exam schedule id={0}", id);
            throw new DAOException("Failed to delete exam schedule entry.", e);
        }
    }

    /**
     * Update an existing exam schedule entry.
     */
    public boolean updateExam(int id, String subjectName, String subjectCode,
                             String examType, LocalDate examDate) {
        if (id <= 0) {
            throw new IllegalArgumentException("Exam ID must be positive.");
        }
        if (subjectName == null || subjectName.trim().isEmpty()) {
            throw new IllegalArgumentException("Subject name must not be empty.");
        }
        if (subjectCode == null || subjectCode.trim().isEmpty()) {
            throw new IllegalArgumentException("Subject code must not be empty.");
        }
        if (examType == null || examType.trim().isEmpty()) {
            throw new IllegalArgumentException("Exam type must not be empty.");
        }
        if (examDate == null) {
            throw new IllegalArgumentException("Exam date must not be null.");
        }

        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_UPDATE)) {

            ps.setString(1, subjectName.trim());
            ps.setString(2, subjectCode.trim());
            ps.setString(3, examType.trim());
            ps.setDate(4, Date.valueOf(examDate));
            ps.setInt(5, id);

            int rows = ps.executeUpdate();
            LOGGER.log(Level.INFO, "Updated exam id={0}: {1} ({2}) on {3}",
                    new Object[]{id, subjectName, examType, examDate});
            return rows > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating exam schedule id={0}", id);
            throw new DAOException("Failed to update exam schedule entry.", e);
        }
    }

    private ExamSchedule mapRow(ResultSet rs) throws SQLException {
        ExamSchedule e = new ExamSchedule();
        e.setId(rs.getInt("id"));
        e.setSubjectCode(rs.getString("subject_code"));
        e.setSubjectName(rs.getString("subject_name"));
        e.setExamType(rs.getString("exam_type"));
        Date d = rs.getDate("exam_date");
        if (d != null) {
            e.setExamDate(d.toLocalDate());
        }
        e.setCreatedBy(rs.getString("created_by"));
        return e;
    }

    public static class DAOException extends RuntimeException {
        public DAOException(String message) { super(message); }
        public DAOException(String message, Throwable cause) { super(message, cause); }
    }
}
