# PaperWise

An academic paper management system that allows admins to upload and manage exam papers, and students to browse, rate, bookmark, and request papers — all in one place.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Java Servlets (Jakarta EE 10) |
| Frontend | JSP, HTML5, CSS3, JavaScript |
| Database | PostgreSQL |
| Server | Apache Tomcat 10.1 |
| Architecture | MVC (Model-View-Controller) |
| Connection Pooling | JNDI DataSource |
| Icons | Font Awesome 6 (local), Tabler Icons (local) |
| Build Tool | Apache Ant (NetBeans project) |

---

## Features

### Admin Features
- **Dashboard** — Overview of total papers, students, pending requests, and useful marks with stat cards
- **Upload Papers** — Upload academic papers (PDF, DOC, DOCX, PPT, PPTX, TXT, images, video) with subject name, code, year, exam type, chapter, and description
- **All Papers** — Browse, search, filter, edit, and delete all uploaded papers
- **Edit Paper** — Update paper metadata (subject, year, exam type, chapter, description)
- **Delete Paper** — Permanently remove a paper from the system
- **Manage Requests** — View all student paper requests, update status (Pending / Completed / Rejected), and add admin messages
- **Manage Students** — View all registered students with their usage statistics
- **Analytics** — View difficulty distribution, papers by subject, most popular papers, and useful mark stats
- **Comments** — Post, view, and delete comments on papers (admins can delete student comments; cannot delete other admin comments)
- **Dark / Light Mode** — Persistent theme toggle saved in localStorage

### Student Features
- **Dashboard** — Overview of available papers, personal marks, and submitted requests
- **All Papers** — Browse and filter all papers by subject, year, exam type, and difficulty
- **Mark as Useful** — Bookmark papers as useful with a toggle; bookmarks are tracked per student
- **My Marked Papers** — View all papers the student has bookmarked
- **Difficulty Voting** — Rate each paper as Easy, Medium, or Hard; view community vote breakdown
- **Comments & Replies** — Post comments on papers, reply to others' comments, and delete own comments
- **Request a Paper** — Submit a request for a specific paper not yet uploaded
- **Track Requests** — View request status and admin reply messages; delete pending/rejected requests
- **Forgot Password** — OTP-based password reset via email (6-digit OTP, 10-minute expiry)
- **Dark / Light Mode** — Persistent theme toggle

---

## Project Structure

```
PaperWise_AJT/
├── src/
│   └── java/com/paperwise/
│       ├── dao/          # Data Access Objects (DB queries)
│       ├── filter/       # AuthFilter — session-based route protection
│       ├── model/        # POJO models (User, Paper, PaperRequest, PaperComment, ...)
│       ├── servlet/      # Jakarta Servlets (one per action)
│       └── util/         # EmailService (OTP delivery via Gmail SMTP)
├── web/
│   ├── css/              # paperwise.css — global design system
│   ├── js/               # paperwise.js — theme toggle, shared utils
│   ├── resources/
│   │   ├── fontawesome/  # Font Awesome 6 (local, no CDN)
│   │   ├── tabler-icons/ # Tabler Icons (local, no CDN)
│   │   └── css/          # theme.css, layout.css, components.css, responsive.css
│   ├── WEB-INF/
│   │   ├── web.xml       # Servlet config, error pages, JNDI resource ref
│   │   └── views/        # Server-side-only JSPs (myMarked.jsp, uploadPaper.jsp)
│   ├── META-INF/
│   │   └── context.xml   # Tomcat JNDI DataSource config
│   ├── login.jsp
│   ├── register.jsp
│   ├── forgotPassword.jsp
│   ├── admin-dashboard.jsp
│   ├── student-dashboard.jsp
│   ├── allPapers.jsp
│   ├── studentAllPapers.jsp
│   ├── analytics.jsp
│   ├── students.jsp
│   ├── adminRequests.jsp
│   ├── requestPaper.jsp
│   ├── editPaper.jsp
│   ├── upload.jsp
│   ├── error404.jsp
│   └── error500.jsp
├── lib/
│   └── postgresql-42.7.10.jar
├── database_setup.sql    # Full DB schema
└── build.xml             # Ant build file
```

---

## How to Run

### Prerequisites
- Java JDK 17+
- Apache Tomcat 10.1
- PostgreSQL 14+
- NetBeans IDE (recommended) or any IDE with Ant support

### 1. Clone the repository
```bash
git clone https://github.com/KRISHTI2503/PaperWise.git
cd PaperWise
```

### 2. Set up the PostgreSQL database
```sql
-- Create the database
CREATE DATABASE paperwise;
```
Then run the full schema:
```bash
psql -U postgres -d paperwise -f database_setup.sql
```

### 3. Configure the JNDI DataSource
Edit `web/META-INF/context.xml` with your PostgreSQL credentials:
```xml
<Resource name="jdbc/paperwise"
          auth="Container"
          type="javax.sql.DataSource"
          driverClassName="org.postgresql.Driver"
          url="jdbc:postgresql://localhost:5432/paperwise"
          username="YOUR_DB_USER"
          password="YOUR_DB_PASSWORD"
          maxTotal="20"
          maxIdle="10"
          maxWaitMillis="10000"/>
```

### 4. Configure Tomcat in NetBeans
- Go to **Tools → Servers → Add Server → Apache Tomcat 10.1**
- Point it to your Tomcat installation directory
- Ensure the PostgreSQL JDBC driver JAR is in `lib/`

### 5. (Optional) Configure OTP email for Forgot Password
Edit `src/java/com/paperwise/util/EmailService.java`:
```java
private static final String FROM_EMAIL  = "your.gmail@gmail.com";
private static final String APP_PASSWORD = "your-16-char-app-password";
```
Use a Gmail App Password (not your account password).

### 6. Create the uploads directory
```bash
mkdir C:/paperwise_uploads
```
This is where uploaded paper files are stored.

### 7. Build and run
In NetBeans: **Right-click project → Clean and Build**, then **Run**.

The application will be available at:
```
http://localhost:8080/PaperWise_AJT/
```

---

## Database Tables

| Table | Description |
|---|---|
| `users` | Stores registered users with username, email, hashed password, and role (`admin` / `student`) |
| `papers` | Stores uploaded paper metadata — subject, code, year, exam type, chapter, description, file path |
| `votes` | Tracks which students have marked which papers as useful (many-to-many) |
| `difficulty_votes` | Stores per-student difficulty ratings for each paper (`easy`, `medium`, `hard`) — one vote per user per paper, upsertable |
| `paper_requests` | Student requests for papers not yet uploaded — includes status, admin reply message |
| `paper_comments` | Comments and threaded replies on papers — stores parent_comment_id for reply nesting |
| `password_reset_tokens` | OTP tokens for the forgot-password flow — includes expiry timestamp |

---

## Screenshots

> Screenshots will be added soon.

---

## Author

**KRISHTI2503** — [github.com/KRISHTI2503](https://github.com/KRISHTI2503)
