# User Registration Feature Documentation

## Overview

The PaperWise application now includes a complete user registration system that allows new users to create accounts with the "student" role by default.

## Features Implemented

### 1. Registration Page (`web/register.jsp`)

**URL**: `/register.jsp`

**Features**:
- Modern, responsive UI matching the login page design
- Form fields:
  - Username (required, min 3 chars, alphanumeric + underscore only)
  - Email (required, valid email format)
  - Password (required, min 6 chars)
  - Confirm Password (required, must match password)
- Client-side validation
- Password visibility toggle for both password fields
- Real-time password match validation
- Error message display
- Link back to login page
- Form resubmission prevention

### 2. RegisterServlet (`src/java/com/paperwise/servlet/RegisterServlet.java`)

**URL Mapping**: `@WebServlet("/register")`

**HTTP Methods**:
- `GET`: Displays the registration form
- `POST`: Processes registration submission

**Validation**:
- All fields required
- Username: min 3 characters, alphanumeric + underscore only
- Email: valid email format
- Password: min 6 characters
- Password confirmation must match
- Username uniqueness check

**Security**:
- Password hashing using SHA-256 (simple hashing for development)
- Input sanitization
- SQL injection prevention via PreparedStatement
- JNDI DataSource connection pooling

**Process Flow**:
1. Validate input fields
2. Check if username already exists
3. Hash password using SHA-256
4. Create User object with "student" role
5. Insert into database via UserDAO
6. Redirect to login page with success message

### 3. UserDAO Updates (`src/java/com/paperwise/dao/UserDAO.java`)

**New Methods**:

#### `boolean usernameExists(String username)`
- Checks if a username already exists in the database
- Returns `true` if username is taken, `false` otherwise
- Uses PreparedStatement for SQL injection prevention

#### `boolean registerUser(User user)`
- Inserts a new user into the database
- Sets default role to "student" if not specified
- Sets `created_at` to `CURRENT_TIMESTAMP`
- Returns `true` on success, `false` on failure
- Throws `DAOException` on database errors

**SQL Statements Added**:
```sql
-- Check username existence
SELECT 1 FROM users WHERE username = ?

-- Insert new user
INSERT INTO users (username, email, password, role, created_at) 
VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)
```

### 4. LoginServlet Updates

**Password Hashing**:
- Added `hashPassword()` method using SHA-256
- Login now hashes the entered password before validation
- Compares hashed password with stored hash in database

**Import Added**:
```java
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
```

### 5. Login Page Updates (`web/login.jsp`)

**New Features**:
- Success message display (green banner)
- Registration link at bottom: "New user? Register here"
- Styled link matching the design theme

**Success Message Handling**:
- Displays success message from URL parameter `?success=...`
- Used after successful registration
- Auto-dismisses on page navigation

### 6. AuthFilter Updates (`src/java/com/paperwise/filter/AuthFilter.java`)

**Public Resources Added**:
- `/register.jsp` - Registration page
- `/register` - Registration servlet

**Updated `isPublicResource()` method**:
```java
return path.equals(LOGIN_PAGE)
    || path.equals(LOGIN_SERVLET)
    || path.equals(REGISTER_PAGE)      // NEW
    || path.equals(REGISTER_SERVLET)   // NEW
    || path.equals("/logout")
    // ... other public resources
```

### 7. Database Setup Updates (`database_setup.sql`)

**Password Storage**:
- Test users now use SHA-256 hashed passwords
- Hashes are 64-character hexadecimal strings

**Test User Credentials**:
| Username | Password | SHA-256 Hash | Role |
|----------|----------|--------------|------|
| admin | admin123 | 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9 | admin |
| student | student123 | (see SQL file) | student |
| john_doe | password123 | ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f | student |
| jane_smith | password123 | ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f | student |

## User Flow

### Registration Flow

1. User visits `/login.jsp`
2. Clicks "Register here" link
3. Redirected to `/register.jsp`
4. Fills out registration form:
   - Username
   - Email
   - Password
   - Confirm Password
5. Submits form to `/register` (POST)
6. Server validates input:
   - All fields present
   - Username format valid
   - Email format valid
   - Password length sufficient
   - Passwords match
7. Server checks username availability
8. Server hashes password
9. Server creates user with "student" role
10. Server inserts into database
11. Redirects to `/login.jsp?success=Account created successfully!`
12. User sees success message
13. User logs in with new credentials

