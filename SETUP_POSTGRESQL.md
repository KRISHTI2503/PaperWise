# PostgreSQL Setup Instructions for PaperWise

## Overview
This project is configured to use PostgreSQL with Tomcat 10.1 via JNDI lookup. The PostgreSQL JDBC driver is expected to be in Tomcat's lib directory, not bundled with the WAR file.

## Prerequisites
- Apache Tomcat 10.1.x
- PostgreSQL 12 or higher
- PostgreSQL JDBC Driver 42.7.10 (or compatible)

## Step 1: Install PostgreSQL JDBC Driver in Tomcat

1. Download the PostgreSQL JDBC driver if not already available:
   - File: `postgresql-42.7.10.jar`
   - Location in project: `lib/postgresql-42.7.10.jar`

2. Copy the driver to Tomcat's lib directory:
   ```
   Windows: %CATALINA_HOME%\lib\
   Linux/Mac: $CATALINA_HOME/lib/
   ```

3. Restart Tomcat after copying the driver.

## Step 2: Create PostgreSQL Database

1. Connect to PostgreSQL:
   ```bash
   psql -U postgres
   ```

2. Create the database:
   ```sql
   CREATE DATABASE paperwise_db;
   ```

3. Create the users table:
   ```sql
   \c paperwise_db

   CREATE TABLE users (
       user_id SERIAL PRIMARY KEY,
       username VARCHAR(50) UNIQUE NOT NULL,
       email VARCHAR(100) UNIQUE NOT NULL,
       password VARCHAR(255) NOT NULL,
       role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'student')),
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
   ```

4. Insert test users:
   ```sql
   -- Admin user (password: admin123)
   INSERT INTO users (username, email, password, role) 
   VALUES ('admin', 'admin@paperwise.com', 'admin123', 'admin');

   -- Student user (password: student123)
   INSERT INTO users (username, email, password, role) 
   VALUES ('student', 'student@paperwise.com', 'student123', 'student');
   ```

## Step 3: Configure Database Connection

The JNDI datasource is configured in `web/META-INF/context.xml`:

```xml
<Resource name="jdbc/paperwise"
          auth="Container"
          type="javax.sql.DataSource"
          driverClassName="org.postgresql.Driver"
          url="jdbc:postgresql://localhost:5432/paperwise_db"
          username="postgres"
          password="postgres"
          maxTotal="20"
          maxIdle="10"
          maxWaitMillis="10000"/>
```

**Update the following if needed:**
- `url`: Change host/port/database name
- `username`: Your PostgreSQL username
- `password`: Your PostgreSQL password

## Step 4: Verify Configuration

### Check JNDI Lookup
The application uses JNDI name: `java:comp/env/jdbc/paperwise`

This is configured in:
- `web/META-INF/context.xml` - Resource definition
- `web/WEB-INF/web.xml` - Resource reference
- `UserDAO.java` - JNDI lookup code

### Test Database Connection
1. Deploy the application to Tomcat
2. Access: `http://localhost:8080/PaperWise_AJT/testdb`
3. You should see database connection success message

## Step 5: Login to Application

1. Access: `http://localhost:8080/PaperWise_AJT/login.jsp`
2. Use test credentials:
   - Admin: `admin` / `admin123`
   - Student: `student` / `student123`

## Project Structure

### Servlet Mappings (using @WebServlet)
- `/login` - LoginServlet
- `/logout` - LogoutServlet
- `/testdb` - TestDBServlet

### Filter Mappings (using @WebFilter)
- `/*` - AuthFilter (protects all resources except public ones)

### Configuration Files
- `web/META-INF/context.xml` - JNDI DataSource configuration
- `web/WEB-INF/web.xml` - Minimal Jakarta EE 10 configuration
- `nbproject/project.properties` - No PostgreSQL jar in classpath
- `nbproject/project.xml` - No libraries bundled in WAR

## Important Notes

1. **Driver Location**: PostgreSQL JDBC driver MUST be in `$CATALINA_HOME/lib/`, NOT in `WEB-INF/lib/`

2. **No MySQL References**: All MySQL driver references have been removed

3. **Jakarta EE 10**: Using Jakarta EE 10 (not Java EE)
   - Package: `jakarta.servlet.*` (not `javax.servlet.*`)
   - web.xml version: 6.0

4. **Security Warning**: The current implementation stores passwords in plain text. 
   For production, implement proper password hashing (BCrypt, Argon2, etc.)

5. **Session Management**: 
   - Session timeout: 30 minutes
   - Session attribute: `loggedInUser` (User object)
   - HttpOnly cookies enabled

## Troubleshooting

### ClassNotFoundException: org.postgresql.Driver
- Ensure `postgresql-42.7.10.jar` is in `$CATALINA_HOME/lib/`
- Restart Tomcat after adding the driver

### NamingException: Name jdbc/paperwise is not bound
- Check `context.xml` Resource configuration
- Verify JNDI name matches: `java:comp/env/jdbc/paperwise`
- Check Tomcat logs for startup errors

### Connection refused to PostgreSQL
- Verify PostgreSQL is running: `pg_ctl status`
- Check connection parameters in `context.xml`
- Verify PostgreSQL accepts connections on port 5432

### Authentication fails
- Verify users table exists and has data
- Check username/password in database
- Review Tomcat logs for SQL errors

## Development Notes

- All servlets use `@WebServlet` annotations (no servlet mappings in web.xml)
- AuthFilter uses `@WebFilter` annotation (no filter mappings in web.xml)
- web.xml is minimal and only contains:
  - Display name
  - Welcome files
  - Session configuration
  - Resource reference for JNDI
