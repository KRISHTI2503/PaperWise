-- ============================================================================
-- Fix difficulty_votes CHECK constraint to use lowercase
-- ============================================================================
-- This script updates the CHECK constraint to accept lowercase values
-- Run this script to fix the constraint violation error
-- ============================================================================

-- Connect to paperwise_db database
\c paperwise_db

-- Drop the existing CHECK constraint
ALTER TABLE difficulty_votes 
DROP CONSTRAINT IF EXISTS difficulty_votes_difficulty_level_check;

-- Add new CHECK constraint with lowercase values
ALTER TABLE difficulty_votes 
ADD CONSTRAINT difficulty_votes_difficulty_level_check 
CHECK (difficulty_level IN ('easy', 'medium', 'hard'));

-- Verify the constraint
\d difficulty_votes

-- Test query
SELECT constraint_name, check_clause 
FROM information_schema.check_constraints 
WHERE constraint_name = 'difficulty_votes_difficulty_level_check';

PRINT 'CHECK constraint updated successfully to accept lowercase values: easy, medium, hard';
