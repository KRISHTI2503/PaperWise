# Plain Text Password Implementation

## ⚠️ SECURITY WARNING

**This implementation stores passwords in PLAIN TEXT for development purposes only.**

**NEVER use this in production!** Plain text passwords are a critical security vulnerability.

## Overview

The PaperWise application has been updated to use plain text password storage for simplified development and testing. This implementation includes strong password validation rules to ensure password quality.

## Changes Made

### 1. LoginServlet Updates

**Removed:**
- SHA-256 password hashing
- `hashPassword()` method
- `MessageDigest` imports

**Updated:**
- Direct password comparison (no hashing)
- Plain text password validation against database

**Code:**
```java
// Before (with hashing)
String hashedPassword = hashPassword(password);
boolean isValid = userDAO.validateLogin(username, hashedPassword);

// After (plain text)
boolean isValid = userDAO.validateLogin(username, password);
```

### 2. RegisterServlet Updates

**Removed:**
- SHA-256 password hashing
- `hashPassword()` method
- `MessageDigest` imports

**Added:**
- Strong password validation rules
- Helper methods for password strength checking

**Updated:**
- Stores password as plain text
- Minimum password length: 8 characters (was 6)

**New Validation Methods:**
```java
private boolean hasUpperCase(String password)
private boolean hasLowerCase(String password)
private boolean hasDigit(String password)
private boolean hasSpecialChar(String password)
```

### 3. Password Validation Rules

**Requirements:**
- Minimum 8 characters
- At least 1 uppercase letter (A-Z)
- At least 1 lowercase letter (a-z)
- At least 1 digit (0-9)
- At least 1 special character (!@#$%^&*)

**Example Valid Passwords:**
- `admin123A!`
- `student123A!`
- `Password1!`
- `MyP@ssw0rd`
- `Test123!@#`

**Example Invalid Passwords:**
- `password` - No uppercase, digit, or special char
- `PASSWORD123!` - No lowercase
- `Password123` - No special character
- `Pass1!` - Too short (less than 8 chars)
- `Password!` - No digit

### 4. register.jsp Updates

**Added HTML5 Pattern Validation:**
```html
<input 
    type="password" 
    pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$"
    title="Password must be at least 8 characters and contain: uppercase, lowercase, digit, and special character (!@#$%^&*)"
    minlength="8"
/>
```

**Updated Requirements Text:**
```
At least 8 characters with uppercase, lowercase, digit, and special character (!@#$%^&*)
```

### 5. database_setup.sql Updates

**Test User Credentials:**

| Username | Password | Role |
|----------|----------|------|
| admin | admin123A! | admin |
| student | student123A! | student |
| john_doe | password123A! | student |
| jane_smith | password123A! | student |

**SQL:**
```sql
-- Plain text passwords
INSERT INTO users (username, email, password, role) 
VALUES 
    ('admin', 'admin@paperwise.com', 'admin123A!', 'admin'),
    ('student', 'student@paperwise.com', 'student123A!', 'student'),
    ('john_doe', 'john.doe@paperwise.com', 'password123A!', 'student'),
    ('jane_smith', 'jane.smith@paperwise.com', 'password123A!', 'student');
```

## Password Validation Flow

### Client-Side (register.jsp)

1. HTML5 `pattern` attribute validates format
2. JavaScript validates password match
3. Browser shows validation errors before submission

### Server-Side (RegisterServlet)

1. Check all fields present
2. Validate username format
3. Validate email format
4. Validate password length (≥8)
5. Check uppercase letter present
6. Check lowercase letter present
7. Check digit present
8. Check special character present
9. Verify passwords match
10. Check username uniqueness
11. Store plain text password

## Testing

### Update Database

Run the updated SQL script to replace hashed passwords with plain text:

```bash
psql -U postgres -d paperwise_db -f database_setup.sql
```

Or manually update:

```sql
-- Update existing users
UPDATE users SET password = 'admin123A!' WHERE username = 'admin';
UPDATE users SET password = 'student123A!' WHERE username = 'student';
UPDATE users SET password = 'password123A!' WHERE username = 'john_doe';
UPDATE users SET password = 'password123A!' WHERE username = 'jane_smith';
```

### Test Login

```
URL: http://localhost:8080/PaperWise_AJT/login.jsp

Admin Login:
- Username: admin
- Password: admin123A!

Student Login:
- Username: student
- Password: student123A!
```

### Test Registration

**Valid Registration:**
```
Username: testuser
Email: test@test.com
Password: Test123!@#
Confirm: Test123!@#
```

**Invalid - No Uppercase:**
```
Password: test123!@#
Error: "Password must contain at least one uppercase letter."
```

**Invalid - No Lowercase:**
```
Password: TEST123!@#
Error: "Password must contain at least one lowercase letter."
```

**Invalid - No Digit:**
```
Password: TestTest!@#
Error: "Password must contain at least one digit."
```

**Invalid - No Special Character:**
```
Password: Test1234
Error: "Password must contain at least one special character (!@#$%^&*)."
```

**Invalid - Too Short:**
```
Password: Test1!
Error: "Password must be at least 8 characters long."
```

## Validation Error Messages

### Server-Side Errors (RegisterServlet)

```java
"All fields are required."
"Username must be at least 3 characters long."
"Username can only contain letters, numbers, and underscores."
"Please enter a valid email address."
"Password must be at least 8 characters long."
"Password must contain at least one uppercase letter."
"Password must contain at least one lowercase letter."
"Password must contain at least one digit."
"Password must contain at least one special character (!@#$%^&*)."
"Passwords do not match."
"Username 'xxx' is already taken. Please choose another."
```

### Client-Side Validation (HTML5)

- Required field validation
- Minimum length validation
- Pattern matching validation
- Email format validation

## Database Schema

**No changes to database structure:**

```sql
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,  -- Stores plain text (8-255 chars)
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'student')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Security Considerations

### Current Implementation (Development Only)

**Vulnerabilities:**
1. ❌ Passwords stored in plain text
2. ❌ Passwords visible in database
3. ❌ No protection if database is compromised
4. ❌ Passwords visible in logs if logged
5. ❌ Passwords visible in backups

**Mitigations:**
1. ✅ Strong password requirements
2. ✅ SQL injection prevention (PreparedStatement)
3. ✅ Input validation
4. ✅ Session management
5. ✅ HttpOnly cookies

### Production Requirements

**For production, you MUST:**

1. **Implement Password Hashing:**
   - Use BCrypt, Argon2, or PBKDF2
   - Add salt to each password
   - Use adaptive hashing (configurable work factor)

2. **Enable HTTPS:**
   - Encrypt data in transit
   - Prevent password interception
   - Set secure cookie flag

3. **Add Rate Limiting:**
   - Prevent brute force attacks
   - Limit login attempts
   - Add CAPTCHA

4. **Implement Logging:**
   - Log authentication attempts
   - Monitor for suspicious activity
   - Never log passwords

5. **Regular Security Audits:**
   - Penetration testing
   - Code reviews
   - Dependency updates

## Migration to Hashed Passwords

When ready for production, follow these steps:

### 1. Choose Hashing Algorithm

**Recommended: BCrypt**

Add dependency (Maven):
```xml
<dependency>
    <groupId>org.mindrot</groupId>
    <artifactId>jbcrypt</artifactId>
    <version>0.4</version>
</dependency>
```

### 2. Update RegisterServlet

```java
import org.mindrot.jbcrypt.BCrypt;

// In doPost method
String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));
newUser.setPassword(hashedPassword);
```

### 3. Update LoginServlet

```java
import org.mindrot.jbcrypt.BCrypt;

