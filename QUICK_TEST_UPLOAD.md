# Quick Test Guide - Paper Upload Module

## Prerequisites

- PostgreSQL running
- Database `paperwise_db` exists
- Papers table created
- Tomcat running with deployed application
- Admin user exists with password `admin123A!`

## Step 1: Create Papers Table

```bash
psql -U postgres -d paperwise_db -f database_setup.sql
```

**Verify:**
```sql
\d papers

-- Should show:
-- paper_id, title, subject_code, year, file_path, uploaded_by, uploaded_at
```

## Step 2: Login as Admin

```
URL: http://localhost:8080/PaperWise_AJT/login.jsp

Username: admin
Password: admin123A!
```

**Expected:**
- ✅ Login succeeds
- ✅ Redirects to admin dashboard
- ✅ Shows "Upload Paper" button

## Step 3: Access Upload Page

Click "Upload Paper" button or navigate to:
```
http://localhost:8080/PaperWise_AJT/uploadPaper
```

**Expected:**
- ✅ Upload form displays
- ✅ Shows file upload area
- ✅ Shows form fields (title, subject code, year)

## Step 4: Upload a Paper

### Test Valid Upload

```
Title: Data Structures Final Exam 2023
Subject Code: CS101
Year: 2023
File: Select a PDF file (< 10MB)
```

**Click "Upload Paper"**

**Expected:**
- ✅ Redirects to admin dashboard
- ✅ Shows success message: "Paper 'Data Structures Final Exam 2023' uploaded successfully!"
- ✅ File saved in uploads/ directory
- ✅ Database record created

### Verify Upload

**Check Database:**
```sql
SELECT * FROM papers ORDER BY uploaded_at DESC LIMIT 1;
```

**Expected Output:**
```
 paper_id |            title             | subject_code | year |        file_path         | uploaded_by |      uploaded_at
----------+------------------------------+--------------+------+--------------------------+-------------+---------------------
        1 | Data Structures Final Exam   | CS101        | 2023 | uploads/Data_Struct...   |           1 | 2026-02-26 10:30:00
```

**Check File System:**
```bash
# Windows
dir %CATALINA_HOME%\webapps\PaperWise_AJT\uploads

# Linux/Mac
ls -la $CATALINA_HOME/webapps/PaperWise_AJT/uploads/
```

**Expected:**
- File exists with unique name
- Format: `{name}_{timestamp}.{ext}`

## Step 5: Test Validation

### Empty Title

```
Title: (leave empty)
Subject Code: CS101
Year: 2023
File: Select file
```

**Expected:**
- ❌ Error: "All fields are required."

### Invalid Year

```
Title: Test Paper
Subject Code: CS101
Year: 1800
File: Select file
```

**Expected:**
- ❌ Error: "Please enter a valid year (1900-2100)."

### No File Selected

```
Title: Test Paper
Subject Code: CS101
Year: 2023
File: (don't select)
```

**Expected:**
- ❌ Error: "Please select a file to upload."

### Invalid File Type

```
Title: Test Paper
Subject Code: CS101
Year: 2023
File: Select .exe or .zip file
```

**Expected:**
- ❌ Error: "Invalid file type. Allowed types: PDF, DOC, DOCX, TXT"

### File Too Large

```
Title: Test Paper
Subject Code: CS101
Year: 2023
File: Select file > 10MB
```

**Expected:**
- ❌ Client-side: Alert "File size exceeds 10MB limit"
- ❌ Server-side: Multipart config rejects

## Step 6: Test Access Control

### Non-Admin Access

```
1. Logout
2. Login as student:
   Username: student
   Password: student123A!

3. Try to access:
   http://localhost:8080/PaperWise_AJT/uploadPaper
```

**Expected:**
- ❌ 403 Forbidden
- ❌ Message: "Access denied. Administrator privileges required."

### Unauthenticated Access

```
1. Logout
2. Try to access:
   http://localhost:8080/PaperWise_AJT/upload.jsp
```

**Expected:**
- ❌ Redirects to login page

## Step 7: Test Multiple Uploads

Upload 3 different papers:

```
Paper 1:
- Title: Algorithms Midterm 2023
- Subject: CS102
- Year: 2023
- File: algorithms.pdf

Paper 2:
- Title: Database Systems Final
- Subject: CS201
- Year: 2022
- File: database.docx

Paper 3:
- Title: Operating Systems Quiz
- Subject: CS301
- Year: 2023
- File: os_quiz.txt
```

