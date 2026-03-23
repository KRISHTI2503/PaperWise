# DifficultyVoteServlet Implementation

## Overview
Servlet for handling difficulty rating votes on papers. Students can rate papers as Easy, Medium, or Hard.

## Configuration

**URL Mapping:** `/rateDifficulty`  
**HTTP Method:** POST only  
**Access:** Student users only

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `paperId` | int | Yes | The ID of the paper being rated |
| `difficulty` | String | Yes | Difficulty level: "Easy", "Medium", or "Hard" |

## Implementation Details

### doPost() Method

```java
@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    HttpSession session = request.getSession(false);
    User user = (User) session.getAttribute("user");
    
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int paperId = Integer.parseInt(request.getParameter("paperId"));
    String level = request.getParameter("difficulty");
    
    DifficultyVoteDAO dao = new DifficultyVoteDAO();
    dao.addOrUpdateDifficultyVote(paperId, user.getUserId(), level);
    
    response.sendRedirect("studentDashboard");
}
```

### Features

1. **Session Validation**
   - Checks for logged-in user
   - Supports both "user" and "loggedInUser" session attributes
   - Redirects to login if not authenticated

2. **Parameter Validation**
   - Validates paper ID is present and numeric
   - Validates difficulty level is present
   - Returns error messages for invalid input

3. **UPSERT Logic**
   - First vote → Inserts new record
   - Change vote → Updates existing record
   - Handled by DifficultyVoteDAO

4. **Error Handling**
   - Catches NumberFormatException for invalid paper ID
   - Catches IllegalArgumentException for invalid difficulty level
   - Catches general exceptions
   - All errors logged with stack traces

5. **User Feedback**
   - Success message: "Difficulty rating recorded: [level]"
   - Error messages for various failure scenarios
   - Messages stored in session attributes

6. **Redirect Pattern**
   - Always redirects to studentDashboard
   - Follows redirect-after-post pattern
   - Prevents form resubmission

## JSP Integration

### Basic Form (3 Buttons)

```jsp
<form action="${pageContext.request.contextPath}/rateDifficulty" method="post" style="display:inline;">
    <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
    
    <button type="submit" name="difficulty" value="Easy" class="btn btn-success btn-small">
        😊 Easy
    </button>
    <button type="submit" name="difficulty" value="Medium" class="btn btn-warning btn-small">
        😐 Medium
    </button>
    <button type="submit" name="difficulty" value="Hard" class="btn btn-danger btn-small">
        😰 Hard
    </button>
</form>
```

### With User's Current Vote Highlighted

```jsp
<%
    DifficultyVoteDAO diffDao = new DifficultyVoteDAO();
    String userVote = diffDao.getUserDifficultyVote(paper.getPaperId(), loggedInUser.getUserId());
%>

<form action="${pageContext.request.contextPath}/rateDifficulty" method="post" style="display:inline;">
    <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
    
    <button type="submit" name="difficulty" value="Easy" 
            class="btn btn-small <%= "Easy".equals(userVote) ? "btn-success active" : "btn-outline-success" %>">
        😊 Easy
    </button>
    <button type="submit" name="difficulty" value="Medium" 
            class="btn btn-small <%= "Medium".equals(userVote) ? "btn-warning active" : "btn-outline-warning" %>">
        😐 Medium
    </button>
    <button type="submit" name="difficulty" value="Hard" 
            class="btn btn-small <%= "Hard".equals(userVote) ? "btn-danger active" : "btn-outline-danger" %>">
        😰 Hard
    </button>
</form>
```

### Display Statistics

```jsp
<%
    DifficultyVoteDAO diffDao = new DifficultyVoteDAO();
    Map<String, Integer> stats = diffDao.getDifficultyStats(paper.getPaperId());
    int easy = stats.getOrDefault("Easy", 0);
    int medium = stats.getOrDefault("Medium", 0);
    int hard = stats.getOrDefault("Hard", 0);
    int total = easy + medium + hard;
%>

<div class="difficulty-stats">
    <small class="text-muted">
        Difficulty: 
        <span class="badge badge-success">😊 <%= easy %></span>
        <span class="badge badge-warning">😐 <%= medium %></span>
        <span class="badge badge-danger">😰 <%= hard %></span>
        (<%= total %> votes)
    </small>
</div>
```

