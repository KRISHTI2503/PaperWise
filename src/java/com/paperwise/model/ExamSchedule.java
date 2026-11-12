package com.paperwise.model;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class ExamSchedule {

    private int id;
    private String subjectCode;
    private String subjectName;
    private String examType;
    private LocalDate examDate;
    private String createdBy;

    private static final DateTimeFormatter DISPLAY_FMT =
            DateTimeFormatter.ofPattern("MMM dd, yyyy");

    public ExamSchedule() {}

    public int getId()                          { return id; }
    public void setId(int id)                   { this.id = id; }

    public String getSubjectCode()              { return subjectCode; }
    public void setSubjectCode(String s)        { this.subjectCode = s; }

    public String getSubjectName()              { return subjectName; }
    public void setSubjectName(String s)        { this.subjectName = s; }

    public String getExamType()                 { return examType; }
    public void setExamType(String s)           { this.examType = s; }

    public LocalDate getExamDate()              { return examDate; }
    public void setExamDate(LocalDate d)        { this.examDate = d; }

    public String getCreatedBy()                { return createdBy; }
    public void setCreatedBy(String s)          { this.createdBy = s; }

    /** Human-readable date for display in JSP, e.g. "Jun 20, 2026". */
    public String getExamDateFormatted() {
        return examDate != null ? examDate.format(DISPLAY_FMT) : "";
    }

    /** ISO date string yyyy-MM-dd for use in date inputs. */
    public String getExamDateIso() {
        return examDate != null ? examDate.toString() : "";
    }
}
