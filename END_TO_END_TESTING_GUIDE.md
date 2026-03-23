# End-to-End Testing Guide

## Overview
Comprehensive testing guide for PaperWise application features.

---

## Prerequisites

### 1. Database Setup
```sql
-- Ensure all tables exist
\c paperwise_db

-- Verify tables
\dt

-- Expected tables:
-- users
-- papers
-- votes
-- difficulty_votes
-- paper_requests
```

### 2. Test Users
```sql
-- Admin user
SELECT * FROM users WHERE username = 'admin';
-- Expected: role = 'admin'

-- Student user
SELECT * FROM users WHERE username = 'student';
-- Expected: role = 'student'
```

### 3. Server Running
- Tomcat server started
- Application deployed
- No compilation errors
- PostgreSQL running

---

## Test 1: Valid Request Submission ✅

### Objective
Test that students can successfully submit paper requests with valid data.

### Steps

1. **Login as Student**
   - URL: `http://localhost:8080/PaperWise/login.jsp`
   - Username: `student`
   - Password: `student123A!`
   - Click "Login"

2. **Navigate to Request Paper**
   - From student dashboard
   - Click "Request Paper" link or button
   - URL should be: `/requestPaper`

3. **Fill Form with Valid Data**
   - Subject Name: `Data Structures and Algorithms`
   - Subject Code: `CS201`
   - Year: Select `2024` (or current year)
   - Description: `Need previous year question papers for exam preparation`
   - Click "Submit Request"

### Expected Results
- ✅ Success message: "Paper request for 'Data Structures and Algorithms' submitted successfully!"
- ✅ Redirects to student dashboard
- ✅ Success message auto-hides after 3 seconds
- ✅ No 500 errors
- ✅ No SQL exceptions in logs

### Database Verification
```sql
SELECT * FROM paper_requests 
WHERE subject_name = 'Data Structures and Algorithms'
ORDER BY requested_at DESC 
LIMIT 1;

-- Expected:
-- subject_name: Data Structures and Algorithms
-- subject_code: CS201
-- year: 2024
-- description: Need previous year question papers...
-- status: pending
-- requested_at: current timestamp
-- user_id: (student's user_id)
```

### Console Logs to Check
```
=== REQUEST PAPER YEAR VALIDATION ===
User ID: [student_id]
Subject: Data Structures and Algorithms
Requested year: 2024
Current year: 2024
Min year: 2004
Valid range: 2004 - 2024
VALIDATION PASSED: Year 2024 is valid.
=== END YEAR VALIDATION ===

Paper request submitted by user student: Data Structures and Algorithms (CS201) - Year 2024
```

---

## Test 2: Invalid Year Submission ✅

### Objective
Test that year validation rejects invalid years (future years and years > 20 years old).

### Test 2A: Future Year

#### Steps
1. Login as student
2. Navigate to Request Paper form
3. Fill form:
   - Subject Name: `Machine Learning`
   - Subject Code: `CS401`
   - Year: `2030` (future year)
   - Description: `Test future year`
4. Click "Submit Request"

#### Expected Results
- ✅ Error message: "Year must be between 2004 and 2024."
- ✅ Form data preserved (subject name, code, description still filled)
- ✅ Stays on request form (does NOT redirect)
- ✅ No database insert
- ✅ No 500 errors

#### Console Logs
```
=== REQUEST PAPER YEAR VALIDATION ===
Requested year: 2030
Current year: 2024
Min year: 2004
Valid range: 2004 - 2024
VALIDATION FAILED: Year must be between 2004 and 2024.
=== END YEAR VALIDATION ===
```

### Test 2B: Year Too Old

#### Steps
1. Stay on request form
2. Change year to `2000` (more than 20 years old)
3. Click "Submit Request"

#### Expected Results
- ✅ Error message: "Year must be between 2004 and 2024."
- ✅ Form data preserved
- ✅ No database insert
- ✅ No 500 errors

### Test 2C: Boundary Testing

Test these years:
- `2004` (currentYear - 20) → ✅ Should PASS
- `2003` (currentYear - 21) → ❌ Should FAIL
- `2024` (currentYear) → ✅ Should PASS
- `2025` (currentYear + 1) → ❌ Should FAIL

---

## Test 3: Admin Status Change ✅

### Objective
Test that admins can view and update paper request statuses.

### Steps

1. **Login as Admin**
   - URL: `http://localhost:8080/PaperWise/login.jsp`
   - Username: `admin`
   - Password: `admin123A!`
   - Click "Login"

