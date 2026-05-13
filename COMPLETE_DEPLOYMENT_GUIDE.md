# 🚀 Complete LinkKart Deployment Guide

## Issues Fixed in This Guide:
1. ✅ Images not showing in mobile app
2. ✅ Images not showing in storefront
3. ✅ Stores not loading in storefront
4. ✅ Complete deployment steps

---

## 🔧 ISSUE 1: Images Not Showing - ROOT CAUSE

### Problem:
Images are stored in `backend/storage/app/public/products/` but:
- Backend API serves from `backend/public/storage/` (symlink missing)
- Image paths in database are relative: `/storage/products/image.jpg`
- Full URL needed: `http://192.168.1.22:8000/storage/products/image.jpg`

### Solution:

#### Step 1: Create Storage Symlink
```bash
cd backend/public
# On Windows
mklink /D storage ..\storage\app\public

# On Linux/Mac
ln -s ../storage/app/public storage
```

#### Step 2: Verify Images Exist
```bash
cd backend
ls storage/app/public/products/
# Should show: 69f8cb223f45d.jpg, 69fa149900974.jpg, etc.
```

#### Step 3: Test Image URL
Open browser: `http://192.168.1.22:8000/storage/products/69f8cb223f45d.jpg`
- Should display the image
- If 404, symlink is missing

---

## 🔧 ISSUE 2: Storefront Not Loading Stores

### Problem:
- Storefront tries `http://localhost:8000` but backend runs on `192.168.1.22:8000`
- CORS might be blocking requests
- API endpoint mismatch

### Solution:

#### Update Storefront Config
Edit `storefront/src/config.js`:
```javascript
// REPLACE THIS:
export const API_BASE_URL = currentHost === 'localhost' || currentHost === '127.0.0.1' 
  ? `http://${currentHost}:${apiPort}` 
  : `http://${currentHost}:${apiPort}`;

// WITH THIS (use your actual IP):
export const API_BASE_URL = 'http://192.168.1.22:8000';
```

#### Update Storefront .env
Edit `storefront/.env`:
```env
REACT_APP_API_BASE_URL=http://192.168.1.22:8000
REACT_APP_RAZORPAY_KEY_ID=rzp_test_SnZobCxSkQHK8T
```

---

## 📦 COMPLETE DEPLOYMENT STEPS

### Prerequisites:
- ✅ PHP 7.4+ installed
- ✅ MySQL installed and running
- ✅ Node.js 14+ installed
- ✅ Composer installed (optional, not required for this project)

---

### STEP 1: Database Setup

#### 1.1 Create Database
```bash
# Open MySQL
mysql -u root -p

# Create database
CREATE DATABASE linkkart CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE linkkart;

# Exit MySQL
exit;
```

#### 1.2 Import Database Schema
```bash
cd backend

# Import all tables
mysql -u root -p linkkart < database/migrations/create_users_table.sql
mysql -u root -p linkkart < database/migrations/2024_01_01_000001_create_stores_table.php
mysql -u root -p linkkart < database/migrations/2024_01_01_000002_create_products_table.php
mysql -u root -p linkkart < database/migrations/2024_01_01_000003_create_analytics_events_table.php
mysql -u root -p linkkart < database/migrations/2024_01_01_000004_create_admins_table.php
mysql -u root -p linkkart < database/migrations/create_subscription_tables.sql
mysql -u root -p linkkart < database/migrations/add_constraints_and_indexes.sql
```

#### 1.3 Verify Database
```bash
php database/verify_database.php
```

---

### STEP 2: Backend Setup

#### 2.1 Configure Environment
Edit `backend/.env`:
```env
APP_NAME=LinkKart
APP_ENV=production
APP_DEBUG=false
APP_URL=http://192.168.1.22:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=linkkart
DB_USERNAME=root
DB_PASSWORD=

RAZORPAY_KEY_ID=rzp_test_SnZobCxSkQHK8T
RAZORPAY_KEY_SECRET=cBSLn082YWFL57LvUG5JFETM

JWT_SECRET=linkkart_luxury_secret_key_2024
JWT_TTL=86400

