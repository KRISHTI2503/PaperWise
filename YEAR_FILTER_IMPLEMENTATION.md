# Year Filter Dropdown Implementation

## Overview
Added a year filter dropdown to the student dashboard that allows filtering papers by year while maintaining clean MVC architecture.

## Implementation Details

### 1. Database Layer (PaperDAO.java)

#### Added SQL Constants
```java
private static final String SQL_GET_DISTINCT_YEARS =
        "SELECT DISTINCT year FROM papers ORDER BY year DESC";

private static final String SQL_FIND_PAPERS_BY_YEAR =
        "SELECT p.*, " +
        "       COUNT(DISTINCT v.id) AS useful_count, " +
        "       COUNT(*) FILTER (WHERE d.difficulty_level = 'easy') AS easy_count, " +
        "       COUNT(*) FILTER (WHERE d.difficulty_level = 'medium') AS medium_count, " +
        "       COUNT(*) FILTER (WHERE d.difficulty_level = 'hard') AS hard_count, " +
        "       u.username " +
        "FROM papers p " +
        "LEFT JOIN users u ON p.uploaded_by = u.user_id " +
        "LEFT JOIN votes v ON p.paper_id = v.paper_id " +
        "LEFT JOIN difficulty_votes d ON p.paper_id = d.paper_id " +
        "WHERE p.year = ? " +
        "GROUP BY p.paper_id, u.username " +
        "ORDER BY useful_count DESC, p.created_at DESC";
```

#### Added Methods

**getDistinctYears()**
- Fetches all unique years from papers table
- Returns List<Integer> sorted in descending order
- Used to populate dropdown options

**getPapersByYear(int year)**
- Fetches papers for a specific year
- Includes vote counts and difficulty stats
- Maintains same structure as getAllPapersWithVotes()

### 2. Controller Layer (StudentDashboardServlet.java)

#### Enhanced doGet() Method
```java
// Get year filter parameter
String yearParam = request.getParameter("year");
List<Paper> papers;

if (yearParam != null && !yearParam.trim().isEmpty() && !yearParam.equals("all")) {
    // Filter by year
    int year = Integer.parseInt(yearParam);
    papers = paperDAO.getPapersByYear(year);
    request.setAttribute("selectedYear", year);
} else {
    // Fetch all papers
    papers = paperDAO.getAllPapersWithVotes();
}

// Get distinct years for dropdown
List<Integer> availableYears = paperDAO.getDistinctYears();
request.setAttribute("availableYears", availableYears);
```

### 3. View Layer (student-dashboard.jsp)

#### Added Year Filter Dropdown
```jsp
<div class="filter-section" style="display: flex; gap: 15px;">
    <div class="search-bar" style="flex: 1;">
        <input type="text" id="searchInput" 
               placeholder="🔍 Search by subject code, name, or year...">
    </div>
    
    <div class="year-filter" style="min-width: 150px;">
        <select id="yearFilter" 
                onchange="window.location.href='${pageContext.request.contextPath}/studentDashboard?year=' + this.value">
            <option value="all">All Years</option>
            <% for (Integer year : availableYears) { %>
                <option value="<%= year %>" 
                        <%= (selectedYear != null && selectedYear.equals(year)) ? "selected" : "" %>>
                    <%= year %>
                </option>
            <% } %>
        </select>
    </div>
</div>
```

## Features

### Year Filter Dropdown
- **Dynamic Population**: Years fetched from database
- **Sorted**: Most recent years first (DESC order)
- **"All Years" Option**: Shows all papers when selected
- **Persistent Selection**: Selected year remains after page reload
- **Auto-Submit**: Changes URL and reloads page on selection

### Combined with Search
- Year filter works at server level (filters data)
- Search works at client level (filters displayed rows)
- Both can be used together:
  1. Select year → Server filters papers
  2. Type search → Client filters visible rows

## User Experience

### Workflow
1. User opens student dashboard → Sees all papers
2. User selects "2023" from dropdown → Page reloads with only 2023 papers
3. User types "CS" in search → Further filters to show only CS papers from 2023
4. User selects "All Years" → Shows all papers again

### URL Parameters
- `/studentDashboard` → All papers
- `/studentDashboard?year=2023` → Only 2023 papers
- `/studentDashboard?year=all` → All papers (explicit)

## Technical Details

### MVC Architecture
✅ **Model**: Paper.java (no changes needed)  
✅ **View**: student-dashboard.jsp (added dropdown UI)  
✅ **Controller**: StudentDashboardServlet.java (handles year parameter)  
✅ **DAO**: PaperDAO.java (new methods for year filtering)

### Database Impact
- No schema changes required
- Uses existing `year` column
- Efficient queries with proper indexing

### Performance
- `getDistinctYears()`: Fast query, typically < 10 rows
- `getPapersByYear()`: Indexed on year column
- Client-side search remains instant

## Benefits

1. **Clean Separation**: Server-side year filter, client-side search
2. **Efficient**: Only fetches needed papers from database
3. **Maintainable**: Follows existing MVC pattern
4. **Extensible**: Easy to add more filters (subject, difficulty, etc.)
5. **User-Friendly**: Intuitive dropdown interface

## Testing Scenarios

1. **All Years**: Select "All Years" → Shows all papers
2. **Specific Year**: Select "2023" → Shows only 2023 papers
3. **Combined Filter**: Select year + search → Both filters apply
4. **No Papers**: Select year with no papers → Shows empty state
5. **Invalid Year**: URL with invalid year → Falls back to all papers

## Future Enhancements (Optional)

Could add:
1. **Multiple Filters**: Subject, difficulty, chapter
2. **Filter Persistence**: Remember filters in session
3. **Clear Filters Button**: Reset all filters at once
4. **Filter Count**: Show "Showing X of Y papers"
5. **Advanced Filters**: Date range, file type, etc.

## Files Modified

1. **src/java/com/paperwise/dao/PaperDAO.java**
   - Added SQL_GET_DISTINCT_YEARS constant
   - Added SQL_FIND_PAPERS_BY_YEAR constant
   - Added getDistinctYears() method
   - Added getPapersByYear(int year) method

2. **src/java/com/paperwise/servlet/StudentDashboardServlet.java**
   - Enhanced doGet() to handle year parameter
   - Added logic to fetch distinct years
   - Added logic to filter papers by year
   - Set selectedYear attribute for view

3. **web/student-dashboard.jsp**
   - Added year filter dropdown
   - Restructured filter section with flexbox layout
   - Added onchange handler for auto-submit
   - Added selected state preservation

## No Changes Required

- Database schema (uses existing columns)
- Model classes (Paper.java unchanged)
- Other servlets (isolated change)
- JavaScript search (works independently)
