-- ============================================================================
-- Difficulty Voting Logic Verification Script
-- ============================================================================
-- Run this script to verify the difficulty voting logic is working correctly
-- ============================================================================

\c paperwise_db

-- ============================================================================
-- 1. Check UNIQUE Constraint Exists
-- ============================================================================
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'difficulty_votes' 
AND constraint_type = 'UNIQUE';

-- Expected: unique_difficulty_vote

-- ============================================================================
-- 2. Check for Duplicate Votes (Should be 0)
-- ============================================================================
SELECT paper_id, user_id, COUNT(*) as vote_count
FROM difficulty_votes 
GROUP BY paper_id, user_id 
HAVING COUNT(*) > 1;

-- Expected: 0 rows (no duplicates)

-- ============================================================================
-- 3. View Current Difficulty Votes
-- ============================================================================
SELECT 
    dv.id,
    dv.paper_id,
    p.subject_name,
    dv.user_id,
    u.username,
    dv.difficulty_level,
    dv.created_at,
    dv.updated_at
FROM difficulty_votes dv
JOIN papers p ON dv.paper_id = p.paper_id
JOIN users u ON dv.user_id = u.user_id
ORDER BY dv.paper_id, dv.user_id;

-- ============================================================================
-- 4. Verify Counts Per Paper
-- ============================================================================
SELECT 
    p.paper_id,
    p.subject_name,
    COUNT(CASE WHEN dv.difficulty_level = 'easy' THEN 1 END) AS easy_count,
    COUNT(CASE WHEN dv.difficulty_level = 'medium' THEN 1 END) AS medium_count,
    COUNT(CASE WHEN dv.difficulty_level = 'hard' THEN 1 END) AS hard_count,
    COUNT(*) AS total_votes
FROM papers p
LEFT JOIN difficulty_votes dv ON p.paper_id = dv.paper_id
GROUP BY p.paper_id, p.subject_name
ORDER BY p.paper_id;

-- ============================================================================
-- 5. Test UPSERT Logic
-- ============================================================================
-- Clean up test data first
DELETE FROM difficulty_votes WHERE paper_id = 999 AND user_id = 999;

-- Test 1: Insert new vote
INSERT INTO difficulty_votes (paper_id, user_id, difficulty_level) 
VALUES (999, 999, 'easy')
ON CONFLICT (paper_id, user_id) 
DO UPDATE SET difficulty_level = EXCLUDED.difficulty_level;

-- Check: Should have 1 row
SELECT * FROM difficulty_votes WHERE paper_id = 999 AND user_id = 999;
-- Expected: 1 row with difficulty_level = 'easy'

-- Test 2: Update existing vote
INSERT INTO difficulty_votes (paper_id, user_id, difficulty_level) 
VALUES (999, 999, 'hard')
ON CONFLICT (paper_id, user_id) 
DO UPDATE SET difficulty_level = EXCLUDED.difficulty_level;

-- Check: Should still have 1 row, but updated
SELECT * FROM difficulty_votes WHERE paper_id = 999 AND user_id = 999;
-- Expected: 1 row with difficulty_level = 'hard'

-- Verify count
SELECT COUNT(*) FROM difficulty_votes WHERE paper_id = 999 AND user_id = 999;
-- Expected: 1 (not 2!)

-- Clean up test data
DELETE FROM difficulty_votes WHERE paper_id = 999 AND user_id = 999;

-- ============================================================================
-- 6. Check Difficulty Level Values
-- ============================================================================
SELECT DISTINCT difficulty_level 
FROM difficulty_votes 
ORDER BY difficulty_level;

-- Expected: easy, hard, medium (all lowercase)

-- ============================================================================
-- 7. Verify CHECK Constraint
-- ============================================================================
SELECT constraint_name, check_clause 
FROM information_schema.check_constraints 
WHERE constraint_name = 'difficulty_votes_difficulty_level_check';

-- Expected: (difficulty_level IN ('easy', 'medium', 'hard'))

-- ============================================================================
-- 8. Test Invalid Insert (Should Fail)
-- ============================================================================
-- This should fail with CHECK constraint violation
-- INSERT INTO difficulty_votes (paper_id, user_id, difficulty_level) 
-- VALUES (1, 1, 'veryhard');
-- Expected: ERROR: new row violates check constraint

-- ============================================================================
-- 9. Summary Report
-- ============================================================================
SELECT 
    'Total Papers' AS metric,
    COUNT(DISTINCT paper_id) AS value
FROM difficulty_votes
UNION ALL
SELECT 
    'Total Votes' AS metric,
    COUNT(*) AS value
FROM difficulty_votes
UNION ALL
SELECT 
    'Unique Voters' AS metric,
    COUNT(DISTINCT user_id) AS value
FROM difficulty_votes
UNION ALL
SELECT 
    'Easy Votes' AS metric,
    COUNT(*) AS value
FROM difficulty_votes
WHERE difficulty_level = 'easy'
UNION ALL
SELECT 
    'Medium Votes' AS metric,
    COUNT(*) AS value
FROM difficulty_votes
WHERE difficulty_level = 'medium'
UNION ALL
SELECT 
    'Hard Votes' AS metric,
    COUNT(*) AS value
FROM difficulty_votes
WHERE difficulty_level = 'hard';

-- ============================================================================
-- 10. Check for Orphaned Votes
-- ============================================================================
-- Votes for non-existent papers
SELECT dv.* 
FROM difficulty_votes dv
LEFT JOIN papers p ON dv.paper_id = p.paper_id
WHERE p.paper_id IS NULL;

-- Expected: 0 rows

-- Votes from non-existent users
SELECT dv.* 
FROM difficulty_votes dv
LEFT JOIN users u ON dv.user_id = u.user_id
WHERE u.user_id IS NULL;

-- Expected: 0 rows

-- ============================================================================
-- Verification Complete
-- ============================================================================
\echo 'Verification complete! Review results above.'
\echo 'Key checks:'
\echo '  1. UNIQUE constraint exists'
\echo '  2. No duplicate votes'
\echo '  3. UPSERT works correctly'
\echo '  4. All values are lowercase'
\echo '  5. CHECK constraint enforced'
