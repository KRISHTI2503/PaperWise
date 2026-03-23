package com.paperwise.model;

import java.time.LocalDateTime;

public class Paper {

    public static final int POPULAR_THRESHOLD = 3;

    private int paperId;
    private String subjectName;
    private String subjectCode;
    private int year;
    private String chapter;
    private String fileUrl;
    private int uploadedBy;
    private LocalDateTime createdAt;
    private String uploaderUsername;
    private int voteCount;
    private int usefulCount;
    private boolean alreadyMarked;
    private int easyCount;
    private int mediumCount;
    private int hardCount;
    private String difficultyLabel;

    public Paper() {}

    public Paper(String subjectName, String subjectCode, int year,
                 String chapter, String fileUrl, int uploadedBy) {
        this.subjectName = subjectName;
        this.subjectCode = subjectCode;
        this.year = year;
        this.chapter = chapter;
        this.fileUrl = fileUrl;
        this.uploadedBy = uploadedBy;
    }

    public Paper(int paperId, String subjectName, String subjectCode, int year,
                 String chapter, String fileUrl, int uploadedBy, LocalDateTime createdAt) {
        this.paperId = paperId;
        this.subjectName = subjectName;
        this.subjectCode = subjectCode;
        this.year = year;
        this.chapter = chapter;
        this.fileUrl = fileUrl;
        this.uploadedBy = uploadedBy;
        this.createdAt = createdAt;
    }

    public int getPaperId() {
        return paperId;
    }

    public void setPaperId(int paperId) {
        this.paperId = paperId;
    }

    public String getSubjectName() {
        return subjectName;
    }

    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }

    public String getSubjectCode() {
        return subjectCode;
    }

    public void setSubjectCode(String subjectCode) {
        this.subjectCode = subjectCode;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public String getChapter() {
        return chapter;
    }

    public void setChapter(String chapter) {
        this.chapter = chapter;
    }

    public String getFileUrl() {
        return fileUrl;
    }

    public void setFileUrl(String fileUrl) {
        this.fileUrl = fileUrl;
    }

    public int getUploadedBy() {
        return uploadedBy;
    }

    public void setUploadedBy(int uploadedBy) {
        this.uploadedBy = uploadedBy;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getUploaderUsername() {
        return uploaderUsername;
    }

    public void setUploaderUsername(String uploaderUsername) {
        this.uploaderUsername = uploaderUsername;
    }

    public int getVoteCount() {
        return voteCount;
    }

    public void setVoteCount(int voteCount) {
        this.voteCount = voteCount;
    }

    public int getUsefulCount() {
        return usefulCount;
    }

    public void setUsefulCount(int usefulCount) {
        this.usefulCount = usefulCount;
    }

    public boolean isAlreadyMarked() {
        return alreadyMarked;
    }

    public void setAlreadyMarked(boolean alreadyMarked) {
        this.alreadyMarked = alreadyMarked;
    }

    public int getEasyCount() {
        return easyCount;
    }

    public void setEasyCount(int easyCount) {
        this.easyCount = easyCount;
    }

    public int getMediumCount() {
        return mediumCount;
    }

    public void setMediumCount(int mediumCount) {
        this.mediumCount = mediumCount;
    }

    public int getHardCount() {
        return hardCount;
    }

    public void setHardCount(int hardCount) {
        this.hardCount = hardCount;
    }

    public String getDifficultyLabel() {
        return difficultyLabel;
    }

    public void setDifficultyLabel(String difficultyLabel) {
        this.difficultyLabel = difficultyLabel;
    }

    public void calculateDifficulty() {
        if (easyCount == 0 && mediumCount == 0 && hardCount == 0) {
            difficultyLabel = "Not Rated";
            return;
        }

        if (easyCount > mediumCount && easyCount > hardCount) {
            difficultyLabel = "Easy";
            return;
        }

        if (mediumCount > easyCount && mediumCount > hardCount) {
            difficultyLabel = "Medium";
            return;
        }

        if (hardCount > easyCount && hardCount > mediumCount) {
            difficultyLabel = "Hard";
            return;
        }

        difficultyLabel = "Mixed";
    }

    public boolean isPopular() {
        return usefulCount >= POPULAR_THRESHOLD;
    }

    @Override
    public String toString() {
        return "Paper{" +
                "paperId=" + paperId +
                ", subjectName='" + subjectName + '\'' +
                ", subjectCode='" + subjectCode + '\'' +
                ", year=" + year +
                ", chapter='" + chapter + '\'' +
                ", fileUrl='" + fileUrl + '\'' +
                ", uploadedBy=" + uploadedBy +
                ", createdAt=" + createdAt +
                '}';
    }
}