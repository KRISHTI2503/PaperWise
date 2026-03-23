package com.paperwise.model;

public class DifficultyStats {

    private int easyCount;
    private int mediumCount;
    private int hardCount;

    public DifficultyStats() {
        this.easyCount = 0;
        this.mediumCount = 0;
        this.hardCount = 0;
    }

    public DifficultyStats(int easyCount, int mediumCount, int hardCount) {
        this.easyCount = easyCount;
        this.mediumCount = mediumCount;
        this.hardCount = hardCount;
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

    public int getTotalVotes() {
        return easyCount + mediumCount + hardCount;
    }

    public String getDifficultyLabel() {
        if (easyCount == 0 && mediumCount == 0 && hardCount == 0) {
            return "NOT RATED";
        }

        if (easyCount > mediumCount && easyCount > hardCount) {
            return "EASY";
        }

        if (mediumCount > easyCount && mediumCount > hardCount) {
            return "MEDIUM";
        }

        if (hardCount > easyCount && hardCount > mediumCount) {
            return "HARD";
        }

        return "MIXED";
    }

    @Override
    public String toString() {
        return "DifficultyStats{" +
                "easy=" + easyCount +
                ", medium=" + mediumCount +
                ", hard=" + hardCount +
                ", total=" + getTotalVotes() +
                ", label='" + getDifficultyLabel() + '\'' +
                '}';
    }
}