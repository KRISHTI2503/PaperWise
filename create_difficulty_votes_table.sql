-- ============================================================================
-- Create difficulty_votes table for PaperWise
-- ============================================================================
-- This table stores difficulty ratings for papers voted by students
-- Uses PostgreSQL UNIQUE constraint to prevent duplicate votes
-- Supports UPSERT operations with ON CONFLICT
-- ============================================================================

-- Connect to paperwise_db database first
\c paperwise_db

-- Create difficulty_votes table
CREATE TABLE IF NOT EXISTS difficulty_votes (
    id SERIAL PRIMARY KEY,
    paper_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    difficulty_level VARCHAR(20) NOT NULL CHECK (difficulty_level IN ('Easy', 'Medium', 'Hard')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_difficulty_paper FOREIGN KEY (paper_id) 
        REFERENCES papers(paper_id) ON DELETE CASCADE,
    CONSTRAINT fk_difficulty_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE,
    
    -- Unique constraint: one vote per user per paper
    CONSTRAINT unique_difficulty_vote UNIQUE (paper_id, user_id)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_difficulty_votes_paper_id ON difficulty_votes(paper_id);
CREATE INDEX IF NOT EXISTS idx_difficulty_votes_user_id ON difficulty_votes(user_id);
CREATE INDEX IF NOT EXISTS idx_difficulty_votes_level ON difficulty_votes(difficulty_level);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_difficulty_votes_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_difficulty_votes_timestamp
    BEFORE UPDATE ON difficulty_votes
    FOR EACH ROW
    EXECUTE FUNCTION update_difficulty_votes_timestamp();

-- Display table structure
\d difficulty_votes

-- Test query: Get difficulty stats for a paper
-- SELECT difficulty_level, COUNT(*) as count 
-- FROM difficulty_votes 
-- WHERE paper_id = 1 
-- GROUP BY difficulty_level;

-- ============================================================================
-- Notes:
-- ============================================================================
-- 1. UNIQUE constraint (paper_id, user_id) prevents duplicate votes
-- 2. CHECK constraint ensures only 'Easy', 'Medium', 'Hard' values
-- 3. ON CONFLICT in DAO allows UPSERT (insert or update)
-- 4. Cascade delete removes votes when paper or user is deleted
-- 5. Indexes improve query performance for stats and lookups
-- ============================================================================
