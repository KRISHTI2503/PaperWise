# PaperWise

A collaborative platform for students to browse, share, and request academic papers and study materials. Built with Jakarta EE 10, featuring role-based authentication, real-time difficulty voting, and cloud storage.

---

## Features

### Authentication & Roles
- **Role-based access control**: Admin and Student roles
- **Session management**: Secure login/logout with session tracking
- **Registration**: Students can self-register; admin accounts are created via database

### Admin Features
- **Upload Papers**: Upload PDFs and documents (max 20MB) to Supabase Storage
- **Edit Papers**: Modify paper metadata (subject, year, chapter, exam type)
- **Delete Papers**: Remove papers from database and storage
- **Manage Requests**: View and respond to student paper requests
- **Student Management**: View all registered students
- **Analytics Dashboard**: Track upload trends, popular papers, and user activity
- **Announcements**: Post announcements visible to all students
- **Exam Schedule**: Create and manage exam schedules with edit capabilities
- **Notifications**: Bell icon with real-time notification count

### Student Features
- **Browse Papers**: View all available papers with filtering
- **Advanced Filtering**: Filter by subject, year, exam type with clear filters button
- **Mark as Useful**: Vote papers as useful (one vote per user)
- **Live Difficulty Voting**: Vote Easy/Medium/Hard with real-time percentage updates
- **Comments & Replies**: Threaded comments on papers
- **Request Papers**: Submit requests for missing papers with edit and delete
- **View Requests**: Track status of submitted requests
- **Announcements**: View admin announcements
- **Exam Schedule**: View upcoming exams with countdown timers
- **Notifications**: Bell icon for paper upload notifications

### UI/UX
- **Dark and Light Mode**: Theme toggle with preference persistence
- **Responsive Design**: Works on desktop, tablet, and mobile
- **Real-time Updates**: Difficulty stats update without page refresh
- **Toast Notifications**: Non-intrusive success/error messages

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| **Backend** | Jakarta EE 10, Java Servlets |
| **Frontend** | JSP, HTML5, CSS3, JavaScript |
| **Database** | PostgreSQL 14+ (Neon for production) |
| **App Server** | Apache Tomcat 10.1 |
| **Build Tool** | Apache Ant |
| **Deployment** | Docker, Render (free tier) |
| **File Storage** | Supabase Storage (private bucket) |
| **Architecture** | MVC, JNDI DataSource |

---

## Project Structure

```
PaperWise_AJT/
├── src/
│   ├── java/com/paperwise/
│   │   ├── dao/              # Data Access Objects
│   │   ├── filter/           # AuthFilter (role-based access)
│   │   ├── model/            # POJOs (User, Paper, etc.)
│   │   ├── servlet/          # Controllers
│   │   └── util/             # SupabaseStorageService
│   └── conf/                 # MANIFEST.MF
├── web/
│   ├── META-INF/             # context.xml (JNDI config)
│   ├── WEB-INF/
│   │   ├── views/            # JSP pages
│   │   ├── includes/         # Reusable JSP fragments
│   │   └── web.xml           # Deployment descriptor
│   ├── resources/
│   │   ├── css/              # Stylesheets
│   │   ├── js/               # JavaScript
│   │   ├── fontawesome/      # Icons
│   │   └── tabler-icons/     # Icons
│   ├── *.jsp                 # Main pages
│   └── index.html            # Landing page
├── database/
│   ├── schema.sql            # Production database schema
│   └── README.md             # Database setup instructions
├── nbproject/                # NetBeans project files
├── lib/                      # Libraries
├── docs/                     # Documentation
│   ├── DEPLOYMENT.md         # Deployment guide
│   └── PRE_DEPLOYMENT_CHECKLIST.md
├── .env.example              # Environment variables template
├── .gitignore                # Git ignore rules
├── build.xml                 # Ant build configuration
├── Dockerfile                # Docker multi-stage build
├── docker-entrypoint.sh      # Container entrypoint
├── render.yaml               # Render deployment config
├── test-docker-env.sh        # Docker test script (Bash)
└── test-docker-env.ps1       # Docker test script (PowerShell)
```

---

## Local Development Setup

### Prerequisites
- Java 17 or higher
- Apache Tomcat 10.1+
- PostgreSQL 14+
- Apache Ant (for building)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/KRISHTI2503/PaperWise.git
   cd PaperWise
   ```

2. **Set up the database**
   ```bash
   # Create database
   createdb paperwise
   
   # Run schema
   psql -d paperwise -f database/schema.sql
   
   # Set admin password (replace with your password)
   psql -d paperwise -c "UPDATE users SET password = 'admin123' WHERE username = 'admin'"
   ```

3. **Configure environment variables**
   
   Copy `.env.example` to create your local configuration, then set environment variables:

   **Option A: Set in your IDE/Tomcat configuration**
   - `JDBC_URL=jdbc:postgresql://localhost:5432/paperwise?sslmode=prefer`
   - `JDBC_USERNAME=postgres`
   - `JDBC_PASSWORD=your_password`
   - `SUPABASE_URL=` (leave empty for local dev)
   - `SUPABASE_KEY=` (leave empty)
   - `SUPABASE_BUCKET=` (leave empty)
   - `APP_ENV=local`

   **Option B: Set via command line (for Tomcat startup)**
   
   Windows PowerShell:
   ```powershell
   $env:APP_ENV="local"
   $env:JDBC_URL="jdbc:postgresql://localhost:5432/paperwise?sslmode=prefer"
   # ... set other variables
   # Then start Tomcat
   ```

   Linux/Mac:
   ```bash
   export APP_ENV=local
   export JDBC_URL=jdbc:postgresql://localhost:5432/paperwise?sslmode=prefer
   # ... set other variables
   # Then start Tomcat
   ```