2. **Navigate to Manage Requests**
   - From admin dashboard
   - Click "Manage Requests" link
   - URL should be: `/adminRequests`

3. **Verify Request Display**
   - Should see table with all requests
   - Check columns: Subject Name, Subject Code, Year, Description, Requested By, Requested At, Status, Action
   - Requests should be ordered by most recent first

4. **Update Status to Approved**
   - Find the request created in Test 1
   - In the "Action" column, select "Approved" from dropdown
   - Click "Update" button

5. **Verify Status Update**
   - Success message: "Request status updated to 'approved' successfully!"
   - Status badge changes to green "APPROVED"
   - Page reloads with updated data

6. **Update Status to Completed**
   - Select "Completed" from dropdown
   - Click "Update"
   - Status badge changes to blue "COMPLETED"

7. **Update Status to Rejected**
   - Select "Rejected" from dropdown
   - Click "Update"
   - Status badge changes to red "REJECTED"

### Expected Results
- ✅ All requests visible to admin
- ✅ Requests ordered by requested_at DESC
- ✅ Status updates work for all values (approved, rejected, completed)
- ✅ Success messages displayed
- ✅ Status badges update correctly
- ✅ No 500 errors
- ✅ No SQL exceptions

### Database Verification
```sql
SELECT request_id, subject_name, status 
FROM paper_requests 
WHERE subject_name = 'Data Structures and Algorithms';

-- Status should reflect last update (rejected)
```

### Console Logs
```
Admin admin viewing [X] paper requests.
Admin admin updated request [request_id] status to: approved
Admin admin updated request [request_id] status to: completed
Admin admin updated request [request_id] status to: rejected
```

### Test 3B: Non-Admin Access

#### Steps
1. Logout admin
2. Login as student
3. Try to access: `http://localhost:8080/PaperWise/adminRequests`

#### Expected Results
- ✅ HTTP 403 Forbidden error
- ✅ Message: "Access denied. Administrator privileges required."
- ✅ Student cannot access admin endpoints

---

## Test 4: Marked Filtering ✅

### Objective
Test that students can view only papers they've marked as useful.

### Setup
First, mark some papers as useful:

1. **Login as Student**
2. **Navigate to Student Dashboard**
3. **Mark 3 Papers as Useful**
   - Find papers in the list
   - Click "Useful" button on 3 different papers
   - Note which papers you marked

### Test Steps

1. **View All Papers (Default)**
   - URL: `/studentDashboard`
   - Dropdown should show "All Papers" selected
   - Should see all papers in database

2. **Switch to Marked Papers View**
   - Click dropdown at top of page
   - Select "My Marked Papers"
   - URL changes to: `/studentDashboard?view=marked`
   - Page reloads

3. **Verify Marked Papers Display**
   - Should see ONLY the 3 papers you marked
   - Papers ordered by when you marked them (most recent first)
   - All paper details visible (subject, code, year, votes, difficulty)
   - "Marked" button should be disabled/greyed out

4. **Switch Back to All Papers**
   - Select "All Papers" from dropdown
   - URL changes to: `/studentDashboard?view=all` or `/studentDashboard`
   - Should see all papers again

### Expected Results
- ✅ "My Marked Papers" shows only user's marked papers
- ✅ Papers ordered by marked_at DESC (most recent first)
- ✅ Switching between views works correctly
- ✅ No papers from other users shown
- ✅ All paper details displayed correctly
- ✅ No 500 errors
- ✅ No SQL exceptions

### Database Verification
```sql
-- Get papers marked by student
SELECT p.subject_name, v.created_at as marked_at
FROM papers p
JOIN votes v ON p.paper_id = v.paper_id
WHERE v.user_id = (SELECT user_id FROM users WHERE username = 'student')
ORDER BY v.created_at DESC;

-- Should match papers shown in "My Marked Papers" view
```

### Console Logs
```
Showing marked papers for user: student
Retrieved [X] papers for user ID [student_id].
Student dashboard loaded with [X] papers for user student
```

### Test 4B: User Isolation

#### Steps
1. Login as different student (or create new student account)
2. Mark different papers
3. View "My Marked Papers"

#### Expected Results
- ✅ Each user sees only their own marked papers
- ✅ No cross-user data leakage

---

## Test 5: Pagination ✅

### Current Status
**Pagination is NOT currently implemented** in the application.

### Expected Behavior
- All papers loaded at once
- No page numbers
- No "Next" or "Previous" buttons
- No LIMIT/OFFSET in queries

