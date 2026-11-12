# PaperWise Pre-Deployment Checklist

Use this checklist before pushing to GitHub and deploying to Render.

---

## 🚨 CRITICAL SECURITY ACTIONS

- [ ] **Revoke Firebase Key** (MUST DO FIRST)
  - Go to Firebase Console: https://console.firebase.google.com
  - Navigate to: Settings → Service Accounts
  - Find key ID: `e07d4c5551f8547fd55cb94fde2c6819d736399c`
  - Click "..." → Delete/Revoke
  - **This key was exposed in git history and MUST be revoked**

- [ ] **Revoke Old Gmail App Password** (if used)
  - Go to Google Account: https://myaccount.google.com/apppasswords
  - Find "Brevo SMTP" or similar
  - Revoke access

---

## Repository Preparation

### Verify No Secrets in Code
- [ ] Run: `git grep -i "password" | grep -v "password_hash\|getPassword\|setPassword\|bcrypt"`
- [ ] Run: `git grep -i "private_key"`
- [ ] Run: `git grep -i "api.?key" | grep -v "SUPABASE_KEY\|apikey"`
- [ ] Confirm NO actual secrets found (only variable names)

### Verify .gitignore Working
- [ ] Check: `git status`
- [ ] Confirm these are NOT tracked:
  - `build/` folder
  - `dist/` folder
  - `.env` file
  - `uploads/` folder
  - `*.log` files
  - `*.war` files

### Verify Required Files Present
- [ ] `Dockerfile` exists
- [ ] `docker-entrypoint.sh` exists (must be executable)
- [ ] `render.yaml` exists
- [ ] `database/schema.sql` exists
- [ ] `DEPLOYMENT.md` exists
- [ ] `README.md` updated
- [ ] `.env.example` exists

---

## Neon Postgres Setup

- [ ] Created Neon account at https://neon.tech
- [ ] Created project named `paperwise-db`
- [ ] Selected region (choose closest to your users)
- [ ] Saved connection string with `?sslmode=require`
- [ ] Connected to database (psql or SQL Editor)
- [ ] Ran `database/schema.sql` successfully
- [ ] Generated bcrypt hash for password `admin123` at https://bcrypt-generator.com/
- [ ] Updated admin user:
  ```sql
  UPDATE users SET password = '<your-bcrypt-hash>' WHERE username = 'admin';
  ```
- [ ] Verified admin user exists:
  ```sql
  SELECT username, role FROM users WHERE username = 'admin';
  ```

### Credentials to Save
```
JDBC_URL: jdbc:postgresql://_____.neon.tech:5432/_____?sslmode=require
JDBC_USERNAME: _____
JDBC_PASSWORD: _____
```

---

## Supabase Storage Setup

- [ ] Created Supabase account at https://supabase.com
- [ ] Created project named `paperwise-storage`
- [ ] Selected same region as Neon
- [ ] Created storage bucket:
  - Name: `paperwise-files`
  - **IMPORTANT**: Set to **PRIVATE** (not public)
- [ ] Verified bucket appears in Storage dashboard
- [ ] Copied Project URL from Settings → API
- [ ] Copied **service_role** key from Settings → API (NOT anon key - server-side only)

### Credentials to Save
```
SUPABASE_URL: https://_____.supabase.co
SUPABASE_KEY: eyJhbGc_____ (service_role key)
SUPABASE_BUCKET: paperwise-files
```

---

## GitHub Repository

- [ ] Repository exists: https://github.com/KRISHTI2503/PaperWise
- [ ] Repository is empty or ready for first push
- [ ] You have push access

### First Push
```bash
cd "C:\Users\krish\OneDrive\Pictures\Documents\NetBeansProjects\PaperWise_AJT"

# Initialize git (if not already done)
git init

# Add all files
git add .

# Verify no secrets are staged
git status

# Commit
git commit -m "Initial commit - PaperWise deployment ready"

# Add remote
git remote add origin https://github.com/KRISHTI2503/PaperWise.git

# Push to GitHub
git push -u origin main
```

---

## Render Deployment

### Connect Repository
- [ ] Logged in to https://render.com
- [ ] Clicked "New +" → "Web Service"
- [ ] Connected GitHub account
- [ ] Selected repository: `KRISHTI2503/PaperWise`
- [ ] Confirmed Dockerfile is detected

### Configure Service
- [ ] Name: `paperwise`
- [ ] Branch: `main` (or your branch)
- [ ] Runtime: **Docker**
- [ ] Plan: **Free**
- [ ] Health Check Path: `/health`

