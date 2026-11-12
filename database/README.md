# PaperWise Database Setup

## Schema File

`schema.sql` - Complete database schema for production deployment on Neon Postgres

### What's Included:
- Users table (admin and student roles)
- Papers table (uploaded documents)
- Votes table (usefulness voting)
- Difficulty votes table
- Paper requests table
- Notifications table
- All necessary indexes
- Foreign key constraints

### What's Excluded:
- `firebase_uid` column - Firebase authentication methods are defined in code but never called
- `auth_provider` column - Related to Firebase, not used in production
- These columns exist in the local database for legacy compatibility but are not needed for deployment

## Setup Instructions

### For Neon Postgres (Production):

1. Create a new Neon project at [neon.tech](https://neon.tech)

2. Get your connection string from Neon dashboard. Neon provides a PostgreSQL URL like:
   ```
   postgresql://neondb_owner:AbCd1234@ep-example.us-east-1.aws.neon.tech/neondb?sslmode=require
   ```

3. **Convert to JDBC format**: Extract the components for PaperWise:
   - **Host**: `ep-example.us-east-1.aws.neon.tech`
   - **Database**: `neondb`
   - **Username**: `neondb_owner`
   - **Password**: `AbCd1234`
   
   Then create:
   - `JDBC_URL`: `jdbc:postgresql://ep-example.us-east-1.aws.neon.tech/neondb?sslmode=require`
   - `JDBC_USERNAME`: `neondb_owner`
   - `JDBC_PASSWORD`: `AbCd1234`

4. Connect to your Neon database using psql or the Neon SQL Editor:
   ```bash
   psql "postgresql://neondb_owner:AbCd1234@ep-example.us-east-1.aws.neon.tech/neondb?sslmode=require"
   ```

5. Run the schema:
   ```sql
   \i schema.sql
   ```
   Or copy-paste the contents of `schema.sql` into the Neon SQL Editor.

6. **Set admin password immediately**:
   ```sql
   -- Replace 'YourStrongPassword' with actual password
   UPDATE users 
   SET password = 'YourStrongPassword' 
   WHERE username = 'admin';
   ```
   
   **⚠️ CRITICAL**: Passwords are stored as plain text currently. This is a security risk. After deployment, implement bcrypt password hashing as the first priority.

7. Set environment variables in Render (see deployment guide)

## Notes

- Neon free tier limits: 0.5 GB storage, shared compute
- Connection pooling is configured for free tier (maxTotal=5, maxIdle=2)
- All timestamps use `CURRENT_TIMESTAMP` (UTC)
- Cascade deletes ensure referential integrity
