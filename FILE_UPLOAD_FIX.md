# File Upload and 404 Fix - External Storage Solution

## Issue Fixed
Files were being uploaded to the application's deployment directory, causing 404 errors when the application was redeployed or when Tomcat couldn't resolve the path correctly.

## Solution
Use an external fixed directory (`C:/paperwise_uploads`) and serve files through a dedicated servlet.

## Implementation Date
February 27, 2026

## Changes Made

### 1. UploadPaperServlet
**Upload Directory**: Changed from dynamic to fixed external path
```java
// OLD (problematic):
String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";

// NEW (fixed):
String uploadPath = "C:/paperwise_uploads";
```

**Directory Creation**: Uses `mkdirs()` for nested directories
```java
File uploadDir = new File(uploadPath);
if (!uploadDir.exists()) {
    uploadDir.mkdirs();
}
```

**File Saving**: Direct write to external directory
```java
filePart.write(uploadPath + File.separator + uniqueFileName);
```

**Database Storage**: Stores only filename (NOT path)
```java
// OLD: "uploads/filename.ext"
// NEW: "filename.ext"
String filePath = uniqueFileName;
paper.setFileUrl(filePath);
```

### 2. ViewFileServlet (NEW)
**Purpose**: Serves files from external storage directory

**URL Mapping**: `/viewFile`

**Parameters**:
- `fileName` (required) - The filename to serve
- `download` (optional) - If present, forces download instead of inline view