### Verification Steps

1. **Check Student Dashboard**
   - Navigate to `/studentDashboard`
   - Scroll through paper list
   - Should see all papers in one page

2. **Check Marked Papers**
   - Navigate to `/studentDashboard?view=marked`
   - Should see all marked papers in one page

3. **Check Admin Requests**
   - Navigate to `/adminRequests`
   - Should see all requests in one page

### Expected Results
- ✅ No pagination controls visible
- ✅ All records loaded at once
- ✅ No page parameter in URL
- ✅ No pagination-related errors

### Future Pagination Implementation

If pagination is added later, test:
- Page parameter in URL: `?page=2`
- Offset calculation: `(page - 1) * limit`
- "Next" and "Previous" buttons work
- Page numbers maintained when switching views
- No page reset to 1 on every request

---

## Test 6: Ensure No 500 Errors ✅

### Objective
Verify that all endpoints handle errors gracefully without 500 Internal Server Errors.

### Test Cases

#### 6A: Missing Required Fields
1. Navigate to `/requestPaper`
2. Leave subject name empty
3. Submit form
- ✅ Expected: Error message, NOT 500 error

#### 6B: Invalid Request ID
1. Login as admin
2. Navigate to `/adminRequests`
3. Manually craft POST request with invalid requestId
- ✅ Expected: Error message or validation error, NOT 500 error

#### 6C: Invalid Year Format
1. Navigate to `/requestPaper`
2. Use browser dev tools to change year input to text
3. Submit with year = "abc"
- ✅ Expected: "Year must be a valid number" error, NOT 500 error

#### 6D: Session Timeout
1. Login as student
2. Wait for session timeout (or clear session cookie)
3. Try to access `/studentDashboard`
- ✅ Expected: Redirect to login page, NOT 500 error

#### 6E: Database Connection Issues
1. Stop PostgreSQL temporarily
2. Try to access any page
- ✅ Expected: Graceful error message, NOT 500 error
- ✅ Error logged with stack trace

### Error Handling Verification

Check that all servlets have:
```java
try {
    // ... operations ...
} catch (Exception e) {
    System.err.println("Error message");
    e.printStackTrace();
    request.setAttribute("errorMessage", "User-friendly message");
    request.getRequestDispatcher("view.jsp").forward(request, response);
}
```

---

## Test 7: Ensure No SQL Exceptions ✅

### Objective
Verify that all database operations are safe and handle errors properly.

### Test Cases

#### 7A: Duplicate Vote Prevention
1. Login as student
2. Mark a paper as useful
3. Try to mark the same paper again
- ✅ Expected: "You already marked this paper" message
- ✅ No SQL exception (ON CONFLICT DO NOTHING)

#### 7B: Duplicate Difficulty Vote
1. Vote "Easy" on a paper
2. Vote "Medium" on the same paper
- ✅ Expected: Vote updated (UPSERT)
- ✅ No SQL exception (ON CONFLICT DO UPDATE)

#### 7C: Foreign Key Constraints
1. Try to insert paper request with invalid user_id
- ✅ Expected: Caught and handled gracefully
- ✅ No SQL exception exposed to user

#### 7D: NULL Handling
1. Submit paper request without description (optional field)
- ✅ Expected: Inserts successfully with NULL description
- ✅ No SQL exception

#### 7E: SQL Injection Attempts
1. Try to inject SQL in form fields:
   - Subject Name: `'; DROP TABLE papers; --`
   - Subject Code: `' OR '1'='1`
- ✅ Expected: Treated as literal strings
- ✅ No SQL execution
- ✅ Parameterized queries prevent injection

### SQL Exception Monitoring

Check Tomcat logs for:
```
SQLException
PSQLException
org.postgresql.util.PSQLException
```

Should NOT appear during normal operations.

### Database Integrity Checks
```sql
-- Check for orphaned records
SELECT COUNT(*) FROM paper_requests pr
LEFT JOIN users u ON pr.user_id = u.user_id
WHERE u.user_id IS NULL;
-- Expected: 0

-- Check for invalid status values
SELECT COUNT(*) FROM paper_requests
WHERE status NOT IN ('pending', 'approved', 'rejected', 'completed');
-- Expected: 0

-- Check for invalid years
SELECT COUNT(*) FROM paper_requests
WHERE year < 1900 OR year > 2100;
-- Expected: 0 (or only valid years)
```

---

## Comprehensive Test Execution Checklist

