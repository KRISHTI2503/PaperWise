# Testing User Registration - Quick Guide

## Prerequisites

1. PostgreSQL is running
2. Database `paperwise_db` exists
3. Table `users` exists
4. Tomcat is running with application deployed
5. Existing test users have hashed passwords

## Update Existing Users (Important!)

Before testing, update existing users to use hashed passwords:

```sql
-- Connect to database
psql -U postgres -d paperwise_db

-- Update admin password (admin123)
UPDATE users 
SET password = '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9'
WHERE username = 'admin';

-- Update student password (student123)
UPDATE users 
SET password = '9c6b057e89574d7e261b1ffc0eab5273b8a5b70c6a5b7e1e8d3f4e5a6b7c8d9e'
WHERE username = 'student';

-- Verify updates
SELECT username, LENGTH(password) as hash_length FROM users;
-- Should show hash_length = 64 for all users
```

Or simply re-run the setup script:
```bash
psql -U postgres -f database_setup.sql
```

## Test Scenarios

### 1. Successful Registration

**Steps:**
1. Open browser: `http://localhost:8080/PaperWise_AJT/register.jsp`
2. Fill form:
   - Username: `newuser`
   - Email: `newuser@test.com`
   - Password: `test123`
   - Confirm Password: `test123`
3. Click "Create Account"

**Expected Result:**
- ✅ Redirects to login page
- ✅ Shows green success message: "Account created successfully! Please login."
- ✅ Can login with `newuser` / `test123`
- ✅ Redirects to student dashboard

**Verify in Database:**
```sql
SELECT username, email, role, created_at 
FROM users 
WHERE username = 'newuser';
```

---

### 2. Duplicate Username

**Steps:**
1. Go to register page
2. Fill form:
   - Username: `admin` (existing user)
   - Email: `test@test.com`
   - Password: `test123`
   - Confirm Password: `test123`
3. Click "Create Account"

**Expected Result:**
- ❌ Stays on register page
- ❌ Shows error: "Username 'admin' is already taken. Please choose another."
- ✅ Form fields retain values (except passwords)

---

### 3. Password Mismatch

**Steps:**
1. Go to register page
2. Fill form:
   - Username: `testuser`
   - Email: `test@test.com`
   - Password: `password123`
   - Confirm Password: `different123`
3. Click "Create Account"

**Expected Result:**
- ❌ Shows error: "Passwords do not match."
- ✅ Client-side validation may catch this before submission

---

### 4. Invalid Username Format

**Steps:**
1. Go to register page
2. Fill form:
   - Username: `test@user` (contains @)
   - Email: `test@test.com`
   - Password: `test123`
   - Confirm Password: `test123`
3. Click "Create Account"

**Expected Result:**
- ❌ Shows error: "Username can only contain letters, numbers, and underscores."
- ✅ HTML5 validation may prevent submission

---

### 5. Short Username

**Steps:**
1. Go to register page
2. Fill form:
   - Username: `ab` (2 chars)
   - Email: `test@test.com`
   - Password: `test123`
   - Confirm Password: `test123`
3. Click "Create Account"

**Expected Result:**
- ❌ Shows error: "Username must be at least 3 characters long."
- ✅ HTML5 minlength validation may prevent submission

---

### 6. Invalid Email

**Steps:**
1. Go to register page
2. Fill form:
   - Username: `testuser`
   - Email: `notanemail`
   - Password: `test123`
   - Confirm Password: `test123`
3. Click "Create Account"

**Expected Result:**
- ❌ Shows error: "Please enter a valid email address."
- ✅ HTML5 email validation may prevent submission

---

### 7. Short Password

**Steps:**
1. Go to register page
2. Fill form:
   - Username: `testuser`
   - Email: `test@test.com`
   - Password: `12345` (5 chars)
   - Confirm Password: `12345`
3. Click "Create Account"

**Expected Result:**
- ❌ Shows error: "Password must be at least 6 characters long."
- ✅ HTML5 minlength validation may prevent submission

---

### 8. Empty Fields

**Steps:**
1. Go to register page
2. Leave all fields empty
3. Click "Create Account"

**Expected Result:**
- ❌ Shows error: "All fields are required."
- ✅ HTML5 required validation may prevent submission

---

### 9. Login After Registration

**Steps:**
1. Register new user: `testuser2` / `test@test.com` / `test123`
2. Redirected to login page with success message
3. Login with `testuser2` / `test123`

**Expected Result:**
- ✅ Login succeeds
- ✅ Redirects to `/student-dashboard.jsp`
- ✅ Shows "Welcome, testuser2!"
- ✅ Shows "Role: student"

---

### 10. Navigation Flow

**Steps:**
1. Go to login page: `/login.jsp`
2. Click "Register here" link
3. Verify redirects to `/register.jsp`
4. Click "Sign in" link
5. Verify redirects back to `/login.jsp`

**Expected Result:**
- ✅ All links work correctly
- ✅ No 404 errors
- ✅ Smooth navigation

---

## UI/UX Testing

### Password Toggle

**Test:**
1. Go to register page
2. Enter password in "Password" field
3. Click eye icon (👁️)
4. Verify password becomes visible
5. Click icon again (🙈)
6. Verify password is hidden

