# Marked Papers Feature Implementation

## Overview
Implemented a feature to allow students to view only papers they have marked as useful, ordered by when they marked them (most recent first).

---

## Changes Made

### 1. VoteDAO.java - New Method

**Added**: `getUserMarkedPapersWithDetails(int userId)`

**Purpose**: Retrieves all papers marked by a specific user with full details and vote counts.

**Key Features**:
- Filters papers by user_id from session (secure, user-specific)
- Orders by `marked_at` (votes.created_at) DESC - most recently marked first
- Includes all paper details, vote counts, and difficulty stats
- Returns fully populated Paper objects with `alreadyMarked` flag set to true

**SQL Query**:
```sql
SELECT p.*, 
       COUNT(DISTINCT v.id) AS useful_count, 
       COUNT(*) FILTER (WHERE d.difficulty_level = 'easy') AS easy_count, 
       COUNT(*) FILTER (WHERE d.difficulty_level = 'medium') AS medium_count, 
       COUNT(*) FILTER (WHERE d.difficulty_level = 'hard') AS hard_count, 
       u.username, 
       m.created_at AS marked_at 
FROM papers p 
JOIN votes m ON p.paper_id = m.paper_id 
LEFT JOIN users u ON p.uploaded_by = u.user_id 
LEFT JOIN votes v ON p.paper_id = v.paper_id 
LEFT JOIN difficulty_votes d ON p.paper_id = d.paper_id 
WHERE m.user_id = ? 
GROUP BY p.paper_id, u.username, m.created_at 
ORDER BY m.created_at DESC
```

**Security**: 
- Uses parameterized query (prevents SQL injection)
- Filters by logged-in user's ID from session
- Does NOT fetch all marked records globally

---

### 2. StudentDashboardServlet.java - View Mode Support

**Added**: Support for `view=marked` parameter

**Logic**:
```java
String viewParam = request.getParameter("view");
boolean showOnlyMarked = "marked".equalsIgnoreCase(viewParam);

if (showOnlyMarked) {
    // Show only papers marked by this user, ordered by marked_at DESC
    papers = voteDAO.getUserMarkedPapersWithDetails(loggedInUser.getUserId());
    request.setAttribute("viewMode", "marked");
} else {
    // Show all papers (existing logic)
    // ... year filter, vote counts, etc.
}
```

**Session Filtering**:
- Reads `loggedInUser` from session
- Passes `loggedInUser.getUserId()` to DAO method
- Ensures user only sees their own marked papers

**No Pagination Issues**:
- Current implementation does not use LIMIT/OFFSET
- All marked papers are loaded at once
- If pagination is added later, ensure:
  - Page parameter is read from request
  - Offset calculation: `int offset = (page - 1) * limit;`
  - Page number maintained in links

---

### 3. student-dashboard.jsp - View Filter Dropdown

**Added**: View filter dropdown before search bar

**HTML**:
```html
<select id="viewFilter" onchange="window.location.href='...?view=' + this.value">
    <option value="all">All Papers</option>
    <option value="marked">My Marked Papers</option>
</select>
```

**Features**:
- Dropdown persists selected view mode
- "All Papers" - shows all papers (default)
- "My Marked Papers" - shows only papers marked by logged-in user
- Ordered by when marked (most recent first)

---

## User Flow

1. Student logs in and goes to dashboard
2. By default, sees "All Papers" view
3. Clicks dropdown and selects "My Marked Papers"
4. Page reloads with `?view=marked` parameter
5. Servlet detects view mode and calls `getUserMarkedPapersWithDetails(userId)`
6. DAO queries database for papers marked by this user, ordered by marked_at DESC
7. Papers displayed in table, ordered by most recently marked first
8. Student can switch back to "All Papers" view anytime

---

## Security Verification

✅ **Session-based filtering**: User ID read from session, not request parameter
✅ **SQL injection protection**: Parameterized queries used
✅ **User isolation**: Each user only sees their own marked papers
✅ **No global data leak**: Does NOT fetch all marked records

---

## Testing Checklist

- [ ] Student can view all papers (default view)
- [ ] Student can switch to "My Marked Papers" view
- [ ] Marked papers are ordered by most recent first
- [ ] Only papers marked by logged-in user are shown
- [ ] Switching back to "All Papers" works correctly
- [ ] Search functionality works in both views
- [ ] Year filter works in "All Papers" view
- [ ] No pagination reset issues (if pagination added)

---

## Future Enhancements (Optional)

If pagination is needed:
1. Add LIMIT and OFFSET to SQL query
2. Read page parameter: `int page = Integer.parseInt(request.getParameter("page") != null ? request.getParameter("page") : "1");`
3. Calculate offset: `int offset = (page - 1) * limit;`
4. Pass page number in links: `?view=marked&page=2`
5. Display pagination controls in JSP

---

## Files Modified

1. `src/java/com/paperwise/dao/VoteDAO.java`
   - Added SQL constant: `SQL_GET_USER_MARKED_PAPERS_WITH_DETAILS`
   - Added method: `getUserMarkedPapersWithDetails(int userId)`

2. `src/java/com/paperwise/servlet/StudentDashboardServlet.java`
   - Added view mode detection
   - Added conditional logic for marked papers view
   - Maintained existing year filter and search functionality

3. `web/student-dashboard.jsp`
   - Added view filter dropdown
   - Positioned before search bar
   - Persists selected view mode

---

## Compliance

✅ No changes to existing modules (upload, voting, difficulty)
✅ Clean MVC separation maintained
✅ Proper session management
✅ SQL injection protection
✅ User-specific data filtering

---

**Status**: ✅ COMPLETE
**Date**: Current Session
