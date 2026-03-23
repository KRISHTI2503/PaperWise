# Student Interaction Features - Voting System

## Overview
Complete implementation of student voting system with enhanced UI features including vote counts, popular badges, file type icons, search functionality, and statistics dashboard.

## Implementation Date
February 26, 2026

## Features Implemented

### 1. Voting System
- **VoteDAO**: Complete DAO for vote operations
  - `hasUserVoted(paperId, userId)` - Check if user already voted
  - `addVote(paperId, userId)` - Add new vote
  - `getVoteCount(paperId)` - Get total votes for paper
  - `getUserVotedPapers(userId)` - Get all papers user voted for

- **VoteServlet**: Handles voting requests (@WebServlet("/votePaper"))
  - Student-only access (role verification)
  - Prevents duplicate votes
  - Validates paper existence
  - Redirects back to student dashboard with success/error message

### 2. Vote Count Display
- **PaperDAO Enhancements**:
  - `getAllPapersWithVotes()` - Fetches papers with vote counts
  - SQL query with LEFT JOIN on votes table
  - Papers sorted by vote count DESC, then created_at DESC
  - `getVoteCount(paperId)` - Get votes for specific paper

- **Paper Model**:
  - Added `voteCount` field with getter/setter

### 3. Student Dashboard Actions
For each paper, students can:
- **View** - Open file in new tab (blue button)
- **Download** - Download file (green button)
- **Vote** - Vote for paper (purple button) - only if not voted
- **Voted** - Disabled button showing already voted (gray)

### 4. UI Improvements