FRONTEND_URL=http://192.168.1.22:3000
STOREFRONT_URL=http://192.168.1.22:3001
```

#### 2.2 Create Storage Directories
```bash
cd backend

# Create directories
mkdir -p storage/app/public/products
mkdir -p storage/app/public/logos
mkdir -p storage/app/public/stores
mkdir -p storage/logs
mkdir -p storage/cache
mkdir -p public/storage

# Set permissions (Linux/Mac)
chmod -R 775 storage
chmod -R 775 public/storage

# Windows - no chmod needed
```

#### 2.3 Create Storage Symlink
```bash
cd backend/public

# Windows (run as Administrator)
mklink /D storage ..\storage\app\public

# Linux/Mac
ln -s ../storage/app/public storage
```

#### 2.4 Start Backend Server
```bash
cd backend/public

# Find your IP address
# Windows: ipconfig
# Linux/Mac: ifconfig or ip addr

# Start server on your IP (replace with your actual IP)
php -S 192.168.1.22:8000 api.php
```

**Backend should now be running at: `http://192.168.1.22:8000`**

---

### STEP 3: Mobile App Setup

#### 3.1 Update API Configuration
Edit `mobile-app/lib/utils/constants.dart`:
```dart
class AppConstants {
  // REPLACE WITH YOUR ACTUAL IP
  static const String baseUrl = 'http://192.168.1.22:8000/api/v1';
  
  // Helper method for image URLs
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return 'http://192.168.1.22:8000$imagePath';
  }
}
```

#### 3.2 Install Dependencies
```bash
cd mobile-app
flutter pub get
```

#### 3.3 Run Mobile App
```bash
# List available devices
flutter devices

# Run on connected device
flutter run

# Or run on specific device
flutter run -d <device-id>

# For web
flutter run -d chrome
```

---

### STEP 4: Storefront Setup

#### 4.1 Update Configuration
Edit `storefront/src/config.js`:
```javascript
// Use your actual IP
export const API_BASE_URL = 'http://192.168.1.22:8000';
export const API_VERSION = '/api/v1';

export const API_ENDPOINTS = {
  STORES: `${API_BASE_URL}${API_VERSION}/stores`,
  PRODUCTS: `${API_BASE_URL}${API_VERSION}/products`,
  ANALYTICS: `${API_BASE_URL}${API_VERSION}/analytics`,
  ORDERS: `${API_BASE_URL}${API_VERSION}/orders`,
};
```

#### 4.2 Update Environment
Edit `storefront/.env`:
```env
REACT_APP_API_BASE_URL=http://192.168.1.22:8000
REACT_APP_RAZORPAY_KEY_ID=rzp_test_SnZobCxSkQHK8T
```

#### 4.3 Install Dependencies
```bash
cd storefront
npm install
```

#### 4.4 Start Storefront
```bash
# Development mode
npm start

# Production build
npm run build

# Serve production build
npx serve -s build -l 3001
```

**Storefront should now be running at: `http://localhost:3001`**

---

### STEP 5: Admin Dashboard Setup

#### 5.1 Update Configuration
Edit `admin-dashboard/.env`:
```env
REACT_APP_API_BASE_URL=http://192.168.1.22:8000
REACT_APP_RAZORPAY_KEY_ID=rzp_test_SnZobCxSkQHK8T
```

#### 5.2 Install Dependencies
```bash
cd admin-dashboard
npm install
```

#### 5.3 Start Admin Dashboard
```bash
npm start
```

**Admin Dashboard should now be running at: `http://localhost:3000`**

---

## 🧪 TESTING THE DEPLOYMENT

### Test 1: Backend Health Check
```bash
curl http://192.168.1.22:8000/api/health
# Expected: {"success":true,"status":"healthy","timestamp":...}
```

### Test 2: Get Stores
```bash
curl http://192.168.1.22:8000/api/v1/stores
# Expected: {"success":true,"data":[...],"count":...}
```

### Test 3: Image Access
Open browser: `http://192.168.1.22:8000/storage/products/69f8cb223f45d.jpg`
- Should display image
- If 404, check symlink

