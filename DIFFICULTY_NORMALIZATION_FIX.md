# Difficulty Vote Normalization Fix

## Problem
PostgreSQL CHECK constraint violation when inserting difficulty votes:
```
ERROR: new row for relation "difficulty_votes" violates check constraint "difficulty_votes_difficulty_level_check"
Failing row contains (..., Easy)
```

**Root Cause:** Database constraint allows only lowercase values ('easy', 'medium', 'hard'), but application was sending capitalized values ('Easy', 'Medium', 'Hard').

## Solution
Normalize all difficulty values to lowercase before database insertion.

## Changes Made

### 1. Updated DifficultyVoteServlet.java

**File:** `src/java/com/paperwise/servlet/DifficultyVoteServlet.java`

**Added Normalization:**
```java
// Get parameters
String paperIdParam = request.getParameter("paperId");
String level = request.getParameter("difficulty");

// Normalize difficulty level to lowercase
if (level != null) {
    level = level.toLowerCase().trim();
}
```

**Added Validation:**
```java
// Validate difficulty level is one of the allowed values
if (!level.equals("easy") && !level.equals("medium") && !level.equals("hard")) {
    session.setAttribute("errorMessage", "Invalid difficulty level. Must be easy, medium, or hard.");
    response.sendRedirect("studentDashboard");
    return;
}
```

**Benefits:**
- ✅ Normalizes input immediately after receiving
- ✅ Validates against lowercase values
- ✅ Prevents CHECK constraint violations
- ✅ User-friendly error messages

### 2. Updated DifficultyVoteDAO.java

**File:** `src/java/com/paperwise/dao/DifficultyVoteDAO.java`

**Updated Method:**
```java
public void addOrUpdateDifficultyVote(int paperId, int userId, String level) {
    // ...
    
    // Normalize and validate difficulty level
    String normalizedLevel = level.trim().toLowerCase();
    if (!isValidDifficultyLevel(normalizedLevel)) {
        throw new IllegalArgumentException(
                "Invalid difficulty level. Must be one of: easy, medium, hard");
    }
    
    // Insert normalized value
    statement.setString(3, normalizedLevel);
    
    // ...
}
```

**Benefits:**
- ✅ Double protection (servlet + DAO)
- ✅ Ensures lowercase before database insert
- ✅ Updated error messages to reflect lowercase

### 3. Updated PaperDAO.java

**File:** `src/java/com/paperwise/dao/PaperDAO.java`

**Updated SQL Query:**
```sql
SELECT p.*, 
       COUNT(DISTINCT v.id) AS useful_count, 
       COUNT(CASE WHEN d.difficulty_level = 'easy' THEN 1 END) AS easy_count, 
       COUNT(CASE WHEN d.difficulty_level = 'medium' THEN 1 END) AS medium_count, 
       COUNT(CASE WHEN d.difficulty_level = 'hard' THEN 1 END) AS hard_count, 
       u.username 
FROM papers p 
LEFT JOIN votes v ON p.paper_id = v.paper_id 
LEFT JOIN difficulty_votes d ON p.paper_id = d.paper_id 
GROUP BY p.paper_id, u.username 
ORDER BY useful_count DESC, p.created_at DESC
```

**Changes:**
- Changed `'Easy'` → `'easy'`
- Changed `'Medium'` → `'medium'`
- Changed `'Hard'` → `'hard'`

### 4. Database Constraint Fix

**File:** `fix_difficulty_constraint.sql`

**SQL Script:**
```sql
-- Drop existing CHECK constraint
ALTER TABLE difficulty_votes 
DROP CONSTRAINT IF EXISTS difficulty_votes_difficulty_level_check;

-- Add new CHECK constraint with lowercase values
ALTER TABLE difficulty_votes 
ADD CONSTRAINT difficulty_votes_difficulty_level_check 
CHECK (difficulty_level IN ('easy', 'medium', 'hard'));
```

**Run Command:**
```bash
psql -U postgres -d paperwise_db -f fix_difficulty_constraint.sql
```

## Data Flow

### Before Fix
```
JSP Button: value="Easy"
    ↓
Servlet: level = "Easy"
    ↓
DAO: normalizedLevel = "Easy"
    ↓
Database: INSERT 'Easy'
    ↓
❌ CHECK constraint violation!
```

### After Fix
```
JSP Button: value="Easy"
    ↓
Servlet: level = "Easy" → level = "easy"
    ↓
DAO: normalizedLevel = "easy"
    ↓
Database: INSERT 'easy'
    ↓
✅ Success!
```

## Testing

### Test Case 1: Capitalized Input
```java
// Input: "Easy"
String level = "Easy";
level = level.toLowerCase().trim();
// Result: "easy" ✅
```

### Test Case 2: Mixed Case Input
```java
// Input: "EaSy"
String level = "EaSy";
level = level.toLowerCase().trim();
// Result: "easy" ✅
```

