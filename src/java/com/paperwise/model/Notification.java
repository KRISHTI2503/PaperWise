package com.paperwise.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

public class Notification {

    private int id;
    private int userId;
    private String message;
    private String link;
    private boolean read;
    private LocalDateTime createdAt;

    private static final DateTimeFormatter DISPLAY_FMT =
            DateTimeFormatter.ofPattern("MMM dd, HH:mm");

    public Notification() {}

    public int getId()                          { return id; }
    public void setId(int id)                   { this.id = id; }

    public int getUserId()                      { return userId; }
    public void setUserId(int userId)           { this.userId = userId; }

    public String getMessage()                  { return message; }
    public void setMessage(String message)      { this.message = message; }

    public String getLink()                     { return link; }
    public void setLink(String link)            { this.link = link; }

    public boolean isRead()                     { return read; }
    public void setRead(boolean read)           { this.read = read; }

    public LocalDateTime getCreatedAt()         { return createdAt; }
    public void setCreatedAt(LocalDateTime t)   { this.createdAt = t; }

    /** Human-readable time for display, e.g. "Jun 13, 14:32" */
    public String getCreatedAtFormatted() {
        if (createdAt == null) return "";
        return createdAt.format(DISPLAY_FMT);
    }

    /** Relative time label, e.g. "2 min ago", "3 hrs ago", "Yesterday" */
    public String getRelativeTime() {
        if (createdAt == null) return "";
        LocalDateTime now = LocalDateTime.now();
        long minutes = ChronoUnit.MINUTES.between(createdAt, now);
        if (minutes < 1)   return "Just now";
        if (minutes < 60)  return minutes + " min ago";
        long hours = ChronoUnit.HOURS.between(createdAt, now);
        if (hours < 24)    return hours + " hr" + (hours == 1 ? "" : "s") + " ago";
        long days = ChronoUnit.DAYS.between(createdAt, now);
        if (days == 1)     return "Yesterday";
        if (days < 7)      return days + " days ago";
        return createdAt.format(DISPLAY_FMT);
    }
}