### Test 4: Storefront
Open browser: `http://localhost:3001`
- Should show stores list
- Click on a store
- Should show products with images

### Test 5: Mobile App
- Open mobile app
- Should show products with images
- Images should load properly

---

## 🐛 TROUBLESHOOTING

### Issue: Images Still Not Showing

#### Check 1: Verify Symlink
```bash
cd backend/public
ls -la storage  # Linux/Mac
dir storage     # Windows

# Should show: storage -> ../storage/app/public
```

#### Check 2: Verify Image Files
```bash
cd backend/storage/app/public/products
ls -la  # Should show image files
```

#### Check 3: Test Direct Access
Open: `http://192.168.1.22:8000/storage/products/69f8cb223f45d.jpg`
- If 404: Symlink issue
- If 403: Permission issue
- If works: Check mobile app/storefront config

#### Check 4: Check Image Paths in Database
```bash
mysql -u root -p linkkart
SELECT id, name, image, images FROM products LIMIT 5;
```
Should show: `/storage/products/filename.jpg`

### Issue: Storefront Not Loading Stores

#### Check 1: Backend Running
```bash
curl http://192.168.1.22:8000/api/v1/stores
```

#### Check 2: CORS Headers
Check browser console for CORS errors
Backend `api.php` should have:
```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
```

#### Check 3: Storefront Config
```bash
cd storefront
cat src/config.js
# Should show: export const API_BASE_URL = 'http://192.168.1.22:8000';
```

### Issue: Database Connection Failed

#### Check 1: MySQL Running
```bash
# Windows
net start MySQL80

# Linux
sudo systemctl start mysql

# Mac
brew services start mysql
```

#### Check 2: Database Exists
```bash
mysql -u root -p -e "SHOW DATABASES LIKE 'linkkart';"
```

#### Check 3: Credentials
Edit `backend/.env`:
```env
DB_DATABASE=linkkart
DB_USERNAME=root
DB_PASSWORD=          # Leave empty if no password
```

---

## 📱 PRODUCTION DEPLOYMENT

### For Production Server:

#### 1. Use Apache/Nginx Instead of PHP Built-in Server

**Apache .htaccess** (backend/public/.htaccess):
```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ api.php [QSA,L]
</IfModule>
```

**Nginx Config**:
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    root /path/to/backend/public;
    index api.php;

    location / {
        try_files $uri $uri/ /api.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_index api.php;
        include fastcgi_params;
    }

    location /storage {
        alias /path/to/backend/storage/app/public;
    }
}
```

#### 2. Update URLs in All Configs
Replace `192.168.1.22:8000` with your domain:
- `backend/.env` → APP_URL
- `mobile-app/lib/utils/constants.dart` → baseUrl
- `storefront/src/config.js` → API_BASE_URL
- `admin-dashboard/.env` → REACT_APP_API_BASE_URL

#### 3. Build Production Assets
```bash
# Storefront
cd storefront
npm run build

# Admin Dashboard
cd admin-dashboard
npm run build

# Mobile App APK
cd mobile-app
flutter build apk --release
```

---

## 🎯 QUICK START SCRIPT

Create `start-all.bat` (Windows) or `start-all.sh` (Linux/Mac):

```bash
#!/bin/bash

# Start Backend
cd backend/public
php -S 192.168.1.22:8000 api.php &

# Start Storefront
cd ../../storefront
npm start &

# Start Admin Dashboard
cd ../admin-dashboard
npm start &

echo "✅ All services started!"
echo "Backend: http://192.168.1.22:8000"
echo "Storefront: http://localhost:3001"
echo "Admin: http://localhost:3000"
```

---

## 📞 SUPPORT

If issues persist:
1. Check all URLs use same IP address
2. Verify backend is running: `curl http://192.168.1.22:8000/api/health`
3. Check browser console for errors
4. Verify database has data: `mysql -u root -p linkkart -e "SELECT COUNT(*) FROM stores;"`
5. Test image access directly in browser

---

**Status**: Ready for deployment
**Last Updated**: May 11, 2026
