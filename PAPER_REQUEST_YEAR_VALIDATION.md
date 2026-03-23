# Paper Request Year Validation Implementation

## Overview
Implemented comprehensive backend year validation for the paper_requests table with dynamic year range calculation.

## Business Rule
**Valid Year Range**: `currentYear - 20` to `currentYear` (inclusive)

Example in 2026:
- Valid: 2006, 2007, ..., 2025, 2026
- Invalid: 2005 (too old), 2027 (future)

## Implementation

### 1. Model Layer (PaperRequest.java)
Created POJO class representing a paper request:
```java
public class PaperRequest {
    private int requestId;
    private String subjectName;
    private String subjectCode;
    private int year;              // ← Validated field
    private String chapter;
    private int requestedBy;
    private String status;         // pending, fulfilled, rejected
    private LocalDateTime createdAt;
    // ... getters/setters
}
```

### 2. DAO Layer (PaperRequestDAO.java)

#### Constants
```java
private static final int VALID_YEARS_BACK = 20;
```

#### Year Validation Method
```java
public boolean isValidYear(int year) {
    int currentYear = Year.now().getValue();
    int minYear = currentYear - VALID_YEARS_BACK;
    
    return year >= minYear && year <= currentYear;
}
```

#### Save Method with Validation
```java
public boolean saveRequest(PaperRequest request) {
    // ═══════════════════════════════════════════════════════════════════
    // CRITICAL: Year Validation (Backend)
    // ═══════════════════════════════════════════════════════════════════
    int currentYear = Year.now().getValue();
    int minYear = currentYear - VALID_YEARS_BACK;
    int year = request.getYear();

    System.out.println("=== PAPER REQUEST YEAR VALIDATION ===");
    System.out.println("Requested year: " + year);
    System.out.println("Current year: " + currentYear);
    System.out.println("Min year: " + minYear);
    System.out.println("Valid range: " + minYear + " - " + currentYear);

    if (year < minYear || year > currentYear) {
        String errorMsg = "Year must be between " + minYear + " and " + currentYear + ".";
        System.out.println("VALIDATION FAILED: " + errorMsg);
        throw new IllegalArgumentException(errorMsg);
    }

    System.out.println("VALIDATION PASSED: Year " + year + " is valid.");
    
    // Proceed with database insert...
}
```

### 3. Database Schema (create_paper_requests_table.sql)
```sql
CREATE TABLE IF NOT EXISTS paper_requests (
    request_id SERIAL PRIMARY KEY,
    subject_name VARCHAR(150) NOT NULL,
    subject_code VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    chapter VARCHAR(100),
    requested_by INT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' 
        CHECK (status IN ('pending', 'fulfilled', 'rejected')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_requested_by FOREIGN KEY (requested_by) 
        REFERENCES users(user_id) ON DELETE CASCADE
);
```

## Validation Flow

### Request Submission Flow
```
1. User submits request form
   ↓
2. Servlet receives POST request
   ↓
3. Parse year parameter
   ↓
4. Create PaperRequest object
   ↓
5. Call paperRequestDAO.saveRequest(request)
   ↓
6. DAO validates year:
   - Calculate currentYear = Year.now().getValue()
   - Calculate minYear = currentYear - 20
   - Check: year >= minYear && year <= currentYear
   ↓
7a. If VALID:
    - Insert into database
    - Return success
    - Redirect with success message
   ↓
7b. If INVALID:
    - Throw IllegalArgumentException
    - Catch in servlet
    - Forward back to form
    - Show error message
```

## Key Features

### ✅ Dynamic Calculation
- Uses `Year.now().getValue()` - NOT hardcoded
- Automatically adjusts each year
- No maintenance required

### ✅ Backend Validation
- Validation happens in DAO before database insert
- Cannot be bypassed by client manipulation
- Throws exception if validation fails

### ✅ Clear Error Messages
- Shows exact valid range: "Year must be between 2006 and 2026."
- User knows exactly what's wrong
- Easy to fix and resubmit

### ✅ Debug Logging
- Comprehensive console output
- Shows requested year, current year, min year
- Shows validation result (PASSED/FAILED)
- Easy to troubleshoot issues

## Example Servlet Implementation

