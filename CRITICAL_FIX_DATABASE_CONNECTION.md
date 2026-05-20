# 🚨 CRITICAL FIX: Database Connection Issue

## Problem Identified

The product creation error is caused by **hardcoded database credentials** in the backend files. The production server cannot connect to the database because it's using default localhost credentials instead of your production database credentials.

## Root Cause

Both `backend/public/index.php` and `backend/public/api.php` were using hardcoded values:
```php
$host = 'localhost';
$dbname = 'linkkart';
$username = 'root';
$password = '';  // Empty password
```

These credentials work on local development but **fail on production servers** which have different database configurations.

## Fix Applied

✅ Updated both files to read from `.env` file:
```php
$host = $_ENV['DB_HOST'] ?? 'localhost';
$dbname = $_ENV['DB_DATABASE'] ?? 'linkkart';
$username = $_ENV['DB_USERNAME'] ?? 'root';
$password = $_ENV['DB_PASSWORD'] ?? '';
```

## What You Need to Do NOW

### Step 1: Update Production .env File

**SSH into your production server:**
```bash
ssh your_user@api.linkkart.shop
cd /path/to/backend
```

**Edit the .env file:**
```bash
nano .env
```

**Update with your ACTUAL production database credentials:**
```env
APP_NAME=LinkKart
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.linkkart.shop

# CRITICAL: Update these with your actual production database credentials
DB_CONNECTION=mysql
DB_HOST=localhost                    # or your database server IP
DB_PORT=3306
DB_DATABASE=linkkart                 # your actual database name
DB_USERNAME=your_actual_db_user      # your actual database username
DB_PASSWORD=your_actual_db_password  # your actual database password

# Razorpay (use production keys if available)
RAZORPAY_KEY_ID=rzp_test_SnZobCxSkQHK8T
RAZORPAY_KEY_SECRET=cBSLn082YWFL57LvUG5JFETM
TAX_RATE=0.00
WEBHOOK_SECRET=YOUR_WEBHOOK_SECRET

# JWT
JWT_SECRET=linkkart_production_secret_key_2024
JWT_TTL=86400

# Frontend URLs
FRONTEND_URL=https://admin.linkkart.shop
STOREFRONT_URL=https://linkkart.shop
```

**Save and exit** (Ctrl+X, then Y, then Enter)

### Step 2: Upload Updated Backend Files

You need to upload these updated files to your production server:
- `backend/public/index.php` (database connection now reads from .env)
- `backend/public/api.php` (database connection now reads from .env)

**Option A: Using FTP/SFTP**
1. Open FileZilla or your FTP client
2. Connect to api.linkkart.shop
3. Navigate to `/public_html/backend/public/` (or your backend path)
4. Upload `index.php` and `api.php` (overwrite existing files)

**Option B: Using SCP**
```bash
scp backend/public/index.php your_user@api.linkkart.shop:/path/to/backend/public/
scp backend/public/api.php your_user@api.linkkart.shop:/path/to/backend/public/
```

**Option C: Using Git**
```bash
# On your local machine
git add backend/public/index.php backend/public/api.php
git commit -m "Fix: Read database credentials from .env file"
git push origin main

# On production server
ssh your_user@api.linkkart.shop
cd /path/to/backend
git pull origin main
```

### Step 3: Verify Database Connection

**Test the connection:**
```bash
curl https://api.linkkart.shop/api/health
```

**Expected response:**
```json
{
  "success": true,
  "message": "LinkKart API is running with MySQL",
  "version": "1.0.0",
  "database": "Connected",
  "timestamp": "2024-..."
}
```

**If you get an error**, it will now show the actual database configuration:
```json
{
  "success": false,
  "message": "Database connection failed",
  "error": "SQLSTATE[HY000] [1045] Access denied...",
  "config": {
    "host": "localhost",
    "database": "linkkart",
    "user": "root"
  }
}
```

### Step 4: Run Diagnostic Script

