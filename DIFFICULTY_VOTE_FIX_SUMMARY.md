# Difficulty Voting Logic Fix Summary

## Problem
Difficulty vote counts were sometimes increasing incorrectly (+2, +3) due to potential duplicate rows in the `difficulty_votes` table.

## Root Cause
- Missing or improperly enforced UNIQUE constraint on (paper_id, user_id)
- Potential duplicate votes in the database

## Solution Implemented

### 1. Database Constraint (REQUIRED)
Run the SQL script: `fix_difficulty_votes_duplicates.sql`

This script:
- Identifies existing duplicate votes
- Removes duplicates (keeps most recent)
- Adds UNIQUE constraint: `UNIQUE (paper_id, user_id)`
- Verifies the fix

### 2. UPSERT Logic (ALREADY CORRECT)
`DifficultyVoteDAO.java` already uses proper UPSERT:

```java
INSERT INTO difficulty_votes (paper_id, user_id, difficulty_level)
VALUES (?, ?, ?)
ON CONFLICT (paper_id, user_id)
DO UPDATE SET difficulty_level = EXCLUDED.difficulty_level
```

This ensures:
- First vote → INSERT
- Change vote → UPDATE (not duplicate)
- No duplicate rows possible

### 3. SQL Aggregation (OPTIMIZED)
`PaperDAO.java` now uses PostgreSQL FILTER clause:

```sql
COUNT(*) FILTER (WHERE d.difficulty_level = 'easy') AS easy_count,
COUNT(*) FILTER (WHERE d.difficulty_level = 'medium') AS medium_count,
COUNT(*) FILTER (WHERE d.difficulty_level = 'hard') AS hard_count
```

Benefits:
- More efficient than CASE WHEN
- Clearer intent
- PostgreSQL-optimized

### 4. No Manual Increment Logic
Verified: No Java code manually increments counts.
All counts come from SQL aggregation.

## Verification Steps

1. Run `fix_difficulty_votes_duplicates.sql` to clean data and add constraint
2. Restart application
3. Test voting:
   - Vote "Easy" on paper #1 → Count should be 1
   - Change to "Medium" on paper #1 → Easy=0, Medium=1
   - Vote "Easy" on paper #1 again → Easy=1, Medium=0
4. Check database:
   ```sql
   SELECT paper_id, user_id, COUNT(*)
   FROM difficulty_votes
   GROUP BY paper_id, user_id
   HAVING COUNT(*) > 1;
   ```
   Should return 0 rows (no duplicates)

## Files Modified

1. `src/java/com/paperwise/dao/PaperDAO.java`
   - Optimized SQL to use FILTER clause

2. `fix_difficulty_votes_duplicates.sql` (NEW)
   - Removes duplicates
   - Adds UNIQUE constraint
   - Verification queries

3. `verify_difficulty_unique_constraint.sql` (NEW)
   - Quick check for constraint existence

## Expected Behavior After Fix

- Each user can vote once per paper
- Changing vote updates existing record (no duplicate)
- Counts are always accurate
- No +2 or +3 increments
- Database enforces uniqueness at constraint level

## Technical Details

### UNIQUE Constraint
```sql
ALTER TABLE difficulty_votes
ADD CONSTRAINT difficulty_votes_paper_user_unique
UNIQUE (paper_id, user_id);
```

### UPSERT Behavior
- User votes "Easy" → INSERT (easy_count = 1)
- User changes to "Medium" → UPDATE (easy_count = 0, medium_count = 1)
- User changes to "Hard" → UPDATE (medium_count = 0, hard_count = 1)

### Aggregation
Always calculated fresh from database:
- No cached counts
- No manual increments
- SQL GROUP BY with FILTER
- Accurate real-time counts
