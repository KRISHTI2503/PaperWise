package com.paperwise.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Announcement {

    private int id;
    private String title;
    private String body;
    private int createdBy;
    private String creatorUsername;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
    private boolean pinned;

    private static final DateTimeFormatter DISPLAY_FMT =
            DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm");

    public Announcement() {}

    public int getId()                        { return id; }
    public void setId(int id)                 { this.id = id; }

    public String getTitle()                  { return title; }
    public void setTitle(String title)        { this.title = title; }

    public String getBody()                   { return body; }
    public void setBody(String body)          { this.body = body; }

    public int getCreatedBy()                 { return createdBy; }
    public void setCreatedBy(int createdBy)   { this.createdBy = createdBy; }

    public String getCreatorUsername()               { return creatorUsername; }
    public void setCreatorUsername(String u)         { this.creatorUsername = u; }

    public LocalDateTime getCreatedAt()              { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt){ this.createdAt = createdAt; }

    public LocalDateTime getExpiresAt()              { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt){ this.expiresAt = expiresAt; }

    public boolean isPinned()                { return pinned; }
    public void setPinned(boolean pinned)    { this.pinned = pinned; }

    /** Formatted created timestamp for display in JSP. */
    public String getCreatedAtFormatted() {
        return createdAt != null ? createdAt.format(DISPLAY_FMT) : "";
    }

    /** Formatted expiry timestamp, or "Never" if null. */
    public String getExpiresAtFormatted() {
        return expiresAt != null ? expiresAt.format(DISPLAY_FMT) : "Never";
    }

    /** ISO datetime string for HTML datetime-local input, e.g. "2026-12-31T23:59". */
    public String getExpiresAtIso() {
        if (expiresAt == null) return "";
        // HTML datetime-local format: yyyy-MM-ddTHH:mm
        return expiresAt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
    }
}
