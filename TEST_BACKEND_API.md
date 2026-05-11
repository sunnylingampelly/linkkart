# Backend API Test Guide

## Quick Test Commands

### 1. Check if Backend is Running
```bash
curl http://localhost:8000/api/health
```

**Expected Response:**
```json
{
  "success": true,
  "message": "LinkKart API is running",
  "version": "1.0.0",
  "timestamp": "2024-01-01T00:00:00.000000Z"
}
```

### 2. Test Stores Endpoint
```bash
curl http://localhost:8000/api/v1/stores
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Store Name",
      "slug": "store-slug",
      "phone": "+91 1234567890",
      "logo": null,
      "products": [...]
    }
  ]
}
```

### 3. Test Specific Store
```bash
curl http://localhost:8000/api/v1/stores/store-slug
```

## Start Backend Server

### Option 1: Using PHP Built-in Server
```bash
cd backend
php -S localhost:8000 -t public
```

### Option 2: Using Laravel Artisan
```bash
cd backend
php artisan serve --port=8000
```

## Common Issues & Solutions

### Issue 1: "Connection Refused"
**Problem:** Backend server is not running

**Solution:**
```bash
cd backend
php artisan serve --port=8000
```

### Issue 2: "404 Not Found"
**Problem:** Wrong API endpoint

**Solution:** Use correct endpoints:
- ✅ `http://localhost:8000/api/v1/stores`
- ❌ `http://localhost:8000/api-stores.php`

### Issue 3: "Database Connection Error"
**Problem:** MySQL not running or wrong credentials

**Solution:**
1. Start MySQL/XAMPP
2. Check `.env` file in backend folder
3. Verify database name: `linkkart`

### Issue 4: "Empty Response"
**Problem:** No stores in database

**Solution:**
```sql
-- Check if stores exist
SELECT * FROM stores;

-- If empty, add a test store
INSERT INTO stores (name, slug, phone, created_at, updated_at) 
VALUES ('Test Store', 'test-store', '+91 9876543210', NOW(), NOW());
```

## Frontend API Calls

### HomePage.js
```javascript
// Correct endpoint
const urls = [
  'http://localhost:8000/api/v1/stores',
  'http://192.168.1.2:8000/api/v1/stores'
];
```

### StorePage.js
```javascript
// Correct endpoint
const urls = [
  `http://localhost:8000/api/v1/stores/${slug}`,
  `http://192.168.1.2:8000/api/v1/stores/${slug}`
];
```

### ProductPage.js
```javascript
// Correct endpoint
const urls = [
  `http://localhost:8000/api/v1/stores/${slug}`,
  `http://192.168.1.2:8000/api/v1/stores/${slug}`
];
```

## Verify Everything is Working

### Step 1: Start Backend
```bash
cd backend
php artisan serve --port=8000
```

### Step 2: Test API
```bash
curl http://localhost:8000/api/health
curl http://localhost:8000/api/v1/stores
```

### Step 3: Start Frontend
```bash
cd storefront
npm start
```

### Step 4: Open Browser
```
http://localhost:3001
```

## Expected Flow

1. **Backend Running** → Port 8000
2. **Frontend Running** → Port 3001
3. **Frontend calls** → `http://localhost:8000/api/v1/stores`
4. **Backend responds** → JSON with stores data
5. **Frontend displays** → Store cards on homepage

## Debug Mode

### Enable Laravel Debug
Edit `backend/.env`:
```
APP_DEBUG=true
APP_ENV=local
```

### Check Laravel Logs
```bash
tail -f backend/storage/logs/laravel.log
```

### Browser Console
Open browser console (F12) and check:
- Network tab for API calls
- Console tab for JavaScript errors

## Current Status

✅ **API Routes Configured** - `/api/v1/stores` endpoint exists
✅ **HomePage Updated** - Now uses correct endpoint
✅ **StorePage Working** - Already using correct endpoint
✅ **ProductPage Working** - Already using correct endpoint

## Next: Start Backend

Run this command to start the backend:
```bash
cd backend && php artisan serve --port=8000
```

Then refresh the storefront at `http://localhost:3001`
