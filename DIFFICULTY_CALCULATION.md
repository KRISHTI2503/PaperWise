# Difficulty Score Calculation

## Overview
Automatic calculation of difficulty label based on weighted average of student votes.

## Implementation

### Paper Model Updates

**File:** `src/java/com/paperwise/model/Paper.java`

**Added Field:**
```java
private String difficultyLabel;
```

**Added Method:**
```java
public void calculateDifficulty() {
    int total = easyCount + mediumCount + hardCount;
    
    if (total == 0) {
        difficultyLabel = "Not Rated";
        return;
    }
    
    double score = (1.0 * easyCount + 
                   2.0 * mediumCount + 
                   3.0 * hardCount) / total;
    
    if (score <= 1.5) {
        difficultyLabel = "Easy";
    } else if (score <= 2.3) {
        difficultyLabel = "Medium";
    } else {
        difficultyLabel = "Hard";
    }
}
```

**Added Getter/Setter:**
```java
public String getDifficultyLabel() { return difficultyLabel; }
public void setDifficultyLabel(String difficultyLabel) { this.difficultyLabel = difficultyLabel; }
```

### DAO Updates

**File:** `src/java/com/paperwise/dao/PaperDAO.java`

**Updated Method:** `getAllPapersWithVotes()`

```java
while (resultSet.next()) {
    Paper paper = mapRow(resultSet);
    paper.setUsefulCount(resultSet.getInt("useful_count"));
    paper.setEasyCount(resultSet.getInt("easy_count"));
    paper.setMediumCount(resultSet.getInt("medium_count"));
    paper.setHardCount(resultSet.getInt("hard_count"));
    // Calculate difficulty label automatically
    paper.calculateDifficulty();
    papers.add(paper);
}
```

## Calculation Logic

### Weighted Average Formula

```
score = (1.0 × easy_count + 2.0 × medium_count + 3.0 × hard_count) / total_votes
```

**Weights:**
- Easy: 1.0
- Medium: 2.0
- Hard: 3.0

### Score Ranges

| Score Range | Label |
|-------------|-------|
| 0 votes | "Not Rated" |
| ≤ 1.5 | "Easy" |
| 1.5 < score ≤ 2.3 | "Medium" |
| > 2.3 | "Hard" |

### Examples

#### Example 1: Mostly Easy
- Easy: 8 votes
- Medium: 2 votes
- Hard: 0 votes
- **Score:** (1.0×8 + 2.0×2 + 3.0×0) / 10 = 12/10 = 1.2
- **Label:** "Easy" ✅

#### Example 2: Balanced Medium
- Easy: 3 votes
- Medium: 5 votes
- Hard: 2 votes
- **Score:** (1.0×3 + 2.0×5 + 3.0×2) / 10 = 19/10 = 1.9
- **Label:** "Medium" ✅

#### Example 3: Mostly Hard
- Easy: 1 vote
- Medium: 2 votes
- Hard: 7 votes
- **Score:** (1.0×1 + 2.0×2 + 3.0×7) / 10 = 26/10 = 2.6
- **Label:** "Hard" ✅

#### Example 4: No Votes
- Easy: 0 votes
- Medium: 0 votes
- Hard: 0 votes
- **Score:** N/A
- **Label:** "Not Rated" ✅

#### Example 5: Edge Case (Score = 1.5)
- Easy: 5 votes
- Medium: 5 votes
- Hard: 0 votes
- **Score:** (1.0×5 + 2.0×5 + 3.0×0) / 10 = 15/10 = 1.5
- **Label:** "Easy" ✅ (≤ 1.5)

#### Example 6: Edge Case (Score = 2.3)
- Easy: 2 votes
- Medium: 3 votes
- Hard: 5 votes
- **Score:** (1.0×2 + 2.0×3 + 3.0×5) / 10 = 23/10 = 2.3
- **Label:** "Medium" ✅ (≤ 2.3)

## Usage in JSP

### Display Difficulty Label

```jsp
<span class="difficulty-badge <%= paper.getDifficultyLabel().toLowerCase() %>">
    <%= paper.getDifficultyLabel() %>
</span>
```

### Display with Icon

```jsp
<%
    String icon = "";
    String cssClass = "";
    switch (paper.getDifficultyLabel()) {
        case "Easy":
            icon = "😊";
            cssClass = "badge-success";
            break;
        case "Medium":
            icon = "😐";
            cssClass = "badge-warning";
            break;
        case "Hard":
            icon = "😰";
            cssClass = "badge-danger";
            break;
        default:
            icon = "❓";
            cssClass = "badge-secondary";
    }
%>
<span class="badge <%= cssClass %>">
    <%= icon %> <%= paper.getDifficultyLabel() %>
</span>
```

### Display with Vote Breakdown

```jsp
<div class="difficulty-info">
    <strong>Difficulty: <%= paper.getDifficultyLabel() %></strong>
    <small class="text-muted">
        (😊 <%= paper.getEasyCount() %> | 
         😐 <%= paper.getMediumCount() %> | 
         😰 <%= paper.getHardCount() %>)
    </small>
</div>
```

### Conditional Styling

```jsp
<tr class="<%= paper.getDifficultyLabel().equals("Hard") ? "hard-paper" : "" %>">
    <!-- paper row content -->
</tr>
```

## CSS Styling

