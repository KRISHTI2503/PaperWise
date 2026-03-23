# Marked Papers Troubleshooting Guide

## Problem
When clicking "My Marked Papers" from dropdown, it shows "No Papers Available" even after marking papers.

---

## Architecture Clarification

**IMPORTANT**: This application uses the `votes` table (NOT a separate `marks` table).

### Table Structure
```sql
CREATE TABLE votes (
    id SERIAL PRIMARY KEY,
    paper_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_vote UNIQUE (paper_id, user_id)
);
```

- `id` = vote_id (PRIMARY KEY)
- `user_id` = FK to users table
- `paper_id` = FK to papers table
- `created_at` = timestamp (used as marked_at)

---

## Debug Logging Added

### 1. VoteDAO.getUserMarkedPapersWithDetails()
```
=== GET USER MARKED PAPERS DEBUG ===
User ID: [userId]
SQL Query: [full query]
Parameter 1 (userId): [userId]
Found marked paper: [subject_name] (ID: [paper_id])
Total marked papers found: [count]
=== END DEBUG ===
```

### 2. StudentDashboardServlet
```
=== STUDENT DASHBOARD DEBUG ===
Logged in user: [username]
User ID: [userId]
View parameter: [view]
Show only marked: [true/false]
Fetching marked papers for user ID: [userId]
Marked papers retrieved: [count]
=== END DEBUG ===
```

### 3. MarkUsefulServlet
```
=== MARK USEFUL DEBUG ===
User: [username]
User ID: [userId]
Paper ID: [paperId]
Already marked: [true/false]
Inserting new mark...
Mark inserted successfully
=== END MARK USEFUL DEBUG ===
```

### 4. VoteDAO.insertVote()
```
=== INSERT VOTE DEBUG ===
Inserting vote: Paper ID = [paperId], User ID = [userId]
Rows affected: [count]
Vote added for paper ID [paperId] by user ID [userId]
=== END INSERT VOTE DEBUG ===
```

---

## Diagnostic Steps

### Step 1: Run Diagnostic SQL Script

Execute the diagnostic script:
```bash
psql -U postgres -d paperwise_db -f diagnose_marked_papers.sql
```

This will check:
1. Votes table structure
2. Total votes count
3. Votes by user
4. Specific user's votes
5. Test the marked papers query
6. Check for orphaned votes
7. Verify papers exist
8. Verify users exist
9. Check indexes
10. Check constraints

### Step 2: Check Tomcat Console Logs

After marking a paper, look for:
```
=== MARK USEFUL DEBUG ===
User: student
User ID: 2
Paper ID: 1
Already marked: false
Inserting new mark...
=== INSERT VOTE DEBUG ===
Inserting vote: Paper ID = 1, User ID = 2
Rows affected: 1
Vote added for paper ID 1 by user ID 2
=== END INSERT VOTE DEBUG ===
Mark inserted successfully
=== END MARK USEFUL DEBUG ===
```

If you see "Rows affected: 0", the insert failed (likely duplicate).

### Step 3: Check Marked Papers View

After clicking "My Marked Papers", look for:
```
=== STUDENT DASHBOARD DEBUG ===
Logged in user: student
User ID: 2
View parameter: marked
Show only marked: true
Fetching marked papers for user ID: 2
=== GET USER MARKED PAPERS DEBUG ===
User ID: 2
SQL Query: SELECT p.*, ...
Parameter 1 (userId): 2
Found marked paper: Data Structures (ID: 1)
Found marked paper: Algorithms (ID: 2)
Total marked papers found: 2
=== END DEBUG ===
Marked papers retrieved: 2
=== END DEBUG ===
```

If "Total marked papers found: 0", no votes exist for this user.

---

## Common Issues and Solutions

### Issue 1: No Votes Being Inserted

**Symptoms**:
- "Rows affected: 0" in insert vote debug
- Total votes count = 0 in diagnostic script

