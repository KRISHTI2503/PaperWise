# Admin Management Features - Edit and Delete Papers

## Overview
Complete implementation of admin management features allowing administrators to edit paper metadata and delete papers from the system.

## Implementation Date
February 26, 2026

## Features Implemented

### 1. Edit Paper Functionality
- **Servlet**: `EditPaperServlet.java` (@WebServlet("/editPaper"))
- **View**: `editPaper.jsp`
- **Capabilities**:
  - GET: Loads paper by ID and displays edit form
  - POST: Updates paper metadata in database
  - Updates: subject_name, subject_code, year, chapter
  - Does NOT update file_url (uploaded file cannot be changed)
  - Admin-only access with role verification
  - Validation for all required fields
  - Null-safe handling for optional chapter field

### 2. Delete Paper Functionality
- **Servlet**: `DeletePaperServlet.java` (@WebServlet("/deletePaper"))
- **Capabilities**:
  - Deletes physical file from uploads folder
  - Removes database record
  - Admin-only access with role verification
  - Confirmation dialog before deletion
  - Proper error handling and logging

### 3. Updated Admin Dashboard
- **File**: `admin-dashboard.jsp`
- **Enhancements**:
  - Added Edit button for each paper
  - Added Delete button with confirmation dialog
  - Total papers count display in header
  - Improved action buttons layout
  - Color-coded buttons:
    - View: Blue (#4299e1)
    - Download: Green (#48bb78)
    - Edit: Orange (#ed8936)
    - Delete: Red (#e53e3e)

### 4. Updated AuthFilter
- **File**: `AuthFilter.java`
- **Protected Endpoints**:
  - `/editPaper` - Admin only
  - `/editPaper.jsp` - Admin only
  - `/deletePaper` - Admin only

## Database Operations

### PaperDAO Methods Used
1. `getPaperById(int paperId)` - Fetch paper for editing
2. `updatePaper(Paper paper)` - Update paper metadata
3. `deletePaper(int paperId)` - Delete paper record

### SQL Operations
```sql
-- Update paper metadata
UPDATE papers 
SET subject_name = ?, subject_code = ?, year = ?, chapter = ? 
WHERE paper_id = ?

-- Delete paper
DELETE FROM papers WHERE paper_id = ?
```

## User Interface

### Edit Paper Form
- Pre-filled with existing paper data
- Fields:
  - Subject Name (required, max 150 chars)
  - Subject Code (required, max 50 chars)
  - Year (required, 1900-2100)
  - Chapter (optional, max 100 chars)
- Info box: "You can only edit paper metadata. The uploaded file cannot be changed."
- Buttons: Update Paper, Cancel

### Admin Dashboard Actions
Each paper row displays:
- View button (if file exists)
- Download button (if file exists)
- Edit button (always visible)
- Delete button (with confirmation)

## Security Features

### Role Protection
- All servlets verify admin role before processing
- Non-admin users receive 403 Forbidden error
- Session validation on every request

### Confirmation Dialog
- JavaScript confirmation before deletion
- Message: "Are you sure you want to delete this paper? This action cannot be undone."

## Error Handling

### Edit Paper Errors
- Invalid paper ID format
- Paper not found
- Missing required fields
- Database errors

### Delete Paper Errors
- Invalid paper ID format
- Paper not found
- File deletion failures (logged but not blocking)
- Database errors

## Success Messages
- Edit: "Paper '[subject_name]' updated successfully!"
- Delete: "Paper '[subject_name]' deleted successfully!"
- Auto-hide after 3 seconds

## Logging
All operations logged with:
- INFO: Successful operations
- WARNING: Invalid inputs, missing files
- SEVERE: Database errors, initialization failures

## File Structure
```
src/java/com/paperwise/servlet/
├── EditPaperServlet.java       (NEW)
├── DeletePaperServlet.java     (NEW)
└── AdminDashboardServlet.java  (existing)

web/
├── editPaper.jsp               (NEW)
└── admin-dashboard.jsp         (UPDATED)

src/java/com/paperwise/filter/
└── AuthFilter.java             (UPDATED)

src/java/com/paperwise/dao/
└── PaperDAO.java               (existing - has updatePaper, deletePaper)
```

## Testing Checklist

### Edit Paper
- [ ] Load edit form with existing paper data
- [ ] Update all fields successfully
- [ ] Update with null chapter
- [ ] Validate required fields
- [ ] Verify file_url is NOT changed
- [ ] Check success message display
- [ ] Test with non-admin user (should fail)

### Delete Paper
- [ ] Delete paper with existing file
- [ ] Delete paper with missing file
- [ ] Verify confirmation dialog appears
- [ ] Check physical file is deleted
- [ ] Check database record is deleted
- [ ] Verify success message display
- [ ] Test with non-admin user (should fail)

### Admin Dashboard
- [ ] Verify total papers count
- [ ] Check all action buttons display correctly
- [ ] Test Edit button navigation
- [ ] Test Delete button confirmation
- [ ] Verify View/Download only show when file exists

## Notes
- File uploads cannot be changed during edit (by design)
- Physical file deletion failures are logged but don't block database deletion
- All operations require admin role
- Success messages auto-hide after 3 seconds
- Delete confirmation prevents accidental deletions
