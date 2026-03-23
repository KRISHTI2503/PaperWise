# Vote System Fix - Database Error Resolution

## Issue Identified
The `votes` table was missing from the database, causing all vote operations to fail with database errors.

## Root Cause
The `database_setup.sql` script did not include the `votes` table creation, even though the application code (VoteDAO, VoteServlet) was already implemented correctly.

## Solution

### Step 1: Create the Votes Table

Run this SQL script to create the votes table:

```sql
-- Connect to your database
\c paperwise_db

-- Create votes table
CREATE TABLE IF NOT EXISTS votes (
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

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_votes_paper_id ON votes(paper_id);
CREATE INDEX IF NOT EXISTS idx_votes_user_id ON votes(user_id);
```

**Quick Setup**: Run the provided `create_votes_table.sql` file:
```bash
psql -U postgres -d paperwise_db -f create_votes_table.sql
```

### Step 2: Verify Table Creation

```sql
-- Check table structure
\d votes

-- Should show:
-- vote_id    | integer (PRIMARY KEY)
-- paper_id   | integer (NOT NULL, FOREIGN KEY)
-- user_id    | integer (NOT NULL, FOREIGN KEY)
-- created_at | timestamp (DEFAULT CURRENT_TIMESTAMP)
-- UNIQUE constraint on (paper_id, user_id)
```

### Step 3: Test Vote System

1. Login as student user
2. Navigate to student dashboard
3. Click "Vote" button on any paper
4. Verify success message appears
5. Verify button changes to "Voted" (disabled)
6. Try voting again - should show "You have already voted" error

## Implementation Details

### VoteDAO Methods (Already Correct)

#### hasUserVoted(int paperId, int userId)
```java
// Checks if vote exists
SELECT 1 FROM votes WHERE paper_id = ? AND user_id = ?
```

#### addVote(int paperId, int userId)
```java
// Inserts new vote
INSERT INTO votes (paper_id, user_id) VALUES (?, ?)
```

#### getVoteCount(int paperId)
```java
// Gets total votes for a paper
SELECT COUNT(*) FROM votes WHERE paper_id = ?
```

#### getUserVotedPapers(int userId)
```java
// Gets all papers user voted for
SELECT paper_id FROM votes WHERE user_id = ?
```

### VoteServlet Flow (Already Correct)

```
1. Verify user is authenticated
   → If not: redirect to login

2. Verify user is student
   → If not: show error "Only students can vote"

3. Get paper_id from request parameter "id"
   → If invalid: show error

4. Verify paper exists
   → If not: show error "Paper not found"

5. Check if user already voted
   → If yes: show error "You have already voted"

6. Insert vote into database
   → If success: show success message
   → If fail: show error

7. Redirect to /studentDashboard
```

### StudentDashboardServlet (Already Correct)

```java
// Fetches papers with vote counts
List<Paper> papers = paperDAO.getAllPapersWithVotes();

// Gets user's voted papers
Set<Integer> votedPapers = voteDAO.getUserVotedPapers(userId);

// Sets as request attributes
request.setAttribute("papers", papers);
request.setAttribute("votedPapers", votedPapers);
```

### student-dashboard.jsp Vote Button (Already Correct)

```jsp
<% 
boolean hasVoted = votedPapers != null && votedPapers.contains(paper.getPaperId());
if (hasVoted) { 
%>
    <button class="btn btn-small btn-voted" disabled>
        ✓ Voted
    </button>
<% } else { %>
    <form action="${pageContext.request.contextPath}/votePaper" method="post" style="display: inline;">
        <input type="hidden" name="id" value="<%= paper.getPaperId() %>">
        <button type="submit" class="btn btn-small btn-vote">
            Vote
        </button>
    </form>
<% } %>
```

## Database Schema

### Votes Table Structure

```sql
CREATE TABLE votes (
    vote_id SERIAL PRIMARY KEY,           -- Auto-incrementing ID
    paper_id INTEGER NOT NULL,            -- Reference to papers table
    user_id INTEGER NOT NULL,             -- Reference to users table
    created_at TIMESTAMP DEFAULT NOW(),   -- Vote timestamp
    
    -- Foreign key constraints
    CONSTRAINT fk_vote_paper FOREIGN KEY (paper_id) 
        REFERENCES papers(paper_id) ON DELETE CASCADE,
    CONSTRAINT fk_vote_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE,
    
    -- Prevent duplicate votes
    CONSTRAINT unique_vote UNIQUE (paper_id, user_id)
);
```

### Key Features

1. **UNIQUE Constraint**: `(paper_id, user_id)`
   - Prevents duplicate votes at database level
   - Even if application logic fails, database ensures integrity

