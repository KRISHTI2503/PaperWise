-- ============================================================
-- PaperWise — Migration: Add description column + comments table
-- Run this in pgAdmin (postgres / password) against the paperwise DB
-- ============================================================

-- STEP 1: Add description column to papers table (safe — skips if already exists)
ALTER TABLE papers ADD COLUMN IF NOT EXISTS description TEXT;

-- STEP 2: Create paper_comments table (safe — skips if already exists)
CREATE TABLE IF NOT EXISTS paper_comments (
    id           SERIAL PRIMARY KEY,
    paper_id     INTEGER NOT NULL REFERENCES papers(paper_id) ON DELETE CASCADE,
    username     VARCHAR(100) NOT NULL,
    comment_text TEXT NOT NULL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Optional: index for fast lookup by paper
CREATE INDEX IF NOT EXISTS idx_paper_comments_paper_id ON paper_comments(paper_id);
