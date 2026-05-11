# URGENT: Fix Stores Not Loading

## Problem
The backend on port 8000 is serving a **different application** (medical/doctor booking system), not our LinkKart API.

## Solution

### Step 1: Stop Current Backend
1. Find the terminal/command prompt running the backend
2. Press `Ctrl+C` to stop it

### Step 2: Start Correct Backend

**Option A: Use test-api.php (Quick Test)**
```bash
# Open browser and go to:
http://localhost:8000/test-api.php
```

**Option B: Start PHP Built-in Server (Recommended)**
```bash
cd backend/public
php -S localhost:8000
```

This will serve files from `backend/public/` directory.

### Step 3: Update Storefront to Use test-api.php

The storefront needs to call:
```
http://localhost:8000/test-api.php
```

## Files Created

1. **backend/public/test-api.php** - Simple API that returns stores
2. **backend/public/api.php** - Full API with all endpoints
3. **START_BACKEND.bat** - Windows batch file to start backend

## Quick Test

After starting the backend, open browser:
```
http://localhost:8000/test-api.php
```

You should see:
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "Store Name",
            "slug": "store-slug",
            ...
        }
    ],
    "count": 1
}
```

## Update Frontend

The HomePage.js is already updated to try multiple URLs:
1. `http://localhost:8000/api.php/api/v1/stores`
2. `http://localhost:8000/api/v1/stores`
3. `http://localhost:8000/test-api.php` (add this)

## Complete Fix Steps

### 1. Stop Wrong Backend
- Find terminal running backend
- Press Ctrl+C

### 2. Navigate to Backend
```bash
cd backend/public
```

### 3. Start PHP Server
```bash
php -S localhost:8000
```

### 4. Test API
Open browser:
```
http://localhost:8000/test-api.php
```

### 5. Refresh Storefront
```
http://localhost:3001
```

Stores should now appear!

## Why This Happened

The backend on port 8000 was running a **different PHP application** (medical booking system), not our LinkKart backend.

Our LinkKart files are in `backend/public/` but a different application was being served.

## Permanent Solution

Always start the backend from the correct directory:
```bash
cd backend/public
php -S localhost:8000
```

Or use the batch file:
```bash
START_BACKEND.bat
```

## Verification

After starting backend, check:

1. **Health Check:**
```
http://localhost:8000/test-api.php
```

2. **Stores API:**
Should return JSON with stores data

3. **Storefront:**
```
http://localhost:3001
```
Should show store cards

## If Still Not Working

1. Check MySQL is running (XAMPP/WAMP)
2. Check database "linkkart" exists
3. Check stores table has data:
```sql
SELECT * FROM stores WHERE is_active = 1;
```

4. Check browser console (F12) for errors

## Next Steps

Once stores are loading:
1. ✅ Homepage will show store cards
2. ✅ Click store to see products
3. ✅ Click product to see details with quantity selector
4. ✅ Order via WhatsApp button works

The platform will look international and professional! 🌍✨
