# PaperWise Deployment Checklist

## Pre-Deployment Checklist

### ✅ PostgreSQL Configuration

- [ ] PostgreSQL 12+ is installed
- [ ] PostgreSQL service is running
- [ ] Database `paperwise_db` exists
- [ ] Table `users` exists with correct schema
- [ ] Test users are inserted (admin, student)
- [ ] Can connect via: `psql -U postgres -d paperwise_db`

**Quick Test:**
```bash
psql -U postgres -d paperwise_db -c "SELECT username, role FROM users;"
```

Expected output:
```
 username | role
----------+--------
 admin    | admin
 student  | student
```

---

### ✅ Tomcat Configuration

- [ ] Tomcat 10.1.x is installed
- [ ] `postgresql-42.7.10.jar` is in `$CATALINA_HOME/lib/`
- [ ] Tomcat has been restarted after adding the driver
- [ ] No PostgreSQL jar in project `lib/` directory will be bundled

**Verify Driver Location:**
```bash
# Windows
dir %CATALINA_HOME%\lib\postgresql*.jar

# Linux/Mac
ls $CATALINA_HOME/lib/postgresql*.jar
```

Expected: Should show `postgresql-42.7.10.jar`

---

### ✅ Project Configuration

- [ ] `web/META-INF/context.xml` has PostgreSQL DataSource
- [ ] JNDI name is `jdbc/paperwise`
- [ ] Driver class is `org.postgresql.Driver`
- [ ] JDBC URL is `jdbc:postgresql://localhost:5432/paperwise_db`
- [ ] Database credentials are correct
- [ ] `web/WEB-INF/web.xml` has resource-ref for JNDI
- [ ] `nbproject/project.properties` has empty `javac.classpath`
- [ ] `nbproject/project.xml` has empty `<web-module-libraries/>`

**Verify Project Files:**
```bash
# Check context.xml
type web\META-INF\context.xml

# Check web.xml
type web\WEB-INF\web.xml

# Check project.properties (should NOT contain postgresql reference)
findstr /i "postgresql" nbproject\project.properties
# Expected: No output or only comments
```

---

### ✅ Source Code Verification

- [ ] All servlets use `@WebServlet` annotations
- [ ] AuthFilter uses `@WebFilter` annotation
- [ ] UserDAO uses JNDI: `java:comp/env/jdbc/paperwise`
- [ ] TestDBServlet uses correct JNDI lookup
- [ ] No MySQL driver references in code

**Verify Annotations:**
```bash
# Check servlet annotations
findstr /i "@WebServlet" src\java\com\paperwise\servlet\*.java

# Check filter annotation
findstr /i "@WebFilter" src\java\com\paperwise\filter\*.java

# Check JNDI name
findstr /i "java:comp/env/jdbc/paperwise" src\java\com\paperwise\dao\*.java
```

---

## Build and Deploy

### Step 1: Clean Build
```bash
ant clean
ant dist
```

**Verify:**
- [ ] Build completes without errors
- [ ] `dist/PaperWise_AJT.war` is created

### Step 2: Verify WAR Contents
```bash
# Extract WAR to temp directory (optional verification)
jar tf dist\PaperWise_AJT.war | findstr /i "postgresql"
```

**Expected:** No output (PostgreSQL jar should NOT be in WAR)

### Step 3: Deploy to Tomcat
```bash
# Option 1: Copy WAR to webapps
copy dist\PaperWise_AJT.war %CATALINA_HOME%\webapps\

# Option 2: Use Tomcat Manager
# Upload via http://localhost:8080/manager/html

# Option 3: Use IDE deployment
# Deploy from NetBeans/Eclipse/IntelliJ
```

**Verify:**
- [ ] WAR is copied to `$CATALINA_HOME/webapps/`
- [ ] Tomcat auto-deploys and creates `PaperWise_AJT` directory
- [ ] No errors in Tomcat logs

### Step 4: Check Tomcat Logs
```bash
# Windows
type %CATALINA_HOME%\logs\catalina.out

# Linux/Mac
tail -f $CATALINA_HOME/logs/catalina.out
```

