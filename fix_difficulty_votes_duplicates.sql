-- Fix difficulty_votes table to prevent duplicate votes
-- This script removes duplicates and ensures UNIQUE constraint exists

-- Step 1: Check for existing duplicates
SELECT paper_id, user_id, COUNT(*) as duplicate_count
FROM difficulty_votes
GROUP BY paper_id, user_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Step 2: Remove duplicate rows (keep the most recent based on id)
-- This assumes 'id' is a SERIAL column where higher id = more recent
DELETE FROM difficulty_votes a
USING difficulty_votes b
WHERE a.id < b.id
  AND a.paper_id = b.paper_id
  AND a.user_id = b.user_id;

-- Step 3: Verify duplicates are removed
SELECT paper_id, user_id, COUNT(*) as duplicate_count
FROM difficulty_votes
GROUP BY paper_id, user_id
HAVING COUNT(*) > 1;
-- Should return 0 rows

-- Step 4: Check if UNIQUE constraint already exists
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'difficulty_votes'
  AND constraint_type = 'UNIQUE';

-- Step 5: Add UNIQUE constraint if it doesn't exist
-- If the above query returns no rows, run this:
ALTER TABLE difficulty_votes
DROP CONSTRAINT IF EXISTS difficulty_votes_paper_user_unique;

ALTER TABLE difficulty_votes
ADD CONSTRAINT difficulty_votes_paper_user_unique
UNIQUE (paper_id, user_id);

-- Step 6: Verify constraint was added successfully
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'difficulty_votes'
  AND constraint_type = 'UNIQUE';

-- Step 7: Test the constraint (should fail with duplicate key error)
-- Uncomment to test:
-- INSERT INTO difficulty_votes (paper_id, user_id, difficulty_level)
-- VALUES (1, 1, 'easy');
-- INSERT INTO difficulty_votes (paper_id, user_id, difficulty_level)
-- VALUES (1, 1, 'medium');
-- Expected: ERROR: duplicate key value violates unique constraint

-- Step 8: Verify vote counts are correct
SELECT 
    p.paper_id,
    p.subject_name,
    COUNT(*) FILTER (WHERE d.difficulty_level = 'easy') AS easy_count,
    COUNT(*) FILTER (WHERE d.difficulty_level = 'medium') AS medium_count,
    COUNT(*) FILTER (WHERE d.difficulty_level = 'hard') AS hard_count,
    COUNT(*) AS total_difficulty_votes
FROM papers p
LEFT JOIN difficulty_votes d ON p.paper_id = d.paper_id
GROUP BY p.paper_id, p.subject_name
ORDER BY p.paper_id;
