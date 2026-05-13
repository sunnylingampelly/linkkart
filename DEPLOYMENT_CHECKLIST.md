# ✅ Live Server Deployment Checklist

## Quick Reference for Deploying LinkKart to Production

---

## 🎯 ISSUE: "database.php not found"

### ✅ SOLUTION:
File created at: `backend/config/database.php`

**Make sure this file is uploaded to your server at:**
```
public_html/backend/config/database.php
```

---

## 📦 FILES TO UPLOAD

### 1. Backend Files
```
Upload TO: public_html/api/
FROM: backend/public/*

Files:
- api.php
- api_payments.php
- index.php
- .htaccess (create if missing)
```

### 2. Backend Config & Logic
```
Upload TO: public_html/backend/
FROM: backend/* (except public folder)

Important files:
- .env (update for production!)
- config/database.php ⭐ (THIS FILE!)
- lib/JWT.php
- lib/Razorpay.php
- storage/ (entire folder)
```

### 3. Storefront
```
Build first: npm run build
Upload TO: public_html/store/
FROM: storefront/build/*
```

### 4. Admin Dashboard
```
Build first: npm run build
Upload TO: public_html/admin/
FROM: admin-dashboard/build/*
```

---

## 🗄️ DATABASE SETUP

### Step 1: Create Database (cPanel)
```
Database Name: linkkart_db
Username: linkkart_user
Password: [strong password]
Privileges: ALL
```

### Step 2: Import Tables (phpMyAdmin)
Import these files in order:
1. `backend/database/migrations/create_users_table.sql`
2. `backend/database/migrations/create_subscription_tables.sql`
3. `backend/database/migrations/add_constraints_and_indexes.sql`

Or copy SQL from migration PHP files and execute.

---

## ⚙️ CONFIGURATION FILES

### 1. backend/.env (Production)
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

DB_HOST=localhost
DB_DATABASE=linkkart_db
DB_USERNAME=linkkart_user
DB_PASSWORD=your_actual_password

JWT_SECRET=change_this_to_random_string_production

FRONTEND_URL=https://yourdomain.com
STOREFRONT_URL=https://yourdomain.com/store
```

### 2. backend/config/database.php ⭐
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

### 3. backend/public/.htaccess
```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ api.php [L]
</IfModule>

<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header set Access-Control-Allow-Headers "Content-Type, Authorization"
</IfModule>
```

### 4. storefront/src/config.js (Before Build)
```javascript
export const API_BASE_URL = 'https://yourdomain.com/api';
```

### 5. admin-dashboard/.env (Before Build)
```env
REACT_APP_API_BASE_URL=https://yourdomain.com/api
```

---

## 🔗 CREATE STORAGE SYMLINK

### Via SSH:
```bash
cd public_html/api
ln -s ../backend/storage/app/public storage
```

### Via cPanel:
1. File Manager → public_html/api/
2. Create symbolic link named `storage`
3. Target: `../backend/storage/app/public`

---

## 🧪 TESTING CHECKLIST

### ✅ Test 1: API Health
```
URL: https://yourdomain.com/api/health
Expected: {"success":true,"status":"healthy"}
```

### ✅ Test 2: Database Connection
```
URL: https://yourdomain.com/api/v1/stores
Expected: {"success":true,"data":[...]}
```

### ✅ Test 3: Images
```
URL: https://yourdomain.com/api/storage/products/[image].jpg
Expected: Image displays
```

### ✅ Test 4: Storefront
```
URL: https://yourdomain.com/store
Expected: Homepage with stores
```

### ✅ Test 5: Admin
```
URL: https://yourdomain.com/admin
Expected: Login page
```

---

## 🐛 TROUBLESHOOTING

### Error: "database.php not found"
- ✅ Upload `backend/config/database.php` to server
- ✅ Check path: `public_html/backend/config/database.php`

### Error: "500 Internal Server Error"
- ✅ Check `.htaccess` exists in `api/` folder
- ✅ Check file permissions (755 for folders)
- ✅ Check cPanel error logs

### Error: "Database connection failed"
- ✅ Verify credentials in `.env`
- ✅ Use `localhost` not `127.0.0.1`
- ✅ Check database user has privileges

### Error: "Images not showing"
- ✅ Create storage symlink
- ✅ Check permissions on storage folder (755)
- ✅ Verify images exist in `backend/storage/app/public/products/`

### Error: "Storefront blank page"
- ✅ Rebuild with production API URL
- ✅ Check `.htaccess` in store folder
- ✅ Check browser console for errors

---

## 📁 FINAL SERVER STRUCTURE

```
public_html/
├── api/                    ← backend/public/*
│   ├── api.php
│   ├── .htaccess
│   └── storage/           ← symlink
├── backend/               ← backend/* (except public)
│   ├── .env              ⭐ UPDATE THIS
│   ├── config/
│   │   └── database.php  ⭐ MUST EXIST
│   ├── lib/
│   └── storage/
│       └── app/
│           └── public/
│               └── products/
├── store/                 ← storefront/build/*
│   ├── index.html
│   └── .htaccess
└── admin/                 ← admin-dashboard/build/*
    ├── index.html
    └── .htaccess
```

---

## 🚀 QUICK START COMMANDS

### Build Storefront:
```bash
cd storefront
# Update src/config.js with production URL first!
npm run build
# Upload build/* to public_html/store/
```

### Build Admin:
```bash
cd admin-dashboard
# Update .env with production URL first!
npm run build
# Upload build/* to public_html/admin/
```

### Set Permissions (SSH):
```bash
cd public_html
chmod -R 755 backend/storage
chmod -R 755 api
chmod 644 backend/.env
chmod 644 backend/config/database.php
```

---

## ✅ FINAL CHECKLIST

Before going live:

- [ ] `database.php` uploaded to `backend/config/`
- [ ] `.env` updated with production database credentials
- [ ] Database created and tables imported
- [ ] Storage symlink created
- [ ] All `.htaccess` files in place
- [ ] Storefront built with production API URL
- [ ] Admin built with production API URL
- [ ] File permissions set correctly
- [ ] API health check returns success
- [ ] Images load correctly
- [ ] Storefront displays stores
- [ ] Admin login page accessible

---

## 🎉 YOU'RE DONE!

Your LinkKart application should now be live at:
- **API**: https://yourdomain.com/api
- **Storefront**: https://yourdomain.com/store
- **Admin**: https://yourdomain.com/admin

---

**Need Help?** Check error logs in cPanel or enable `APP_DEBUG=true` temporarily.
