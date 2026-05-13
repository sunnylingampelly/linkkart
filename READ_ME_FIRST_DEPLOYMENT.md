# 🚀 READ THIS FIRST - Deployment Guide

## You asked: "database.php is not found when deploying"

## ✅ FIXED! Here's what I did:

---

## 📦 FILES CREATED FOR YOU

### 1. **backend/config/database.php** ⭐
   - Database configuration file
   - Required by hosting servers
   - Already created and ready to use

### 2. **backend/bootstrap/helpers.php** ⭐
   - Helper functions (env, config, etc.)
   - Required by some hosting providers
   - Already created and ready to use

### 3. **backend/public/.htaccess**
   - Apache rewrite rules
   - CORS headers
   - Create this if missing

### 4. **Complete Deployment Guides**
   - `LIVE_SERVER_DEPLOYMENT.md` - Full guide
   - `DEPLOYMENT_CHECKLIST.md` - Quick checklist
   - `DEPLOYMENT_SUMMARY.md` - Overview
   - `QUICK_FIX_DATABASE_PHP.md` - Quick fix guide

---

## 🎯 WHAT TO DO NOW

### Step 1: Push to Your Git Repo
```bash
git add .
git commit -m "Add database.php and deployment files"
git push origin main
```

### Step 2: Pull on Your Server
```bash
# SSH into your server
cd public_html
git pull origin main
```

**OR** upload these files manually via FTP/cPanel:
- `backend/config/database.php`
- `backend/bootstrap/helpers.php`

---

## ⚙️ CONFIGURATION NEEDED

### Update backend/.env on Server
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

DB_HOST=localhost
DB_DATABASE=your_database_name
DB_USERNAME=your_database_user
DB_PASSWORD=your_database_password

JWT_SECRET=change_this_to_random_string

FRONTEND_URL=https://yourdomain.com
STOREFRONT_URL=https://yourdomain.com/store
```

---

## 🗄️ DATABASE SETUP

### In cPanel → MySQL Databases:
1. Create database: `linkkart_db`
2. Create user: `linkkart_user`
3. Set strong password
4. Add user to database with ALL privileges

### In phpMyAdmin:
Import these SQL files:
1. `backend/database/migrations/create_users_table.sql`
2. `backend/database/migrations/create_subscription_tables.sql`
3. `backend/database/migrations/add_constraints_and_indexes.sql`

---

## 📁 SERVER FOLDER STRUCTURE

```
public_html/
├── api/                    ← backend/public/*
│   ├── api.php
│   ├── .htaccess          ⭐ Create if missing
│   └── storage/           ← symlink to ../backend/storage/app/public
├── backend/               ← backend/* (except public)
│   ├── .env              ⭐ Update with production DB
│   ├── config/
│   │   └── database.php  ⭐ NEW FILE - Already created
│   ├── bootstrap/
│   │   └── helpers.php   ⭐ NEW FILE - Already created
│   ├── lib/
│   └── storage/
├── store/                 ← storefront/build/*
└── admin/                 ← admin-dashboard/build/*
```

---

## 🔗 CREATE STORAGE SYMLINK

### Via SSH:
```bash
cd public_html/api
ln -s ../backend/storage/app/public storage
```

### Via cPanel File Manager:
1. Navigate to `public_html/api/`
2. Create symbolic link
3. Name: `storage`
4. Target: `../backend/storage/app/public`

---

## 🧪 TEST YOUR DEPLOYMENT

### Test 1: API Health
```
URL: https://yourdomain.com/api/health
Expected: {"success":true,"status":"healthy"}
```

### Test 2: Database Connection
```
URL: https://yourdomain.com/api/v1/stores
Expected: {"success":true,"data":[...]}
```

### Test 3: Storefront
```
URL: https://yourdomain.com/store
Expected: Homepage with stores
```

---

## 🐛 TROUBLESHOOTING

### Still getting "database.php not found"?

**Check 1**: File exists on server
```bash
ls -la public_html/backend/config/database.php
```

**Check 2**: Correct path
```
✅ Correct: public_html/backend/config/database.php
❌ Wrong:   public_html/config/database.php
```

**Check 3**: File uploaded
- If using Git: Did you push and pull?
- If using FTP: Did you upload the file?

### Database connection failed?

**Check 1**: .env credentials
```env
DB_HOST=localhost          ← Use localhost, not 127.0.0.1
DB_DATABASE=linkkart_db    ← Your actual database name
DB_USERNAME=linkkart_user  ← Your actual username
DB_PASSWORD=your_password  ← Your actual password
```

**Check 2**: Database exists
- Login to phpMyAdmin
- Check database is created
- Check user has privileges

### 500 Internal Server Error?

**Check 1**: .htaccess exists
```bash
ls -la public_html/api/.htaccess
```

**Check 2**: Enable error display
```env
# In backend/.env
APP_DEBUG=true
```

Then visit your API URL to see detailed errors.

---

## 📚 DETAILED GUIDES

For complete step-by-step instructions, read:

1. **LIVE_SERVER_DEPLOYMENT.md** - Complete deployment guide
2. **DEPLOYMENT_CHECKLIST.md** - Quick checklist
3. **QUICK_FIX_DATABASE_PHP.md** - Quick fix for database.php issue

---

## ✅ FINAL CHECKLIST

Before going live:

- [ ] `database.php` uploaded to `backend/config/`
- [ ] `helpers.php` uploaded to `backend/bootstrap/`
- [ ] `.env` updated with production database credentials
- [ ] Database created and tables imported
- [ ] Storage symlink created
- [ ] `.htaccess` files in place
- [ ] Storefront built with production API URL
- [ ] Admin built with production API URL
- [ ] API health check works
- [ ] Stores endpoint returns data
- [ ] Images load correctly

---

## 🎉 YOU'RE READY!

All files have been created. Now:

1. **Push to Git** or **Upload via FTP**
2. **Update .env** with production credentials
3. **Setup database** in cPanel
4. **Test API** endpoints
5. **Go live!** 🚀

---

## 📞 NEED HELP?

If you're still stuck:
1. Check cPanel error logs
2. Enable `APP_DEBUG=true` in `.env`
3. Test API: `curl https://yourdomain.com/api/health`
4. Verify all files uploaded correctly

---

**Status**: ✅ All Files Created - Ready to Deploy
**Date**: May 11, 2026
**Action**: Push to Git or Upload Files