**Look for:**
- ✅ "Deployment of web application archive ... has finished"
- ✅ No ClassNotFoundException for PostgreSQL driver
- ✅ No NamingException for JNDI lookup
- ❌ No SQLException or connection errors

---

## Post-Deployment Testing

### Test 1: Database Connection Test
```
URL: http://localhost:8080/PaperWise_AJT/testdb
```

**Expected Results:**
- [ ] ✓ JNDI lookup successful
- [ ] ✓ Database connection established
- [ ] PostgreSQL version displayed
- [ ] ✓ Users table accessible: X users found
- [ ] Connection details shown (database, URL, driver, user)
- [ ] "All tests passed!" message

**If Failed:**
- Check PostgreSQL is running
- Verify driver in Tomcat lib
- Check context.xml configuration
- Review Tomcat logs

---

### Test 2: Login Page
```
URL: http://localhost:8080/PaperWise_AJT/login.jsp
```

**Expected Results:**
- [ ] Modern login page loads
- [ ] No 404 or 500 errors
- [ ] Form has username and password fields
- [ ] Password toggle button works

---

### Test 3: Admin Login
```
URL: http://localhost:8080/PaperWise_AJT/login.jsp
Username: admin
Password: admin123
```

**Expected Results:**
- [ ] Login succeeds
- [ ] Redirects to `/admin-dashboard.jsp`
- [ ] Shows "Welcome, admin!"
- [ ] Shows "Role: admin"
- [ ] Logout link works

---

### Test 4: Student Login
```
URL: http://localhost:8080/PaperWise_AJT/login.jsp
Username: student
Password: student123
```

**Expected Results:**
- [ ] Login succeeds
- [ ] Redirects to `/student-dashboard.jsp`
- [ ] Shows "Welcome, student!"
- [ ] Shows "Role: student"
- [ ] Logout link works

---

### Test 5: Authentication Filter
```
URL: http://localhost:8080/PaperWise_AJT/admin-dashboard.jsp
(without logging in)
```

**Expected Results:**
- [ ] Redirects to `/login.jsp`
- [ ] Cannot access protected pages without authentication

---

### Test 6: Logout
```
1. Login as any user
2. Click "Logout" link
```

**Expected Results:**
- [ ] Session is invalidated
- [ ] Redirects to `/login.jsp`
- [ ] Cannot access protected pages after logout
- [ ] Must login again to access dashboards

---

## Configuration Verification

### Verify JNDI Configuration

**Check context.xml:**
```xml
<Resource name="jdbc/paperwise"
          auth="Container"
          type="javax.sql.DataSource"
          driverClassName="org.postgresql.Driver"
          url="jdbc:postgresql://localhost:5432/paperwise_db"
          username="postgres"
          password="postgres"
          .../>
```

**Check web.xml:**
```xml
<resource-ref>
    <res-ref-name>jdbc/paperwise</res-ref-name>
    <res-type>javax.sql.DataSource</res-type>
    <res-auth>Container</res-auth>
</resource-ref>
```

**Check UserDAO.java:**
```java
private static final String JNDI_DATASOURCE = "java:comp/env/jdbc/paperwise";
```

All three must match!

---

### Verify Servlet Mappings

**No mappings in web.xml** - All use annotations:

```java
@WebServlet("/login")   // LoginServlet
@WebServlet("/logout")  // LogoutServlet
@WebServlet("/testdb")  // TestDBServlet
```

**Verify:**
```bash
findstr /i "servlet-mapping" web\WEB-INF\web.xml
```
Expected: No output (no servlet mappings in web.xml)

---

### Verify Filter Mapping

**No mapping in web.xml** - Uses annotation:

```java
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
```

**Verify:**
```bash
findstr /i "filter-mapping" web\WEB-INF\web.xml
```
Expected: No output (no filter mappings in web.xml)

---

## Troubleshooting Guide

### Problem: ClassNotFoundException: org.postgresql.Driver

