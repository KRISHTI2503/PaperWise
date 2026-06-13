package com.paperwise.dao;

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
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO for analytics data — reads from existing tables only, no writes.
 */
public class AnalyticsDAO {

    private static final Logger LOGGER = Logger.getLogger(AnalyticsDAO.class.getName());
    private static final String JNDI_DATASOURCE = "java:comp/env/jdbc/paperwise";

    // ── Summary counts ──────────────────────────────────────────────────────
    private static final String SQL_COUNT_PAPERS =
            "SELECT COUNT(*) FROM papers";

    private static final String SQL_COUNT_STUDENTS =
            "SELECT COUNT(*) FROM users WHERE role = 'student'";

    private static final String SQL_COUNT_DIFF_VOTES =
            "SELECT COUNT(*) FROM difficulty_votes";

    private static final String SQL_COUNT_USEFUL_MARKS =
            "SELECT COUNT(*) FROM votes";

    // ── Global difficulty distribution ──────────────────────────────────────
    private static final String SQL_GLOBAL_DIFFICULTY =
            "SELECT " +
            "  COUNT(*) FILTER (WHERE difficulty_level = 'easy')   AS easy_count, " +
            "  COUNT(*) FILTER (WHERE difficulty_level = 'medium') AS medium_count, " +
            "  COUNT(*) FILTER (WHERE difficulty_level = 'hard')   AS hard_count " +
            "FROM difficulty_votes";

    // ── Papers by subject code ───────────────────────────────────────────────
    private static final String SQL_PAPERS_BY_SUBJECT =
            "SELECT p.subject_code, " +
            "       COUNT(DISTINCT p.paper_id) AS paper_count, " +
            "       COALESCE(SUM(v_counts.useful), 0) AS total_useful, " +
            "       COALESCE(d_counts.easy_c, 0)   AS easy_c, " +
            "       COALESCE(d_counts.medium_c, 0) AS medium_c, " +
            "       COALESCE(d_counts.hard_c, 0)   AS hard_c " +
            "FROM papers p " +
            "LEFT JOIN ( " +
            "    SELECT paper_id, COUNT(*) AS useful " +
            "    FROM votes GROUP BY paper_id " +
            ") v_counts ON v_counts.paper_id = p.paper_id " +
            "LEFT JOIN ( " +
            "    SELECT paper_id, " +
            "           COUNT(*) FILTER (WHERE difficulty_level = 'easy')   AS easy_c, " +
            "           COUNT(*) FILTER (WHERE difficulty_level = 'medium') AS medium_c, " +
            "           COUNT(*) FILTER (WHERE difficulty_level = 'hard')   AS hard_c " +
            "    FROM difficulty_votes GROUP BY paper_id " +
            ") d_counts ON d_counts.paper_id = p.paper_id " +
            "GROUP BY p.subject_code, d_counts.easy_c, d_counts.medium_c, d_counts.hard_c " +
            "ORDER BY paper_count DESC";

    // ── Most popular papers (top 5) ──────────────────────────────────────────
    private static final String SQL_TOP_PAPERS =
            "SELECT p.paper_id, p.subject_name, p.subject_code, p.year, " +
            "       COUNT(v.id) AS useful_count " +
            "FROM papers p " +
            "LEFT JOIN votes v ON v.paper_id = p.paper_id " +
            "GROUP BY p.paper_id, p.subject_name, p.subject_code, p.year " +
            "ORDER BY useful_count DESC " +
            "LIMIT 5";

    // ── Monthly upload activity ──────────────────────────────────────────────
    private static final String SQL_MONTHLY_UPLOADS =
            "SELECT TO_CHAR(created_at, 'YYYY-MM') AS month_key, " +
            "       TO_CHAR(created_at, 'Mon YYYY') AS month_label, " +
            "       COUNT(*) AS upload_count " +
            "FROM papers " +
            "WHERE created_at IS NOT NULL " +
            "GROUP BY month_key, month_label " +
            "ORDER BY month_key DESC " +
            "LIMIT 12";

    // ────────────────────────────────────────────────────────────────────────

    private DataSource dataSource;

    private DataSource getDataSource() {
        if (dataSource == null) {
            try {
                Context ctx = new InitialContext();
                dataSource = (DataSource) ctx.lookup(JNDI_DATASOURCE);
            } catch (NamingException e) {
                LOGGER.log(Level.SEVERE, "JNDI lookup failed: " + JNDI_DATASOURCE, e);
                throw new RuntimeException("DataSource lookup failed.", e);
            }
        }
        return dataSource;
    }

    /** Returns [totalPapers, totalStudents, totalDiffVotes, totalUsefulMarks]. */
    public int[] getSummaryCounts() {
        int[] counts = new int[4];
        String[] sqls = {SQL_COUNT_PAPERS, SQL_COUNT_STUDENTS, SQL_COUNT_DIFF_VOTES, SQL_COUNT_USEFUL_MARKS};
        try (Connection conn = getDataSource().getConnection()) {
            for (int i = 0; i < sqls.length; i++) {
                try (PreparedStatement ps = conn.prepareStatement(sqls[i]);
                     ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) counts[i] = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching summary counts.", e);
        }
        return counts;
    }

    /** Returns int[3]: [easyCount, mediumCount, hardCount] across all papers. */
    public int[] getGlobalDifficultyStats() {
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_GLOBAL_DIFFICULTY);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return new int[]{rs.getInt("easy_count"), rs.getInt("medium_count"), rs.getInt("hard_count")};
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching global difficulty stats.", e);
        }
        return new int[]{0, 0, 0};
    }

    /**
     * Returns list of maps, each with keys:
     * subjectCode, paperCount, totalUseful, easyCount, mediumCount, hardCount, dominantDiff
     */
    public List<Map<String, Object>> getPapersBySubjectCode() {
        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_PAPERS_BY_SUBJECT);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("subjectCode",  rs.getString("subject_code"));
                row.put("paperCount",   rs.getInt("paper_count"));
                row.put("totalUseful",  rs.getInt("total_useful"));
                int e = rs.getInt("easy_c"), m = rs.getInt("medium_c"), h = rs.getInt("hard_c");
                row.put("easyCount",    e);
                row.put("mediumCount",  m);
                row.put("hardCount",    h);
                String dom = "Not Rated";
                if (e > 0 || m > 0 || h > 0) {
                    if (e >= m && e >= h)      dom = "Easy";
                    else if (m >= e && m >= h) dom = "Medium";
                    else                        dom = "Hard";
                }
                row.put("dominantDiff", dom);
                rows.add(row);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching papers by subject code.", e);
        }
        return rows;
    }

    /**
     * Returns top 5 most popular papers.
     * Each map has: paperId, subjectName, subjectCode, year, usefulCount
     */
    public List<Map<String, Object>> getTopPapers() {
        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_TOP_PAPERS);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("paperId",      rs.getInt("paper_id"));
                row.put("subjectName",  rs.getString("subject_name"));
                row.put("subjectCode",  rs.getString("subject_code"));
                row.put("year",         rs.getInt("year"));
                row.put("usefulCount",  rs.getInt("useful_count"));
                rows.add(row);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching top papers.", e);
        }
        return rows;
    }

    /**
     * Returns monthly upload activity (last 12 months, newest first).
     * Each map has: monthLabel, uploadCount
     */
    public List<Map<String, Object>> getMonthlyUploads() {
        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection conn = getDataSource().getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_MONTHLY_UPLOADS);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("monthLabel",   rs.getString("month_label"));
                row.put("uploadCount",  rs.getInt("upload_count"));
                rows.add(row);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching monthly uploads.", e);
        }
        return rows;
    }
}
