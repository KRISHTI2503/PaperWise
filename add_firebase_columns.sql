-- ============================================================================
-- Add Firebase Authentication Columns to users table
-- ============================================================================
-- This migration adds support for Google Sign-In via Firebase
-- while preserving all existing email/password users
-- ============================================================================

-- Connect to the paperwise database
\c paperwise

-- Add firebase_uid column (can be NULL for local email/password users)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS firebase_uid VARCHAR(128);

-- Add auth_provider column (default 'local' for existing users)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS auth_provider VARCHAR(20) DEFAULT 'local';

-- Update existing users to explicitly set auth_provider = 'local'
UPDATE users 
SET auth_provider = 'local' 
WHERE auth_provider IS NULL;

-- Add index on firebase_uid for fast lookup (Google Sign-In users)
CREATE INDEX IF NOT EXISTS idx_users_firebase_uid 
ON users(firebase_uid) 
WHERE firebase_uid IS NOT NULL;

-- Add unique constraint on firebase_uid (each Firebase user can only have one PaperWise account)
-- Using a partial unique index to allow multiple NULL values
CREATE UNIQUE INDEX IF NOT EXISTS unique_firebase_uid 
ON users(firebase_uid) 
WHERE firebase_uid IS NOT NULL;

-- Add index on auth_provider for filtering by authentication method
CREATE INDEX IF NOT EXISTS idx_users_auth_provider 
ON users(auth_provider);

-- Verify the changes
SELECT 
    column_name, 
    data_type, 
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
  AND column_name IN ('firebase_uid', 'auth_provider')
ORDER BY ordinal_position;

-- Show sample data
SELECT 
    user_id,
    username,
    email,
    role,
    firebase_uid,
    auth_provider,
    created_at
FROM users 
LIMIT 5;

-- ============================================================================
-- Migration complete!
-- ============================================================================
-- Existing users: firebase_uid=NULL, auth_provider='local'
-- Future Google users: firebase_uid='xxx', auth_provider='google'
-- ============================================================================