### Pre-Testing
- [ ] Database is running
- [ ] All tables created
- [ ] Test users exist (admin, student)
- [ ] Tomcat server started
- [ ] Application deployed successfully
- [ ] No compilation errors

### Test Execution
- [ ] Test 1: Valid request submission - PASS
- [ ] Test 2A: Future year rejection - PASS
- [ ] Test 2B: Old year rejection - PASS
- [ ] Test 2C: Boundary testing - PASS
- [ ] Test 3: Admin status change - PASS
- [ ] Test 3B: Non-admin access denied - PASS
- [ ] Test 4: Marked filtering - PASS
- [ ] Test 4B: User isolation - PASS
- [ ] Test 5: Pagination (not implemented) - PASS
- [ ] Test 6A-E: No 500 errors - PASS
- [ ] Test 7A-E: No SQL exceptions - PASS

### Post-Testing
- [ ] Check Tomcat logs for errors
- [ ] Check PostgreSQL logs for errors
- [ ] Verify database integrity
- [ ] Clean up test data (optional)

---

## Common Issues and Solutions

### Issue 1: Session Timeout
**Symptom**: Redirects to login unexpectedly
**Solution**: Increase session timeout in web.xml or re-login

### Issue 2: Database Connection Pool Exhausted
**Symptom**: "Cannot get connection" errors
**Solution**: Check that connections are properly closed (try-with-resources)

### Issue 3: Year Validation Fails
**Symptom**: Valid years rejected
**Solution**: Check system date, verify Year.now().getValue() returns correct year

### Issue 4: Marked Papers Empty
**Symptom**: "My Marked Papers" shows no results
**Solution**: Ensure you've marked papers first, check votes table

### Issue 5: Status Update Fails
**Symptom**: Status doesn't change
**Solution**: Check admin role, verify request_id is valid

---

## Performance Testing (Optional)

### Load Testing
1. Create 100+ paper requests
2. Navigate to admin requests page
3. Verify page loads in < 2 seconds

### Concurrent Users
1. Login as multiple users simultaneously
2. Mark papers concurrently
3. Verify no race conditions or deadlocks

### Large Dataset
1. Insert 1000+ papers
2. Test marked filtering performance
3. Verify queries use indexes

---

## Security Testing

### Authentication
- [ ] Cannot access protected pages without login
- [ ] Session validation works
- [ ] Logout clears session

### Authorization
- [ ] Students cannot access admin pages
- [ ] Admins can access all pages
- [ ] Role checks enforced

### Input Validation
- [ ] XSS attempts blocked
- [ ] SQL injection prevented
- [ ] Year validation enforced
- [ ] Required fields validated

### Data Privacy
- [ ] Users see only their own marked papers
- [ ] No cross-user data leakage
- [ ] User IDs from session, not request

---

## Final Verification

### Code Quality
- [ ] No compilation errors
- [ ] No warnings in IDE
- [ ] All imports resolved
- [ ] Proper exception handling

### Database
- [ ] All tables exist
- [ ] Foreign keys enforced
- [ ] Indexes created
- [ ] Constraints working

### Functionality
- [ ] All features working
- [ ] No 500 errors
- [ ] No SQL exceptions
- [ ] User-friendly error messages

### Documentation
- [ ] All features documented
- [ ] Test results recorded
- [ ] Known issues listed
- [ ] Deployment guide available

---

## Test Results Template

```
=== END-TO-END TEST RESULTS ===
Date: [DATE]
Tester: [NAME]
Environment: [DEV/STAGING/PROD]

Test 1: Valid Request Submission
Status: [PASS/FAIL]
Notes: [Any observations]

Test 2: Invalid Year Submission
Status: [PASS/FAIL]
Notes: [Any observations]

Test 3: Admin Status Change
Status: [PASS/FAIL]
Notes: [Any observations]

Test 4: Marked Filtering
Status: [PASS/FAIL]
Notes: [Any observations]

Test 5: Pagination
Status: [PASS/FAIL/N/A]
Notes: [Any observations]

Test 6: No 500 Errors
Status: [PASS/FAIL]
Notes: [Any observations]

Test 7: No SQL Exceptions
Status: [PASS/FAIL]
Notes: [Any observations]

Overall Status: [PASS/FAIL]
Issues Found: [COUNT]
Critical Issues: [COUNT]
```

---

## Conclusion

This comprehensive testing guide covers all major features and edge cases. Execute each test systematically and document results. All tests should PASS for production deployment.

**Ready for Testing**: ✅ YES
**Expected Result**: All tests PASS
**Estimated Time**: 30-45 minutes