// In doPost method
User user = userDAO.getUserByUsername(username);
if (user != null && BCrypt.checkpw(password, user.getPassword())) {
    // Login successful
}
```

### 4. Migrate Existing Passwords

```java
// One-time migration script
for (User user : allUsers) {
    String plainPassword = user.getPassword();
    String hashedPassword = BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
    userDAO.updatePassword(user.getUserId(), hashedPassword);
}
```

### 5. Update Database

```sql
-- Increase password column size for hashes
ALTER TABLE users ALTER COLUMN password TYPE VARCHAR(255);
```

## File Changes Summary

```
Modified Files:
├── src/java/com/paperwise/servlet/
│   ├── LoginServlet.java           ✅ Removed hashing, direct comparison
│   └── RegisterServlet.java        ✅ Removed hashing, added strong validation
├── web/
│   └── register.jsp                ✅ Updated pattern, minlength=8
├── database_setup.sql              ✅ Plain text passwords
└── PLAIN_TEXT_PASSWORDS.md         ✅ This documentation

Unchanged Files:
├── src/java/com/paperwise/dao/UserDAO.java
├── src/java/com/paperwise/filter/AuthFilter.java
├── src/java/com/paperwise/model/User.java
└── web/login.jsp
```

## Quick Reference

### Test Credentials

```
Admin:
  Username: admin
  Password: admin123A!

Student:
  Username: student
  Password: student123A!
```

### Password Requirements

```
✓ Minimum 8 characters
✓ At least 1 uppercase (A-Z)
✓ At least 1 lowercase (a-z)
✓ At least 1 digit (0-9)
✓ At least 1 special (!@#$%^&*)
```

### Valid Password Examples

```
admin123A!
student123A!
Password1!
MyP@ssw0rd
Test123!@#
Secure1!
Welcome2@
```

### Validation Pattern (Regex)

```regex
^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$
```

**Breakdown:**
- `(?=.*[a-z])` - At least one lowercase
- `(?=.*[A-Z])` - At least one uppercase
- `(?=.*\d)` - At least one digit
- `(?=.*[!@#$%^&*])` - At least one special char
- `[A-Za-z\d!@#$%^&*]{8,}` - Only these chars, min 8 length

## Troubleshooting

### Issue: Login fails with correct credentials

**Solution:**
```sql
-- Check password in database
SELECT username, password FROM users WHERE username = 'admin';

-- Should show: admin123A! (not a hash)

-- If showing hash, update to plain text
UPDATE users SET password = 'admin123A!' WHERE username = 'admin';
```

### Issue: Registration fails with strong password

**Check validation:**
```
Password: Test123!

✓ Length: 8 chars
✓ Uppercase: T
✓ Lowercase: est
✓ Digit: 123
✓ Special: !

Should succeed!
```

### Issue: HTML5 validation not working

**Browser compatibility:**
- Ensure modern browser (Chrome, Firefox, Edge, Safari)
- Check JavaScript is enabled
- Server-side validation will still work

---

**Remember: This is for DEVELOPMENT ONLY. Never use plain text passwords in production!** 🔒
