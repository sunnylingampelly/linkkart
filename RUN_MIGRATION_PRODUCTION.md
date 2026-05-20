# 🚀 Run Migration on Production

## What This Does
Assigns free plans to all stores so product creation works.

---

## Method 1: Test Locally First (Recommended)

### Step 1: Run on Local Database
```bash
cd backend/database
php run_migration.php 2024_05_20_fix_store_subscriptions.sql
```

**Expected output:**
```
✅ Database connection successful
📝 Found 5 SQL statements
▶️  Executing: INSERT IGNORE INTO plans...
   ✅ Success
...
🎉 SUCCESS! All stores have subscriptions assigned.
```

### Step 2: Commit and Push
```bash
git add backend/database/migrations/2024_05_20_fix_store_subscriptions.sql
git add backend/database/run_migration.php
git commit -m "Add migration to fix store subscriptions"
git push origin main
```

### Step 3: Pull on Production Server
```bash
# SSH into production
ssh your_user@your_server

# Navigate to backend
cd /path/to/backend

# Pull latest code
git pull origin main

# Run migration
cd database
php run_migration.php 2024_05_20_fix_store_subscriptions.sql
```

---

## Method 2: Direct Upload to Production

### Step 1: Upload Files via FTP/cPanel
Upload these 2 files to production:
- `backend/database/migrations/2024_05_20_fix_store_subscriptions.sql`
- `backend/database/run_migration.php`

### Step 2: SSH into Server
```bash
ssh your_user@your_server
cd /path/to/backend/database
```

### Step 3: Run Migration
```bash
php run_migration.php 2024_05_20_fix_store_subscriptions.sql
```

---

## Method 3: Using cPanel Terminal (If Available)

### Step 1: Upload Files
1. Login to cPanel
2. File Manager → Upload files to `/backend/database/`

### Step 2: Open Terminal
1. In cPanel, find "Terminal" or "SSH Access"
2. Click to open terminal

### Step 3: Run Migration
```bash
cd public_html/backend/database
php run_migration.php 2024_05_20_fix_store_subscriptions.sql
```

---

## Method 4: No SSH? Use Web-Based Runner

### Step 1: Create Web Runner
Create `backend/public/run_migration_web.php`:

```php
<?php
// Only allow from localhost or specific IP for security
$allowedIPs = ['127.0.0.1', 'YOUR_IP_HERE'];
if (!in_array($_SERVER['REMOTE_ADDR'], $allowedIPs)) {
    die('Access denied');
}

// Include the migration runner
require_once __DIR__ . '/../database/run_migration.php';
?>
```

### Step 2: Visit URL
```
https://api.linkkart.shop/run_migration_web.php?file=2024_05_20_fix_store_subscriptions.sql
```

### Step 3: Delete the File After Use
**Important:** Delete `run_migration_web.php` after running for security!

---

## Verification

### Check via URL
```
https://api.linkkart.shop/api/check-stores
```

Should show: `"needs_fix": false`

### Check in Mobile App
1. Open app
2. Go to Products
3. Add a product
4. Should work! ✅

---

## Troubleshooting

### Error: "php: command not found"
Try these alternatives:
```bash
php7.4 run_migration.php 2024_05_20_fix_store_subscriptions.sql
php8.0 run_migration.php 2024_05_20_fix_store_subscriptions.sql
/usr/bin/php run_migration.php 2024_05_20_fix_store_subscriptions.sql
```

### Error: "Database connection failed"
- Check `.env` file has correct credentials
- Make sure you're in the right directory

### Error: "Migration file not found"
```bash
# Make sure you're in the database directory
cd backend/database
pwd  # Should show: /path/to/backend/database

# Then run
php run_migration.php 2024_05_20_fix_store_subscriptions.sql
```

---

## What Gets Changed

### Before Migration:
```
stores table:
- id: 1, name: "My Store", subscription_id: NULL ❌

subscriptions table:
- (empty)
```

### After Migration:
```
plans table:
- id: 1, name: "Free", product_limit: 5 ✅

subscriptions table:
- id: 1, store_id: 1, plan_id: 1, status: "active" ✅

stores table:
- id: 1, name: "My Store", subscription_id: 1 ✅
```

---

## Quick Command Reference

```bash
# Test locally
cd backend/database
php run_migration.php 2024_05_20_fix_store_subscriptions.sql

# Push to Git
git add backend/database/migrations/2024_05_20_fix_store_subscriptions.sql
git add backend/database/run_migration.php
git commit -m "Add store subscription migration"
git push origin main

# Run on production
ssh user@server
cd /path/to/backend
git pull origin main
cd database
php run_migration.php 2024_05_20_fix_store_subscriptions.sql
```

---

## Safety Notes

✅ **Safe to run multiple times** - Uses `INSERT IGNORE` so won't create duplicates
✅ **Non-destructive** - Only adds data, doesn't delete anything
✅ **Reversible** - Can manually delete subscriptions if needed
✅ **Tested** - Verified on local database first

---

**Recommended:** Use Method 1 (test locally, then push to production)