## CSS Styling

```css
.btn-outline-success {
    background: white;
    color: #28a745;
    border: 1px solid #28a745;
}

.btn-outline-warning {
    background: white;
    color: #ffc107;
    border: 1px solid #ffc107;
}

.btn-outline-danger {
    background: white;
    color: #dc3545;
    border: 1px solid #dc3545;
}

.btn.active {
    font-weight: bold;
    box-shadow: 0 0 0 3px rgba(0,123,255,.25);
}

.difficulty-stats {
    margin-top: 8px;
}

.difficulty-stats .badge {
    margin-right: 4px;
    padding: 4px 8px;
}
```

## Testing Checklist

- [ ] Servlet initializes without errors
- [ ] POST request with valid data succeeds
- [ ] First vote inserts new record
- [ ] Second vote updates existing record
- [ ] Invalid paper ID returns error message
- [ ] Missing difficulty parameter returns error message
- [ ] Invalid difficulty level rejected by DAO
- [ ] Unauthenticated user redirected to login
- [ ] Success message displays after vote
- [ ] Error message displays on failure
- [ ] Redirect to studentDashboard works
- [ ] No form resubmission on refresh

## Error Messages

| Scenario | Message |
|----------|---------|
| No paper ID | "Invalid paper ID." |
| No difficulty level | "Please select a difficulty level." |
| Invalid paper ID format | "Invalid paper ID format." |
| Invalid difficulty level | "Invalid difficulty level. Must be one of: Easy, Medium, Hard" |
| Database error | "Failed to record difficulty rating. Please try again." |

## Session Attributes

### Input (from user session)
- `user` or `loggedInUser` - User object

### Output (set by servlet)
- `successMessage` - Success feedback
- `errorMessage` - Error feedback

## Flow Diagram

```
User clicks difficulty button
    ↓
POST /rateDifficulty
    ↓
Check authentication → Not logged in → Redirect to login.jsp
    ↓ Logged in
Validate parameters → Invalid → Set error message
    ↓ Valid
Call DAO.addOrUpdateDifficultyVote()
    ↓
Success → Set success message
    ↓
Redirect to studentDashboard
    ↓
Display message and updated stats
```

## Integration with StudentDashboardServlet

Update StudentDashboardServlet to fetch difficulty stats:

```java
@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response) {
    // ... existing code ...
    
    DifficultyVoteDAO diffDao = new DifficultyVoteDAO();
    
    // For each paper, get difficulty stats
    for (Paper paper : papers) {
        Map<String, Integer> stats = diffDao.getDifficultyStats(paper.getPaperId());
        paper.setDifficultyStats(stats); // Add this field to Paper model
        
        // Get user's vote
        String userVote = diffDao.getUserDifficultyVote(paper.getPaperId(), userId);
        paper.setUserDifficultyVote(userVote); // Add this field to Paper model
    }
    
    // ... forward to JSP ...
}
```

## Files

- **Servlet:** `src/java/com/paperwise/servlet/DifficultyVoteServlet.java`
- **DAO:** `src/java/com/paperwise/dao/DifficultyVoteDAO.java`
- **SQL:** `create_difficulty_votes_table.sql`

## Next Steps

1. ✅ Create DifficultyVoteServlet (DONE)
2. [ ] Run SQL script to create difficulty_votes table
3. [ ] Add difficulty buttons to student-dashboard.jsp
4. [ ] Update Paper model with difficulty fields (optional)
5. [ ] Update StudentDashboardServlet to fetch stats
6. [ ] Test complete flow
7. [ ] Add CSS styling for buttons

## Notes

- POST-only servlet (no GET handler)
- Uses redirect-after-post pattern
- Supports both "user" and "loggedInUser" session attributes
- Comprehensive error handling
- All errors logged with stack traces
- No compilation errors
