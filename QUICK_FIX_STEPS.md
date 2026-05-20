# 🚀 Quick Fix Steps - Product Creation Error

## The Problem
Product creation failing with "DATABASE_ERROR" because backend is using hardcoded database credentials instead of reading from production `.env` file.

## The Solution (3 Steps)

### Step 1: Check Your Database Configuration
Visit this URL in your browser:
```
https://api.linkkart.shop/api/check-db
```

This will show you:
- ✅ If .env file exists
- ✅ Current database settings
- ✅ If database connection works
- ✅ Which tables exist
- ✅ What needs to be fixed

### Step 2: Update Production .env File

**On your production server**, edit the `.env` file:

```bash
# SSH into server
ssh your_user@your_server

# Navigate to backend folder
cd /path/to/backend

# Edit .env file
nano .env
```

**Update these lines with your ACTUAL database credentials:**
```env
DB_HOST=localhost
DB_DATABASE=linkkart
DB_USERNAME=your_actual_username
DB_PASSWORD=your_actual_password
```

**Save and exit** (Ctrl+X, Y, Enter)

### Step 3: Upload Fixed Backend Files

Upload these 2 files to your production server:
- `backend/public/index.php`
- `backend/public/api.php`

**Using FileZilla/FTP:**
1. Connect to your server
2. Go to `/public_html/backend/public/` (or your path)
3. Upload both files (overwrite existing)

**Or using Git:**
```bash
# On local machine
git add backend/public/index.php backend/public/api.php
git commit -m "Fix database connection"
git push

# On production server
cd /path/to/backend
git pull
```

## Test It Works

### Test 1: API Health Check
```
https://api.linkkart.shop/api/health
```
Should return: `"database": "Connected"`

### Test 2: Diagnostic Script
```
https://api.linkkart.shop/api/test-product
```
Should return: `"overall_status": "ALL_CHECKS_PASSED"`

### Test 3: Mobile App
1. Open app
2. Go to Products
3. Add a product
4. Should work! ✅

## Don't Know Your Database Credentials?

### Option 1: Check cPanel
1. Login to cPanel
2. Go to "MySQL Databases"
3. Find your database name and username
4. Reset password if needed

### Option 2: Check Hosting Panel
Look for "Database Management" or "phpMyAdmin" in your hosting control panel

### Option 3: Contact Support
Ask your hosting provider for:
- Database host (usually `localhost`)
- Database name
- Database username  
- Database password

## Files Changed
1. ✅ `backend/public/index.php` - Now reads from .env
2. ✅ `backend/public/api.php` - Now reads from .env
3. ✅ `backend/public/check_db_config.php` - New diagnostic tool
4. ✅ `backend/public/test_product_creation.php` - New test script

## Need Help?

Run the diagnostic URL and share the output:
```
https://api.linkkart.shop/api/check-db
```

---

**Time to fix:** 5-10 minutes
**Priority:** 🚨 CRITICAL
**Status:** Code ready, needs production .env update