**Possible Causes**:
1. Database connection issue
2. Foreign key constraint violation
3. Duplicate vote (ON CONFLICT triggered)

**Solution**:
```sql
-- Check if paper exists
SELECT * FROM papers WHERE paper_id = 1;

-- Check if user exists
SELECT * FROM users WHERE user_id = 2;

-- Try manual insert
INSERT INTO votes (paper_id, user_id) VALUES (1, 2);
```

### Issue 2: Wrong User ID

**Symptoms**:
- Votes inserted but not showing in marked papers
- User ID mismatch in logs

**Possible Causes**:
1. Session attribute name mismatch
2. Different user logged in
3. User ID not set correctly

**Solution**:
Check session attribute in MarkUsefulServlet:
```java
// Check both "user" and "loggedInUser" attributes
User user = (User) session.getAttribute("user");
if (user == null) {
    user = (User) session.getAttribute("loggedInUser");
}
```

Verify user ID:
```sql
SELECT user_id, username FROM users WHERE username = 'student';
```

### Issue 3: SQL Query Issue

**Symptoms**:
- SQLException in logs
- "Total marked papers found: 0" even though votes exist

**Possible Causes**:
1. Column name mismatch
2. JOIN condition incorrect
3. WHERE clause filtering out all results

**Solution**:
Test the query manually:
```sql
SELECT p.*, 
       COUNT(DISTINCT v.id) AS useful_count, 
       m.created_at AS marked_at 
FROM papers p 
JOIN votes m ON p.paper_id = m.paper_id 
WHERE m.user_id = 2
GROUP BY p.paper_id, m.created_at 
ORDER BY m.created_at DESC;
```

### Issue 4: Session Attribute Name Mismatch

**Symptoms**:
- User ID = 0 or null in logs
- Redirect to login page

**Possible Causes**:
- Session attribute is "loggedInUser" but code checks "user"
- Or vice versa

**Solution**:
Verify session attribute name:
```java
// In LoginServlet
session.setAttribute("loggedInUser", user);

// In StudentDashboardServlet
User loggedInUser = (User) session.getAttribute("loggedInUser");

// In MarkUsefulServlet - check both
User user = (User) session.getAttribute("user");
if (user == null) {
    user = (User) session.getAttribute("loggedInUser");
}
```

### Issue 5: Papers Deleted

**Symptoms**:
- Votes exist but papers don't show
- Orphaned votes in diagnostic script