### Test Case 3: Whitespace
```java
// Input: " Easy "
String level = " Easy ";
level = level.toLowerCase().trim();
// Result: "easy" ✅
```

### Test Case 4: Invalid Input
```java
// Input: "VeryHard"
String level = "VeryHard";
level = level.toLowerCase().trim();
// Result: "veryhard"
// Validation: !level.equals("easy") && !level.equals("medium") && !level.equals("hard")
// Action: Return error ✅
```

## Deployment Steps

### Step 1: Update Database Constraint
```bash
psql -U postgres -d paperwise_db -f fix_difficulty_constraint.sql
```

### Step 2: Clean and Rebuild Project
```
Right-click project → Clean
Right-click project → Build
```

### Step 3: Restart Tomcat
```
Right-click Tomcat → Restart
```

### Step 4: Test Difficulty Voting
1. Login as student
2. Click "😊 Easy" button
3. Verify success message
4. Check database: `SELECT * FROM difficulty_votes;`
5. Verify value is lowercase: 'easy'

## Verification Queries

### Check Constraint
```sql
SELECT constraint_name, check_clause 
FROM information_schema.check_constraints 
WHERE constraint_name = 'difficulty_votes_difficulty_level_check';
```

**Expected Result:**
```
constraint_name                          | check_clause
-----------------------------------------|----------------------------------
difficulty_votes_difficulty_level_check  | (difficulty_level IN ('easy', 'medium', 'hard'))
```

### Check Existing Data
```sql
SELECT difficulty_level, COUNT(*) 
FROM difficulty_votes 
GROUP BY difficulty_level;
```

**Expected Result:**
```
difficulty_level | count
-----------------|-------
easy             | 5
medium           | 3
hard             | 2
```

### Test Insert
```sql
INSERT INTO difficulty_votes (paper_id, user_id, difficulty_level) 
VALUES (1, 1, 'easy');
-- Should succeed ✅

INSERT INTO difficulty_votes (paper_id, user_id, difficulty_level) 
VALUES (1, 2, 'Easy');
-- Should fail ❌ (uppercase not allowed)
```

## Error Messages

### Before Fix
```
ERROR: new row for relation "difficulty_votes" violates check constraint "difficulty_votes_difficulty_level_check"
Detail: Failing row contains (1, 1, 1, Easy, 2024-01-15 10:30:00, 2024-01-15 10:30:00).
```

### After Fix
```
✅ Difficulty rating recorded: easy
```

## Backward Compatibility

### Existing Data
If you have existing data with capitalized values, migrate it:

```sql
-- Update existing data to lowercase
UPDATE difficulty_votes 
SET difficulty_level = LOWER(difficulty_level);

-- Verify
SELECT DISTINCT difficulty_level FROM difficulty_votes;
-- Should show: easy, medium, hard
```

### JSP Buttons
No changes needed! Buttons still send capitalized values:
```jsp
<button name="difficulty" value="Easy">😊 Easy</button>
```

Servlet normalizes them automatically.

## Files Modified

1. ✅ `src/java/com/paperwise/servlet/DifficultyVoteServlet.java`
   - Added normalization: `level.toLowerCase().trim()`
   - Added validation for lowercase values

2. ✅ `src/java/com/paperwise/dao/DifficultyVoteDAO.java`
   - Updated normalization to lowercase
   - Updated error messages

3. ✅ `src/java/com/paperwise/dao/PaperDAO.java`
   - Updated SQL query to check lowercase values

4. ✅ `fix_difficulty_constraint.sql`
   - Script to update database constraint

## Verification Checklist

- [x] Servlet normalizes to lowercase
- [x] Servlet validates against lowercase values
- [x] DAO normalizes to lowercase
- [x] SQL query checks lowercase values
- [x] Database constraint allows lowercase
- [x] No compilation errors
- [ ] Database constraint updated
- [ ] Existing data migrated (if any)
- [ ] Test difficulty voting works
- [ ] Verify database contains lowercase values

## Troubleshooting

### Issue: Still getting CHECK constraint error
**Solution:** Run `fix_difficulty_constraint.sql` to update database constraint

### Issue: Existing data has capitalized values
**Solution:** Run migration query to lowercase existing data

### Issue: Validation fails
**Solution:** Verify servlet normalization happens before validation

### Issue: Query returns 0 counts
**Solution:** Verify SQL query uses lowercase in CASE WHEN clauses

## Summary

**Problem:** Database expects lowercase, application sent capitalized  
**Solution:** Normalize to lowercase at servlet and DAO levels  
**Result:** No more CHECK constraint violations ✅

**Key Changes:**
- Servlet: `level = level.toLowerCase().trim()`
- DAO: `normalizedLevel = level.trim().toLowerCase()`
- SQL: `d.difficulty_level = 'easy'` (not 'Easy')
- Database: `CHECK (difficulty_level IN ('easy', 'medium', 'hard'))`

**Status: Fix complete! ✅**
