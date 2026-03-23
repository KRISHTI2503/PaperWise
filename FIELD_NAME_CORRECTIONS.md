# Field Name Corrections - Database Schema Alignment

## Overview

Updated Java code to match the actual PostgreSQL database schema. The database uses different column names than initially implemented.

## Database Schema (Actual)

```sql
CREATE TABLE papers (
    paper_id SERIAL PRIMARY KEY,
    subject_name VARCHAR(150) NOT NULL,
    subject_code VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    chapter VARCHAR(100),              -- NULLABLE
    file_url VARCHAR(255) NOT NULL,
    uploaded_by INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_uploaded_by FOREIGN KEY (uploaded_by) 
        REFERENCES users(user_id) ON DELETE CASCADE
);
```

## Field Name Changes

### Before (Incorrect) → After (Correct)

| Old Field Name | New Field Name | Type | Notes |
|----------------|----------------|------|-------|
| `title` | `subjectName` | VARCHAR(150) | Required |
| `filePath` | `fileUrl` | VARCHAR(255) | Required |
| `uploadedAt` | `createdAt` | TIMESTAMP | Auto-generated |
| N/A | `chapter` | VARCHAR(100) | **NEW - Optional** |

### Fields Unchanged

- `paperId` → `paper_id`
- `subjectCode` → `subject_code`
- `year` → `year`
- `uploadedBy` → `uploaded_by`

## Files Updated

### 1. Paper.java (Model)

**Changed Fields:**
```java
// Before
private String title;
private String filePath;
private LocalDateTime uploadedAt;

// After
private String subjectName;
private String fileUrl;
private String chapter;        // NEW - nullable
private LocalDateTime createdAt;
```

**Changed Getters/Setters:**
```java
// Before
getTitle() / setTitle()
getFilePath() / setFilePath()
getUploadedAt() / setUploadedAt()

// After
getSubjectName() / setSubjectName()
getFileUrl() / setFileUrl()
getChapter() / setChapter()    // NEW
getCreatedAt() / setCreatedAt()
```

### 2. PaperDAO.java

**Updated SQL:**
```sql
-- Before
INSERT INTO papers (title, subject_code, year, file_path, uploaded_by, uploaded_at) 
VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)

-- After
INSERT INTO papers (subject_name, subject_code, year, chapter, file_url, uploaded_by) 
VALUES (?, ?, ?, ?, ?, ?)
```

**Updated savePaper() Method:**
```java
// Before
statement.setString(1, paper.getTitle());
statement.setString(2, paper.getSubjectCode());
statement.setInt(3, paper.getYear());
statement.setString(4, paper.getFilePath());
statement.setInt(5, paper.getUploadedBy());

// After
statement.setString(1, paper.getSubjectName());
statement.setString(2, paper.getSubjectCode());
statement.setInt(3, paper.getYear());

// Handle optional chapter field
if (paper.getChapter() != null && !paper.getChapter().isBlank()) {
    statement.setString(4, paper.getChapter());
} else {
    statement.setNull(4, java.sql.Types.VARCHAR);
}

statement.setString(5, paper.getFileUrl());
statement.setInt(6, paper.getUploadedBy());
```

**Updated mapRow() Method:**
```java
// Before
paper.setTitle(resultSet.getString("title"));
paper.setFilePath(resultSet.getString("file_path"));
paper.setUploadedAt(uploadedAt.toLocalDateTime());

// After
paper.setSubjectName(resultSet.getString("subject_name"));
paper.setFileUrl(resultSet.getString("file_url"));
paper.setChapter(resultSet.getString("chapter")); // Can be null
paper.setCreatedAt(createdAt.toLocalDateTime());
```

**Updated SELECT Queries:**
```sql
-- Before
SELECT p.paper_id, p.title, p.subject_code, p.year, p.file_path, 
       p.uploaded_by, p.uploaded_at, u.username

-- After
SELECT p.paper_id, p.subject_name, p.subject_code, p.year, p.chapter, p.file_url, 
       p.uploaded_by, p.created_at, u.username
```

