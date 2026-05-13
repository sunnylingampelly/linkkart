# ⚡ QUICK FIX: "database.php not found"

## ✅ SOLUTION - File Already Created!

The file `backend/config/database.php` has been created for you.

---

## 📦 WHAT TO DO NOW

### Option 1: Push to Git (Recommended)
```bash
# Add the new files
git add backend/config/database.php
git add backend/bootstrap/helpers.php
git add backend/public/.htaccess

# Commit
git commit -m "Add database.php and deployment files"

# Push to your repo
git push origin main
```

### Option 2: Upload Manually
If you're deploying via FTP/cPanel:

1. **Upload these files to your server**:
   ```
   backend/config/database.php       → public_html/backend/config/database.php
   backend/bootstrap/helpers.php     → public_html/backend/bootstrap/helpers.php
   ```

2. **Verify the files exist on server**:
   ```
   public_html/
   └── backend/
       ├── config/
       │   └── database.php     ✅ MUST EXIST
       └── bootstrap/
           └── helpers.php      ✅ MUST EXIST
   ```

---

## 🔧 WHAT IS database.php?

This file tells your application how to connect to the database.

**Content** (already created for you):
```php
<?php
return [
    'default' => 'mysql',
    'connections' => [
        'mysql' => [
            'driver' => 'mysql',
            'host' => env('DB_HOST', 'localhost'),
            'database' => env('DB_DATABASE', 'linkkart'),
            'username' => env('DB_USERNAME', 'root'),
            'password' => env('DB_PASSWORD', ''),
            'charset' => 'utf8mb4',
            'collation' => 'utf8mb4_unicode_ci',
        ],
    ],
];
```

It reads values from your `.env` file.

---

## ⚙️ UPDATE YOUR .env FILE

Make sure `backend/.env` has correct database credentials:

```env
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=your_database_name
DB_USERNAME=your_database_user
DB_PASSWORD=your_database_password
```

**For cPanel/Hostinger**:
- DB_HOST is usually `localhost`
- Database name format: `username_dbname`
- Username format: `username_dbuser`

---

## 🧪 TEST IT WORKS

### Test 1: Check File Exists
```bash
# On your server (via SSH)
ls -la public_html/backend/config/database.php

# Should show the file
```

### Test 2: Test API
```bash
# Visit in browser or curl
https://yourdomain.com/api/health

# Expected response:
{"success":true,"status":"healthy","timestamp":...}
```

### Test 3: Test Database Connection
```bash
# Visit in browser
https://yourdomain.com/api/v1/stores

# Expected response:
{"success":true,"data":[...],"count":...}
```

---

## 🐛 STILL GETTING ERROR?

### Check 1: File Path
```
✅ Correct: public_html/backend/config/database.php
❌ Wrong:   public_html/config/database.php
❌ Wrong:   public_html/api/config/database.php
```

### Check 2: File Permissions
```bash
# Via SSH
chmod 644 public_html/backend/config/database.php
```

### Check 3: .env File
```bash
# Make sure .env exists
ls -la public_html/backend/.env

# Should show the file
```

### Check 4: PHP Version
Your server needs PHP 7.4 or higher.
Check in cPanel → Select PHP Version

---

## 📁 COMPLETE FILE STRUCTURE

Your server should have:
```
public_html/
├── api/                              (backend public files)
│   ├── api.php
│   ├── api_payments.php
│   ├── .htaccess
│   └── storage/                      (symlink)
├── backend/                          (backend private files)
│   ├── .env                          ⭐ Database credentials here
│   ├── config/
│   │   └── database.php              ⭐ THIS FILE
│   ├── bootstrap/
│   │   └── helpers.php               ⭐ Helper functions
│   ├── lib/
│   │   ├── JWT.php
│   │   └── Razorpay.php
│   └── storage/
│       └── app/
│           └── public/
│               └── products/
├── store/                            (storefront)
│   └── index.html
└── admin/                            (admin dashboard)
    └── index.html
```

---

## ✅ CHECKLIST

- [ ] `database.php` file uploaded to `backend/config/`
- [ ] `helpers.php` file uploaded to `backend/bootstrap/`
- [ ] `.env` file has correct database credentials
- [ ] Database created in cPanel
- [ ] Database user has ALL privileges
- [ ] Tables imported via phpMyAdmin
- [ ] API health check returns success

---

## 🎯 NEXT STEPS

1. **Push to Git** or **Upload files manually**
2. **Update .env** with production database credentials
3. **Test API**: Visit `https://yourdomain.com/api/health`
4. **Done!** Your app should work now

---

## 📞 STILL STUCK?

Enable error display to see what's wrong:

Edit `backend/.env`:
```env
APP_DEBUG=true
```

Then visit your API URL and you'll see detailed error messages.

**Remember to set it back to `false` after fixing!**

---

**Status**: ✅ Files Created - Ready to Deploy
**Action Required**: Upload files or push to Git
