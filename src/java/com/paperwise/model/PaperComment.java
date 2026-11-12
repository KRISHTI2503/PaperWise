package com.paperwise.model;

import java.util.ArrayList;
import java.util.List;

public class PaperComment {
    private int commentId;
    private int paperId;
    private int userId;
    private String username;
    private String userRole;   // role of the comment author: "admin" or "student"
    private String commentText;
    private String createdAt;
    private Integer parentCommentId;
    private List<PaperComment> replies = new ArrayList<>();

    public int getCommentId() {
        return commentId;
    }

    public void setCommentId(int commentId) {
        this.commentId = commentId;
    }

    public int getPaperId() {
        return paperId;
    }

    public void setPaperId(int paperId) {
        this.paperId = paperId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getUserRole() {
        return userRole;
    }

    public void setUserRole(String userRole) {
        this.userRole = userRole;
    }

    public String getCommentText() {
        return commentText;
    }

    public void setCommentText(String commentText) {
        this.commentText = commentText;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public Integer getParentCommentId() {
        return parentCommentId;
    }

    public void setParentCommentId(Integer parentCommentId) {
        this.parentCommentId = parentCommentId;
    }

    public List<PaperComment> getReplies() {
        return replies;
    }

    public void setReplies(List<PaperComment> replies) {
        this.replies = replies;
    }
}