**Verify:**
```sql
SELECT paper_id, title, subject_code, year 
FROM papers 
ORDER BY uploaded_at DESC;
```

**Expected:**
- All 3 papers in database
- All 3 files in uploads/ directory
- Unique filenames for each

## Step 8: Test File Download (Manual)

```
1. Note file_path from database:
   SELECT file_path FROM papers WHERE paper_id = 1;

2. Construct URL:
   http://localhost:8080/PaperWise_AJT/uploads/{filename}

3. Access URL in browser
```

**Expected:**
- File downloads or displays (depending on type)

**Note:** You may need to add a download servlet for proper file serving.

## Verification Checklist

- [ ] Papers table exists in database
- [ ] Can login as admin
- [ ] Upload button visible on admin dashboard
- [ ] Upload form displays correctly
- [ ] Can upload PDF file successfully
- [ ] Can upload DOC/DOCX file successfully
- [ ] Can upload TXT file successfully
- [ ] Success message displays after upload
- [ ] File saved in uploads/ directory
- [ ] Database record created correctly
- [ ] Unique filename generated
- [ ] Empty field validation works
- [ ] Invalid year validation works
- [ ] No file validation works
- [ ] Invalid file type validation works
- [ ] File size limit enforced
- [ ] Non-admin gets 403 error
- [ ] Unauthenticated redirects to login
- [ ] Multiple uploads work correctly
- [ ] Foreign key constraint works (uploaded_by)

## Database Queries

### View All Papers

```sql
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

### Count Papers by Subject

```sql
SELECT subject_code, COUNT(*) as paper_count
FROM papers
GROUP BY subject_code
ORDER BY paper_count DESC;
```

### Count Papers by Year

```sql
SELECT year, COUNT(*) as paper_count
FROM papers
GROUP BY year
ORDER BY year DESC;
```

### Papers Uploaded by Admin

```sql
SELECT p.title, p.uploaded_at
FROM papers p
JOIN users u ON p.uploaded_by = u.user_id
WHERE u.username = 'admin'
ORDER BY p.uploaded_at DESC;
```

## Cleanup

```sql
-- Delete all papers
DELETE FROM papers;

-- Reset sequence
ALTER SEQUENCE papers_paper_id_seq RESTART WITH 1;

-- Verify
SELECT COUNT(*) FROM papers;  -- Should be 0
```

```bash
# Delete uploaded files (Windows)
del /Q %CATALINA_HOME%\webapps\PaperWise_AJT\uploads\*

# Delete uploaded files (Linux/Mac)
rm -f $CATALINA_HOME/webapps/PaperWise_AJT/uploads/*
```

## Common Issues

### Issue: Uploads directory not found

**Solution:**
- Directory is created automatically on first upload
- Check Tomcat has write permissions
- Manually create: `mkdir uploads` in webapp root

### Issue: Foreign key constraint violation

**Solution:**
```sql
-- Check admin user exists
SELECT user_id, username FROM users WHERE username = 'admin';

-- If not, create admin user
INSERT INTO users (username, email, password, role)
VALUES ('admin', 'admin@paperwise.com', 'admin123A!', 'admin');
```

### Issue: File upload fails silently

**Solution:**
- Check Tomcat logs: `catalina.out`
- Check file permissions
- Verify multipart config
- Check file size limit

### Issue: Success message doesn't display

**Solution:**
- Check session attribute is set
- Verify admin-dashboard.jsp reads session attribute
- Clear browser cache

## Quick Commands

```bash
# Create table
psql -U postgres -d paperwise_db -f database_setup.sql

# Check papers
psql -U postgres -d paperwise_db -c "SELECT * FROM papers;"

# Count papers
psql -U postgres -d paperwise_db -c "SELECT COUNT(*) FROM papers;"

# Delete all papers
psql -U postgres -d paperwise_db -c "DELETE FROM papers;"

# Check uploads directory
dir %CATALINA_HOME%\webapps\PaperWise_AJT\uploads

# View Tomcat logs
type %CATALINA_HOME%\logs\catalina.out | findstr "Paper"
```

---

**All tests passing? Paper Upload Module is working!** 📄✅
