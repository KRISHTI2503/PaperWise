-- Verify UNIQUE constraint on difficulty_votes table
-- This script checks if the UNIQUE constraint exists and creates it if missing

-- Check if constraint exists
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'difficulty_votes'
  AND constraint_type = 'UNIQUE';

-- If the above returns no rows, run this to add the constraint:
-- First, remove any duplicate rows (keep the most recent)
DELETE FROM difficulty_votes a
USING difficulty_votes b
WHERE a.id < b.id
  AND a.paper_id = b.paper_id
  AND a.user_id = b.user_id;

-- Then add the UNIQUE constraint
ALTER TABLE difficulty_votes
ADD CONSTRAINT difficulty_votes_paper_user_unique
UNIQUE (paper_id, user_id);

-- Verify the constraint was added
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'difficulty_votes'
  AND constraint_type = 'UNIQUE';
