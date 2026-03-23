# DifficultyVoteDAO Implementation

## Overview
DAO class for managing difficulty votes on papers. Allows students to rate paper difficulty as Easy, Medium, or Hard.

## Database Table Structure

```sql
CREATE TABLE difficulty_votes (
    id SERIAL PRIMARY KEY,
    paper_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    difficulty_level VARCHAR(20) NOT NULL CHECK (difficulty_level IN ('Easy', 'Medium', 'Hard')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_difficulty_vote UNIQUE (paper_id, user_id)
);
```

## Features

### 1. UPSERT Support (Insert or Update)
Uses PostgreSQL `ON CONFLICT` to handle both scenarios:
- **First vote**: Inserts new record
- **Change vote**: Updates existing record

```java
addOrUpdateDifficultyVote(int paperId, int userId, String level)
```

**SQL:**
```sql
INSERT INTO difficulty_votes (paper_id, user_id, difficulty_level) 
VALUES (?, ?, ?) 
ON CONFLICT (paper_id, user_id) 
DO UPDATE SET difficulty_level = EXCLUDED.difficulty_level
```

### 2. Get Difficulty Statistics
Returns vote counts for each difficulty level:

```java
Map<String, Integer> getDifficultyStats(int paperId)
```

**Returns:**
```java
{
    "Easy": 5,
    "Medium": 12,
    "Hard": 3
}
```

**SQL:**
```sql
SELECT difficulty_level, COUNT(*) as count 
FROM difficulty_votes 
WHERE paper_id = ? 
GROUP BY difficulty_level
```

### 3. Get User's Vote
Retrieves the difficulty level voted by a specific user:

```java
String getUserDifficultyVote(int paperId, int userId)
```

**Returns:** "Easy", "Medium", "Hard", or null if no vote exists

## Usage Examples

### Example 1: Add or Update Vote
```java
DifficultyVoteDAO dao = new DifficultyVoteDAO();

// First vote - inserts new record
dao.addOrUpdateDifficultyVote(1, 101, "Easy");

// Change vote - updates existing record
dao.addOrUpdateDifficultyVote(1, 101, "Medium");
```

### Example 2: Get Statistics
```java
DifficultyVoteDAO dao = new DifficultyVoteDAO();
Map<String, Integer> stats = dao.getDifficultyStats(1);

int easyCount = stats.getOrDefault("Easy", 0);
int mediumCount = stats.getOrDefault("Medium", 0);
int hardCount = stats.getOrDefault("Hard", 0);

System.out.println("Easy: " + easyCount);
System.out.println("Medium: " + mediumCount);
System.out.println("Hard: " + hardCount);
```

### Example 3: Check User's Vote
```java
DifficultyVoteDAO dao = new DifficultyVoteDAO();
String userVote = dao.getUserDifficultyVote(1, 101);

if (userVote != null) {
    System.out.println("User voted: " + userVote);
} else {
    System.out.println("User has not voted yet");
}
```

## Validation

### Valid Difficulty Levels
- "Easy"
- "Medium"
- "Hard"

(Case-insensitive)

### Input Validation
- Paper ID must be positive integer
- User ID must be positive integer
- Difficulty level must not be null or empty
- Difficulty level must be one of: Easy, Medium, Hard

### Error Handling
- Throws `IllegalArgumentException` for invalid inputs
- Throws `DAOException` for database errors
- All exceptions are logged with stack traces

## Integration with Servlet

### Example Servlet Implementation
```java
@WebServlet("/voteDifficulty")
public class DifficultyVoteServlet extends HttpServlet {
    
    private DifficultyVoteDAO difficultyVoteDAO;
    
    @Override
    public void init() throws ServletException {
        difficultyVoteDAO = new DifficultyVoteDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("loggedInUser");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            int paperId = Integer.parseInt(request.getParameter("paperId"));
            String level = request.getParameter("level");
            
            difficultyVoteDAO.addOrUpdateDifficultyVote(paperId, user.getUserId(), level);
            
            session.setAttribute("successMessage", "Difficulty vote recorded!");
            response.sendRedirect("studentDashboard");
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Failed to record vote.");
            response.sendRedirect("studentDashboard");
        }
    }
}
```

## JSP Integration

### Display Difficulty Buttons
```jsp
<form action="voteDifficulty" method="post" style="display:inline;">
    <input type="hidden" name="paperId" value="${paper.paperId}">
    <button type="submit" name="level" value="Easy" class="btn btn-success">
        😊 Easy
    </button>
    <button type="submit" name="level" value="Medium" class="btn btn-warning">
        😐 Medium
    </button>
    <button type="submit" name="level" value="Hard" class="btn btn-danger">
        😰 Hard
    </button>
</form>
```

### Display Statistics
```jsp
<%
    Map<String, Integer> stats = difficultyVoteDAO.getDifficultyStats(paper.getPaperId());
    int easy = stats.getOrDefault("Easy", 0);
    int medium = stats.getOrDefault("Medium", 0);
    int hard = stats.getOrDefault("Hard", 0);
%>
<div class="difficulty-stats">
    <span>😊 Easy: <%= easy %></span>
    <span>😐 Medium: <%= medium %></span>
    <span>😰 Hard: <%= hard %></span>
</div>
```

## Database Setup

### Run SQL Script
```bash
psql -U postgres -d paperwise_db -f create_difficulty_votes_table.sql
```

### Verify Table Creation
```sql
\d difficulty_votes
```

## Testing Checklist

- [ ] Table created successfully
- [ ] First vote inserts new record
- [ ] Second vote updates existing record
- [ ] Statistics query returns correct counts
- [ ] User vote retrieval works
- [ ] Invalid difficulty level rejected
- [ ] Negative IDs rejected
- [ ] Foreign key constraints work
- [ ] Cascade delete works
- [ ] Indexes created

## Files Created

1. `src/java/com/paperwise/dao/DifficultyVoteDAO.java` - DAO implementation
2. `create_difficulty_votes_table.sql` - Database schema
3. `DIFFICULTY_VOTE_DAO.md` - This documentation

## Next Steps

1. Run `create_difficulty_votes_table.sql` to create the table
2. Create `DifficultyVoteServlet` to handle vote submissions
3. Update student dashboard JSP to display difficulty buttons
4. Add difficulty statistics to Paper model
5. Update StudentDashboardServlet to fetch difficulty stats
6. Test the complete flow

## Notes

- Uses JNDI DataSource (same as other DAOs)
- PostgreSQL-specific UPSERT syntax
- Thread-safe (uses connection pooling)
- Follows existing DAO patterns in the project
- Comprehensive error handling and logging
