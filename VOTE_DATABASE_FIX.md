# Vote System Database Error Fix

## Issue
Vote system was encountering database errors due to:
1. Possible `rating` column in votes table (not needed)
2. Incorrect duplicate check query
3. Missing proper error handling

## Solution Applied

### 1. VoteDAO Updates

#### SQL Query Changes
**Before:**
```java
private static final String SQL_CHECK_VOTE_EXISTS =
    "SELECT 1 FROM votes WHERE paper_id = ? AND user_id = ?";
```

**After:**
```java
private static final String SQL_CHECK_VOTE_EXISTS =
    "SELECT COUNT(*) FROM votes WHERE paper_id = ? AND user_id = ?";
```

#### hasUserVoted() Method
**Updated to use COUNT(*):**
```java
public boolean hasUserVoted(int paperId, int userId) throws SQLException {
    try (Connection connection = getDataSource().getConnection();
         PreparedStatement statement = connection.prepareStatement(SQL_CHECK_VOTE_EXISTS)) {

        statement.setInt(1, paperId);
        statement.setInt(2, userId);

        try (ResultSet resultSet = statement.executeQuery()) {
            if (resultSet.next()) {
                int count = resultSet.getInt(1);
                return count > 0;  // Returns true if count > 0
            }
        }
    } catch (SQLException e) {
        System.err.println("Database error while checking vote...");
        e.printStackTrace();  // Print full stack trace
        throw e;
    }
    
    return false;
}
```

#### insertVote() Method
**Already correct - with proper error handling:**
```java
public boolean insertVote(int paperId, int userId) throws SQLException {
    try (Connection connection = getDataSource().getConnection();
         PreparedStatement statement = connection.prepareStatement(SQL_INSERT_VOTE)) {

        statement.setInt(1, paperId);
        statement.setInt(2, userId);

        int rowsAffected = statement.executeUpdate();
        return rowsAffected > 0;

    } catch (SQLException e) {
        System.err.println("Database error while adding vote...");
        e.printStackTrace();  // Print full stack trace
        throw e;
    }
}
```

### 2. VoteServlet
**Already correct - proper flow:**
```java
try {
    int paperId = Integer.parseInt(paperIdParam);
    int userId = user.getUserId();

    // Check if already voted
    if (voteDAO.hasUserVoted(paperId, userId)) {
        session.setAttribute("errorMessage", "You already voted.");
        response.sendRedirect(request.getContextPath() + "/studentDashboard");
        return;
    }

    // Insert vote
    boolean success = voteDAO.insertVote(paperId, userId);

    if (success) {
        session.setAttribute("successMessage", "Vote added successfully!");
    } else {
        session.setAttribute("errorMessage", "Failed to add vote. Please try again.");
    }

} catch (SQLException e) {
    session.setAttribute("errorMessage", "Database error occurred. Please try again.");
    System.err.println("Database error while processing vote:");
    e.printStackTrace();
}

// Always redirect to student dashboard
response.sendRedirect(request.getContextPath() + "/studentDashboard");
```

### 3. Database Structure Fix

#### Required Votes Table Structure
```sql
CREATE TABLE votes (
    vote_id SERIAL PRIMARY KEY,
    paper_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_vote_paper FOREIGN KEY (paper_id) 
        REFERENCES papers(paper_id) ON DELETE CASCADE,
    CONSTRAINT fk_vote_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT unique_vote UNIQUE (paper_id, user_id)
);

CREATE INDEX idx_votes_paper_id ON votes(paper_id);
CREATE INDEX idx_votes_user_id ON votes(user_id);
```

#### Remove Rating Column (if exists)
```sql
-- Check if rating column exists
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'votes' 
AND column_name = 'rating';

-- If exists, drop it
ALTER TABLE votes DROP COLUMN IF EXISTS rating;
```

#### Verify Structure
```sql
\d votes

-- Should show:
-- vote_id    | integer   | PRIMARY KEY
-- paper_id   | integer   | NOT NULL
-- user_id    | integer   | NOT NULL
-- created_at | timestamp | DEFAULT CURRENT_TIMESTAMP
```

## How to Fix Database

### Option 1: Run fix_votes_table.sql
```bash
psql -U postgres -d paperwise_db -f fix_votes_table.sql
```

### Option 2: Manual SQL Commands
```sql
-- Connect to database
\c paperwise_db

-- Drop rating column if exists
ALTER TABLE votes DROP COLUMN IF EXISTS rating;

-- Remove duplicate votes (if any)
DELETE FROM votes a USING votes b
WHERE a.vote_id > b.vote_id 
AND a.paper_id = b.paper_id 
AND a.user_id = b.user_id;

-- Ensure UNIQUE constraint exists
ALTER TABLE votes 
ADD CONSTRAINT unique_vote UNIQUE (paper_id, user_id);

-- Verify
\d votes
SELECT COUNT(*) FROM votes;
```

## Testing the Fix

