# Fix: Stores Not Loading on Homepage

## Problem
The homepage is trying to fetch stores from `/api/v1/stores` but the endpoint returns 404.

## Root Cause
The backend has **two different systems**:
1. **Laravel Application** (proper framework with routes in `routes/api.php`)
2. **Custom PHP files** (`index.php`, `index-mysql.php`)

Currently, a **Laravel server** is running, but the `/api/v1/stores` route (list all stores) is missing from the Laravel routes.

## Solution

### Option 1: Add Missing Route to Laravel (Recommended)

The `StoreController@index` method exists and works correctly, but it's only accessible via `/api/v1/admin/stores`.

We need to make it public at `/api/v1/stores`.

**File:** `backend/routes/api.php`

The route already exists! Line 18:
```php
Route::get('/stores', [StoreController::class, 'index']); // List all stores
```

### Option 2: Use Custom PHP Backend

Stop the Laravel server and use the custom PHP backend instead.

**Steps:**
1. Stop current backend server (Ctrl+C in the terminal running it)
2. Start custom PHP server:
```bash
cd backend/public
php -S localhost:8000 index.php
```

## Testing

### Test 1: Health Check
```bash
curl http://localhost:8000/api/health
```

**Expected (Laravel):**
```json
{
  "success": true,
  "message": "LinkKart API is running",
  "version": "1.0.0"
}
```

**Expected (Custom PHP):**
```json
{
  "success": true,
  "message": "LinkKart API is running with MySQL",
  "database": "Connected"
}
```

### Test 2: Get All Stores
```bash
curl http://localhost:8000/api/v1/stores
```

**Expected:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Store Name",
      "slug": "store-slug",
      "phone": "+91 1234567890",
      "product_count": 5
    }
  ]
}
```

## Current Issue

The backend is returning:
```json
{"status":false,"data":[],"error":{"message":"Not Found!"}}
```

This format (`"status"` instead of `"success"`) suggests there's **another system** handling requests.

## Quick Fix: Restart Backend with Custom PHP

1. **Stop current backend** (find the terminal and press Ctrl+C)

2. **Start custom PHP backend:**
```bash
cd backend/public
php -S localhost:8000 index.php
```

3. **Refresh storefront:**
```
http://localhost:3001
```

## Permanent Fix: Update Laravel Routes

If you want to use Laravel (recommended for production), ensure the route is properly configured.

**File:** `backend/routes/api.php` (Line 18)
```php
Route::get('/stores', [StoreController::class, 'index']); // ✅ Already exists!
```

The route exists, so the issue might be:
1. **Wrong server running** - Not using Laravel
2. **Route cache** - Laravel routes are cached

**Clear Laravel route cache:**
```bash
cd backend
php artisan route:clear
php artisan cache:clear
php artisan config:clear
```

**Then restart Laravel:**
```bash
php artisan serve --port=8000
```

## Verify Which Backend is Running

Run this command:
```bash
curl http://localhost:8000/api/health
```

- If response includes `"database": "Connected"` → Custom PHP backend ✅
- If response includes `"version": "1.0.0"` only → Laravel backend
- If response includes `"status":false` → Unknown system ❌

## Summary

**Quick Solution:**
1. Stop current backend
2. Run: `cd backend/public && php -S localhost:8000 index.php`
3. Refresh storefront

**Proper Solution:**
1. Use Laravel backend
2. Clear caches: `php artisan route:clear && php artisan cache:clear`
3. Start Laravel: `php artisan serve --port=8000`
4. Verify route exists: `php artisan route:list | grep "api/v1/stores"`

The stores should now load on the homepage! 🎉