```bash
curl https://api.linkkart.shop/test_product_creation.php
```

This will test:
- ✅ Database connection
- ✅ Products table exists
- ✅ Table structure is correct
- ✅ Stores exist
- ✅ Test product insertion
- ✅ Storage directory permissions

### Step 5: Test Product Creation

Once the database connection is working:

1. **Open mobile app**
2. **Go to Products tab**
3. **Click "Add Product"**
4. **Fill in details:**
   - Name: Test Product
   - Price: 500
   - Stock: 69
   - Description: Gym wear
5. **Click Save**

**Expected result:** ✅ Product created successfully

## How to Find Your Database Credentials

If you don't know your production database credentials:

### Method 1: Check cPanel/Hosting Panel
1. Log into your hosting control panel (cPanel, Plesk, etc.)
2. Go to "MySQL Databases" or "Database Management"
3. Find your database name and username
4. Reset password if needed

### Method 2: Check phpMyAdmin
1. Log into phpMyAdmin
2. Look at the top - it shows your username
3. Database name is in the left sidebar

### Method 3: Contact Hosting Provider
If you're using shared hosting, contact support and ask for:
- Database host (usually `localhost`)
- Database name
- Database username
- Database password

### Method 4: Check Existing Config Files
Look for other config files on your server:
```bash
grep -r "DB_HOST" /path/to/your/website/
grep -r "DB_PASSWORD" /path/to/your/website/
```

## Common Database Hosts

- **Shared Hosting**: `localhost`
- **VPS/Dedicated**: `localhost` or `127.0.0.1`
- **Remote Database**: `db.yourdomain.com` or IP address
- **Cloud Database**: Specific hostname from provider

## Security Notes

⚠️ **IMPORTANT:**
1. Never commit `.env` file to Git (it's in `.gitignore`)
2. Use strong database passwords in production
3. Set `APP_DEBUG=false` in production
4. Change `JWT_SECRET` to a unique value
5. Use Razorpay **live keys** (not test keys) in production

## Troubleshooting

### Error: "Access denied for user"
- Wrong username or password in `.env`
- Database user doesn't have permissions
- Solution: Update credentials or grant permissions

### Error: "Unknown database"
- Database name is wrong in `.env`
- Database doesn't exist
- Solution: Create database or fix name

### Error: "Can't connect to MySQL server"
- Wrong host in `.env`
- MySQL server is down
- Firewall blocking connection
- Solution: Check host, restart MySQL, check firewall

### Error: "SQLSTATE[HY000] [2002]"
- MySQL server not running
- Wrong port number
- Solution: Start MySQL, check port (usually 3306)

## Files Changed

1. ✅ `backend/public/index.php` - Now reads from .env
2. ✅ `backend/public/api.php` - Now reads from .env
3. ✅ `backend/public/test_product_creation.php` - New diagnostic script
4. ✅ `backend/.env.production` - Production template

## Next Steps After Fix

Once database connection is working:

1. ✅ Test product creation in mobile app
2. ✅ Test store creation
3. ✅ Test subscription plans
4. ✅ Test analytics tracking
5. ✅ Test storefront display

## Quick Test Commands

```bash
# Test API health
curl https://api.linkkart.shop/api/health

# Test database diagnostic
curl https://api.linkkart.shop/test_product_creation.php

# Test product creation (replace with actual store_id)
curl -X POST https://api.linkkart.shop/api/v1/seller/products \
  -F "store_id=1" \
  -F "name=Test Product" \
  -F "price=99.99" \
  -F "stock_quantity=10"
```

---

## Summary

**Problem**: Hardcoded database credentials causing connection failure
**Solution**: Read credentials from `.env` file
**Action Required**: Update production `.env` with actual database credentials
**Priority**: 🚨 CRITICAL - Blocking all database operations
**ETA**: 5 minutes to fix once you have the correct credentials

**Status**: Code fixed, waiting for production .env update
