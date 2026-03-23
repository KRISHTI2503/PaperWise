# Paper Upload Module Documentation

## Overview

The Paper Upload Module allows admin users to upload academic papers (PDFs, DOC, DOCX, TXT files) to the PaperWise system. Files are stored in the `/uploads/` directory, and metadata is saved to the PostgreSQL database.

## Features Implemented

### 1. Database Table: `papers`

**Schema:**
```sql
CREATE TABLE papers (
    paper_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    subject_code VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    uploaded_by INTEGER NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_uploaded_by FOREIGN KEY (uploaded_by) 
        REFERENCES users(user_id) ON DELETE CASCADE
);
```

**Indexes:**
- `idx_papers_subject_code` - For filtering by subject
- `idx_papers_year` - For filtering by year
- `idx_papers_uploaded_by` - For tracking uploader

### 2. Paper Model (`com.paperwise.model.Paper`)

**Fields:**
- `paperId` (int) - Primary key
- `title` (String) - Paper title
- `subjectCode` (String) - Subject code (e.g., CS101)
- `year` (int) - Year of the paper
- `filePath` (String) - Relative path to uploaded file
- `uploadedBy` (int) - User ID of uploader
- `uploadedAt` (LocalDateTime) - Upload timestamp
- `uploaderUsername` (String) - Optional, for display

### 3. PaperDAO (`com.paperwise.dao.PaperDAO`)

**Methods:**

#### `boolean savePaper(Paper paper)`
- Inserts paper metadata into database
- Uses PreparedStatement for SQL injection prevention
- Returns true on success

#### `List<Paper> getAllPapers()`
- Retrieves all papers with uploader information
- Joins with users table to get username
- Orders by upload date (newest first)

#### `Paper getPaperById(int paperId)`
- Retrieves a single paper by ID
- Returns null if not found

#### `boolean deletePaper(int paperId)`
- Deletes a paper from database
- Returns true if deleted

**JNDI DataSource:**
- Uses `java:comp/env/jdbc/paperwise`
- Connection pooling via Tomcat
- Try-with-resources for proper cleanup

### 4. UploadPaperServlet (`@WebServlet("/uploadPaper")`)

**Configuration:**
```java
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
```

**Features:**
- Admin-only access (role check)
- File upload handling
- File validation (type, size)
- Unique filename generation
- Database metadata storage
- Success/error handling

**Allowed File Types:**
- PDF (.pdf)
- Microsoft Word (.doc, .docx)
- Text files (.txt)

**File Size Limit:** 10MB

**Upload Directory:** `/uploads/` (relative to application root)

### 5. upload.jsp

**Features:**
- Modern, responsive UI
- Drag-and-drop file upload
- Real-time file selection feedback
- Client-side validation
- Form validation before submission
- Error message display
- Admin-only access check

**Form Fields:**
- Title (required, max 255 chars)
- Subject Code (required, max 50 chars)
- Year (required, 1900-2100)
- File (required, PDF/DOC/DOCX/TXT, max 10MB)

### 6. AuthFilter Updates

**Admin-Only Resources:**
- `/upload.jsp` - Upload form page
- `/uploadPaper` - Upload servlet
- `/admin-*` - All admin pages

**Access Control:**
- Unauthenticated users → Redirect to login
- Authenticated non-admin → 403 Forbidden
- Authenticated admin → Allow access

### 7. Admin Dashboard Updates

**New Features:**
- "Upload Paper" button
- Success message display
- Improved styling

## File Upload Flow

1. **Admin accesses upload page:**
   - URL: `/uploadPaper` (GET)
   - AuthFilter checks admin role
   - Displays upload form

2. **Admin fills form and selects file:**
   - Title, subject code, year
   - File selection (drag-drop or click)
   - Client-side validation

3. **Form submission:**
   - POST to `/uploadPaper`
   - Multipart/form-data encoding

4. **Server-side processing:**
   - Verify admin role
   - Validate form input
   - Validate file (type, size)
   - Generate unique filename
   - Save file to `/uploads/` directory
   - Save metadata to database
   - Redirect to admin dashboard

5. **Success:**
   - File stored in `/uploads/`
   - Metadata in `papers` table
   - Success message on dashboard

## File Storage

### Directory Structure

```
PaperWise_AJT/
├── uploads/                          (Created automatically)
│   ├── DataStructures_1234567890.pdf
│   ├── Algorithm_1234567891.docx
│   └── MathExam_1234567892.pdf
└── ...
```

### Filename Generation

**Original:** `Data Structures Exam.pdf`

**Generated:** `Data_Structures_Exam_1234567890123.pdf`

**Format:** `{sanitized_name}_{timestamp}.{extension}`

**Sanitization:**
- Replace special characters with underscore
- Keep alphanumeric, dash, underscore
- Preserve file extension

