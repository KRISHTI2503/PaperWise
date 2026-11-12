# PaperWise Deployment Guide

Complete guide for deploying PaperWise to Render with Docker, Neon Postgres, and Supabase Storage.

## Prerequisites

1. **GitHub account** with access to https://github.com/KRISHTI2503/PaperWise
2. **Render account** at https://render.com (free tier)
3. **Neon account** at https://neon.tech (free tier)
4. **Supabase account** at https://supabase.com (free tier)

---

## Phase 1: Setup Neon Postgres Database

### 1.1 Create Database

1. Go to [neon.tech](https://neon.tech) and create a new project
2. Name your project: `paperwise-db`
3. Select region closest to your users
4. Note your connection string (shown after creation)

### 1.2 Run Schema

1. Open Neon SQL Editor or connect via psql:
   ```bash
   psql "postgresql://username:password@host.neon.tech/dbname?sslmode=require"
   ```

2. Copy contents of `database/schema.sql` and execute

3. **Set admin password immediately**:
   ```sql
   -- ⚠️ Passwords are PLAIN TEXT currently - security risk!
   -- Set a strong password now, implement bcrypt hashing after deployment
   UPDATE users 
   SET password = 'YourStrongPasswordHere123!' 
   WHERE username = 'admin';
   ```

4. Verify:
   ```sql
   SELECT username, role FROM users WHERE username = 'admin';
   ```

### 1.3 Save Credentials

Neon gives you a URL like: `postgresql://user:pass@host.region.aws.neon.tech/dbname?sslmode=require`

**Convert to JDBC format for PaperWise**:
- Extract host, database, username, password from the URL
- `JDBC_URL` = `jdbc:postgresql://HOST/DBNAME?sslmode=require` (add `jdbc:` prefix, remove user:pass@)
- `JDBC_USERNAME` = username from URL
- `JDBC_PASSWORD` = password from URL

**Example**:
- Neon URL: `postgresql://myuser:mypass123@ep-cool-feather.us-east-1.aws.neon.tech/neondb?sslmode=require`
- JDBC_URL: `jdbc:postgresql://ep-cool-feather.us-east-1.aws.neon.tech/neondb?sslmode=require`
- JDBC_USERNAME: `myuser`
- JDBC_PASSWORD: `mypass123`

---

## Phase 2: Setup Supabase Storage

### 2.1 Create Project

1. Go to [supabase.com](https://supabase.com) and create project
2. Name: `paperwise-storage`
3. Database password: (save this, though we won't use Supabase DB)
4. Region: Same as your Neon database

### 2.2 Create Storage Bucket

1. Go to Storage → Buckets
2. Click "New bucket"
3. Name: `paperwise-files`
4. **IMPORTANT**: Make it **PRIVATE** (not public)
5. Create bucket

### 2.3 Get Credentials

1. Go to Settings → API
2. Copy:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **service_role key**: `eyJhbGc...` (long token - this is SECRET, server-side only)

**IMPORTANT**: Use the `service_role` key, NOT the `anon` key. The service_role key has full access and should only be used server-side (never in client JavaScript).

### 2.4 Save Credentials

Note these for Render:
- **SUPABASE_URL**: Your project URL
- **SUPABASE_KEY**: Your service_role key (SECRET - server-side only)
- **SUPABASE_BUCKET**: `paperwise-files`

---

## Phase 3: Deploy to Render

### 3.1 Create Web Service

1. Go to [render.com](https://render.com/dashboard)
2. Click "New +" → "Web Service"
3. Connect your GitHub repository: `KRISHTI2503/PaperWise`
4. Configure:
   - **Name**: `paperwise`
   - **Runtime**: Docker
   - **Branch**: `main` (or your branch)
   - **Plan**: Free

### 3.2 Configure Environment Variables

In Render dashboard, go to Environment tab and add:

| Key | Value | Secret? |
|-----|-------|---------|
| `JDBC_URL` | `jdbc:postgresql://host.neon.tech:5432/db?sslmode=require` | ✓ Yes |
| `JDBC_USERNAME` | Your Neon username | ✓ Yes |
| `JDBC_PASSWORD` | Your Neon password | ✓ Yes |
| `SUPABASE_URL` | `https://xxxxx.supabase.co` | ✓ Yes |
| `SUPABASE_KEY` | Your Supabase service_role key | ✓ Yes |
| `SUPABASE_BUCKET` | `paperwise-files` | No |
| `APP_ENV` | `production` | No |

**Important**: Mark all credentials as "Secret" so they don't appear in logs

### 3.3 Deploy

1. Click "Create Web Service"
2. Render will:
   - Clone your repository
   - Build Docker image (takes 5-10 minutes first time)
   - Start container
   - Run health checks on `/health` endpoint

3. Monitor deployment in Logs tab

### 3.4 Verify Deployment

Once deployed, test your application:

1. **Health Check**:
   ```bash
   curl https://paperwise.onrender.com/health
   ```
   Should return: `OK`

2. **Access Application**:
   - Open: `https://paperwise.onrender.com`
   - You should see the login page

3. **Login as Admin**:
   - Username: `admin`
   - Password: `admin123` (or your chosen password)

---

## Phase 4: Test File Upload

1. Login as admin
2. Go to "Upload Paper"
3. Fill form and upload a PDF (max 20MB)
4. File should upload to Supabase Storage
5. Verify in Supabase dashboard: Storage → paperwise-files

---

## Phase 5: Create Student Account

1. Click "Register" on login page
2. Create a student account
3. Login and verify:
   - Can browse papers
   - Can view PDFs
   - Can download files
   - Can vote on difficulty
   - Can mark papers as useful

---

## Troubleshooting

### Build Fails

- Check Render build logs
- Ensure `build.xml` is present
- Verify all Java files compile locally first

### Database Connection Error

- Verify JDBC_URL includes `?sslmode=require`
- Check Neon database is not paused (free tier auto-pauses)
- Confirm credentials are correct

### File Upload Fails

- Check Supabase bucket name is correct
- Verify bucket is created and private
- Confirm SUPABASE_KEY is the anon public key, not service role key

### Placeholder Error `${JDBC_URL}`

- This means environment variables aren't being injected
- Check `docker-entrypoint.sh` is executable
- Verify all env vars are set in Render dashboard

### 503 Service Unavailable

- Container may be starting (wait 30 seconds)
- Check Render logs for startup errors
- Free tier may have cold start delay

---

## Security Notes

### Secrets Management

✓ **DO**:
- Use Render environment variables for all secrets
- Mark credentials as "Secret" in Render
- Use `?sslmode=require` for database connections
- Keep Supabase bucket private

✗ **DON'T**:
- Commit `.env` files
- Push service account JSONs
- Log secret values
- Make Supabase buckets public

### Firebase Cleanup

**IMPORTANT**: You must revoke the old Firebase private key:
1. Go to Firebase Console
2. Settings → Service Accounts
3. Find key with ID: `e07d4c5551f8547fd55cb94fde2c6819d736399c`
4. Delete/revoke this key

The key was exposed in git history and must be revoked even though the file was deleted.

---

## Monitoring

### Health Checks

Render automatically checks `/health` endpoint:
- Every 30 seconds
- Expects HTTP 200 OK
- No database query (fast response)

### Logs

View logs in Render dashboard:
- Application logs
- Access logs
- Build logs

### Database

Monitor Neon dashboard:
- Storage usage
- Query performance
- Connection count

---

## Scaling Notes

### Free Tier Limits

- **Render**: Spins down after 15min inactivity, cold start ~30s
- **Neon**: 0.5GB storage, shared CPU, auto-pause after 5min
- **Supabase**: 1GB storage, 50MB file size limit per file

### If You Outgrow Free Tier

1. **Render**: Upgrade to Starter ($7/mo) for always-on
2. **Neon**: Pro plan ($19/mo) for dedicated compute
3. **Supabase**: Pro plan ($25/mo) for 100GB storage

---

## Maintenance

### Update Application

1. Push changes to GitHub
2. Render auto-deploys on push (if enabled)
3. Or click "Manual Deploy" in Render dashboard

### Database Migrations

For schema changes:
1. Write migration SQL
2. Test locally first
3. Run against Neon database
4. Verify application still works

### Backup Database

Neon automatically backs up:
- Free tier: 7-day retention
- Export manually: Use pg_dump if needed

---

## Support

- **Render Docs**: https://render.com/docs
- **Neon Docs**: https://neon.tech/docs
- **Supabase Docs**: https://supabase.com/docs
- **PaperWise Repo**: https://github.com/KRISHTI2503/PaperWise

---

## Testing Checklist

Before considering deployment complete, test:

- [ ] Health endpoint returns OK
- [ ] Login works (admin and student)
- [ ] Register new student account
- [ ] Admin can upload paper (PDF)
- [ ] Student can view paper list
- [ ] Student can view PDF inline
- [ ] Student can download PDF
- [ ] Student can vote on difficulty
- [ ] Student can mark paper as useful
- [ ] Admin can see paper requests
- [ ] Admin dashboard shows stats
- [ ] Student dashboard shows stats
- [ ] Notifications work
- [ ] File size limit enforced (20MB)
- [ ] Invalid file types rejected
