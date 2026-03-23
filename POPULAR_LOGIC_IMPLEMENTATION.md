# Popular Badge Logic Implementation

## Overview
Implemented clear, dynamic "Popular" badge logic for papers based on useful vote count.

## Business Rule
A paper is tagged as **POPULAR** if and only if:
```
usefulCount >= 3
```

## Implementation Details

### 1. Paper Model (Paper.java)
Added constant and method for clean encapsulation:

```java
/** Minimum useful votes required for a paper to be considered "Popular" */
public static final int POPULAR_THRESHOLD = 3;

/**
 * Determines if this paper is popular based on useful vote count.
 * A paper is considered popular if it has at least POPULAR_THRESHOLD useful votes.
 * 
 * @return true if usefulCount >= POPULAR_THRESHOLD, false otherwise
 */
public boolean isPopular() {
    return usefulCount >= POPULAR_THRESHOLD;
}
```

### 2. JSP View (student-dashboard.jsp)
Simplified from complex threshold calculation to clean method call:

**Before (Complex):**
```jsp
<%
int popularThreshold = papers.size() > 0 ? papers.get(0).getUsefulCount() : 0;
boolean isPopular = paper.getUsefulCount() > 0 && 
                    paper.getUsefulCount() >= popularThreshold && 
                    popularThreshold > 2;
%>
<% if (isPopular) { %>
    <span class="badge badge-popular">Popular</span>
<% } %>
```

**After (Clean):**
```jsp
<% if (paper.isPopular()) { %>
    <span class="badge badge-popular">Popular</span>
<% } %>
```

## Key Features

### ✅ Not Hardcoded
- Threshold defined as constant: `Paper.POPULAR_THRESHOLD`
- Easy to change in one place
- Can be made configurable later if needed

### ✅ Not Stored in Database
- Computed dynamically based on `usefulCount`
- No additional database column needed
- Always reflects current vote count

### ✅ Clean Architecture
- Business logic in model layer (Paper.java)
- View layer (JSP) just calls method
- Single source of truth for popular logic

### ✅ Maintainable
- Change threshold in one place: `Paper.POPULAR_THRESHOLD`
- Method name clearly expresses intent: `isPopular()`
- No complex conditions scattered in JSP

## Examples

| Useful Count | Is Popular? | Badge Shown? |
|--------------|-------------|--------------|
| 0            | No          | No           |
| 1            | No          | No           |
| 2            | No          | No           |
| 3            | **Yes**     | **Yes**      |
| 4            | **Yes**     | **Yes**      |
| 10           | **Yes**     | **Yes**      |

## Changing the Threshold

To change the popular threshold (e.g., to 5 votes):

1. Open `src/java/com/paperwise/model/Paper.java`
2. Change line:
   ```java
   public static final int POPULAR_THRESHOLD = 5;
   ```
3. Recompile and deploy
4. No other changes needed!

## Benefits

1. **Clarity**: Logic is explicit and easy to understand
2. **Consistency**: Same logic applied everywhere
3. **Flexibility**: Easy to change threshold
4. **Performance**: No database overhead (computed from existing data)
5. **Testability**: Can unit test `isPopular()` method
6. **Maintainability**: Single source of truth

## Technical Notes

- The `isPopular()` method is called during JSP rendering
- No additional database queries needed
- `usefulCount` is already loaded via SQL aggregation in PaperDAO
- Badge styling defined in CSS: `.badge-popular`

## Future Enhancements (Optional)

If needed, the threshold could be made configurable:

1. **Configuration File**: Load from properties file
2. **Database Setting**: Store in settings table
3. **Admin Panel**: Allow admin to change threshold via UI
4. **Per-Category**: Different thresholds for different subjects

Current implementation uses a constant for simplicity and performance.
