# 🌐 Live Server Deployment Guide - LinkKart

## Complete step-by-step guide for deploying to production server (cPanel, Hostinger, etc.)

---

## 📋 Prerequisites

- ✅ Live server with PHP 7.4+ and MySQL
- ✅ cPanel or similar hosting control panel
- ✅ Domain name (optional, can use server IP)
- ✅ FTP/SFTP access or File Manager
- ✅ SSH access (optional but recommended)

---

## 🚀 DEPLOYMENT STEPS

### STEP 1: Prepare Your Files

#### 1.1 Create .htaccess for Backend
Create `backend/public/.htaccess`:
```apache
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To api.php
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ api.php [L]
</IfModule>

# Disable directory browsing
Options -Indexes

# Enable CORS
<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With"
</IfModule>
```

#### 1.2 Update Backend .env for Production
Edit `backend/.env`:
```env
APP_NAME=LinkKart
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=your_database_name
DB_USERNAME=your_database_user
DB_PASSWORD=your_database_password

RAZORPAY_KEY_ID=rzp_test_SnZobCxSkQHK8T
RAZORPAY_KEY_SECRET=cBSLn082YWFL57LvUG5JFETM

JWT_SECRET=linkkart_luxury_secret_key_2024_production
JWT_TTL=86400

FRONTEND_URL=https://yourdomain.com
STOREFRONT_URL=https://yourdomain.com/store
```

---

### STEP 2: Upload Files to Server

#### Option A: Using cPanel File Manager

1. **Login to cPanel**
2. **Open File Manager**
3. **Navigate to public_html**
4. **Create folder structure**:
   ```
   public_html/
   ├── api/              (upload backend/public/* here)
   ├── store/            (upload storefront/build/* here)
   ├── admin/            (upload admin-dashboard/build/* here)
   └── backend/          (upload backend/* except public folder)
   ```

5. **Upload files**:
   - Upload `backend/public/*` to `public_html/api/`
   - Upload rest of `backend/*` to `public_html/backend/`
   - Upload storefront build to `public_html/store/`
   - Upload admin build to `public_html/admin/`

#### Option B: Using FTP (FileZilla)

1. **Connect to your server** via FTP
2. **Navigate to public_html**
3. **Upload files** as described above

#### Option C: Using Git (Recommended)

```bash
# SSH into your server
ssh user@yourserver.com

# Navigate to public_html
cd public_html

# Clone your repository
git clone https://github.com/sunnylingampelly/linkkart.git temp
mv temp/backend .
mv temp/storefront .
mv temp/admin-dashboard .
rm -rf temp

# Move backend public files to api folder
mkdir api
mv backend/public/* api/
```

---

### STEP 3: Setup Database

#### 3.1 Create Database in cPanel

1. **Login to cPanel**
2. **Go to MySQL Databases**
3. **Create New Database**: `linkkart_db`
4. **Create New User**: `linkkart_user`
5. **Set Password**: (strong password)
6. **Add User to Database** with ALL PRIVILEGES

#### 3.2 Import Database Schema

**Option A: Using phpMyAdmin**
1. Open phpMyAdmin from cPanel
2. Select your database
3. Click "Import"
4. Upload and execute these files in order:
   - `backend/database/migrations/create_users_table.sql`
   - `backend/database/migrations/2024_01_01_000001_create_stores_table.php` (copy SQL from file)
   - `backend/database/migrations/2024_01_01_000002_create_products_table.php`
   - `backend/database/migrations/2024_01_01_000003_create_analytics_events_table.php`
   - `backend/database/migrations/2024_01_01_000004_create_admins_table.php`
   - `backend/database/migrations/create_subscription_tables.sql`
   - `backend/database/migrations/add_constraints_and_indexes.sql`

**Option B: Using SSH**
```bash
# SSH into server
ssh user@yourserver.com

cd public_html/backend/database/migrations

# Import each file
mysql -u linkkart_user -p linkkart_db < create_users_table.sql
mysql -u linkkart_user -p linkkart_db < create_subscription_tables.sql
mysql -u linkkart_user -p linkkart_db < add_constraints_and_indexes.sql
```

---

### STEP 4: Configure Backend

#### 4.1 Update .env File on Server

Edit `public_html/backend/.env`:
```env
APP_URL=https://yourdomain.com

DB_HOST=localhost
DB_DATABASE=linkkart_db
DB_USERNAME=linkkart_user
DB_PASSWORD=your_actual_password

FRONTEND_URL=https://yourdomain.com
STOREFRONT_URL=https://yourdomain.com/store
```

#### 4.2 Create Storage Symlink

**Via SSH**:
```bash
cd public_html/api
ln -s ../backend/storage/app/public storage
```

**Via cPanel File Manager**:
1. Navigate to `public_html/api/`
2. Create folder named `storage`
3. Or use SSH (recommended)

#### 4.3 Set Permissions

**Via SSH**:
```bash
cd public_html
chmod -R 755 backend/storage
chmod -R 755 api/storage
chmod -R 755 backend/bootstrap/cache
```

**Via cPanel**:
1. Right-click folders
2. Change Permissions to 755

---

### STEP 5: Configure Storefront

#### 5.1 Build Storefront Locally

```bash
# On your local machine
cd storefront

# Update config for production
# Edit src/config.js
export const API_BASE_URL = 'https://yourdomain.com/api';

# Build
npm run build
```

#### 5.2 Upload Build to Server

Upload contents of `storefront/build/` to `public_html/store/`

#### 5.3 Create .htaccess for Storefront

Create `public_html/store/.htaccess`:
```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /store/
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteCond %{REQUEST_FILENAME} !-l
  RewriteRule . /store/index.html [L]
</IfModule>
```

---

### STEP 6: Configure Admin Dashboard

