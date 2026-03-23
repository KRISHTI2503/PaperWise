# MVC Flow Documentation - PaperWise

## Overview
This document explains the proper Model-View-Controller (MVC) architecture implementation in PaperWise, ensuring that all navigation goes through servlets and data is always fresh from the database.

## Implementation Date
February 26, 2026

## Core Principle: Redirect-After-Post Pattern

### The Problem
When using `forward()` after a POST request, the browser retains the POST data. If the user refreshes the page, the form is resubmitted, causing duplicate operations (double upload, double vote, etc.).

### The Solution
Always use `sendRedirect()` after POST operations. This causes the browser to make a new GET request, preventing form resubmission.

## MVC Flow Architecture

### Request Flow Pattern
```
User Action → Servlet (Controller) → DAO (Model) → Database
                ↓
         JSP (View) ← Request Attributes
```

### Navigation Flow Pattern
```
POST Request → Servlet Processing → sendRedirect() → GET Request → Servlet → JSP
```

## Admin Dashboard Flow

### Correct Flow (Implemented)
```
1. User clicks "Upload Paper" button
   → href="/uploadPaper" (servlet)

2. UploadPaperServlet.doGet()
   → Displays upload.jsp form

3. User submits form
   → POST to /uploadPaper

4. UploadPaperServlet.doPost()
   → Saves file and database record
   → Sets success message in session
   → sendRedirect("/adminDashboard")  ← REDIRECT, not forward

5. Browser makes new GET request
   → GET /adminDashboard

6. AdminDashboardServlet.doGet()
   → Fetches fresh papers from database
   → Sets papers as request attribute
   → Forwards to admin-dashboard.jsp

7. admin-dashboard.jsp
   → Reads papers from request attribute
   → Displays table with fresh data
```

### Why This Works
- Each redirect triggers a fresh database query
- No stale data in session
- Browser back button works correctly
- Page refresh doesn't resubmit forms
- Success messages display once and are removed

## Servlet Responsibilities

### AdminDashboardServlet
**URL**: `/adminDashboard`

**Responsibilities**:
- Verify admin authentication and authorization
- Fetch fresh paper list from database using `paperDAO.getAllPapers()`
- Set papers as request attribute (NOT session)
- Forward to admin-dashboard.jsp
- Handle database errors gracefully

**Code Pattern**:
```java
@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    // 1. Verify authentication
    HttpSession session = request.getSession(false);
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    
    // 2. Verify authorization
    if (!ROLE_ADMIN.equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    
    // 3. Fetch fresh data
    List<Paper> papers = paperDAO.getAllPapers();
    
    // 4. Set as REQUEST attribute (not session)
    request.setAttribute("papers", papers);
    
    // 5. Forward to JSP
    request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
}
```

### UploadPaperServlet
**URL**: `/uploadPaper`

**Responsibilities**:
- GET: Display upload form
- POST: Process upload, save to database, redirect to dashboard

**Critical Pattern**:
```java
@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    // 1. Process upload
    boolean success = paperDAO.savePaper(paper);
    
    if (success) {
        // 2. Store success message in SESSION (survives redirect)
        HttpSession session = request.getSession();
        session.setAttribute("successMessage", "Paper uploaded successfully!");
        
        // 3. REDIRECT to servlet (not JSP)
        response.sendRedirect(request.getContextPath() + "/adminDashboard");
        return;  // Important: stop processing
    } else {
        // 4. On error, FORWARD to form (no redirect needed)
        request.setAttribute("errorMessage", "Upload failed.");
        request.getRequestDispatcher("/upload.jsp").forward(request, response);
    }
}
```

### EditPaperServlet
**URL**: `/editPaper`

**Pattern**: Same as UploadPaperServlet
- GET: Load paper, forward to edit form
- POST: Update paper, redirect to `/adminDashboard`

### DeletePaperServlet
**URL**: `/deletePaper`

**Pattern**: POST-only
- Delete file and database record
- Redirect to `/adminDashboard`

## JSP Responsibilities

### admin-dashboard.jsp

**Responsibilities**:
- Display data from request attributes ONLY
- No database access
- No business logic
- Pure presentation

**Critical Rules**:
```jsp
<%
    // ✓ CORRECT: Read from request attribute
    List<Paper> papers = (List<Paper>) request.getAttribute("papers");
    
    // ✗ WRONG: Never read from session
    // List<Paper> papers = (List<Paper>) session.getAttribute("papers");
%>

<!-- ✓ CORRECT: Link to servlet -->
<a href="${pageContext.request.contextPath}/uploadPaper">Upload Paper</a>

<!-- ✗ WRONG: Never link directly to JSP -->
<!-- <a href="${pageContext.request.contextPath}/upload.jsp">Upload Paper</a> -->
```

## Message Handling Pattern

### Success Messages
**Storage**: Session (survives redirect)
**Display**: Once, then remove
**Pattern**:
```jsp
<%
    String successMessage = (String) session.getAttribute("successMessage");
    if (successMessage != null) {
        session.removeAttribute("successMessage");  // Remove after reading
%>
    <div class="success-message">
        <%= successMessage %>
    </div>
<% } %>
```

