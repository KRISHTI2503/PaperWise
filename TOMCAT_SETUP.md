# Tomcat 10.1 Setup Guide for PaperWise

## Quick Setup Checklist

### 1. Copy PostgreSQL Driver to Tomcat
```bash
# Windows
copy lib\postgresql-42.7.10.jar %CATALINA_HOME%\lib\

# Linux/Mac
cp lib/postgresql-42.7.10.jar $CATALINA_HOME/lib/
```

### 2. Create PostgreSQL Database
```bash
psql -U postgres -f database_setup.sql
```

### 3. Update Database Credentials (if needed)
Edit `web/META-INF/context.xml`:
```xml
<Resource name="jdbc/paperwise"
          ...
          username="postgres"
          password="postgres"
          .../>
```

### 4. Build and Deploy
```bash
# Clean and build
ant clean
ant dist

# Deploy WAR to Tomcat
copy dist\PaperWise_AJT.war %CATALINA_HOME%\webapps\

# Or use Tomcat Manager or IDE deployment
```

### 5. Test the Application
- Test DB: http://localhost:8080/PaperWise_AJT/testdb
- Login: http://localhost:8080/PaperWise_AJT/login.jsp

## Configuration Summary

### JNDI DataSource
- **JNDI Name**: `java:comp/env/jdbc/paperwise`
- **Driver**: `org.postgresql.Driver`
- **URL**: `jdbc:postgresql://localhost:5432/paperwise_db`
- **Configured in**: `web/META-INF/context.xml`

### Servlet Mappings (Annotation-based)
| Servlet | URL Pattern | Annotation |
|---------|-------------|------------|
| LoginServlet | `/login` | `@WebServlet("/login")` |
| LogoutServlet | `/logout` | `@WebServlet("/logout")` |
| TestDBServlet | `/testdb` | `@WebServlet("/testdb")` |

### Filter Mappings (Annotation-based)
| Filter | URL Pattern | Annotation |
|--------|-------------|------------|
| AuthFilter | `/*` | `@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})` |

### Public Resources (No Authentication Required)
- `/login.jsp`
- `/login` (servlet)
- `/logout` (servlet)
- `/` and `/index.html`
- `/css/*`, `/js/*`, `/images/*`, `/static/*`

### Protected Resources (Authentication Required)
- `/admin-dashboard.jsp` (admin role only)
- `/student-dashboard.jsp` (student role only)
- All other resources

## web.xml Configuration

The `web.xml` is minimal and only contains:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         version="6.0">
    
    <!-- Display name -->
    <display-name>PaperWise</display-name>
    
    <!-- Welcome files -->
    <welcome-file-list>
        <welcome-file>index.html</welcome-file>
        <welcome-file>login.jsp</welcome-file>
    </welcome-file-list>
    
    <!-- Session configuration -->
    <session-config>
        <session-timeout>30</session-timeout>
        <cookie-config>
            <http-only>true</http-only>
            <secure>false</secure>
        </cookie-config>
        <tracking-mode>COOKIE</tracking-mode>
    </session-config>
    
    <!-- JNDI resource reference -->
    <resource-ref>
        <res-ref-name>jdbc/paperwise</res-ref-name>
        <res-type>javax.sql.DataSource</res-type>
        <res-auth>Container</res-auth>
    </resource-ref>
    
</web-app>
```

**No servlet or filter mappings in web.xml** - all use annotations!

## Project Structure

```
PaperWise_AJT/
├── src/java/com/paperwise/
│   ├── dao/
│   │   └── UserDAO.java              (JNDI lookup: java:comp/env/jdbc/paperwise)
│   ├── filter/
│   │   └── AuthFilter.java           (@WebFilter)
│   ├── model/
│   │   └── User.java
│   ├── servlet/
│   │   ├── LoginServlet.java         (@WebServlet("/login"))
│   │   ├── LogoutServlet.java        (@WebServlet("/logout"))
│   │   └── TestDBServlet.java        (@WebServlet("/testdb"))
│   └── util/
├── web/
│   ├── META-INF/
│   │   └── context.xml               (DataSource configuration)
│   ├── WEB-INF/
│   │   └── web.xml                   (Minimal Jakarta EE 10 config)
│   ├── login.jsp
│   ├── admin-dashboard.jsp
│   ├── student-dashboard.jsp
│   └── index.html
├── lib/
│   └── postgresql-42.7.10.jar        (Copy to Tomcat lib, not bundled in WAR)
├── nbproject/
│   ├── project.properties            (javac.classpath is empty)
│   └── project.xml                   (web-module-libraries is empty)
├── database_setup.sql
├── SETUP_POSTGRESQL.md
└── TOMCAT_SETUP.md
```

## Key Points

1. **PostgreSQL driver location**: `$CATALINA_HOME/lib/` (NOT in WAR file)
2. **No MySQL references**: All removed
3. **Jakarta EE 10**: Using `jakarta.servlet.*` packages
4. **Annotation-based**: All servlets and filters use annotations
5. **JNDI lookup**: `java:comp/env/jdbc/paperwise`
6. **Session attribute**: `loggedInUser` (User object)

## Test Credentials

| Username | Password | Role |
|----------|----------|------|
| admin | admin123 | admin |
| student | student123 | student |
| john_doe | password123 | student |
| jane_smith | password123 | student |

## Tomcat Logs Location

Check these logs for errors:
- Windows: `%CATALINA_HOME%\logs\catalina.out`
- Linux/Mac: `$CATALINA_HOME/logs/catalina.out`

## Common Issues

### 1. ClassNotFoundException: org.postgresql.Driver
**Solution**: Copy `postgresql-42.7.10.jar` to `$CATALINA_HOME/lib/` and restart Tomcat

### 2. NamingException: Name jdbc/paperwise is not bound
**Solution**: Check `context.xml` Resource configuration and restart Tomcat

### 3. Connection refused
**Solution**: Verify PostgreSQL is running and accepting connections on port 5432

### 4. WAR contains PostgreSQL jar
**Solution**: 
- Check `nbproject/project.properties` - `javac.classpath` should be empty
- Check `nbproject/project.xml` - `<web-module-libraries/>` should be empty
- Clean and rebuild: `ant clean dist`

## Verification Steps

1. **Check driver in Tomcat**:
   ```bash
   ls $CATALINA_HOME/lib/postgresql*.jar
   ```

2. **Check WAR doesn't contain driver**:
   ```bash
   jar tf dist/PaperWise_AJT.war | grep postgresql
   # Should return nothing
   ```

3. **Test database connection**:
   ```bash
   psql -U postgres -d paperwise_db -c "SELECT * FROM users;"
   ```

4. **Test application**:
   - Visit: http://localhost:8080/PaperWise_AJT/testdb
   - Should see: "Database connection successful!"
