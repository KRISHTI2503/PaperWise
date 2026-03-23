# Quick Test Guide - Upload Enhancements

## Test Checklist

### ✅ File Size Tests

- [ ] Upload 1MB PDF - Should succeed
- [ ] Upload 50MB PPTX - Should succeed
- [ ] Upload 150MB MP4 - Should succeed
- [ ] Upload 200MB file - Should succeed
- [ ] Upload 250MB file - Should fail with size error

### ✅ File Type Tests

**Documents:**
- [ ] Upload .pdf file
- [ ] Upload .doc file
- [ ] Upload .docx file
- [ ] Upload .txt file

**Presentations:**
- [ ] Upload .ppt file
- [ ] Upload .pptx file

**Images:**
- [ ] Upload .jpg file
- [ ] Upload .jpeg file
- [ ] Upload .png file

**Videos:**
- [ ] Upload .mp4 file
- [ ] Upload .mkv file

**Invalid Types:**
- [ ] Try .exe - Should fail
- [ ] Try .zip - Should fail
- [ ] Try .mp3 - Should fail

### ✅ Directory Tests

- [ ] Delete uploads/ directory
- [ ] Upload a file
- [ ] Verify directory created automatically
- [ ] Verify file saved successfully

### ✅ Filename Tests

- [ ] Upload "test.pdf"
- [ ] Upload another "test.pdf"
- [ ] Verify both files exist with different names
- [ ] Verify format: timestamp_filename.ext

### ✅ Error Handling Tests

- [ ] Try upload without selecting file
- [ ] Try upload with empty title
- [ ] Try upload with invalid year
- [ ] Verify error messages display correctly

## Quick Test Commands

### 1. Check Upload Directory

```bash
# Windows
dir %CATALINA_HOME%\webapps\PaperWise_AJT\uploads

# Linux/Mac
ls -lh $CATALINA_HOME/webapps/PaperWise_AJT/uploads/
```

### 2. Check Database Records

```sql
SELECT 
    paper_id,
    title,
    subject_code,
    file_path,
    LENGTH(file_path) as path_length
FROM papers
ORDER BY uploaded_at DESC
LIMIT 5;
```

### 3. Verify File Paths

```sql
-- All should start with "uploads/"
SELECT file_path FROM papers;
```

### 4. Check File Extensions

```sql
SELECT 
    SUBSTRING(file_path FROM '\.([^.]+)$') as extension,
    COUNT(*) as count
FROM papers
GROUP BY extension;
```

## Test Scenarios

### Scenario 1: Upload Large Video

```
1. Login as admin
2. Click "Upload Paper"
3. Fill form:
   Title: Introduction to Programming Lecture 1
   Subject: CS101
   Year: 2023
   File: Select 150MB MP4 video

4. Click "Upload Paper"

Expected:
✅ Upload succeeds
✅ Success message displays
✅ File saved in uploads/
✅ Database record created
```

### Scenario 2: Upload Presentation

```
1. Login as admin
2. Click "Upload Paper"
3. Fill form:
   Title: Data Structures Slides
   Subject: CS102
   Year: 2023
   File: Select PPTX file

4. Click "Upload Paper"

Expected:
✅ Upload succeeds
✅ File type accepted
✅ File saved correctly
```

### Scenario 3: Upload Image

```
1. Login as admin
2. Click "Upload Paper"
3. Fill form:
   Title: Algorithm Flowchart
   Subject: CS103
   Year: 2023
   File: Select PNG image

4. Click "Upload Paper"

Expected:
✅ Upload succeeds
✅ Image file accepted
✅ File saved correctly
```

### Scenario 4: Test File Size Limit

```
1. Login as admin
2. Click "Upload Paper"
3. Fill form with 250MB file
4. Try to upload

Expected:
❌ Client-side alert: "File size exceeds 200MB limit"
❌ Upload prevented
```

### Scenario 5: Test Invalid File Type

```
1. Login as admin
2. Click "Upload Paper"
3. Try to select .exe file

Expected:
❌ File picker filters out .exe
❌ If bypassed, server rejects with error
```

### Scenario 6: Test Directory Creation

```
1. Stop Tomcat
2. Delete uploads/ directory:
   rm -rf $CATALINA_HOME/webapps/PaperWise_AJT/uploads

3. Start Tomcat
4. Login as admin
5. Upload a file

Expected:
✅ Directory created automatically
✅ File uploaded successfully
✅ No errors
```