#### 6.1 Build Admin Dashboard Locally

```bash
# On your local machine
cd admin-dashboard

# Update .env for production
REACT_APP_API_BASE_URL=https://yourdomain.com/api

# Build
npm run build
```

#### 6.2 Upload Build to Server

Upload contents of `admin-dashboard/build/` to `public_html/admin/`

#### 6.3 Create .htaccess for Admin

Create `public_html/admin/.htaccess`:
```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /admin/
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteCond %{REQUEST_FILENAME} !-l
  RewriteRule . /admin/index.html [L]
</IfModule>
```

---

### STEP 7: Configure API Routing

#### 7.1 Main .htaccess in public_html

Create/Edit `public_html/.htaccess`:
```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    
    # API Routes
    RewriteCond %{REQUEST_URI} ^/api/
    RewriteRule ^api/(.*)$ api/api.php [L,QSA]
    
    # Storefront Routes
    RewriteCond %{REQUEST_URI} ^/store/
    RewriteRule ^store/(.*)$ store/$1 [L]
    
    # Admin Routes
    RewriteCond %{REQUEST_URI} ^/admin/
    RewriteRule ^admin/(.*)$ admin/$1 [L]
    
    # Default to storefront
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ store/$1 [L]
</IfModule>
```

---

### STEP 8: Test Deployment

#### 8.1 Test API
Visit: `https://yourdomain.com/api/health`
Expected: `{"success":true,"status":"healthy"}`

#### 8.2 Test Stores Endpoint
Visit: `https://yourdomain.com/api/v1/stores`
Expected: `{"success":true,"data":[...]}`

#### 8.3 Test Storefront
Visit: `https://yourdomain.com/store`
Should show: Homepage with stores

#### 8.4 Test Admin
Visit: `https://yourdomain.com/admin`
Should show: Login page

#### 8.5 Test Images
Visit: `https://yourdomain.com/api/storage/products/[image-name].jpg`
Should show: Product image

---

## 🐛 COMMON ISSUES & FIXES

### Issue 1: "database.php not found"

**Solution**: File already created at `backend/config/database.php`
Make sure it's uploaded to server at: `public_html/backend/config/database.php`

### Issue 2: "500 Internal Server Error"

**Check**:
1. `.htaccess` file exists in `public_html/api/`
2. `mod_rewrite` is enabled (ask hosting provider)
3. File permissions are correct (755 for folders, 644 for files)
4. Check error logs in cPanel

### Issue 3: "Database connection failed"

**Check**:
1. Database credentials in `.env` are correct
2. Database user has ALL PRIVILEGES
3. Database host is `localhost` (not 127.0.0.1)
4. Test connection via phpMyAdmin

### Issue 4: "Images not showing"

**Check**:
1. Storage symlink exists: `public_html/api/storage` → `../backend/storage/app/public`
2. Image files exist in `backend/storage/app/public/products/`
3. Permissions are 755 on storage folders
4. Test direct image URL

### Issue 5: "CORS errors"

**Solution**: Add to `backend/public/api.php` (already included):
```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
```

### Issue 6: "Storefront shows blank page"

**Check**:
1. Build was created with correct API URL
2. `.htaccess` exists in store folder
3. Check browser console for errors
4. Verify API is accessible

---

## 📁 FINAL FOLDER STRUCTURE ON SERVER

```
public_html/
├── .htaccess                          (main routing)
├── api/                               (backend public files)
│   ├── .htaccess                      (API routing)
│   ├── api.php                        (main API file)
│   ├── api_payments.php
│   ├── storage/                       (symlink to ../backend/storage/app/public)
│   └── ...
├── backend/                           (backend private files)
│   ├── .env                           (production config)
│   ├── config/
│   │   └── database.php               (database config)
│   ├── database/
│   ├── lib/
│   ├── storage/
│   │   └── app/
│   │       └── public/
│   │           ├── products/          (product images)
│   │           ├── logos/             (store logos)
│   │           └── stores/
│   └── ...
├── store/                             (storefront build)
│   ├── .htaccess                      (React routing)
│   ├── index.html
│   ├── static/
│   └── ...
└── admin/                             (admin dashboard build)
    ├── .htaccess                      (React routing)
    ├── index.html
    ├── static/
    └── ...
```

---

## 🔐 SECURITY CHECKLIST

- [ ] Set `APP_DEBUG=false` in production `.env`
- [ ] Use strong database password
- [ ] Change `JWT_SECRET` to unique value
- [ ] Set proper file permissions (755/644)
- [ ] Keep `.env` file outside public_html if possible
- [ ] Enable HTTPS/SSL certificate
- [ ] Disable directory listing
- [ ] Keep backend folder outside public_html (if possible)

---

## 🚀 QUICK DEPLOYMENT CHECKLIST

- [ ] Database created and imported
- [ ] `.env` file configured with production values
- [ ] `database.php` file exists in `backend/config/`
- [ ] Storage symlink created
- [ ] File permissions set (755/644)
- [ ] `.htaccess` files in place (main, api, store, admin)
- [ ] Storefront built with production API URL
- [ ] Admin built with production API URL
- [ ] All files uploaded to correct folders
- [ ] API health check works
- [ ] Stores endpoint returns data
- [ ] Images load correctly
- [ ] Storefront displays properly
- [ ] Admin dashboard accessible

---

## 📞 NEED HELP?

If you're still facing issues:

1. **Check error logs**: cPanel → Error Logs
2. **Test API directly**: `curl https://yourdomain.com/api/health`
3. **Verify database**: phpMyAdmin → check tables exist
4. **Check permissions**: All folders 755, files 644
5. **Enable error display temporarily**: `APP_DEBUG=true` in `.env`

---

**Status**: Production Ready
**Last Updated**: May 11, 2026