**Security Features**:
- Prevents directory traversal attacks (blocks `..`, `/`, `\`)
- Validates file exists before serving
- Only serves files from designated directory

**Content Type Detection**:
- Automatically detects MIME type based on file extension
- Falls back to `application/octet-stream` for unknown types

**Streaming**:
```java
try (FileInputStream fileInputStream = new FileInputStream(file);
     OutputStream outputStream = response.getOutputStream()) {
    
    byte[] buffer = new byte[4096];
    int bytesRead;
    
    while ((bytesRead = fileInputStream.read(buffer)) != -1) {
        outputStream.write(buffer, 0, bytesRead);
    }
}
```

### 3. admin-dashboard.jsp
**View Link**: Changed to use ViewFileServlet
```jsp
<!-- OLD -->
<a href="${pageContext.request.contextPath}/${paper.fileUrl}">View</a>

<!-- NEW -->
<a href="${pageContext.request.contextPath}/viewFile?fileName=${paper.fileUrl}">View</a>
```

**Download Link**: Added download parameter
```jsp
<a href="${pageContext.request.contextPath}/viewFile?fileName=${paper.fileUrl}&download=true">
    Download
</a>
```

### 4. student-dashboard.jsp
Same changes as admin-dashboard.jsp

### 5. DeletePaperServlet
**File Deletion**: Updated to use external directory
```java
// OLD:
String filePath = getServletContext().getRealPath("/") + fileUrl;

// NEW:
String filePath = "C:/paperwise_uploads" + File.separator + fileUrl;
```

## File Flow

### Upload Flow
```
1. User selects file in upload.jsp
   ↓
2. POST to /uploadPaper
   ↓
3. UploadPaperServlet receives file
   ↓
4. Save to C:/paperwise_uploads/timestamp_filename.ext
   ↓
5. Store in DB: "timestamp_filename.ext"
   ↓
6. Redirect to /adminDashboard
```

### View Flow
```
1. User clicks "View" button
   ↓
2. GET /viewFile?fileName=timestamp_filename.ext
   ↓
3. ViewFileServlet reads from C:/paperwise_uploads/
   ↓
4. Streams file to browser
   ↓
5. Browser displays file (inline)
```

### Download Flow
```
1. User clicks "Download" button
   ↓
2. GET /viewFile?fileName=timestamp_filename.ext&download=true
   ↓
3. ViewFileServlet reads from C:/paperwise_uploads/
   ↓
4. Sets Content-Disposition: attachment
   ↓
5. Browser downloads file
```

## Directory Structure

### External Storage
```
C:/
└── paperwise_uploads/
    ├── 1709020800000_document.pdf
    ├── 1709020801000_presentation.pptx
    ├── 1709020802000_image.jpg
    └── ...
```

### Database
```sql
papers table:
- paper_id: 1
- file_url: "1709020800000_document.pdf"  (filename only)

- paper_id: 2
- file_url: "1709020801000_presentation.pptx"

- paper_id: 3
- file_url: "1709020802000_image.jpg"
```

## Benefits

### 1. Persistence
- Files survive application redeployment
- Files survive Tomcat restarts
- Files survive WAR file updates

### 2. Portability
- Easy to backup (single directory)
- Easy to migrate (copy directory)
- Easy to configure (change one constant)

### 3. Security
- Files not accessible via direct URL
- All access goes through servlet (can add authentication)
- Directory traversal protection

### 4. Performance
- No servlet context lookups
- Direct file system access
- Efficient streaming

### 5. Maintainability
- Clear separation of concerns
- Easy to debug (fixed path)
- Easy to monitor (single directory)

## Configuration

### Change Upload Directory
To use a different directory, update the constant in two places:

**UploadPaperServlet.java**:
```java
String uploadPath = "C:/paperwise_uploads";  // Change this
```

**ViewFileServlet.java**:
```java
private static final String UPLOAD_DIRECTORY = "C:/paperwise_uploads";  // Change this
```

**DeletePaperServlet.java**:
```java
String filePath = "C:/paperwise_uploads" + File.separator + fileUrl;  // Change this
```

### For Linux/Mac
Change to:
```java
String uploadPath = "/var/paperwise_uploads";
```

### For Network Drive
```java
String uploadPath = "\\\\server\\share\\paperwise_uploads";
```

## Security Considerations

### ViewFileServlet Security
1. **Directory Traversal Prevention**:
   ```java
   if (fileName.contains("..") || fileName.contains("/") || fileName.contains("\\")) {
       response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid file name.");
       return;
   }
   ```

2. **File Existence Check**:
   ```java
   if (!file.exists() || !file.isFile()) {
       response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found.");
       return;
   }
   ```

3. **Authentication** (Future Enhancement):
   ```java
   // Add at the beginning of doGet()
   HttpSession session = request.getSession(false);
   if (session == null || session.getAttribute("loggedInUser") == null) {
       response.sendRedirect(request.getContextPath() + "/login.jsp");
       return;
   }
   ```

## Testing Checklist

### Upload Tests
- [ ] Upload PDF file
- [ ] Upload DOC file
- [ ] Upload image file
- [ ] Upload video file
- [ ] Verify file saved to C:/paperwise_uploads
- [ ] Verify filename stored in database
- [ ] Verify success message displays

### View Tests
- [ ] Click "View" button
- [ ] PDF opens in new tab
- [ ] Image displays in browser
- [ ] Video plays in browser
- [ ] No 404 errors

### Download Tests
- [ ] Click "Download" button
- [ ] File downloads to computer
- [ ] Filename is correct
- [ ] File opens correctly

### Delete Tests
- [ ] Delete paper
- [ ] Verify file deleted from C:/paperwise_uploads
- [ ] Verify database record deleted
- [ ] Verify success message

### Security Tests
- [ ] Try accessing /viewFile without fileName parameter
- [ ] Try accessing /viewFile?fileName=../../../etc/passwd
- [ ] Try accessing /viewFile?fileName=C:/Windows/System32/config/sam
- [ ] Verify all blocked with error messages

### Persistence Tests
- [ ] Upload file
- [ ] Restart Tomcat
- [ ] Verify file still accessible
- [ ] Redeploy WAR file
- [ ] Verify file still accessible

## Troubleshooting

### Issue: "Failed to create upload directory"
**Solution**: Ensure the application has write permissions to C:/ drive
```bash
# Windows: Run as Administrator or grant permissions
icacls C:\paperwise_uploads /grant Users:(OI)(CI)F
```

### Issue: "File not found" when viewing
**Solution**: Check that file exists in C:/paperwise_uploads
```bash
# Windows
dir C:\paperwise_uploads

# Verify filename matches database
```

### Issue: Files not downloading
**Solution**: Check ViewFileServlet is mapped correctly
```bash
# Verify servlet mapping
# Should see: @WebServlet("/viewFile")
```

### Issue: 404 on /viewFile
**Solution**: Ensure servlet is compiled and deployed
```bash
# Check if ViewFileServlet.class exists in WEB-INF/classes
```

## Migration from Old System

### If you have existing files in uploads/ folder:

1. **Copy files to new location**:
   ```bash
   # Windows
   xcopy /E /I "C:\path\to\tomcat\webapps\paperwise\uploads" "C:\paperwise_uploads"
   ```

2. **Update database**:
   ```sql
   -- Remove "uploads/" prefix from file_url
   UPDATE papers 
   SET file_url = REPLACE(file_url, 'uploads/', '');
   ```

3. **Verify**:
   ```sql
   -- Check updated paths
   SELECT paper_id, file_url FROM papers;
   
   -- Should show:
   -- 1, "1709020800000_document.pdf"
   -- NOT: "uploads/1709020800000_document.pdf"
   ```

## Summary

### Files Changed
1. **UploadPaperServlet.java** - Uses C:/paperwise_uploads, stores filename only
2. **ViewFileServlet.java** (NEW) - Serves files from external directory
3. **admin-dashboard.jsp** - Uses /viewFile servlet
4. **student-dashboard.jsp** - Uses /viewFile servlet
5. **DeletePaperServlet.java** - Deletes from C:/paperwise_uploads

### Key Points
- Files stored in: `C:/paperwise_uploads`
- Database stores: `filename.ext` (NOT path)
- Files served via: `/viewFile?fileName=filename.ext`
- View: Opens in browser (inline)
- Download: Forces download (attachment)

The file upload and 404 issue is now permanently fixed!