### 3. UploadPaperServlet.java

**Updated Form Parameter Reading:**
```java
// Before
String title = sanitise(request.getParameter("title"));

// After
String subjectName = sanitise(request.getParameter("subjectName"));
String chapter = sanitise(request.getParameter("chapter")); // NEW - optional
```

**Updated Paper Object Creation:**
```java
// Before
Paper paper = new Paper();
paper.setTitle(title);
paper.setSubjectCode(subjectCode);
paper.setYear(year);
paper.setFilePath(relativeFilePath);
paper.setUploadedBy(loggedInUser.getUserId());

// After
Paper paper = new Paper();
paper.setSubjectName(subjectName);
paper.setSubjectCode(subjectCode);
paper.setYear(year);

// Handle optional chapter
if (chapter != null && !chapter.isEmpty()) {
    paper.setChapter(chapter);
} else {
    paper.setChapter(null);
}

paper.setFileUrl(relativeFileUrl);
paper.setUploadedBy(loggedInUser.getUserId());
```

**Updated Validation:**
```java
// Before
private String validateInput(String title, String subjectCode, String yearStr) {
    if (title.isEmpty() || subjectCode.isEmpty() || yearStr.isEmpty()) {
        return "All fields are required.";
    }
    if (title.length() > 255) {
        return "Title is too long (maximum 255 characters).";
    }
    // ...
}

// After
private String validateInput(String subjectName, String subjectCode, String yearStr) {
    if (subjectName.isEmpty() || subjectCode.isEmpty() || yearStr.isEmpty()) {
        return "Subject name, subject code, and year are required.";
    }
    if (subjectName.length() > 150) {
        return "Subject name is too long (maximum 150 characters).";
    }
    // ...
}
```

**Updated Success Message:**
```java
// Before
session.setAttribute(ATTR_SUCCESS, 
        "Paper '" + title + "' uploaded successfully!");

// After
session.setAttribute(ATTR_SUCCESS, 
        "Paper '" + subjectName + "' uploaded successfully!");
```

### 4. upload.jsp

**Updated Form Fields:**
```html
<!-- Before -->
<label for="title">Paper Title<span class="required">*</span></label>
<input type="text" id="title" name="title" maxlength="255" required />

<!-- After -->
<label for="subjectName">Subject Name<span class="required">*</span></label>
<input type="text" id="subjectName" name="subjectName" maxlength="150" required />

<!-- NEW - Optional Chapter Field -->
<label for="chapter">Chapter (Optional)</label>
<input type="text" id="chapter" name="chapter" maxlength="100" />
```

### 5. database_setup.sql

**Updated Table Definition:**
```sql
-- Before
CREATE TABLE papers (
    paper_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    subject_code VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    uploaded_by INTEGER NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- ...
);

-- After
CREATE TABLE papers (
    paper_id SERIAL PRIMARY KEY,
    subject_name VARCHAR(150) NOT NULL,
    subject_code VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    chapter VARCHAR(100),              -- NEW - nullable
    file_url VARCHAR(255) NOT NULL,
    uploaded_by INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- ...
);
```

## Null Handling for Chapter Field

The `chapter` field is optional (nullable) in the database. Proper null handling is implemented:

### In PaperDAO.savePaper():
```java
// Handle optional chapter field (can be null)
if (paper.getChapter() != null && !paper.getChapter().isBlank()) {
    statement.setString(4, paper.getChapter());
} else {
    statement.setNull(4, java.sql.Types.VARCHAR);
}
```

### In PaperDAO.mapRow():
```java
// Handle optional chapter field (can be null)
String chapter = resultSet.getString("chapter");
paper.setChapter(chapter); // Will be null if database value is NULL
```

### In UploadPaperServlet:
```java
// Set chapter (can be null or empty)
if (chapter != null && !chapter.isEmpty()) {
    paper.setChapter(chapter);
} else {
    paper.setChapter(null);
}
```

## Testing

### Test Required Fields

