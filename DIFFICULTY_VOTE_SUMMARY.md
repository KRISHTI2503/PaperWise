# DifficultyVoteDAO - Implementation Summary

## ✅ Status: COMPLETED

The DifficultyVoteDAO has been successfully created with all requested features.

## 📁 Files Created

1. **src/java/com/paperwise/dao/DifficultyVoteDAO.java** ✅
2. **create_difficulty_votes_table.sql** ✅
3. **DIFFICULTY_VOTE_DAO.md** (Documentation) ✅

## 🔧 Implemented Methods

### 1️⃣ addOrUpdateDifficultyVote() ✅

**Signature:**
```java
public void addOrUpdateDifficultyVote(int paperId, int userId, String level)
```

**Features:**
- ✅ Uses PostgreSQL UPSERT with `ON CONFLICT`
- ✅ First vote → INSERT new record
- ✅ Change vote → UPDATE existing record
- ✅ Uses JNDI DataSource (not DBConnection)
- ✅ Input validation (positive IDs, valid difficulty level)
- ✅ Exception handling with stack traces

**SQL:**
```sql
INSERT INTO difficulty_votes (paper_id, user_id, difficulty_level) 
VALUES (?, ?, ?) 
ON CONFLICT (paper_id, user_id) 
DO UPDATE SET difficulty_level = EXCLUDED.difficulty_level
```

### 2️⃣ getDifficultyStats() ✅

**Signature:**
```java
public Map<String, Integer> getDifficultyStats(int paperId)
```

**Features:**
- ✅ Returns `Map<String, Integer>` with vote counts
- ✅ Groups by difficulty level
- ✅ Uses JNDI DataSource
- ✅ Exception handling with stack traces

**SQL:**
```sql
SELECT difficulty_level, COUNT(*) as count 
FROM difficulty_votes 
WHERE paper_id = ? 
GROUP BY difficulty_level
```

**Example Return:**
```java
{
    "Easy": 5,
    "Medium": 12,
    "Hard": 3
}
```

### 3️⃣ getUserDifficultyVote() ✅ (Bonus)

**Signature:**
```java
public String getUserDifficultyVote(int paperId, int userId)
```

**Features:**
- ✅ Returns user's current vote
- ✅ Returns null if no vote exists
- ✅ Useful for highlighting user's selection in UI

## 🗄️ Database Schema

**Table:** `difficulty_votes`

```sql
CREATE TABLE difficulty_votes (
    id SERIAL PRIMARY KEY,
    paper_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    difficulty_level VARCHAR(20) NOT NULL 
        CHECK (difficulty_level IN ('Easy', 'Medium', 'Hard')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_difficulty_vote UNIQUE (paper_id, user_id)
);
```

**Key Features:**
- ✅ UNIQUE constraint prevents duplicate votes
- ✅ CHECK constraint validates difficulty levels
- ✅ Foreign keys with CASCADE delete
- ✅ Indexes for performance
- ✅ Auto-update timestamp trigger

## 📊 Usage Example

### In Servlet:
```java
@WebServlet("/voteDifficulty")
public class DifficultyVoteServlet extends HttpServlet {
    
    private DifficultyVoteDAO dao;
    
    @Override
    public void init() {
        dao = new DifficultyVoteDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        int paperId = Integer.parseInt(request.getParameter("paperId"));
        String level = request.getParameter("level");
        User user = (User) request.getSession().getAttribute("loggedInUser");
        
        dao.addOrUpdateDifficultyVote(paperId, user.getUserId(), level);
        
        response.sendRedirect("studentDashboard");
    }
}
```

### In JSP:
```jsp
<form action="voteDifficulty" method="post" style="display:inline;">
    <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
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

<%
    Map<String, Integer> stats = dao.getDifficultyStats(paper.getPaperId());
%>
<div>
    Easy: <%= stats.getOrDefault("Easy", 0) %> |
    Medium: <%= stats.getOrDefault("Medium", 0) %> |
    Hard: <%= stats.getOrDefault("Hard", 0) %>
</div>
```

## 🚀 Next Steps

1. **Create Database Table:**
   ```bash
   psql -U postgres -d paperwise_db -f create_difficulty_votes_table.sql
   ```

2. **Create DifficultyVoteServlet:**
   - Map to `/voteDifficulty`
   - Handle POST requests
   - Call `addOrUpdateDifficultyVote()`

3. **Update Student Dashboard:**
   - Add difficulty vote buttons
   - Display statistics
   - Highlight user's current vote

4. **Update Paper Model (Optional):**
   - Add difficulty stats fields
   - Add getter/setter methods

5. **Update StudentDashboardServlet:**
   - Fetch difficulty stats for each paper
   - Set as request attributes

## ✅ Verification

- [x] DifficultyVoteDAO.java created
- [x] Uses JNDI DataSource (matches project pattern)
- [x] PostgreSQL UPSERT with ON CONFLICT
- [x] getDifficultyStats() returns Map<String, Integer>
- [x] Input validation implemented
- [x] Exception handling with stack traces
- [x] No compilation errors
- [x] SQL script created
- [x] Documentation created

## 📝 Notes

- Uses JNDI DataSource (`java:comp/env/jdbc/paperwise`) instead of DBConnection
- Follows same pattern as VoteDAO
- Thread-safe (connection pooling)
- PostgreSQL-specific syntax (ON CONFLICT)
- Comprehensive error handling
- Validates difficulty levels: Easy, Medium, Hard (case-insensitive)

**Status: Ready to use! ✅**