```java
@WebServlet("/requestPaper")
public class RequestPaperServlet extends HttpServlet {
    
    private PaperRequestDAO requestDAO;
    
    @Override
    public void init() throws ServletException {
        requestDAO = new PaperRequestDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get form parameters
        String subjectName = request.getParameter("subjectName");
        String subjectCode = request.getParameter("subjectCode");
        String yearStr = request.getParameter("year");
        String chapter = request.getParameter("chapter");
        
        try {
            int year = Integer.parseInt(yearStr);
            
            // Create request object
            PaperRequest paperRequest = new PaperRequest();
            paperRequest.setSubjectName(subjectName);
            paperRequest.setSubjectCode(subjectCode);
            paperRequest.setYear(year);
            paperRequest.setChapter(chapter);
            paperRequest.setRequestedBy(loggedInUser.getUserId());
            
            // Save with validation
            boolean success = requestDAO.saveRequest(paperRequest);
            
            if (success) {
                session.setAttribute("successMessage", 
                    "Paper request submitted successfully!");
                response.sendRedirect("studentDashboard");
            }
            
        } catch (IllegalArgumentException e) {
            // Year validation failed
            request.setAttribute("errorMessage", e.getMessage());
            request.setAttribute("subjectName", subjectName);
            request.setAttribute("subjectCode", subjectCode);
            request.setAttribute("year", yearStr);
            request.setAttribute("chapter", chapter);
            request.getRequestDispatcher("/requestPaper.jsp")
                   .forward(request, response);
        } catch (Exception e) {
            // Other errors
            request.setAttribute("errorMessage", 
                "An error occurred. Please try again.");
            request.getRequestDispatcher("/requestPaper.jsp")
                   .forward(request, response);
        }
    }
}
```

## Testing Scenarios

### Valid Years (in 2026)
| Year | Result  | Reason                    |
|------|---------|---------------------------|
| 2026 | ✅ PASS | Current year              |
| 2025 | ✅ PASS | Within range              |
| 2020 | ✅ PASS | Within range              |
| 2010 | ✅ PASS | Within range              |
| 2006 | ✅ PASS | Minimum valid year        |

### Invalid Years (in 2026)
| Year | Result  | Reason                    |
|------|---------|---------------------------|
| 2027 | ❌ FAIL | Future year               |
| 2030 | ❌ FAIL | Future year               |
| 2005 | ❌ FAIL | Too old (> 20 years)      |
| 2000 | ❌ FAIL | Too old (> 20 years)      |
| 1999 | ❌ FAIL | Too old (> 20 years)      |

## Security Benefits

1. **Cannot be bypassed**: Validation in backend, not just frontend
2. **No SQL injection**: Uses PreparedStatement
3. **No invalid data**: Database never receives invalid years
4. **Clear audit trail**: Console logs show all validation attempts

## Maintenance

### Changing the Valid Range
To change from 20 years to a different range:

1. Open `PaperRequestDAO.java`
2. Change line:
   ```java
   private static final int VALID_YEARS_BACK = 30; // Changed from 20
   ```
3. Recompile and deploy
4. No other changes needed!

### Automatic Updates
- No code changes needed each year
- `Year.now().getValue()` automatically returns current year
- Valid range automatically adjusts

## Files Created

1. **src/java/com/paperwise/model/PaperRequest.java**
   - Model class for paper requests

2. **src/java/com/paperwise/dao/PaperRequestDAO.java**
   - DAO with year validation logic
   - saveRequest() method with validation
   - isValidYear() helper method
   - getValidYearRange() for error messages

3. **create_paper_requests_table.sql**
   - Database schema for paper_requests table
   - Indexes for performance
   - Foreign key constraints

4. **PAPER_REQUEST_YEAR_VALIDATION.md** (this file)
   - Complete documentation

## Next Steps

To complete the implementation:

1. **Run SQL Script**:
   ```bash
   psql -U your_user -d paperwise -f create_paper_requests_table.sql
   ```

2. **Create RequestPaperServlet**:
   - Handle GET: Show request form
   - Handle POST: Process submission with validation

3. **Create requestPaper.jsp**:
   - Form with subject name, code, year, chapter fields
   - Display error messages
   - Frontend validation (optional, but recommended)

4. **Update Navigation**:
   - Add "Request Paper" link to student dashboard

## Conclusion

This implementation provides:
- ✅ Dynamic year validation (not hardcoded)
- ✅ Backend validation (mandatory, cannot be bypassed)
- ✅ Clear error messages
- ✅ Comprehensive logging
- ✅ Clean MVC architecture
- ✅ Easy to maintain and extend

The year validation is robust, secure, and will work correctly for years to come without any code changes.