**Possible Causes**:
- Papers were deleted but votes remain (shouldn't happen with CASCADE)
- Foreign key constraint not working

**Solution**:
```sql
-- Check for orphaned votes
SELECT v.* 
FROM votes v
LEFT JOIN papers p ON v.paper_id = p.paper_id
WHERE p.paper_id IS NULL;

-- Delete orphaned votes
DELETE FROM votes 
WHERE paper_id NOT IN (SELECT paper_id FROM papers);
```

### Issue 6: View Parameter Not Working

**Symptoms**:
- Clicking "My Marked Papers" doesn't change view
- URL doesn't have ?view=marked

**Possible Causes**:
- Dropdown onchange not working
- JavaScript error

**Solution**:
Check dropdown in student-dashboard.jsp:
```html
<select id="viewFilter" 
        onchange="window.location.href='${pageContext.request.contextPath}/studentDashboard?view=' + this.value">
    <option value="all">All Papers</option>
    <option value="marked">My Marked Papers</option>
</select>
```

Test manually:
```
http://localhost:8080/PaperWise/studentDashboard?view=marked
```

---

## Manual Testing Procedure

### 1. Mark a Paper
1. Login as student
2. Go to student dashboard
3. Click "Useful" on a paper
4. Check console logs for insert debug messages
5. Verify success message appears

### 2. Verify Database
```sql
-- Check if vote was inserted
SELECT * FROM votes 
WHERE user_id = (SELECT user_id FROM users WHERE username = 'student')
ORDER BY created_at DESC;
```

### 3. View Marked Papers
1. Click dropdown at top of page
2. Select "My Marked Papers"
3. Check console logs for query debug messages
4. Verify papers appear

### 4. Check Console Output
Look for complete debug flow:
```
=== MARK USEFUL DEBUG ===
...
=== INSERT VOTE DEBUG ===
...
=== STUDENT DASHBOARD DEBUG ===
...
=== GET USER MARKED PAPERS DEBUG ===
...
```

---

## SQL Queries for Verification

### Check Votes for User
```sql
SELECT 
    v.id,
    v.paper_id,
    v.user_id,
    v.created_at,
    p.subject_name,
    u.username
FROM votes v
JOIN papers p ON v.paper_id = p.paper_id
JOIN users u ON v.user_id = u.user_id
WHERE u.username = 'student'
ORDER BY v.created_at DESC;
```

### Test Marked Papers Query
```sql
SELECT p.paper_id, p.subject_name, m.created_at as marked_at
FROM papers p 
JOIN votes m ON p.paper_id = m.paper_id 
WHERE m.user_id = (SELECT user_id FROM users WHERE username = 'student')
ORDER BY m.created_at DESC;
```

### Count Votes by User
```sql
SELECT 
    u.username,
    COUNT(v.id) as vote_count
FROM users u
LEFT JOIN votes v ON u.user_id = v.user_id
GROUP BY u.username;
```

---

## Expected Console Output (Success Case)

### When Marking Paper
```
=== MARK USEFUL DEBUG ===
User: student
User ID: 2
Paper ID: 1
Already marked: false
Inserting new mark...
=== INSERT VOTE DEBUG ===
Inserting vote: Paper ID = 1, User ID = 2
Rows affected: 1
Vote added for paper ID 1 by user ID 2
=== END INSERT VOTE DEBUG ===
Mark inserted successfully
=== END MARK USEFUL DEBUG ===
```

### When Viewing Marked Papers
```
=== STUDENT DASHBOARD DEBUG ===
Logged in user: student
User ID: 2
View parameter: marked
Show only marked: true
Fetching marked papers for user ID: 2
=== GET USER MARKED PAPERS DEBUG ===
User ID: 2
SQL Query: SELECT p.*, COUNT(DISTINCT v.id) AS useful_count, ...
Parameter 1 (userId): 2
Found marked paper: Data Structures and Algorithms (ID: 1)
Total marked papers found: 1
=== END DEBUG ===
Marked papers retrieved: 1
Showing marked papers for user: student
Student dashboard loaded with 1 papers for user student
=== END DEBUG ===
```

---

## Quick Fix Checklist

- [ ] Run diagnostic SQL script
- [ ] Check Tomcat console logs
- [ ] Verify votes table exists and has correct structure
- [ ] Verify votes are being inserted (check database)
- [ ] Verify user_id is correct in logs
- [ ] Verify session attribute name matches
- [ ] Test marked papers query manually in database
- [ ] Check for orphaned votes
- [ ] Verify papers exist
- [ ] Test view parameter in URL manually

---

## Contact Points for Debugging

1. **Database**: Check `votes` table directly
2. **Servlet**: Check console logs for debug messages
3. **DAO**: Check SQL query execution
4. **JSP**: Check dropdown and URL parameters

---

## Files Modified (Debug Logging Added)

1. `src/java/com/paperwise/dao/VoteDAO.java`
   - getUserMarkedPapersWithDetails() - added debug logging
   - insertVote() - added debug logging

2. `src/java/com/paperwise/servlet/StudentDashboardServlet.java`
   - doGet() - added debug logging for view mode

3. `src/java/com/paperwise/servlet/MarkUsefulServlet.java`
   - doPost() - added debug logging for mark insertion

4. `diagnose_marked_papers.sql` - NEW diagnostic script

---

## Next Steps

1. Deploy updated code with debug logging
2. Run diagnostic SQL script
3. Mark a paper and check console logs
4. View marked papers and check console logs
5. Report findings based on debug output

The debug logging will show exactly where the issue is occurring.