### Environment Variables
Add these in Render Dashboard → Environment tab:

**Database Variables** (mark all as SECRET):
- [ ] `JDBC_URL` = `jdbc:postgresql://_____.neon.tech:5432/_____?sslmode=require` ✓ Secret
- [ ] `JDBC_USERNAME` = Your Neon username ✓ Secret
- [ ] `JDBC_PASSWORD` = Your Neon password ✓ Secret

**Supabase Variables** (mark all as SECRET):
- [ ] `SUPABASE_URL` = `https://_____.supabase.co` ✓ Secret
- [ ] `SUPABASE_KEY` = Your service_role key (server-side only) ✓ Secret
- [ ] `SUPABASE_BUCKET` = `paperwise-files` (NOT secret)

**App Configuration**:
- [ ] `APP_ENV` = `production` (NOT secret)

### Deploy
- [ ] Clicked "Create Web Service"
- [ ] Monitoring build logs (first build takes 5-10 minutes)
- [ ] Build completed successfully
- [ ] Health checks passing
- [ ] Service URL noted: `https://paperwise.onrender.com`

---

## Post-Deployment Testing

### Basic Health
- [ ] Open `https://paperwise.onrender.com/health` → Returns "OK"
- [ ] Open `https://paperwise.onrender.com` → Login page loads
- [ ] No errors in Render logs
- [ ] No `${...}` placeholders in logs

### Admin Login
- [ ] Login with username: `admin`
- [ ] Password: Your chosen password
- [ ] Dashboard loads successfully
- [ ] Stats show 0 papers, 0 students initially

### Upload Test
- [ ] Navigate to "Upload Paper"
- [ ] Fill form:
  - Subject Name: Test Paper
  - Subject Code: TEST101
  - Year: 2024
  - File: Upload a PDF (max 20MB)
- [ ] Upload succeeds
- [ ] File appears in paper list
- [ ] Check Supabase dashboard → Storage → paperwise-files → File is there

### View Test
- [ ] Click "View" on uploaded paper
- [ ] PDF opens inline in browser
- [ ] No errors

### Download Test
- [ ] Click "Download" on paper
- [ ] Browser prompts to download
- [ ] Downloaded file opens correctly

### Student Registration
- [ ] Click "Register" on login page
- [ ] Create new student account
- [ ] Login as student
- [ ] Student dashboard loads

### Student Features
- [ ] Browse papers (test paper visible)
- [ ] View paper inline
- [ ] Download paper
- [ ] Vote on difficulty
- [ ] Mark paper as useful
- [ ] Request a paper
- [ ] Check notifications

### Admin Features
- [ ] View paper requests (as admin)
- [ ] Respond to request
- [ ] Check notifications working
- [ ] Verify stats update

---

## Troubleshooting

### Build Fails
- Check Render build logs for specific error
- Verify `build.xml` is present
- Ensure all Java files compile locally

### "Unresolved placeholder" Error
- Check Render environment variables are set
- Verify all 7 variables are present
- Confirm variable names match exactly
- Check `docker-entrypoint.sh` is executable

### Database Connection Error
- Verify `JDBC_URL` includes `?sslmode=require`
- Check Neon database is not paused (wake it up)
- Confirm credentials are correct
- Test connection locally first

### File Upload Fails
- Check Supabase credentials
- Verify bucket name is correct: `paperwise-files`
- Confirm bucket is PRIVATE
- Check Render logs for Supabase errors

### 503 Service Unavailable
- Service may be starting (wait 30 seconds)
- Check Render logs for startup errors
- Free tier may have cold start delay

---

## Success Criteria

You can consider deployment successful when:

✅ Health endpoint returns "OK"
✅ Login page loads
✅ Admin can login
✅ Admin can upload PDF
✅ File appears in Supabase Storage
✅ Student can register
✅ Student can view papers
✅ Student can download papers
✅ Voting works
✅ Notifications work
✅ No errors in Render logs
✅ No `${...}` placeholders in logs

---

## Emergency Rollback

If deployment fails catastrophically:

1. Go to Render Dashboard → Your Service
2. Click "Manual Deploy" dropdown
3. Select previous successful deploy
4. Or: Delete service and start over

Your data is safe in Neon Postgres.

---

## Support

- See `DEPLOYMENT.md` for detailed instructions
- Check Render logs for errors
- Neon docs: https://neon.tech/docs
- Supabase docs: https://supabase.com/docs
- Render docs: https://render.com/docs

---

**Last Updated**: November 9, 2026
**Status**: Ready for deployment