**Cause:** PostgreSQL driver not in Tomcat lib

**Solution:**
```bash
# Copy driver to Tomcat
copy lib\postgresql-42.7.10.jar %CATALINA_HOME%\lib\

# Restart Tomcat
%CATALINA_HOME%\bin\shutdown.bat
%CATALINA_HOME%\bin\startup.bat
```

---

### Problem: NamingException: Name jdbc/paperwise is not bound

**Cause:** JNDI resource not configured or Tomcat not restarted

**Solution:**
1. Verify `context.xml` has Resource definition
2. Verify Resource name is `jdbc/paperwise`
3. Restart Tomcat
4. Check Tomcat logs for errors

---

### Problem: Connection refused to PostgreSQL

**Cause:** PostgreSQL not running or wrong connection parameters

**Solution:**
```bash
# Check PostgreSQL status
pg_ctl status

# Start PostgreSQL
pg_ctl start

# Test connection
psql -U postgres -d paperwise_db

# Verify connection parameters in context.xml
```

---

### Problem: Login fails with valid credentials

**Cause:** Database not populated or wrong table schema

**Solution:**
```bash
# Check users table
psql -U postgres -d paperwise_db -c "SELECT * FROM users;"

# Re-run setup script if needed
psql -U postgres -f database_setup.sql
```

---

### Problem: WAR contains PostgreSQL jar

**Cause:** Project configuration still references the jar

**Solution:**
1. Edit `nbproject/project.properties`
   - Remove `file.reference.postgresql-42.7.10.jar=...`
   - Set `javac.classpath=` (empty)

2. Edit `nbproject/project.xml`
   - Change `<web-module-libraries>` to `<web-module-libraries/>`

3. Clean and rebuild:
   ```bash
   ant clean
   ant dist
   ```

4. Verify:
   ```bash
   jar tf dist\PaperWise_AJT.war | findstr /i "postgresql"
   # Should return nothing
   ```

---

## Success Criteria

All of the following must be true:

- ✅ PostgreSQL driver is in `$CATALINA_HOME/lib/`
- ✅ PostgreSQL driver is NOT in WAR file
- ✅ Database `paperwise_db` exists with `users` table
- ✅ `/testdb` endpoint shows "All tests passed!"
- ✅ Can login as admin and see admin dashboard
- ✅ Can login as student and see student dashboard
- ✅ AuthFilter protects dashboards (redirects to login)
- ✅ Logout works and invalidates session
- ✅ No errors in Tomcat logs
- ✅ All servlets use `@WebServlet` annotations
- ✅ AuthFilter uses `@WebFilter` annotation
- ✅ JNDI name is consistent: `java:comp/env/jdbc/paperwise`

---

## Final Verification Command

Run this comprehensive test:

```bash
# 1. Check driver location
dir %CATALINA_HOME%\lib\postgresql*.jar

# 2. Check WAR doesn't contain driver
jar tf dist\PaperWise_AJT.war | findstr /i "postgresql"

# 3. Test database
psql -U postgres -d paperwise_db -c "SELECT COUNT(*) FROM users;"

# 4. Check Tomcat is running
curl http://localhost:8080

# 5. Test application
curl http://localhost:8080/PaperWise_AJT/testdb
```

If all commands succeed, deployment is complete! 🎉

---

## Quick Reference

| Item | Value |
|------|-------|
| **JNDI Name** | `java:comp/env/jdbc/paperwise` |
| **Driver Class** | `org.postgresql.Driver` |
| **JDBC URL** | `jdbc:postgresql://localhost:5432/paperwise_db` |
| **Driver Location** | `$CATALINA_HOME/lib/postgresql-42.7.10.jar` |
| **Context Path** | `/PaperWise_AJT` |
| **Test Endpoint** | `/testdb` |
| **Login Page** | `/login.jsp` |
| **Admin User** | `admin / admin123` |
| **Student User** | `student / student123` |

---

**Deployment checklist complete!** Follow each section carefully for successful deployment.
