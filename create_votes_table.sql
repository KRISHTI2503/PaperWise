-- ============================================================================
-- Create Votes Table for PaperWise
-- ============================================================================
-- Run this script if you already have the database set up
-- and need to add the votes table
-- ============================================================================

-- Connect to the database
\c paperwise_db

-- ============================================================================
-- Create votes table
-- ============================================================================
CREATE TABLE IF NOT EXISTS votes (
    id SERIAL PRIMARY KEY,
    paper_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vote_paper FOREIGN KEY (paper_id) 
        REFERENCES papers(paper_id) ON DELETE CASCADE,
    CONSTRAINT fk_vote_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT unique_vote UNIQUE (paper_id, user_id)
);

-- Create indexes for votes table for better query performance
CREATE INDEX IF NOT EXISTS idx_votes_paper_id ON votes(paper_id);
CREATE INDEX IF NOT EXISTS idx_votes_user_id ON votes(user_id);

-- ============================================================================
-- Verify table creation
-- ============================================================================
\d votes

-- Test query
SELECT COUNT(*) as vote_count FROM votes;

-- ============================================================================
-- Notes
-- ============================================================================
-- The UNIQUE constraint on (paper_id, user_id) ensures:
-- - Each user can only vote once per paper
-- - Prevents duplicate votes at database level
-- 
-- The CASCADE on foreign keys ensures:
-- - If a paper is deleted, all its votes are deleted
-- - If a user is deleted, all their votes are deleted
