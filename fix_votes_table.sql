-- ============================================================================
-- Fix Votes Table Structure
-- ============================================================================
-- Run this script to fix the votes table structure
-- ============================================================================

-- Connect to the database
\c paperwise_db

-- Check if rating column exists and drop it
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'votes' 
        AND column_name = 'rating'
    ) THEN
        ALTER TABLE votes DROP COLUMN rating;
        RAISE NOTICE 'Dropped rating column from votes table';
    ELSE
        RAISE NOTICE 'Rating column does not exist in votes table';
    END IF;
END $$;

-- Verify votes table structure
\d votes

-- Expected structure:
-- Column     | Type      | Nullable | Default
-- -----------+-----------+----------+-----------------------------------
-- vote_id    | integer   | not null | nextval('votes_vote_id_seq'::regclass)
-- paper_id   | integer   | not null |
-- user_id    | integer   | not null |
-- created_at | timestamp |          | CURRENT_TIMESTAMP
--
-- Indexes:
--   "votes_pkey" PRIMARY KEY, btree (vote_id)
--   "unique_vote" UNIQUE CONSTRAINT, btree (paper_id, user_id)
--   "idx_votes_paper_id" btree (paper_id)
--   "idx_votes_user_id" btree (user_id)
--
-- Foreign-key constraints:
--   "fk_vote_paper" FOREIGN KEY (paper_id) REFERENCES papers(paper_id) ON DELETE CASCADE
--   "fk_vote_user" FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE

-- Test queries
SELECT COUNT(*) as total_votes FROM votes;

-- Check for any duplicate votes (should return 0 rows)
SELECT paper_id, user_id, COUNT(*) as vote_count
FROM votes
GROUP BY paper_id, user_id
HAVING COUNT(*) > 1;

-- If duplicates exist, remove them (keep only the first vote)
DELETE FROM votes a USING votes b
WHERE a.vote_id > b.vote_id 
AND a.paper_id = b.paper_id 
AND a.user_id = b.user_id;

-- Verify UNIQUE constraint exists
SELECT conname, contype, conkey
FROM pg_constraint
WHERE conrelid = 'votes'::regclass
AND contype = 'u';

-- If UNIQUE constraint doesn't exist, add it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conrelid = 'votes'::regclass 
        AND contype = 'u'
        AND conname = 'unique_vote'
    ) THEN
        ALTER TABLE votes ADD CONSTRAINT unique_vote UNIQUE (paper_id, user_id);
        RAISE NOTICE 'Added UNIQUE constraint on (paper_id, user_id)';
    ELSE
        RAISE NOTICE 'UNIQUE constraint already exists';
    END IF;
END $$;

-- Final verification
SELECT 
    'votes' as table_name,
    COUNT(*) as total_votes,
    COUNT(DISTINCT paper_id) as unique_papers,
    COUNT(DISTINCT user_id) as unique_users
FROM votes;

RAISE NOTICE 'Votes table structure fixed successfully!';