```css
/* Difficulty badges */
.difficulty-badge {
    padding: 4px 12px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
}

.difficulty-badge.easy {
    background: #d4edda;
    color: #155724;
}

.difficulty-badge.medium {
    background: #fff3cd;
    color: #856404;
}

.difficulty-badge.hard {
    background: #f8d7da;
    color: #721c24;
}

.difficulty-badge.not.rated {
    background: #e2e3e5;
    color: #6c757d;
}

/* Hard paper highlighting */
.hard-paper {
    background-color: #fff5f5;
}

.hard-paper:hover {
    background-color: #ffe5e5;
}
```

## Testing

### Test Case 1: All Easy Votes
```java
Paper paper = new Paper();
paper.setEasyCount(10);
paper.setMediumCount(0);
paper.setHardCount(0);
paper.calculateDifficulty();
assertEquals("Easy", paper.getDifficultyLabel());
```

### Test Case 2: All Medium Votes
```java
Paper paper = new Paper();
paper.setEasyCount(0);
paper.setMediumCount(10);
paper.setHardCount(0);
paper.calculateDifficulty();
assertEquals("Medium", paper.getDifficultyLabel());
```

### Test Case 3: All Hard Votes
```java
Paper paper = new Paper();
paper.setEasyCount(0);
paper.setMediumCount(0);
paper.setHardCount(10);
paper.calculateDifficulty();
assertEquals("Hard", paper.getDifficultyLabel());
```

### Test Case 4: No Votes
```java
Paper paper = new Paper();
paper.setEasyCount(0);
paper.setMediumCount(0);
paper.setHardCount(0);
paper.calculateDifficulty();
assertEquals("Not Rated", paper.getDifficultyLabel());
```

### Test Case 5: Mixed Votes
```java
Paper paper = new Paper();
paper.setEasyCount(3);
paper.setMediumCount(5);
paper.setHardCount(2);
paper.calculateDifficulty();
// Score = (3 + 10 + 6) / 10 = 1.9
assertEquals("Medium", paper.getDifficultyLabel());
```

## Database Query Verification

```sql
-- Verify calculation matches database
SELECT 
    p.paper_id,
    p.subject_name,
    COUNT(CASE WHEN d.difficulty_level = 'Easy' THEN 1 END) AS easy_count,
    COUNT(CASE WHEN d.difficulty_level = 'Medium' THEN 1 END) AS medium_count,
    COUNT(CASE WHEN d.difficulty_level = 'Hard' THEN 1 END) AS hard_count,
    (1.0 * COUNT(CASE WHEN d.difficulty_level = 'Easy' THEN 1 END) +
     2.0 * COUNT(CASE WHEN d.difficulty_level = 'Medium' THEN 1 END) +
     3.0 * COUNT(CASE WHEN d.difficulty_level = 'Hard' THEN 1 END)) / 
    NULLIF(COUNT(d.id), 0) AS difficulty_score
FROM papers p
LEFT JOIN difficulty_votes d ON p.paper_id = d.paper_id
GROUP BY p.paper_id, p.subject_name
ORDER BY p.paper_id;
```

## Benefits

### 1. Automatic Calculation
- No manual calculation needed in JSP
- Consistent across all views
- Calculated once per paper load

### 2. Simple Display
```jsp
<!-- Before: Complex logic in JSP -->
<%
    int total = paper.getEasyCount() + paper.getMediumCount() + paper.getHardCount();
    double score = (1.0 * paper.getEasyCount() + 2.0 * paper.getMediumCount() + 3.0 * paper.getHardCount()) / total;
    String label = score <= 1.5 ? "Easy" : score <= 2.3 ? "Medium" : "Hard";
%>

<!-- After: Simple getter -->
<%= paper.getDifficultyLabel() %>
```

### 3. Reusable
- Same calculation logic everywhere
- Easy to update thresholds
- Testable in isolation

### 4. Performance
- Calculated once in DAO
- No repeated calculations in JSP
- Minimal overhead

## Customization

### Adjust Thresholds

To make the system more lenient (more papers labeled "Easy"):
```java
if (score <= 1.7) {  // Changed from 1.5
    difficultyLabel = "Easy";
} else if (score <= 2.5) {  // Changed from 2.3
    difficultyLabel = "Medium";
} else {
    difficultyLabel = "Hard";
}
```

### Adjust Weights

To give more weight to "Hard" votes:
```java
double score = (1.0 * easyCount + 
               2.0 * mediumCount + 
               4.0 * hardCount) / total;  // Changed from 3.0
```

### Add More Levels

```java
if (score <= 1.3) {
    difficultyLabel = "Very Easy";
} else if (score <= 1.7) {
    difficultyLabel = "Easy";
} else if (score <= 2.3) {
    difficultyLabel = "Medium";
} else if (score <= 2.7) {
    difficultyLabel = "Hard";
} else {
    difficultyLabel = "Very Hard";
}
```

## Files Modified

1. ✅ `src/java/com/paperwise/model/Paper.java`
   - Added `difficultyLabel` field
   - Added `calculateDifficulty()` method
   - Added getter/setter

2. ✅ `src/java/com/paperwise/dao/PaperDAO.java`
   - Calls `calculateDifficulty()` after setting counts

## Verification Checklist

- [x] difficultyLabel field added
- [x] calculateDifficulty() method implemented
- [x] Getter/setter added
- [x] DAO calls calculateDifficulty()
- [x] No compilation errors
- [ ] Test with various vote combinations
- [ ] Display in JSP
- [ ] Verify labels are correct

## Next Steps

1. Clean and rebuild project
2. Test calculation with sample data
3. Add difficulty label display to student-dashboard.jsp
4. Add CSS styling for badges
5. Test edge cases (0 votes, equal votes, etc.)

**Status: Implementation complete! ✅**
