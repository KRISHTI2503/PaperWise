-- ============================================================================
-- Diagnostic Script for Marked Papers Issue
-- ============================================================================
-- Run this script to diagnose why marked papers are not displaying
-- ============================================================================

\c paperwise_db

-- ============================================================================
-- 1. Verify votes table structure
-- ============================================================================
\echo '=== VOTES TABLE STRUCTURE ==='
\d votes

-- Expected columns:
-- id (SERIAL PRIMARY KEY)
-- paper_id (INTEGER NOT NULL)
-- user_id (INTEGER NOT NULL)
-- created_at (TIMESTAMP DEFAULT CURRENT_TIMESTAMP)

-- ============================================================================
-- 2. Check if any votes exist
-- ============================================================================
\echo ''
\echo '=== TOTAL VOTES COUNT ==='
SELECT COUNT(*) as total_votes FROM votes;

-- ============================================================================
-- 3. Check votes by user
-- ============================================================================
\echo ''
\echo '=== VOTES BY USER ==='
SELECT 
    u.username,
    u.user_id,
    COUNT(v.id) as vote_count
FROM users u
LEFT JOIN votes v ON u.user_id = v.user_id
GROUP BY u.user_id, u.username
ORDER BY vote_count DESC;

-- ============================================================================
-- 4. Check specific user's votes (replace 'student' with actual username)
-- ============================================================================
\echo ''
\echo '=== VOTES FOR STUDENT USER ==='
SELECT 
    v.id as vote_id,
    v.paper_id,
    v.user_id,
    v.created_at as marked_at,
    p.subject_name,
    p.subject_code,
    u.username
FROM votes v
JOIN papers p ON v.paper_id = p.paper_id
JOIN users u ON v.user_id = u.user_id
WHERE u.username = 'student'
ORDER BY v.created_at DESC;

-- ============================================================================
-- 5. Test the marked papers query
-- ============================================================================
\echo ''
\echo '=== TEST MARKED PAPERS QUERY ==='
-- Replace ? with actual user_id (e.g., 2 for student)
SELECT p.*, 
       COUNT(DISTINCT v.id) AS useful_count, 
       COUNT(*) FILTER (WHERE d.difficulty_level = 'easy') AS easy_count, 
       COUNT(*) FILTER (WHERE d.difficulty_level = 'medium') AS medium_count, 
       COUNT(*) FILTER (WHERE d.difficulty_level = 'hard') AS hard_count, 
       u.username, 
       m.created_at AS marked_at 
FROM papers p 
JOIN votes m ON p.paper_id = m.paper_id 
LEFT JOIN users u ON p.uploaded_by = u.user_id 
LEFT JOIN votes v ON p.paper_id = v.paper_id 
LEFT JOIN difficulty_votes d ON p.paper_id = d.paper_id 
WHERE m.user_id = (SELECT user_id FROM users WHERE username = 'student')
GROUP BY p.paper_id, u.username, m.created_at 
ORDER BY m.created_at DESC;

-- ============================================================================
-- 6. Check for orphaned votes (votes with invalid paper_id or user_id)
-- ============================================================================
\echo ''
\echo '=== ORPHANED VOTES CHECK ==='
SELECT 
    v.id,
    v.paper_id,
    v.user_id,
    CASE 
        WHEN p.paper_id IS NULL THEN 'Invalid paper_id'
        WHEN u.user_id IS NULL THEN 'Invalid user_id'
        ELSE 'Valid'
    END as status
FROM votes v
LEFT JOIN papers p ON v.paper_id = p.paper_id
LEFT JOIN users u ON v.user_id = u.user_id
WHERE p.paper_id IS NULL OR u.user_id IS NULL;

-- Expected: 0 rows (no orphaned votes)

-- ============================================================================
-- 7. Check papers table
-- ============================================================================
\echo ''
\echo '=== PAPERS COUNT ==='
SELECT COUNT(*) as total_papers FROM papers;

-- ============================================================================
-- 8. Check users table
-- ============================================================================
\echo ''
\echo '=== USERS ==='
SELECT user_id, username, role FROM users ORDER BY user_id;

-- ============================================================================
-- 9. Verify indexes exist
-- ============================================================================
\echo ''
\echo '=== VOTES TABLE INDEXES ==='
SELECT 
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'votes';

-- Expected indexes:
-- votes_pkey (PRIMARY KEY on id)
-- idx_votes_paper_id
-- idx_votes_user_id
-- unique_vote (UNIQUE constraint on paper_id, user_id)

-- ============================================================================
-- 10. Check constraints
-- ============================================================================
\echo ''
\echo '=== VOTES TABLE CONSTRAINTS ==='
SELECT
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint
WHERE conrelid = 'votes'::regclass;

-- ============================================================================
-- DIAGNOSTIC SUMMARY
-- ============================================================================
\echo ''
\echo '=== DIAGNOSTIC SUMMARY ==='
\echo 'If marked papers are not showing:'
\echo '1. Check if votes exist for the user (section 4)'
\echo '2. Verify user_id matches between users table and votes table'
\echo '3. Check if papers exist (section 7)'
\echo '4. Test the marked papers query (section 5)'
\echo '5. Look for orphaned votes (section 6)'
\echo ''
\echo 'Common issues:'
\echo '- No votes inserted (check section 2 and 4)'
\echo '- Wrong user_id used in query'
\echo '- Session attribute name mismatch (user vs loggedInUser)'
\echo '- Papers deleted but votes remain (orphaned votes)'

-- ============================================================================
-- MANUAL TEST: Insert a test vote
-- ============================================================================
\echo ''
\echo '=== MANUAL TEST: Insert Test Vote ==='
\echo 'To manually insert a test vote, run:'
\echo 'INSERT INTO votes (paper_id, user_id) VALUES (1, 2);'
\echo '(Replace 1 with valid paper_id, 2 with valid user_id)'
\echo ''
\echo 'Then check if it appears in marked papers query (section 5)'