### Error Messages
**Storage**: Request attribute (for forward) OR Session (for redirect)
**Display**: Once
**Pattern**:
```jsp
<%
    // Try request first (from forward)
    String errorMessage = (String) request.getAttribute("errorMessage");
    
    // Fall back to session (from redirect)
    if (errorMessage == null) {
        errorMessage = (String) session.getAttribute("errorMessage");
        if (errorMessage != null) {
            session.removeAttribute("errorMessage");
        }
    }
    
    if (errorMessage != null) {
%>
    <div class="error-message">
        <%= errorMessage %>
    </div>
<% } %>
```

## Navigation Links

### All Navigation Must Go Through Servlets

**Admin Dashboard Links**:
```jsp
<!-- ✓ CORRECT -->
<a href="${pageContext.request.contextPath}/uploadPaper">Upload Paper</a>
<a href="${pageContext.request.contextPath}/editPaper?paperId=123">Edit</a>
<a href="${pageContext.request.contextPath}/adminDashboard">Dashboard</a>

<!-- ✗ WRONG -->
<a href="${pageContext.request.contextPath}/upload.jsp">Upload Paper</a>
<a href="${pageContext.request.contextPath}/admin-dashboard.jsp">Dashboard</a>
```

**Login Redirects**:
```java
// ✓ CORRECT: Redirect to servlet
if (ROLE_ADMIN.equalsIgnoreCase(role)) {
    response.sendRedirect(contextPath + "/adminDashboard");
}

// ✗ WRONG: Redirect to JSP
// response.sendRedirect(contextPath + "/admin-dashboard.jsp");
```

## Data Freshness Guarantee

### How Fresh Data is Ensured

1. **No Session Storage of Lists**
   - Papers list is NEVER stored in session
   - Always fetched fresh from database
   - Prevents stale data issues

2. **Request Scope Only**
   - Papers list stored in request attribute
   - Lives only for one request-response cycle
   - Automatically garbage collected

3. **Redirect Pattern**
   - Every POST operation redirects
   - Redirect triggers new GET request
   - New GET request fetches fresh data

### Example Timeline
```
Time 0: Admin uploads paper A
  → POST /uploadPaper
  → Paper A saved to database
  → Redirect to /adminDashboard

Time 1: Browser follows redirect
  → GET /adminDashboard
  → Query: SELECT * FROM papers
  → Result: [Paper A]
  → Display: Paper A shown

Time 2: Admin uploads paper B (in another tab)
  → POST /uploadPaper
  → Paper B saved to database

Time 3: Admin refreshes first tab
  → GET /adminDashboard
  → Query: SELECT * FROM papers
  → Result: [Paper A, Paper B]
  → Display: Both papers shown ✓
```

## Common Pitfalls and Solutions

### Pitfall 1: Direct JSP Access
**Problem**: User bookmarks `/admin-dashboard.jsp`
**Solution**: AuthFilter blocks direct JSP access, redirects to servlet

### Pitfall 2: Forward After POST
**Problem**: Browser refresh resubmits form
**Solution**: Always redirect after POST

### Pitfall 3: Session-Stored Lists
**Problem**: List becomes stale after other users make changes
**Solution**: Store in request attribute, fetch fresh on every request

### Pitfall 4: Missing Return After Redirect
**Problem**: Code continues executing after redirect
**Solution**: Always `return;` after `sendRedirect()`

```java
// ✓ CORRECT
response.sendRedirect("/adminDashboard");
return;  // Stop processing

// ✗ WRONG
response.sendRedirect("/adminDashboard");
// Code continues executing!
```

## Testing the MVC Flow

### Test Checklist

#### Data Freshness
- [ ] Upload paper in tab 1
- [ ] Refresh tab 2
- [ ] New paper appears in tab 2

#### No Duplicate Operations
- [ ] Upload paper
- [ ] Press browser back button
- [ ] Press browser forward button
- [ ] Refresh page
- [ ] Paper uploaded only once

#### Message Display
- [ ] Success message shows after upload
- [ ] Success message disappears after 3 seconds
- [ ] Refresh page - message doesn't reappear

#### Navigation
- [ ] All links go to servlets, not JSPs
- [ ] Direct JSP access blocked by AuthFilter
- [ ] Back button works correctly

#### Error Handling
- [ ] Database error shows error message
- [ ] Error doesn't prevent future operations
- [ ] Error message clears after display

## Architecture Benefits

### Advantages of This Pattern

1. **Data Consistency**
   - Always shows latest database state
   - No synchronization issues
   - No cache invalidation needed

2. **User Experience**
   - Back button works correctly
   - Refresh doesn't resubmit forms
   - No duplicate operations

3. **Maintainability**
   - Clear separation of concerns
   - Easy to debug (check servlet logs)
   - Easy to modify (change one servlet)

4. **Security**
   - All requests go through AuthFilter
   - Authorization checked in servlet
   - No direct JSP access

5. **Scalability**
   - No session bloat (no lists in session)
   - Stateless request handling
   - Easy to add caching layer later

## Summary

### Golden Rules

1. **Never link directly to JSPs** - Always link to servlets
2. **Never store lists in session** - Use request attributes
3. **Always redirect after POST** - Prevents form resubmission
4. **Always fetch fresh data** - Query database on every GET
5. **Always return after redirect** - Prevents double processing

### File Responsibilities

**Servlets (Controllers)**:
- Handle requests
- Call DAO methods
- Set request/session attributes
- Forward or redirect

**DAOs (Model)**:
- Database operations only
- No HTTP knowledge
- Return data objects

**JSPs (View)**:
- Display data only
- Read from request attributes
- No business logic
- No database access

This architecture ensures PaperWise always displays fresh, accurate data while providing a smooth user experience.