#### Statistics Dashboard
- Total Papers count
- Total Votes across all papers
- Your Votes (user's vote count)

#### Search Functionality
- Real-time client-side search
- Filters by subject code or subject name
- No page reload required

#### File Type Icons
- 📕 PDF files
- 📘 DOC/DOCX files
- 📊 PPT/PPTX files
- 🖼️ JPG/JPEG/PNG images
- 🎬 MP4/MKV videos
- 📄 Other files

#### Popular Badge
- Shows "Popular" badge on papers with highest votes
- Only displayed when vote count > 2
- Orange badge with uppercase text

#### Upload Date Display
- Shows formatted date (e.g., "Feb 26, 2026")
- Uses LocalDateTime formatting

#### Enhanced Styling
- Gradient background (purple to violet)
- Modern card design with shadows
- Hover effects on table rows
- Color-coded action buttons
- Responsive layout

### 5. Security Improvements

#### Role-Based Access Control
- Only students can vote (admin voting blocked)
- Role verification in VoteServlet
- Error message for non-student attempts

#### Duplicate Vote Prevention
- Database check before inserting vote
- User-friendly error message
- Logging of duplicate attempts

#### Paper Validation
- Validates paper exists before voting
- Returns error if paper not found
- Prevents voting on deleted papers

#### Guest Access Prevention
- Session validation required
- Redirects to login if not authenticated
- All endpoints protected by AuthFilter

## Database Schema

### Votes Table (Existing)
```sql
CREATE TABLE votes (
    vote_id SERIAL PRIMARY KEY,
    paper_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_paper FOREIGN KEY (paper_id) REFERENCES papers(paper_id) ON DELETE CASCADE,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT unique_vote UNIQUE (paper_id, user_id)
);
```

## SQL Queries

### Get Papers with Vote Counts (Sorted)
```sql
SELECT p.paper_id, p.subject_name, p.subject_code, p.year, p.chapter, p.file_url,
       p.uploaded_by, p.created_at, u.username,
       COALESCE(COUNT(v.vote_id), 0) as vote_count
FROM papers p
LEFT JOIN users u ON p.uploaded_by = u.user_id
LEFT JOIN votes v ON p.paper_id = v.paper_id
GROUP BY p.paper_id, p.subject_name, p.subject_code, p.year, p.chapter,
         p.file_url, p.uploaded_by, p.created_at, u.username
ORDER BY vote_count DESC, p.created_at DESC
```

### Check if User Voted
```sql
SELECT 1 FROM votes WHERE paper_id = ? AND user_id = ?
```

### Add Vote
```sql
INSERT INTO votes (paper_id, user_id) VALUES (?, ?)
```

### Get Vote Count
```sql
SELECT COUNT(*) FROM votes WHERE paper_id = ?
```

### Get User's Voted Papers
```sql
SELECT paper_id FROM votes WHERE user_id = ?
```

## File Structure
```
src/java/com/paperwise/
├── dao/
│   ├── VoteDAO.java                (NEW)
│   └── PaperDAO.java               (UPDATED - added vote methods)
├── model/
│   └── Paper.java                  (UPDATED - added voteCount field)
└── servlet/
    ├── VoteServlet.java            (NEW)
    └── StudentDashboardServlet.java (UPDATED - fetch votes)

web/
└── student-dashboard.jsp           (COMPLETELY REWRITTEN)
```

## User Flow

### Voting Flow
1. Student views dashboard with papers sorted by votes
2. Papers show vote count and Vote/Voted button
3. Student clicks "Vote" button
4. VoteServlet validates:
   - User is authenticated
   - User is student role
   - Paper exists
   - User hasn't voted yet
5. Vote added to database
6. Success message displayed
7. Dashboard refreshed with updated vote count
8. Button changes to "Voted" (disabled)

### Search Flow
1. Student types in search box
2. JavaScript filters table rows in real-time
3. Matches subject code or subject name
4. No server request needed

## Error Messages

### Voting Errors
- "Only students can vote for papers." - Non-student attempt
- "Invalid paper ID." - Missing or invalid ID
- "Paper not found." - Paper doesn't exist
- "You have already voted for this paper." - Duplicate vote
- "Failed to add vote. Please try again." - Database error

### Dashboard Errors
- "Failed to load papers. Please try again." - Database error

## Success Messages
- "Vote added successfully for '[subject_name]'!" - Vote successful
- Auto-hides after 3 seconds

## Logging
All operations logged with appropriate levels:
- INFO: Successful votes, dashboard loads
- WARNING: Duplicate votes, non-student attempts, invalid IDs
- SEVERE: Database errors, DAO initialization failures

## Testing Checklist

### Voting System
- [ ] Student can vote for paper
- [ ] Vote count increments correctly
- [ ] Duplicate vote prevented
- [ ] Admin cannot vote
- [ ] Guest redirected to login
- [ ] Invalid paper ID handled
- [ ] Success message displays
- [ ] Button changes to "Voted"

### Vote Display
- [ ] Vote counts show correctly
- [ ] Papers sorted by votes (highest first)
- [ ] Popular badge shows on top papers
- [ ] User's voted papers marked correctly

### Search Functionality
- [ ] Search by subject code works
- [ ] Search by subject name works
- [ ] Case-insensitive search
- [ ] Real-time filtering
- [ ] Clear search shows all papers

### UI Features
- [ ] File type icons display correctly
- [ ] Upload dates formatted properly
- [ ] Statistics show correct counts
- [ ] Responsive design works
- [ ] Hover effects work
- [ ] Success message auto-hides

### Security
- [ ] Only students can vote
- [ ] Session validation works
- [ ] Paper existence validated
- [ ] Duplicate votes blocked
- [ ] SQL injection prevented (PreparedStatement)

## Performance Considerations
- Vote counts calculated in single SQL query with JOIN
- User's voted papers fetched once per page load
- Search is client-side (no server requests)
- Indexes on votes table for fast lookups

## Future Enhancements (Not Implemented)
- Unvote functionality
- Vote history page
- Most popular papers widget
- Email notifications for popular papers
- Vote analytics for admins
- Pagination for large datasets
- Advanced filters (year, subject code)
- Export papers list

## Notes
- Votes table must have UNIQUE constraint on (paper_id, user_id)
- Popular badge threshold is configurable (currently > 2 votes)
- File type detection based on file extension
- Search is case-insensitive
- All timestamps use server timezone