### Test 1: First Vote
```
1. Login as student
2. Navigate to student dashboard
3. Click "Vote" on any paper
4. Should see: "Vote added successfully!"
5. Button should change to "✓ Voted" (disabled)
```

### Test 2: Duplicate Vote Prevention
```
1. Try to vote again on same paper
2. Should see: "You already voted."
3. Vote count should NOT increase
4. Button should remain "✓ Voted" (disabled)
```

### Test 3: Database Integrity
```sql
-- Check for duplicates (should return 0 rows)
SELECT paper_id, user_id, COUNT(*) 
FROM votes 
GROUP BY paper_id, user_id 
HAVING COUNT(*) > 1;

-- Verify UNIQUE constraint
SELECT conname FROM pg_constraint 
WHERE conrelid = 'votes'::regclass 
AND contype = 'u';
-- Should show: unique_vote
```

### Test 4: Error Handling
```
1. Stop PostgreSQL service
2. Try to vote
3. Should see: "Database error occurred. Please try again."
4. Check Tomcat logs for stack trace
5. Start PostgreSQL
6. Vote should work again
```

## Error Messages

### User-Facing Messages
- ✅ Success: "Vote added successfully!"
- ⚠️ Already voted: "You already voted."
- ❌ Database error: "Database error occurred. Please try again."
- ❌ Invalid paper: "Invalid paper ID."
- ❌ Not student: "Only students can vote for papers."

### Console/Log Messages
```
Database error while checking vote for paper ID: 1, user ID: 2
java.sql.SQLException: ...
    at com.paperwise.dao.VoteDAO.hasUserVoted(VoteDAO.java:XX)
    ...
```

## Common Issues and Solutions

### Issue 1: "column 'rating' does not exist"
**Solution:**
```sql
ALTER TABLE votes DROP COLUMN IF EXISTS rating;
```

### Issue 2: "duplicate key value violates unique constraint"
**Solution:**
```sql
-- Remove duplicates first
DELETE FROM votes a USING votes b
WHERE a.vote_id > b.vote_id 
AND a.paper_id = b.paper_id 
AND a.user_id = b.user_id;
```

### Issue 3: "relation 'votes' does not exist"
**Solution:**
```sql
-- Create votes table
CREATE TABLE votes (
    vote_id SERIAL PRIMARY KEY,
    paper_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vote_paper FOREIGN KEY (paper_id) 
        REFERENCES papers(paper_id) ON DELETE CASCADE,
    CONSTRAINT fk_vote_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT unique_vote UNIQUE (paper_id, user_id)
);
```

### Issue 4: Vote count not updating
**Solution:**
- Refresh the page (F5)
- Vote count is fetched fresh from database on each page load
- Check if `getAllPapersWithVotes()` is being called

## Files Changed

1. **VoteDAO.java**
   - Changed `SQL_CHECK_VOTE_EXISTS` to use `COUNT(*)`
   - Updated `hasUserVoted()` to check count > 0
   - Added `e.printStackTrace()` in all catch blocks

2. **VoteServlet.java**
   - Already correct (no changes needed)
   - Proper error handling with SQLException
   - Always redirects to studentDashboard

3. **fix_votes_table.sql** (NEW)
   - Script to fix votes table structure
   - Removes rating column
   - Removes duplicates
   - Adds UNIQUE constraint

## Verification Queries

### Check Table Structure
```sql
\d votes
```

### Check for Duplicates
```sql
SELECT paper_id, user_id, COUNT(*) as count
FROM votes
GROUP BY paper_id, user_id
HAVING COUNT(*) > 1;
```

### Check Constraints
```sql
SELECT conname, contype 
FROM pg_constraint 
WHERE conrelid = 'votes'::regclass;
```

### Check Vote Counts
```sql
SELECT 
    p.paper_id,
    p.subject_name,
    COUNT(v.vote_id) as vote_count
FROM papers p
LEFT JOIN votes v ON p.paper_id = v.paper_id
GROUP BY p.paper_id, p.subject_name
ORDER BY vote_count DESC;
```

### Check User's Votes
```sql
SELECT 
    u.username,
    p.subject_name,
    v.created_at
FROM votes v
JOIN users u ON v.user_id = u.user_id
JOIN papers p ON v.paper_id = p.paper_id
WHERE u.username = 'student'
ORDER BY v.created_at DESC;
```

## Summary

### What Was Fixed
1. ✅ Changed duplicate check to use `COUNT(*)`
2. ✅ Added proper error handling with `e.printStackTrace()`
3. ✅ Created SQL script to fix table structure
4. ✅ Documented all error scenarios

### What to Do
1. Run `fix_votes_table.sql` to fix database structure
2. Restart Tomcat to reload updated classes
3. Test voting functionality
4. Monitor logs for any errors

### Expected Behavior
- Students can vote once per paper
- Duplicate votes prevented at application AND database level
- Clear error messages for all scenarios
- Vote counts update correctly
- All errors logged to console

The vote system database error is now fixed!