### Scenario 7: Test Duplicate Filenames

```
1. Upload file: "lecture.pdf"
   Saved as: 1709024567890_lecture.pdf

2. Upload another "lecture.pdf"
   Saved as: 1709024567891_lecture.pdf

3. Verify both files exist

Expected:
✅ No filename conflicts
✅ Both files saved
✅ Different timestamps
```

## Verification Steps

### 1. Check Tomcat Logs

```bash
# Windows
type %CATALINA_HOME%\logs\catalina.out | findstr "Upload"

# Linux/Mac
tail -f $CATALINA_HOME/logs/catalina.out | grep "Upload"
```

**Look for:**
```
INFO: Upload path resolved to: /path/to/uploads
INFO: Created upload directory: /path/to/uploads
INFO: File saved successfully: /path/to/file
INFO: Paper 'Title' uploaded successfully by user 'admin'
```

### 2. Verify File Sizes

```bash
# Check individual file sizes
ls -lh $CATALINA_HOME/webapps/PaperWise_AJT/uploads/

# Check total directory size
du -sh $CATALINA_HOME/webapps/PaperWise_AJT/uploads/
```

### 3. Test File Access

```
1. Note file_path from database
2. Construct URL:
   http://localhost:8080/PaperWise_AJT/uploads/{filename}

3. Access in browser

Expected:
- PDF: Opens in browser
- Images: Display in browser
- Videos: May download or play
- Documents: Download
```

## Common Issues and Solutions

### Issue: "Failed to create upload directory"

**Check:**
```bash
# Verify Tomcat has write permissions
ls -la $CATALINA_HOME/webapps/PaperWise_AJT/

# Manually create if needed
mkdir $CATALINA_HOME/webapps/PaperWise_AJT/uploads
chmod 755 $CATALINA_HOME/webapps/PaperWise_AJT/uploads
```

### Issue: Large file upload fails

**Check Tomcat server.xml:**
```xml
<Connector port="8080" 
           maxPostSize="262144000"
           maxSwallowSize="262144000" />
```

**Restart Tomcat after changes**

### Issue: File type rejected incorrectly

**Verify:**
1. File extension is lowercase
2. Extension in ALLOWED_EXTENSIONS array
3. Accept attribute in HTML includes extension

### Issue: Slow upload for large files

**Normal behavior:**
- 50MB: ~10-20 seconds
- 100MB: ~20-40 seconds
- 200MB: ~40-80 seconds

**Depends on:**
- Network speed
- Disk speed
- Server load

## Performance Monitoring

### Monitor Disk Space

```bash
# Check available space
df -h

# Check uploads directory size
du -sh $CATALINA_HOME/webapps/PaperWise_AJT/uploads/
```

### Monitor Database Size

```sql
-- Check table size
SELECT pg_size_pretty(pg_total_relation_size('papers'));

-- Count records
SELECT COUNT(*) FROM papers;

-- Average file path length
SELECT AVG(LENGTH(file_path)) FROM papers;
```

### Monitor Upload Times

**Check Tomcat logs for timing:**
```
INFO: File saved successfully: /path/to/file (took 2.5 seconds)
```

## Success Criteria

All of the following must pass:

- ✅ Can upload files up to 200MB
- ✅ Can upload PDF, DOC, DOCX files
- ✅ Can upload PPT, PPTX files
- ✅ Can upload JPG, JPEG, PNG files
- ✅ Can upload MP4, MKV files
- ✅ Files > 200MB are rejected
- ✅ Invalid file types are rejected
- ✅ Upload directory created automatically
- ✅ Filenames are unique (timestamp-based)
- ✅ Error messages display correctly
- ✅ Stack traces logged for debugging
- ✅ Files saved with correct paths
- ✅ Database records created correctly
- ✅ Admin-only access enforced
- ✅ Success messages display

## Cleanup

```sql
-- Delete test papers
DELETE FROM papers WHERE title LIKE '%Test%';

-- Or delete all
DELETE FROM papers;
ALTER SEQUENCE papers_paper_id_seq RESTART WITH 1;
```

```bash
# Delete test files
rm -f $CATALINA_HOME/webapps/PaperWise_AJT/uploads/*
```

---

**All tests passing? Upload enhancements are working!** 📄✅

**New Features Verified:**
- ✅ 200MB file size limit
- ✅ 11 file types supported
- ✅ Automatic directory creation
- ✅ Enhanced error handling
- ✅ Improved filename generation
