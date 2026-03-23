# Quick Test Guide - Plain Text Passwords

## Prerequisites

1. PostgreSQL running
2. Database `paperwise_db` exists
3. Tomcat running with deployed application

## Step 1: Update Database

Run the SQL script to update passwords to plain text:

```bash
psql -U postgres -d paperwise_db -f database_setup.sql
```

**Verify:**
```sql
psql -U postgres -d paperwise_db

SELECT username, password, LENGTH(password) as pwd_length 
FROM users;
```

**Expected Output:**
```
 username   |    password     | pwd_length
------------+-----------------+------------
 admin      | admin123A!      |         10
 student    | student123A!    |         12
 john_doe   | password123A!   |         13
 jane_smith | password123A!   |         13
```

## Step 2: Test Login

### Test Admin Login

```
URL: http://localhost:8080/PaperWise_AJT/login.jsp

Username: admin
Password: admin123A!
```

**Expected:**
- ✅ Login succeeds
- ✅ Redirects to `/admin-dashboard.jsp`
- ✅ Shows "Welcome, admin!"

### Test Student Login

```
Username: student
Password: student123A!
```

**Expected:**
- ✅ Login succeeds
- ✅ Redirects to `/student-dashboard.jsp`
- ✅ Shows "Welcome, student!"

### Test Invalid Login

```
Username: admin
Password: wrongpassword
```

**Expected:**
- ❌ Login fails
- ❌ Shows error: "Invalid username or password. Please try again."

## Step 3: Test Registration

### Test Valid Registration

```
URL: http://localhost:8080/PaperWise_AJT/register.jsp

Username: newuser
Email: newuser@test.com
Password: NewUser1!
Confirm: NewUser1!
```

**Expected:**
- ✅ Registration succeeds
- ✅ Redirects to login with success message
- ✅ Can login with new credentials

**Verify in Database:**
```sql
SELECT username, password, role FROM users WHERE username = 'newuser';
```

**Expected:**
```
 username |  password  |  role
----------+------------+---------
 newuser  | NewUser1!  | student
```

### Test Password Validation

#### No Uppercase Letter

```
Password: newuser1!
Confirm: newuser1!
```

**Expected:**
- ❌ Error: "Password must contain at least one uppercase letter."

#### No Lowercase Letter

```
Password: NEWUSER1!
Confirm: NEWUSER1!
```

**Expected:**
- ❌ Error: "Password must contain at least one lowercase letter."

#### No Digit

```
Password: NewUser!
Confirm: NewUser!
```

**Expected:**
- ❌ Error: "Password must contain at least one digit."

#### No Special Character

```
Password: NewUser1
Confirm: NewUser1
```

**Expected:**
- ❌ Error: "Password must contain at least one special character (!@#$%^&*)."

#### Too Short

```
Password: New1!
Confirm: New1!
```

**Expected:**
- ❌ Error: "Password must be at least 8 characters long."

#### Password Mismatch

```
Password: NewUser1!
Confirm: Different1!
```

**Expected:**
- ❌ Error: "Passwords do not match."

### Test Duplicate Username

```
Username: admin
Email: test@test.com
Password: NewUser1!
Confirm: NewUser1!
```

**Expected:**
- ❌ Error: "Username 'admin' is already taken. Please choose another."

## Step 4: Verify Password Storage

```sql
-- Check that passwords are stored as plain text
SELECT username, password, LENGTH(password) as length 
FROM users 
ORDER BY username;
```

**Expected:**
- All passwords should be readable plain text
- No 64-character hashes
- Passwords match what was entered

## Step 5: Test Complete Flow

1. **Register new user:**
   - Username: `testflow`
   - Email: `testflow@test.com`
   - Password: `TestFlow1!`

2. **Verify redirect to login**

3. **Login with new credentials:**
   - Username: `testflow`
   - Password: `TestFlow1!`

4. **Verify access to student dashboard**