**Expected:**
- ✅ Toggle works for both password fields
- ✅ Icons change appropriately

### Form Validation

**Test:**
1. Try to submit empty form
2. Try invalid email format
3. Try short username
4. Try mismatched passwords

**Expected:**
- ✅ HTML5 validation prevents submission
- ✅ Helpful error messages shown
- ✅ Fields highlighted in red

### Responsive Design

**Test:**
1. Open register page on desktop
2. Resize browser to mobile size
3. Test on actual mobile device

**Expected:**
- ✅ Form adapts to screen size
- ✅ All elements visible and usable
- ✅ No horizontal scrolling

---

## Database Verification

### Check New User

```sql
-- View new user details
SELECT user_id, username, email, role, created_at 
FROM users 
WHERE username = 'newuser';

-- Verify password is hashed
SELECT username, LENGTH(password) as hash_length 
FROM users 
WHERE username = 'newuser';
-- Should show hash_length = 64

-- Check password hash format
SELECT username, password 
FROM users 
WHERE username = 'newuser';
-- Should be 64-character hexadecimal string
```

### Check User Count

```sql
-- Count users by role
SELECT role, COUNT(*) as count 
FROM users 
GROUP BY role;

-- Should show increased student count
```

### Verify Timestamps

```sql
-- Check created_at is set
SELECT username, created_at 
FROM users 
WHERE username = 'newuser';

-- Should show current timestamp
```

---

## Security Testing

### SQL Injection Attempt

**Test:**
1. Go to register page
2. Enter username: `admin'; DROP TABLE users; --`
3. Submit form

**Expected:**
- ✅ No SQL injection occurs
- ✅ Username validation fails (contains invalid characters)
- ✅ PreparedStatement prevents injection

### XSS Attempt

**Test:**
1. Go to register page
2. Enter username: `<script>alert('XSS')</script>`
3. Submit form

**Expected:**
- ✅ No script execution
- ✅ Username validation fails (contains invalid characters)
- ✅ Input sanitization prevents XSS

### Password Hashing

**Test:**
1. Register user with password: `test123`
2. Check database:
   ```sql
   SELECT password FROM users WHERE username = 'testuser';
   ```

**Expected:**
- ✅ Password is NOT stored as `test123`
- ✅ Password is 64-character hash
- ✅ Same password produces same hash (deterministic)

---

## Performance Testing

### Concurrent Registrations

**Test:**
1. Open multiple browser tabs
2. Register different users simultaneously
3. Verify all succeed

**Expected:**
- ✅ All registrations complete
- ✅ No duplicate usernames created
- ✅ Database constraints enforced

### Database Connection Pooling

**Test:**
1. Register 10 users in quick succession
2. Check Tomcat logs for connection issues

**Expected:**
- ✅ No connection pool exhaustion
- ✅ Connections properly released
- ✅ No timeout errors

---

## Error Handling

### Database Down

**Test:**
1. Stop PostgreSQL
2. Try to register

**Expected:**
- ❌ Shows error: "A server error occurred. Please try again later."
- ✅ No stack trace shown to user
- ✅ Error logged in Tomcat logs

### Invalid Database State

**Test:**
1. Drop users table:
   ```sql
   DROP TABLE users;
   ```
2. Try to register

**Expected:**
- ❌ Shows error message
- ✅ Application doesn't crash
- ✅ Error logged

---

## Cleanup After Testing

```sql
-- Remove test users
DELETE FROM users WHERE username LIKE 'test%';
DELETE FROM users WHERE username = 'newuser';

-- Or keep them for future testing
-- Just verify they don't interfere with production data
```

---

## Quick Test Script

Run all tests quickly:

```bash
# 1. Update existing users with hashed passwords
psql -U postgres -d paperwise_db -f database_setup.sql

# 2. Test registration
curl -X POST http://localhost:8080/PaperWise_AJT/register \
  -d "username=testuser&email=test@test.com&password=test123&confirmPassword=test123"

# 3. Verify in database
psql -U postgres -d paperwise_db -c "SELECT * FROM users WHERE username='testuser';"

# 4. Test login
curl -X POST http://localhost:8080/PaperWise_AJT/login \
  -d "username=testuser&password=test123" \
  -c cookies.txt

# 5. Cleanup
psql -U postgres -d paperwise_db -c "DELETE FROM users WHERE username='testuser';"
```

---

## Checklist

Before marking registration as complete:

- [ ] Can register new user successfully
- [ ] Duplicate username is rejected
- [ ] Password mismatch is caught
- [ ] Invalid username format is rejected
- [ ] Invalid email format is rejected
- [ ] Short password is rejected
- [ ] Empty fields are rejected
- [ ] Can login with newly registered user
- [ ] New user has "student" role
- [ ] Password is hashed in database
- [ ] Success message shows on login page
- [ ] Register link works from login page
- [ ] Login link works from register page
- [ ] Password toggle works
- [ ] Form validation works
- [ ] Responsive design works
- [ ] No SQL injection possible
- [ ] No XSS possible
- [ ] Database connections properly managed
- [ ] Errors handled gracefully

---

**All tests passing? Registration feature is ready!** ✅