2. **Foreign Keys with CASCADE**:
   - If paper deleted → all its votes deleted
   - If user deleted → all their votes deleted
   - Maintains referential integrity

3. **Indexes**:
   - `idx_votes_paper_id` - Fast lookup of votes for a paper
   - `idx_votes_user_id` - Fast lookup of user's votes

## Security Features

### 1. Role-Based Access Control
```java
// Only students can vote
if (!ROLE_STUDENT.equalsIgnoreCase(loggedInUser.getRole())) {
    session.setAttribute("errorMessage", "Only students can vote for papers.");
    return;
}
```

### 2. Duplicate Vote Prevention
```java
// Check before inserting
if (voteDAO.hasUserVoted(paperId, userId)) {
    session.setAttribute("errorMessage", "You have already voted for this paper.");
    return;
}
```

### 3. Paper Validation
```java
// Verify paper exists
Paper paper = paperDAO.getPaperById(paperId);
if (paper == null) {
    session.setAttribute("errorMessage", "Paper not found.");
    return;
}
```

### 4. SQL Injection Prevention
- All queries use PreparedStatement
- Parameters properly escaped
- No string concatenation in SQL

## Error Handling

### Database Errors
```java
try {
    boolean success = voteDAO.addVote(paperId, userId);
} catch (VoteDAO.DAOException e) {
    session.setAttribute("errorMessage", "Database error occurred. Please try again.");
    LOGGER.log(Level.SEVERE, "Error processing vote.", e);
}
```

### User-Friendly Messages
- "You have already voted for this paper."
- "Only students can vote for papers."
- "Paper not found."
- "Invalid paper ID."
- "Database error occurred. Please try again."

## Testing Checklist

### Basic Functionality
- [ ] Create votes table successfully
- [ ] Student can vote for paper
- [ ] Vote count increments
- [ ] Button changes to "Voted"
- [ ] Success message displays

### Duplicate Vote Prevention
- [ ] Voting twice shows error
- [ ] Database rejects duplicate (UNIQUE constraint)
- [ ] Error message is user-friendly

### Role Restrictions
- [ ] Admin cannot vote
- [ ] Guest redirected to login
- [ ] Only student role can vote

### Edge Cases
- [ ] Invalid paper ID handled
- [ ] Deleted paper handled
- [ ] Database connection error handled
- [ ] Null user handled

### UI/UX
- [ ] Vote button visible for non-voted papers
- [ ] Voted button disabled for voted papers
- [ ] Success message auto-hides after 3 seconds
- [ ] Vote count displays correctly
- [ ] Popular badge shows for high-voted papers

## Files Updated

1. **database_setup.sql** - Added votes table creation
2. **create_votes_table.sql** - NEW - Standalone votes table creation
3. **VOTE_SYSTEM_FIX.md** - NEW - This documentation

## Files Already Correct (No Changes Needed)

- ✅ VoteDAO.java - All methods implemented correctly
- ✅ VoteServlet.java - Proper flow and error handling
- ✅ StudentDashboardServlet.java - Fetches votes correctly
- ✅ student-dashboard.jsp - Vote button logic correct
- ✅ Paper.java - Has voteCount field
- ✅ PaperDAO.java - Has getAllPapersWithVotes() method

## Common Issues and Solutions

### Issue: "Table votes does not exist"
**Solution**: Run `create_votes_table.sql`

### Issue: "Duplicate key value violates unique constraint"
**Solution**: This is expected - user already voted. Application handles this gracefully.

### Issue: Vote count not updating
**Solution**: Refresh page - vote count fetched fresh from database on each request

### Issue: "Only students can vote" for student user
**Solution**: Check user role in database - should be 'student' not 'Student'

## Performance Considerations

### Indexes
- `idx_votes_paper_id` - Speeds up vote count queries
- `idx_votes_user_id` - Speeds up "has user voted" checks
- UNIQUE constraint also creates implicit index

### Query Optimization
```sql
-- Efficient vote count (uses index)
SELECT COUNT(*) FROM votes WHERE paper_id = ?

-- Efficient duplicate check (uses index)
SELECT 1 FROM votes WHERE paper_id = ? AND user_id = ?

-- Efficient papers with votes (single query with JOIN)
SELECT p.*, COALESCE(COUNT(v.vote_id), 0) as vote_count
FROM papers p
LEFT JOIN votes v ON p.paper_id = v.paper_id
GROUP BY p.paper_id
ORDER BY vote_count DESC
```

## Summary

The vote system was correctly implemented in the application code but failed due to missing database table. After creating the `votes` table with proper constraints and indexes, the system works as designed:

1. Students can vote for papers
2. Duplicate votes prevented
3. Vote counts displayed
4. Voted papers marked
5. Popular papers highlighted

No code changes were needed - only database schema update.