### File Path Storage

**Database:** `uploads/Data_Structures_Exam_1234567890123.pdf`

**Absolute Path:** `{TOMCAT_HOME}/webapps/PaperWise_AJT/uploads/...`

## Security Features

### 1. Role-Based Access Control

```java
// Only admin can upload
if (!isAdmin(request)) {
    response.sendError(HttpServletResponse.SC_FORBIDDEN);
    return;
}
```

### 2. File Type Validation

```java
// Server-side validation
private static final String[] ALLOWED_EXTENSIONS = {
    ".pdf", ".doc", ".docx", ".txt"
};
```

### 3. File Size Limits

```java
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 10  // 10MB
)
```

### 4. SQL Injection Prevention

```java
// PreparedStatement usage
PreparedStatement statement = connection.prepareStatement(SQL_INSERT_PAPER);
statement.setString(1, paper.getTitle());
```

### 5. Unique Filename Generation

```java
// Prevents file overwriting
String uniqueFileName = generateUniqueFileName(fileName);
```

### 6. Input Sanitization

```java
// Sanitize all user input
String title = sanitise(request.getParameter("title"));
```

## Database Setup

### Create Table

```bash
psql -U postgres -d paperwise_db -f database_setup.sql
```

Or manually:

```sql
CREATE TABLE papers (
    paper_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    subject_code VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    uploaded_by INTEGER NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_uploaded_by FOREIGN KEY (uploaded_by) 
        REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX idx_papers_subject_code ON papers(subject_code);
CREATE INDEX idx_papers_year ON papers(year);
CREATE INDEX idx_papers_uploaded_by ON papers(uploaded_by);
```

### Verify Table

```sql
\d papers

SELECT * FROM papers;
```

## Testing

### 1. Setup

```bash
# Create database table
psql -U postgres -d paperwise_db -f database_setup.sql

# Deploy application
ant clean dist
copy dist\PaperWise_AJT.war %CATALINA_HOME%\webapps\

# Start Tomcat
%CATALINA_HOME%\bin\startup.bat
```

### 2. Test Admin Access

```
1. Login as admin:
   URL: http://localhost:8080/PaperWise_AJT/login.jsp
   Username: admin
   Password: admin123A!

2. Click "Upload Paper" button

3. Verify upload form displays
```

### 3. Test File Upload

```
1. Fill form:
   Title: Data Structures Final Exam
   Subject Code: CS101
   Year: 2023
   File: Select a PDF file

2. Click "Upload Paper"

3. Verify:
   - Redirects to admin dashboard
   - Success message displays
   - File exists in uploads/ directory
   - Database record created
```

### 4. Test Validation

**Empty Fields:**
```
Leave title empty → Error: "All fields are required."
```

**Invalid Year:**
```
Year: 1800 → Error: "Please enter a valid year (1900-2100)."
```

**No File Selected:**
```
Don't select file → Error: "Please select a file to upload."
```

**Invalid File Type:**
```
Select .exe file → Error: "Invalid file type. Allowed types: PDF, DOC, DOCX, TXT"
```

**File Too Large:**
```
Select 15MB file → Error: File size exceeds limit
```

### 5. Test Access Control

**Non-Admin Access:**
```
1. Login as student:
   Username: student
   Password: student123A!

2. Try to access:
   URL: http://localhost:8080/PaperWise_AJT/uploadPaper

3. Verify:
   - 403 Forbidden error
   - Message: "Access denied. Administrator privileges required."
```

**Unauthenticated Access:**
```
1. Logout

2. Try to access:
   URL: http://localhost:8080/PaperWise_AJT/upload.jsp

3. Verify:
   - Redirects to login page
```

### 6. Verify Database

```sql
-- Check uploaded papers
SELECT 
    p.paper_id,
    p.title,
    p.subject_code,
    p.year,
    p.file_path,
    u.username as uploaded_by,
    p.uploaded_at
FROM papers p
JOIN users u ON p.uploaded_by = u.user_id
ORDER BY p.uploaded_at DESC;
```

### 7. Verify File System

```bash
# Windows
dir %CATALINA_HOME%\webapps\PaperWise_AJT\uploads

# Linux/Mac
ls -la $CATALINA_HOME/webapps/PaperWise_AJT/uploads/
```

## API Reference

### UploadPaperServlet Endpoints

#### GET /uploadPaper
- **Description:** Display upload form
- **Authentication:** Required (admin only)
- **Response:** upload.jsp

#### POST /uploadPaper
- **Description:** Process file upload
- **Authentication:** Required (admin only)
- **Content-Type:** multipart/form-data
- **Parameters:**
  - `title` (required): Paper title
  - `subjectCode` (required): Subject code
  - `year` (required): Year (1900-2100)
  - `file` (required): File upload (PDF/DOC/DOCX/TXT, max 10MB)
