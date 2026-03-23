# Paper Listing Feature Documentation

## Overview

Implemented complete paper listing functionality for both admin and student dashboards with view/download capabilities.

## Features Implemented

### 1. Paper Listing in Dashboards

**Admin Dashboard:**
- View all uploaded papers in a table
- Columns: Subject Name, Subject Code, Year, Chapter, Uploaded By, Actions
- View and Download buttons for each paper
- File existence check before displaying actions
- Empty state message when no papers exist
- Success message after upload (auto-hides after 3 seconds)

**Student Dashboard:**
- View all available papers
- Columns: Subject Name, Subject Code, Year, Chapter, Actions
- View and Download buttons (no edit/delete)
- File existence check
- Empty state message
- No "Uploaded By" column (students don't need to see this)

### 2. New Servlets Created

#### AdminDashboardServlet (`@WebServlet("/adminDashboard")`)

**Purpose:** Handles admin dashboard display with paper listing

**Features:**
- Role verification (admin only)
- Fetches all papers using `PaperDAO.getAllPapers()`
- Sets papers as request attribute
- Forwards to `admin-dashboard.jsp`
- Error handling with user-friendly messages

**Code:**
```java
@WebServlet("/adminDashboard")
public class AdminDashboardServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Verify admin access
        User loggedInUser = getLoggedInUser(request);
        if (!isAdmin(loggedInUser)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        // Fetch papers
        List<Paper> papers = paperDAO.getAllPapers();
        request.setAttribute("papers", papers);
        
        // Forward to JSP
        request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
    }
}
```

#### StudentDashboardServlet (`@WebServlet("/studentDashboard")`)

**Purpose:** Handles student dashboard display with paper listing

**Features:**
- Authentication verification
- Fetches all papers
- Sets papers as request attribute
- Forwards to `student-dashboard.jsp`
- Error handling

**Code:**
```java
@WebServlet("/studentDashboard")
public class StudentDashboardServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Verify authentication
        User loggedInUser = getLoggedInUser(request);
        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Fetch papers
        List<Paper> papers = paperDAO.getAllPapers();
        request.setAttribute("papers", papers);
        
        // Forward to JSP
        request.getRequestDispatcher("/student-dashboard.jsp").forward(request, response);
    }
}
```

### 3. Updated Components

#### LoginServlet

**Changes:**
- Redirect to servlets instead of JSP files
- Admin: `/adminDashboard` (was `/admin-dashboard.jsp`)
- Student: `/studentDashboard` (was `/student-dashboard.jsp`)

**Benefits:**
- Papers are loaded automatically on login
- Consistent data flow through servlets
- Better separation of concerns

#### UploadPaperServlet

**Changes:**
- Success message attribute: `successMessage` (consistent naming)
- Redirect to: `/adminDashboard` (servlet, not JSP)

**Code:**
```java
// After successful upload
session.setAttribute("successMessage", 
        "Paper '" + subjectName + "' uploaded successfully!");
response.sendRedirect(request.getContextPath() + "/adminDashboard");
```

#### AuthFilter

**Changes:**
- Added `/adminDashboard` to admin-only resources
- Protects servlet endpoints

### 4. Dashboard JSP Updates

#### admin-dashboard.jsp

**Features:**
- Success message display with auto-hide (3 seconds)
- Papers table with all columns
- File existence check
- View/Download buttons
- Empty state when no papers
- Responsive design
- Modern styling

**Table Structure:**
```html
<table class="papers-table">
    <thead>
        <tr>
            <th>Subject Name</th>
            <th>Subject Code</th>
            <th>Year</th>
            <th>Chapter</th>
            <th>Uploaded By</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
        <% for (Paper paper : papers) { %>
        <tr>
            <td><%= paper.getSubjectName() %></td>
            <td><%= paper.getSubjectCode() %></td>
            <td><%= paper.getYear() %></td>
            <td><%= paper.getChapter() != null ? paper.getChapter() : "-" %></td>
            <td><%= paper.getUploaderUsername() %></td>
            <td>
                <a href="<%= paper.getFileUrl() %>" target="_blank">View</a>
                <a href="<%= paper.getFileUrl() %>" download>Download</a>
            </td>
        </tr>
        <% } %>
    </tbody>
</table>
```

**File Existence Check:**
```java
String filePath = application.getRealPath("/") + paper.getFileUrl();
File file = new File(filePath);
boolean fileExists = file.exists();

if (fileExists) {
    // Show View/Download buttons
} else {
    // Show "File not found" message
}
```

**Success Message Auto-Hide:**
```javascript
const successMsg = document.getElementById('successMessage');
if (successMsg) {
    setTimeout(() => {
        successMsg.style.transition = 'opacity 0.5s ease-out';
        successMsg.style.opacity = '0';
        setTimeout(() => {
            successMsg.style.display = 'none';
        }, 500);
    }, 3000);
}
```

#### student-dashboard.jsp

**Features:**
- Same table structure as admin (minus "Uploaded By" column)
- File existence check
- View/Download buttons
- Empty state
- No admin-specific actions

**Differences from Admin:**
- No "Upload Paper" button
- No "Uploaded By" column
- Different empty state message

### 5. File Access

**View Button:**
```html
<a href="${pageContext.request.contextPath}/<%= paper.getFileUrl() %>" 
   target="_blank" 
   class="btn btn-small btn-view">
    View
</a>
```

**Download Button:**
```html
<a href="${pageContext.request.contextPath}/<%= paper.getFileUrl() %>" 
   download 
   class="btn btn-small btn-download">
    Download
</a>
```

**File URL Format:**
- Database: `uploads/1234567890_filename.pdf`
- Full URL: `http://localhost:8080/PaperWise_AJT/uploads/1234567890_filename.pdf`

### 6. Empty State Handling

**When No Papers Exist:**

**Admin Dashboard:**
```html
<div class="empty-state">
    <div class="empty-state-icon">📄</div>
    <h3>No Papers Yet</h3>
    <p>Upload your first paper to get started!</p>
</div>
```

**Student Dashboard:**
```html
<div class="empty-state">
    <div class="empty-state-icon">📄</div>
    <h3>No Papers Available</h3>
    <p>Check back later for new study materials!</p>
</div>
```

## User Flow

### Admin Flow

1. **Login** → Redirects to `/adminDashboard`
2. **AdminDashboardServlet** → Fetches papers, forwards to JSP
3. **admin-dashboard.jsp** → Displays papers table
4. **Upload Paper** → Click "Upload Paper" button
5. **Upload Success** → Redirects to `/adminDashboard` with success message
6. **Success Message** → Displays for 3 seconds, then fades out

### Student Flow

1. **Login** → Redirects to `/studentDashboard`
2. **StudentDashboardServlet** → Fetches papers, forwards to JSP
3. **student-dashboard.jsp** → Displays papers table
4. **View/Download** → Click buttons to access papers

## Security Features

### 1. Role-Based Access Control

**Admin Dashboard:**
```java
if (!ROLE_ADMIN.equalsIgnoreCase(loggedInUser.getRole())) {
    response.sendError(HttpServletResponse.SC_FORBIDDEN,
            "Access denied. Administrator privileges required.");
    return;
}
```

**AuthFilter Protection:**
- `/adminDashboard` → Admin only
- `/studentDashboard` → Authenticated users only
- `/uploads/*` → Accessible to authenticated users

### 2. File Existence Validation

**Before Displaying Actions:**
```java
String filePath = application.getRealPath("/") + paper.getFileUrl();
File file = new File(filePath);
boolean fileExists = file.exists();
```

**Benefits:**
- Prevents broken links
- Shows "File not found" for missing files
- Better user experience

### 3. Null Safety

**Chapter Field:**
```jsp
<%= paper.getChapter() != null ? paper.getChapter() : "-" %>
```

**Uploader Username:**
```jsp
<%= paper.getUploaderUsername() != null ? paper.getUploaderUsername() : "Unknown" %>
```

## Testing

### Test Admin Dashboard

```
1. Login as admin:
   Username: admin
   Password: admin123A!

2. Verify:
   ✅ Redirects to /adminDashboard
   ✅ Papers table displays
   ✅ All columns visible
   ✅ View/Download buttons work
   ✅ "Upload Paper" button visible
```

### Test Student Dashboard

```
1. Login as student:
   Username: student
   Password: student123A!

2. Verify:
   ✅ Redirects to /studentDashboard
   ✅ Papers table displays
   ✅ No "Uploaded By" column
   ✅ View/Download buttons work
   ✅ No "Upload Paper" button
```

### Test Upload Flow

```
1. Login as admin
2. Click "Upload Paper"
3. Upload a paper
4. Verify:
   ✅ Redirects to /adminDashboard
   ✅ Success message displays
   ✅ New paper appears in table
   ✅ Success message fades after 3 seconds
```

### Test File Access

```
1. Click "View" button
   ✅ Opens file in new tab
   ✅ PDF displays in browser
   ✅ Images display
   ✅ Videos may download

2. Click "Download" button
   ✅ File downloads
   ✅ Original filename preserved
```

### Test Empty State

```
1. Delete all papers from database:
   DELETE FROM papers;

2. Refresh dashboard
   ✅ Empty state message displays
   ✅ No table shown
   ✅ Appropriate message for role
```

### Test File Not Found

```
1. Delete a file from uploads/ directory
2. Keep database record
3. Refresh dashboard
   ✅ "File not found" message displays
   ✅ No View/Download buttons
```

## Database Queries

### View All Papers

```sql
SELECT 
    p.paper_id,
    p.subject_name,
    p.subject_code,
    p.year,
    p.chapter,
    p.file_url,
    u.username as uploaded_by,
    p.created_at
FROM papers p
LEFT JOIN users u ON p.uploaded_by = u.user_id
ORDER BY p.created_at DESC;
```

### Count Papers

```sql
SELECT COUNT(*) as total_papers FROM papers;
```

### Papers by Subject

```sql
SELECT subject_code, COUNT(*) as count
FROM papers
GROUP BY subject_code
ORDER BY count DESC;
```

## File Structure

```
PaperWise_AJT/
├── src/java/com/paperwise/
│   ├── dao/
│   │   └── PaperDAO.java              ✅ getAllPapers() exists
│   ├── servlet/
│   │   ├── AdminDashboardServlet.java ✅ NEW
│   │   ├── StudentDashboardServlet.java ✅ NEW
│   │   ├── LoginServlet.java          ✅ UPDATED - redirect to servlets
│   │   └── UploadPaperServlet.java    ✅ UPDATED - redirect to servlet
│   └── filter/
│       └── AuthFilter.java            ✅ UPDATED - protect servlets
├── web/
│   ├── admin-dashboard.jsp            ✅ UPDATED - papers table
│   ├── student-dashboard.jsp          ✅ UPDATED - papers table
│   └── uploads/                       ✅ File storage
└── PAPER_LISTING_FEATURE.md           ✅ This documentation
```

## Troubleshooting

### Issue: Papers not displaying

**Check:**
```sql
-- Verify papers exist
SELECT COUNT(*) FROM papers;

-- Check papers data
SELECT * FROM papers;
```

### Issue: "File not found" for all papers

**Check:**
```bash
# Verify uploads directory exists
ls -la $CATALINA_HOME/webapps/PaperWise_AJT/uploads/

# Check file_url format in database
SELECT file_url FROM papers LIMIT 5;
# Should be: uploads/filename.ext
```

### Issue: Success message not displaying

**Check:**
1. Session attribute name: `successMessage`
2. Redirect URL: `/adminDashboard` (not JSP)
3. JSP reads and removes attribute
4. JavaScript auto-hide is working

### Issue: Students can't access dashboard

**Check:**
1. User is authenticated
2. `/studentDashboard` not in admin-only resources
3. AuthFilter allows authenticated access

## Future Enhancements

1. **Search and Filter:**
   - Search by subject name/code
   - Filter by year
   - Filter by chapter

2. **Pagination:**
   - Limit papers per page
   - Page navigation
   - Configurable page size

3. **Sorting:**
   - Sort by any column
   - Ascending/descending
   - Remember sort preference

4. **File Management:**
   - Delete papers (admin only)
   - Edit metadata
   - Bulk operations

5. **Statistics:**
   - Total papers count
   - Papers by subject chart
   - Download statistics
   - Popular papers

---

**Paper listing feature is complete and ready!** 📄✅

**Key Features:**
- ✅ Admin dashboard with full paper listing
- ✅ Student dashboard with paper access
- ✅ View/Download functionality
- ✅ File existence validation
- ✅ Empty state handling
- ✅ Success message with auto-hide
- ✅ Role-based access control
- ✅ Responsive design