5. **Logout**

6. **Verify redirect to login**

7. **Try to access dashboard without login:**
   - URL: `http://localhost:8080/PaperWise_AJT/student-dashboard.jsp`
   - Should redirect to login

## Password Examples

### Valid Passwords

```
✅ admin123A!
✅ student123A!
✅ Password1!
✅ MyP@ssw0rd
✅ Test123!@#
✅ Secure1!
✅ Welcome2@
✅ Complex1#
✅ Strong9$
✅ Valid8%
```

### Invalid Passwords

```
❌ password      - No uppercase, digit, special char
❌ PASSWORD123!  - No lowercase
❌ Password123   - No special character
❌ Pass1!        - Too short
❌ Password!     - No digit
❌ 12345678!     - No letters
❌ Abcdefgh!     - No digit
❌ Test123       - No special character
```

## Validation Checklist

Test each validation rule:

- [ ] Minimum 8 characters enforced
- [ ] Uppercase letter required
- [ ] Lowercase letter required
- [ ] Digit required
- [ ] Special character required
- [ ] Password match validation works
- [ ] Username uniqueness checked
- [ ] Email format validated
- [ ] Username format validated
- [ ] All fields required

## Database Verification

```sql
-- Count users
SELECT COUNT(*) FROM users;

-- Check password lengths (should be short, not 64 chars)
SELECT username, LENGTH(password) as pwd_length 
FROM users;

-- Verify all passwords are plain text
SELECT username, password 
FROM users 
WHERE LENGTH(password) < 20;  -- Should return all users

-- Check for any hashed passwords (should return 0)
SELECT COUNT(*) 
FROM users 
WHERE LENGTH(password) = 64;  -- Should be 0
```

## Cleanup

```sql
-- Remove test users
DELETE FROM users WHERE username IN ('newuser', 'testflow', 'testuser');

-- Verify cleanup
SELECT username FROM users ORDER BY username;
```

## Quick Commands

```bash
# Update database
psql -U postgres -d paperwise_db -f database_setup.sql

# Check passwords
psql -U postgres -d paperwise_db -c "SELECT username, password FROM users;"

# Test login (curl)
curl -X POST http://localhost:8080/PaperWise_AJT/login \
  -d "username=admin&password=admin123A!" \
  -c cookies.txt -v

# Test registration (curl)
curl -X POST http://localhost:8080/PaperWise_AJT/register \
  -d "username=testuser&email=test@test.com&password=TestUser1!&confirmPassword=TestUser1!" \
  -v

# Cleanup test users
psql -U postgres -d paperwise_db -c "DELETE FROM users WHERE username LIKE 'test%';"
```

## Success Criteria

All of the following must pass:

- ✅ Can login with `admin` / `admin123A!`
- ✅ Can login with `student` / `student123A!`
- ✅ Can register with strong password
- ✅ Cannot register with weak password
- ✅ Cannot register duplicate username
- ✅ Passwords stored as plain text in database
- ✅ Password validation enforces all rules
- ✅ HTML5 validation works in browser
- ✅ Server-side validation works
- ✅ Login redirects to correct dashboard
- ✅ Logout works properly
- ✅ AuthFilter protects dashboards

## Troubleshooting

### Login fails with correct password

```sql
-- Check actual password in database
SELECT username, password FROM users WHERE username = 'admin';

-- If it's a hash, update it
UPDATE users SET password = 'admin123A!' WHERE username = 'admin';
```

### Registration succeeds but login fails

```sql
-- Check what was stored
SELECT username, password FROM users WHERE username = 'newuser';

-- Password should match what was entered exactly
```

### Validation not working

1. Check browser console for JavaScript errors
2. Try different browser
3. Server-side validation should still work
4. Check RegisterServlet logs in Tomcat

---

**All tests passing? Plain text password implementation is working!** ✅

**Remember: This is DEVELOPMENT ONLY. Never use in production!** ⚠️