### Login Flow (Updated)

1. User enters username and password
2. Server hashes the entered password
3. Server compares hashed password with database
4. On success: creates session and redirects to dashboard
5. On failure: shows error message

## Validation Rules

### Username
- **Required**: Yes
- **Min Length**: 3 characters
- **Max Length**: 50 characters (database limit)
- **Format**: Alphanumeric and underscore only (`[a-zA-Z0-9_]+`)
- **Unique**: Must not already exist

### Email
- **Required**: Yes
- **Max Length**: 100 characters (database limit)
- **Format**: Valid email address (`user@domain.com`)
- **Unique**: Not enforced (multiple users can share email)

### Password
- **Required**: Yes
- **Min Length**: 6 characters
- **Max Length**: 255 characters (database limit for hash)
- **Hashing**: SHA-256 (64-character hex string)
- **Confirmation**: Must match confirm password field

### Role
- **Default**: "student"
- **Options**: "admin", "student"
- **Set By**: System (not user-selectable during registration)

## Security Considerations

### Current Implementation (Development)

1. **Password Hashing**: SHA-256
   - Simple hashing without salt
   - Suitable for development only
   - **NOT PRODUCTION-READY**

2. **Input Validation**:
   - Client-side: HTML5 validation + JavaScript
   - Server-side: Comprehensive validation in servlet
   - SQL injection prevention: PreparedStatement

3. **Session Management**:
   - HttpOnly cookies enabled
   - 30-minute timeout
   - Session fixation prevention

### Production Recommendations

1. **Password Hashing**:
   - Replace SHA-256 with BCrypt, Argon2, or PBKDF2
   - Add salt to each password
   - Use adaptive hashing (configurable work factor)

2. **HTTPS**:
   - Enable SSL/TLS in Tomcat
   - Set `<secure>true</secure>` in session config
   - Redirect HTTP to HTTPS

3. **Rate Limiting**:
   - Implement registration rate limiting
   - Prevent automated account creation
   - Add CAPTCHA for bot prevention

4. **Email Verification**:
   - Send verification email after registration
   - Require email confirmation before login
   - Prevent fake email addresses

5. **Password Strength**:
   - Enforce stronger password requirements
   - Check against common password lists
   - Require mix of uppercase, lowercase, numbers, symbols

## Testing

### Manual Testing Steps

1. **Test Registration Success**:
   ```
   1. Go to /register.jsp
   2. Enter: username=testuser, email=test@test.com, password=test123, confirm=test123
   3. Submit form
   4. Verify redirect to login with success message
   5. Login with new credentials
   6. Verify access to student dashboard
   ```

2. **Test Duplicate Username**:
   ```
   1. Go to /register.jsp
   2. Enter: username=admin (existing user)
   3. Submit form
   4. Verify error: "Username 'admin' is already taken"
   ```

3. **Test Password Mismatch**:
   ```
   1. Go to /register.jsp
   2. Enter: password=test123, confirm=different
   3. Submit form
   4. Verify error: "Passwords do not match"
   ```

4. **Test Invalid Username**:
   ```
   1. Go to /register.jsp
   2. Enter: username=test@user (contains @)
   3. Submit form
   4. Verify error: "Username can only contain letters, numbers, and underscores"
   ```

5. **Test Short Password**:
   ```
   1. Go to /register.jsp
   2. Enter: password=12345 (5 chars)
   3. Submit form
   4. Verify error: "Password must be at least 6 characters long"
   ```

6. **Test Invalid Email**:
   ```
   1. Go to /register.jsp
   2. Enter: email=notanemail
   3. Submit form
   4. Verify error: "Please enter a valid email address"
   ```

### Database Verification

```sql
-- Check new user was created
SELECT user_id, username, email, role, created_at 
FROM users 
WHERE username = 'testuser';

-- Verify password is hashed
SELECT LENGTH(password) as hash_length, password 
FROM users 
WHERE username = 'testuser';
-- Should show hash_length = 64 (SHA-256 hex)

-- Verify default role
SELECT role FROM users WHERE username = 'testuser';
-- Should show 'student'
```

## File Structure

