# Difficulty Voting Logic - Implementation Summary

## ✅ Status: CORRECTLY IMPLEMENTED

The difficulty voting logic is already correctly implemented with proper UPSERT and SQL aggregation.

## Implementation Overview

### 1. UPSERT Logic ✅

**Location:** `DifficultyVoteDAO.java`

```sql
INSERT INTO difficulty_votes (paper_id, user_id, difficulty_level) 
VALUES (?, ?, ?) 
ON CONFLICT (paper_id, user_id) 
DO UPDATE SET difficulty_level = EXCLUDED.difficulty_level
```

**Behavior:**
- First vote → INSERT
- Change vote → UPDATE (no duplicate)
- Guaranteed by UNIQUE constraint

### 2. SQL Aggregation ✅

**Location:** `PaperDAO.java`

```sql
COUNT(CASE WHEN d.difficulty_level = 'easy' THEN 1 END) AS easy_count,
COUNT(CASE WHEN d.difficulty_level = 'medium' THEN 1 END) AS medium_count,
COUNT(CASE WHEN d.difficulty_level = 'hard' THEN 1 END) AS hard_count
```

**Behavior:**
- Counts calculated by database
- No manual increment in Java
- Accurate real-time counts

### 3. Database Constraint ✅

```sql
CONSTRAINT unique_difficulty_vote UNIQUE (paper_id, user_id)
```

**Guarantees:**
- One vote per user per paper
- Database-level enforcement
- Cannot be bypassed

## How It Works

### User Votes "Easy"

```
1. User clicks "😊 Easy" button
2. Form submits: paperId=1, difficulty="Easy"
3. Servlet normalizes: "Easy" → "easy"
4. Servlet validates: "easy" in VALID_LEVELS ✓
5. DAO executes UPSERT:
   - If no vote exists → INSERT new row
   - If vote exists → UPDATE existing row
6. Redirect to dashboard
7. Dashboard queries database with aggregation
8. Counts displayed: easy_count, medium_count, hard_count
```

### User Changes Vote to "Hard"

```
1. User clicks "😰 Hard" button
2. Form submits: paperId=1, difficulty="Hard"
3. Servlet normalizes: "Hard" → "hard"
4. Servlet validates: "hard" in VALID_LEVELS ✓
5. DAO executes UPSERT:
   - Vote exists → ON CONFLICT triggered
   - UPDATE difficulty_level = 'hard'
   - Still only 1 row in database
6. Redirect to dashboard
7. Dashboard queries database with aggregation
8. Counts updated: easy_count decreased, hard_count increased
```

## Verification

### Run Verification Script

```bash
psql -U postgres -d paperwise_db -f verify_difficulty_logic.sql
```

### Expected Results

1. **UNIQUE constraint exists:** ✓
2. **No duplicate votes:** ✓
3. **UPSERT works:** ✓
4. **Counts accurate:** ✓
5. **Lowercase values:** ✓

### Manual Test

1. Login as student
2. Click "😊 Easy" for a paper
3. Check database:
   ```sql
   SELECT * FROM difficulty_votes WHERE paper_id = 1 AND user_id = 1;
   ```
   Expected: 1 row with 'easy'

4. Click "😰 Hard" for same paper
5. Check database again:
   ```sql
   SELECT * FROM difficulty_votes WHERE paper_id = 1 AND user_id = 1;
   ```
   Expected: Still 1 row, now with 'hard'

6. Verify counts:
   ```sql
   SELECT 
       COUNT(CASE WHEN difficulty_level = 'easy' THEN 1 END) AS easy,
       COUNT(CASE WHEN difficulty_level = 'medium' THEN 1 END) AS medium,
       COUNT(CASE WHEN difficulty_level = 'hard' THEN 1 END) AS hard
   FROM difficulty_votes WHERE paper_id = 1;
   ```

## Troubleshooting

### If Counts Keep Increasing

**Check 1: UNIQUE Constraint**
```sql
SELECT constraint_name 
FROM information_schema.table_constraints 
WHERE table_name = 'difficulty_votes' 
AND constraint_type = 'UNIQUE';
```

If missing, run:
```sql
ALTER TABLE difficulty_votes 
ADD CONSTRAINT unique_difficulty_vote UNIQUE (paper_id, user_id);
```

**Check 2: Duplicate Rows**
```sql
SELECT paper_id, user_id, COUNT(*) 
FROM difficulty_votes 
GROUP BY paper_id, user_id 
HAVING COUNT(*) > 1;
```

If duplicates exist, clean up:
```sql
-- Keep only the most recent vote per user per paper
DELETE FROM difficulty_votes a
USING difficulty_votes b
WHERE a.id < b.id 
AND a.paper_id = b.paper_id 
AND a.user_id = b.user_id;
```

**Check 3: Application Logs**
Look for SQL errors in Tomcat logs:
```
tail -f /path/to/tomcat/logs/catalina.out
```

## Files Involved

1. ✅ `DifficultyVoteDAO.java` - UPSERT logic
2. ✅ `DifficultyVoteServlet.java` - Input validation
3. ✅ `PaperDAO.java` - SQL aggregation
4. ✅ `Paper.java` - Difficulty calculation
5. ✅ `student-dashboard.jsp` - Display counts
6. ✅ `difficulty_votes` table - Database constraint

## Key Points

✅ **One vote per user per paper** - Enforced by UNIQUE constraint  
✅ **Vote changes update, not insert** - ON CONFLICT DO UPDATE  
✅ **Counts from database** - SQL aggregation, no Java increment  
✅ **Real-time accuracy** - Fresh query on each page load  
✅ **No caching issues** - Request scope, not session  

## Conclusion

**The implementation is correct and follows all best practices!**

If you're experiencing issues with counts increasing incorrectly:
1. Run `verify_difficulty_logic.sql` to check database state
2. Verify UNIQUE constraint exists
3. Check for duplicate rows
4. Review application logs for errors
5. Test UPSERT directly in database

**Most likely cause of issues:** Database constraint not created or duplicate data from before constraint was added.

**Solution:** Run `fix_difficulty_constraint.sql` and clean up duplicates.