- **Success Response:**
  - Redirect to `/admin-dashboard.jsp`
  - Session attribute: `successMessage`
- **Error Response:**
  - Forward to `/upload.jsp`
  - Request attribute: `errorMessage`

### PaperDAO Methods

#### `boolean savePaper(Paper paper)`
```java
Paper paper = new Paper();
paper.setTitle("Data Structures Exam");
paper.setSubjectCode("CS101");
paper.setYear(2023);
paper.setFilePath("uploads/exam_123456.pdf");
paper.setUploadedBy(adminUserId);

boolean success = paperDAO.savePaper(paper);
```

#### `List<Paper> getAllPapers()`
```java
List<Paper> papers = paperDAO.getAllPapers();
for (Paper paper : papers) {
    System.out.println(paper.getTitle());
}
```

#### `Paper getPaperById(int paperId)`
```java
Paper paper = paperDAO.getPaperById(1);
if (paper != null) {
    System.out.println(paper.getTitle());
}
```

#### `boolean deletePaper(int paperId)`
```java
boolean deleted = paperDAO.deletePaper(1);
```

## File Structure

```
PaperWise_AJT/
├── src/java/com/paperwise/
│   ├── dao/
│   │   ├── PaperDAO.java              ✅ NEW - Paper database operations
│   │   └── UserDAO.java               ✅ Existing
│   ├── filter/
│   │   └── AuthFilter.java            ✅ UPDATED - Admin-only resources
│   ├── model/
│   │   ├── Paper.java                 ✅ NEW - Paper entity
│   │   └── User.java                  ✅ Existing
│   └── servlet/
│       ├── LoginServlet.java          ✅ Existing
│       ├── LogoutServlet.java         ✅ Existing
│       ├── RegisterServlet.java       ✅ Existing
│       ├── TestDBServlet.java         ✅ Existing
│       └── UploadPaperServlet.java    ✅ NEW - File upload handling
├── web/
│   ├── admin-dashboard.jsp            ✅ UPDATED - Upload button, success message
│   ├── login.jsp                      ✅ Existing
│   ├── register.jsp                   ✅ Existing
│   ├── student-dashboard.jsp          ✅ Existing
│   ├── upload.jsp                     ✅ NEW - Upload form
│   └── uploads/                       ✅ NEW - File storage directory
├── database_setup.sql                 ✅ UPDATED - Papers table
└── PAPER_UPLOAD_MODULE.md             ✅ This documentation
```

## Troubleshooting

### Issue: 403 Forbidden when accessing upload page

**Cause:** User is not admin

**Solution:**
```sql
-- Check user role
SELECT username, role FROM users WHERE username = 'admin';

-- Update role if needed
UPDATE users SET role = 'admin' WHERE username = 'admin';
```

### Issue: File upload fails with "Directory not found"

**Cause:** Uploads directory doesn't exist

**Solution:**
- Directory is created automatically
- Check Tomcat has write permissions
- Verify application is deployed

### Issue: Database error when saving paper

**Cause:** Papers table doesn't exist

**Solution:**
```bash
psql -U postgres -d paperwise_db -f database_setup.sql
```

### Issue: File size exceeds limit

**Cause:** File larger than 10MB

**Solution:**
- Reduce file size
- Or increase limit in `@MultipartConfig`

### Issue: Invalid file type error

**Cause:** File extension not allowed

**Solution:**
- Use PDF, DOC, DOCX, or TXT files
- Or add extension to `ALLOWED_EXTENSIONS` array

## Configuration

### Change Upload Directory

**UploadPaperServlet.java:**
```java
private static final String UPLOAD_DIRECTORY = "uploads";
// Change to: "papers", "documents", etc.
```

### Change File Size Limit

**UploadPaperServlet.java:**
```java
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 20  // Change to 20MB
)
```

### Add Allowed File Types

**UploadPaperServlet.java:**
```java
private static final String[] ALLOWED_EXTENSIONS = {
    ".pdf", ".doc", ".docx", ".txt", ".ppt", ".pptx"  // Add PowerPoint
};
```

## Future Enhancements

1. **Paper Listing Page:**
   - Display all uploaded papers
   - Search and filter functionality
   - Download links

2. **Paper Management:**
   - Edit paper metadata
   - Delete papers
   - Bulk operations

3. **File Preview:**
   - PDF viewer integration
   - Document preview

4. **Advanced Search:**
   - Full-text search
   - Filter by subject, year
   - Sort options

5. **File Versioning:**
   - Upload new versions
   - Version history
   - Rollback capability

6. **Access Control:**
   - Student access permissions
   - Download tracking
   - Usage analytics

---

**Paper Upload Module is complete and ready for use!** 📄✅