```
PaperWise_AJT/
├── src/java/com/paperwise/
│   ├── dao/
│   │   └── UserDAO.java                    ✅ Added usernameExists(), registerUser()
│   ├── filter/
│   │   └── AuthFilter.java                 ✅ Added register page/servlet to public resources
│   ├── model/
│   │   └── User.java                       ✅ No changes
│   └── servlet/
│       ├── LoginServlet.java               ✅ Added password hashing
│       ├── LogoutServlet.java              ✅ No changes
│       ├── RegisterServlet.java            ✅ NEW - Registration logic
│       └── TestDBServlet.java              ✅ No changes
├── web/
│   ├── login.jsp                           ✅ Added success message, register link
│   ├── register.jsp                        ✅ NEW - Registration form
│   ├── admin-dashboard.jsp                 ✅ No changes
│   └── student-dashboard.jsp               ✅ No changes
├── database_setup.sql                      ✅ Updated with hashed passwords
└── REGISTRATION_FEATURE.md                 ✅ This file
```

## API Reference

### RegisterServlet Endpoints

#### GET /register
- **Description**: Display registration form
- **Response**: register.jsp
- **Authentication**: Not required (public)

#### POST /register
- **Description**: Process registration
- **Parameters**:
  - `username` (required): 3+ chars, alphanumeric + underscore
  - `email` (required): valid email format
  - `password` (required): 6+ chars
  - `confirmPassword` (required): must match password
- **Success Response**: 
  - Redirect to `/login.jsp?success=Account created successfully!`
- **Error Response**: 
  - Forward to `/register.jsp` with error message
- **Authentication**: Not required (public)

### UserDAO Methods

#### `boolean usernameExists(String username)`
```java
// Check if username is taken
if (userDAO.usernameExists("testuser")) {
    // Username already exists
}
```

#### `boolean registerUser(User user)`
```java
// Register new user
User newUser = new User();
newUser.setUsername("testuser");
newUser.setEmail("test@test.com");
newUser.setPassword(hashedPassword);
newUser.setRole("student");

boolean success = userDAO.registerUser(newUser);
```

## Configuration

### No Configuration Changes Required

The registration feature uses existing configuration:
- JNDI DataSource: `java:comp/env/jdbc/paperwise`
- Database: `paperwise_db`
- Table: `users`
- Connection pooling: Configured in `context.xml`

### Servlet Mapping

Uses annotation-based mapping (no web.xml changes):
```java
@WebServlet("/register")
public class RegisterServlet extends HttpServlet { ... }
```

## Troubleshooting

### Issue: "Username already taken" for new username

**Cause**: Database already has that username

**Solution**:
```sql
-- Check existing usernames
SELECT username FROM users;

-- Delete test user if needed
DELETE FROM users WHERE username = 'testuser';
```

### Issue: Login fails after registration

**Cause**: Password hashing mismatch

**Solution**:
1. Verify LoginServlet hashes password before validation
2. Check database has hashed password (64 chars)
3. Test with known hash:
   ```sql
   -- Update user with known hash for 'test123'
   UPDATE users 
   SET password = '9b71d224bd62f3785d96d46ad3ea3d73319bfbc2890caadae2dff72519673ca72'
   WHERE username = 'testuser';
   ```

### Issue: Registration form validation not working

**Cause**: JavaScript disabled or browser compatibility

**Solution**:
- Server-side validation will still work
- Check browser console for JavaScript errors
- Ensure HTML5 validation attributes are supported

### Issue: Database error during registration

**Cause**: Database connection or constraint violation

**Solution**:
1. Check Tomcat logs for detailed error
2. Verify database is running
3. Check JNDI DataSource configuration
4. Verify users table schema matches expectations

## Future Enhancements

1. **Email Verification**
   - Send verification email after registration
   - Add `email_verified` column to users table
   - Prevent login until email is verified

2. **Password Strength Meter**
   - Visual indicator of password strength
   - Real-time feedback as user types
   - Suggestions for stronger passwords

3. **Social Registration**
   - OAuth integration (Google, GitHub, etc.)
   - Link social accounts to existing users

4. **Admin User Creation**
   - Separate admin registration flow
   - Require admin approval for new admins
   - Admin invitation system

5. **Profile Completion**
   - Additional fields (name, phone, etc.)
   - Profile picture upload
   - Multi-step registration wizard

6. **Password Recovery**
   - "Forgot password" link
   - Email-based password reset
   - Security questions

---

**Registration feature is complete and ready for testing!** 🎉