```
Subject Name: Data Structures
Subject Code: CS101
Year: 2023
Chapter: (leave empty)
File: test.pdf
```

**Expected:**
- ✅ Upload succeeds
- ✅ Chapter is NULL in database

### Test With Chapter

```
Subject Name: Algorithms
Subject Code: CS102
Year: 2023
Chapter: Chapter 5: Dynamic Programming
File: test.pdf
```

**Expected:**
- ✅ Upload succeeds
- ✅ Chapter is saved in database

### Verify Database

```sql
-- Check uploaded papers
SELECT 
    paper_id,
    subject_name,
    subject_code,
    year,
    chapter,
    file_url,
    created_at
FROM papers
ORDER BY created_at DESC;
```

**Expected Output:**
```
 paper_id | subject_name  | subject_code | year |        chapter         |      file_url       |      created_at
----------+---------------+--------------+------+------------------------+---------------------+---------------------
        1 | Data Struct.. | CS101        | 2023 | NULL                   | uploads/123_test.pdf| 2026-02-26 10:30:00
        2 | Algorithms    | CS102        | 2023 | Chapter 5: Dynamic...  | uploads/124_test.pdf| 2026-02-26 10:31:00
```

## Migration Notes

### If You Have Existing Data

If you already have data in the `papers` table with old column names, you need to migrate:

```sql
-- Option 1: Rename columns (if structure matches)
ALTER TABLE papers RENAME COLUMN title TO subject_name;
ALTER TABLE papers RENAME COLUMN file_path TO file_url;
ALTER TABLE papers RENAME COLUMN uploaded_at TO created_at;

-- Add new chapter column
ALTER TABLE papers ADD COLUMN chapter VARCHAR(100);

-- Adjust column sizes if needed
ALTER TABLE papers ALTER COLUMN subject_name TYPE VARCHAR(150);
ALTER TABLE papers ALTER COLUMN file_url TYPE VARCHAR(255);
```

```sql
-- Option 2: Create new table and migrate data
CREATE TABLE papers_new (
    paper_id SERIAL PRIMARY KEY,
    subject_name VARCHAR(150) NOT NULL,
    subject_code VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    chapter VARCHAR(100),
    file_url VARCHAR(255) NOT NULL,
    uploaded_by INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_uploaded_by FOREIGN KEY (uploaded_by) 
        REFERENCES users(user_id) ON DELETE CASCADE
);

-- Copy data
INSERT INTO papers_new (paper_id, subject_name, subject_code, year, file_url, uploaded_by, created_at)
SELECT paper_id, title, subject_code, year, file_path, uploaded_by, uploaded_at
FROM papers;

-- Drop old table and rename
DROP TABLE papers;
ALTER TABLE papers_new RENAME TO papers;

-- Recreate indexes
CREATE INDEX idx_papers_subject_code ON papers(subject_code);
CREATE INDEX idx_papers_year ON papers(year);
CREATE INDEX idx_papers_uploaded_by ON papers(uploaded_by);
```

### If Starting Fresh

Simply run the updated `database_setup.sql`:

```bash
psql -U postgres -d paperwise_db -f database_setup.sql
```

## Summary of Changes

**Files Modified:**
1. ✅ `Paper.java` - Updated field names and added chapter
2. ✅ `PaperDAO.java` - Updated SQL and null handling
3. ✅ `UploadPaperServlet.java` - Updated parameter names and validation
4. ✅ `upload.jsp` - Updated form fields
5. ✅ `database_setup.sql` - Updated table definition

**Key Changes:**
- `title` → `subjectName` (VARCHAR 255 → 150)
- `filePath` → `fileUrl` (VARCHAR 500 → 255)
- `uploadedAt` → `createdAt`
- Added `chapter` field (nullable, VARCHAR 100)

**Null Safety:**
- Chapter field properly handles NULL values
- PreparedStatement uses setNull() for NULL values
- ResultSet getString() returns null for NULL values

---

**Field name corrections complete!** All Java code now matches the PostgreSQL database schema exactly. ✅
