# 🔧 Fix Storefront Database Connection

## Problem
Stores are in database but not showing on storefront homepage.

## Root Cause
1. Missing public API endpoint for listing stores
2. Frontend using wrong endpoint

## ✅ Fixes Applied

### 1. Backend Routes (`backend/routes/api.php`)
Added public stores list endpoint:
```php
Route::get('/stores', [StoreController::class, 'index']); // NEW
```

### 2. Frontend (`storefront/src/pages/HomePage.js`)
Updated to use correct endpoint with better error handling:
```javascript
const response = await axios.get('http://192.168.1.2:8000/api/v1/stores');
```

Added console logging to debug response.

## 🚀 How to Fix

### Step 1: Restart Backend
```bash
# Stop current backend (Ctrl+C)
cd D:\linkkart\backend
php artisan serve --host=0.0.0.0 --port=8000
```

### Step 2: Restart Storefront
```bash
# Stop current storefront (Ctrl+C)
cd D:\linkkart\storefront
npm start
```

### Step 3: Test
1. Open http://localhost:3001
2. Open browser console (F12)
3. Check for "Stores response:" and "Stores data:" logs
4. Stores should now appear

## 🐛 If Still Not Working

### Check Backend:
```bash
curl http://192.168.1.2:8000/api/v1/stores
```

Should return:
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "name": "Store Name",
        "slug": "store-slug",
        ...
      }
    ]
  }
}
```

### Check Database:
```sql
SELECT * FROM stores;
```

Should show your stores.

### Check Console:
Open browser console and look for:
- "Stores response:" - Shows API response
- "Stores data:" - Shows parsed stores array
- Any error messages

## 📝 API Endpoints Now Available

### Public (No Auth):
- `GET /api/v1/stores` - List all stores ✅ NEW
- `GET /api/v1/stores/{id}` - Get single store
- `GET /api/v1/stores/{slug}/products` - Get store products

### Seller (No Auth for MVP):
- `GET /api/v1/seller/stores` - List seller stores
- `POST /api/v1/seller/stores` - Create store
- `PUT /api/v1/seller/stores/{id}` - Update store
- `DELETE /api/v1/seller/stores/{id}` - Delete store

## ✅ Expected Result

After restarting:
1. Homepage loads
2. Shows "Available Stores" section
3. Displays store cards with:
   - Store logo
   - Store name
   - Phone number
   - "Visit Store" button
4. Click store → Opens store page with products

## 🎨 Design Note

The storefront has luxury design with:
- Playfair Display fonts
- Black, white, gold colors
- Elegant animations
- Premium feel

If it looks "basic", make sure:
1. Fonts are loading (check Network tab)
2. CSS files are loaded
3. No console errors
4. Browser cache is cleared (Ctrl+Shift+R)

---

**Status**: Routes fixed, restart required
**Next**: Restart backend and storefront