4. **Update context.xml for local development**
   
   Copy `web/META-INF/context.xml.example` to `web/META-INF/context.xml` and adjust if needed for your local setup.

5. **Build the project**
   ```bash
   ant clean war
   ```

6. **Deploy to Tomcat**
   - Copy `dist/PaperWise_AJT.war` to Tomcat's `webapps/` directory
   - Or deploy through your IDE (NetBeans, IntelliJ, Eclipse)

7. **Access the application**
   - Open http://localhost:8080/PaperWise_AJT
   - Login as admin: `admin` / `admin123` (or your set password)

### Local File Storage

When `APP_ENV=local`:
- Files are stored in `web/uploads/` folder (gitignored)
- No Supabase configuration needed
- Automatic fallback if Supabase is unavailable

---

## Production Deployment

See **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** for complete instructions on deploying to Render with Docker, Neon Postgres, and Supabase Storage.

**Quick summary**:
1. Create Neon database and run `database/schema.sql`
2. Create private Supabase Storage bucket
3. Set 7 environment variables in Render
4. Connect GitHub repository
5. Deploy with Docker runtime

---

## Security

### Implemented Security Features

✅ **SQL Injection Prevention**
- All database queries use `PreparedStatement`
- User input is parameterized, never concatenated into SQL

✅ **Role-Based Access Control**
- `AuthFilter` enforces authentication on all protected routes
- Admin-only and student-only resources are separated
- Session-based authentication with role checking

✅ **Session Management**
- Secure session handling with timeout
- Logout clears session data
- CSRF protection through session validation

✅ **File Upload Security**
- File type validation (PDF, DOC, DOCX, PPT, PPTX, TXT, JPG, PNG only)
- File size limit (20MB max)
- Server-side validation in addition to client-side

✅ **Private File Storage**
- Supabase Storage bucket set to private
- Files accessed via signed URLs (1-hour expiry)
- No direct public access to uploaded files

✅ **Environment-Based Configuration**
- All secrets in environment variables
- No hardcoded credentials
- Production mode enforces cloud storage only

✅ **Secure Database Connection**
- Connection pooling via JNDI DataSource
- SSL/TLS for production database (sslmode=require)
- Credentials never logged or exposed

### Known Security Limitations

⚠️ **Passwords Stored as Plain Text**
- Current implementation stores passwords without hashing
- **THIS IS A CRITICAL SECURITY ISSUE**
- **Action Required**: Implement bcrypt password hashing immediately after deployment
- This is the #1 priority for post-deployment security improvements

⚠️ **No Rate Limiting**
- Login attempts are not rate-limited
- Consider adding rate limiting for production

⚠️ **No HTTPS Enforcement in Code**
- Relies on Render's HTTPS termination
- Consider adding HSTS headers

---

## Environment Variables

Required for deployment:

| Variable | Description | Example |
|----------|-------------|---------|
| `JDBC_URL` | Database connection URL | `jdbc:postgresql://host.neon.tech/db?sslmode=require` |
| `JDBC_USERNAME` | Database username | `neondb_owner` |
| `JDBC_PASSWORD` | Database password | `abc123xyz` |
| `SUPABASE_URL` | Supabase project URL | `https://xxxxx.supabase.co` |
| `SUPABASE_KEY` | Supabase service_role key | `eyJhbGc...` |
| `SUPABASE_BUCKET` | Storage bucket name | `paperwise-files` |
| `APP_ENV` | Environment mode | `local` or `production` |

See `.env.example` for a template.

---

## Screenshots

*Screenshots will be added here*

### Admin Dashboard
![Admin Dashboard](screenshots/admin-dashboard.png)

### Student Dashboard
![Student Dashboard](screenshots/student-dashboard.png)

### Paper Browser with Filters
![Paper Browser](screenshots/paper-browser.png)

### Dark Mode
![Dark Mode](screenshots/dark-mode.png)

---

## Testing

### Docker Build Test

Test that environment variables are properly injected:

**Windows**:
```powershell
.\test-docker-env.ps1
```

**Linux/Mac**:
```bash
chmod +x test-docker-env.sh
./test-docker-env.sh
```

This verifies that NO `${...}` placeholders reach the Java code.

---

## Contributing

This is an academic project. If you find issues or want to suggest improvements:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## Future Improvements

Planned features and improvements:

1. **Password Hashing**: Implement bcrypt (CRITICAL)
2. **Email Notifications**: OTP verification, password reset
3. **Advanced Search**: Full-text search across papers
4. **Paper Preview**: PDF preview without download
5. **User Profiles**: Student profiles with stats
6. **Bookmarks**: Save favorite papers
7. **Rate Limiting**: Prevent abuse
8. **Audit Logging**: Track admin actions
9. **Backup System**: Automated database backups
10. **Mobile App**: Native mobile client

---

## License

Proprietary - Academic Project

---

## Support

- **Repository**: https://github.com/KRISHTI2503/PaperWise
- **Documentation**: See `docs/` folder
- **Issues**: Report bugs via GitHub Issues

---

**Built with ❤️ for students**
