# ▶️ RUN NOW - Simple Instructions

## 🎯 Quick Start (2 Terminals Needed)

### Terminal 1: Storefront (Ready to Run!)

The storefront is **ready to go**. Just run:

```bash
cd storefront
npm start
```

**Expected Output:**
```
Compiled successfully!

You can now view linkkart-storefront in the browser.

  Local:            http://localhost:3001
  On Your Network:  http://192.168.x.x:3001
```

**Access at:** http://localhost:3001

---

### Terminal 2: Backend (Needs Setup)

The backend needs a complete Laravel installation. Here's the **fastest way**:

#### Option A: Quick PHP Server (For Testing Only)

```bash
# 1. Navigate to backend
cd backend

# 2. Create a simple test endpoint
# Create: backend/public/index.php
```

Then create `backend/public/index.php` with:

```php
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Health check
if ($uri === '/api/health') {
    echo json_encode([
        'success' => true,
        'message' => 'LinkKart API is running',
        'version' => '1.0.0',
        'timestamp' => date('c')
    ]);
    exit;
}

// Mock store endpoint for testing
if (preg_match('#^/api/v1/stores/(.+)$#', $uri, $matches)) {
    echo json_encode([
        'success' => true,
        'data' => [
            'id' => 1,
            'name' => 'Demo Store',
            'phone' => '+1234567890',
            'slug' => $matches[1],
            'products' => [
                [
                    'id' => 1,
                    'name' => 'Sample Product',
                    'price' => '99.99',
                    'formatted_price' => '$99.99',
                    'description' => 'This is a demo product',
                    'image' => null
                ]
            ]
        ]
    ]);
    exit;
}

http_response_code(404);
echo json_encode(['success' => false, 'message' => 'Not found']);
```

Then run:

```bash
php -S localhost:8000 -t public
```

#### Option B: Full Laravel Setup (Recommended for Production)

```bash
# 1. Create fresh Laravel project
composer create-project laravel/laravel linkkart-backend

# 2. Copy our files
# Copy migrations, models, controllers from backend/ folder

# 3. Install dependencies
cd linkkart-backend
composer require tymon/jwt-auth

# 4. Setup
cp .env.example .env
php artisan key:generate

# 5. Configure database in .env
# DB_DATABASE=linkkart
# DB_USERNAME=root
# DB_PASSWORD=

# 6. Run
php artisan migrate
php artisan serve
```

---

## ✅ Verification

### 1. Check Backend
Open: http://localhost:8000/api/health

Should see:
```json
{
  "success": true,
  "message": "LinkKart API is running"
}
```

### 2. Check Storefront
Open: http://localhost:3001

Should see the LinkKart storefront homepage.

### 3. Test Store Page
Open: http://localhost:3001/store/demo-store

Should see a store page with products.

---

## 🚀 What You Can Do Now

### With Storefront Running:

1. **View Demo Store**: http://localhost:3001/store/demo-store
2. **See Product Layout**: Browse the product grid
3. **Test WhatsApp Button**: Click "Order on WhatsApp"
4. **Test Responsive Design**: Resize browser window

### With Backend Running:

1. **Test API**: Use Postman or curl
2. **Create Stores**: POST to /api/v1/seller/stores
3. **Add Products**: POST to /api/v1/seller/products
4. **View Analytics**: GET /api/v1/admin/analytics/global

---

## 📱 Mobile App (Optional)

If you have Flutter installed:

```bash
cd mobile-app
flutter pub get
flutter run
```

---

## 🎨 Current Status

✅ **Storefront**: Ready to run (npm start)
⚠️ **Backend**: Needs Laravel setup or use simple PHP server
✅ **Mobile App**: Ready (needs Flutter)
✅ **Admin Dashboard**: Ready (npm start)

---

## 💡 Recommended Next Steps

1. **Start Storefront** (easiest):
   ```bash
   cd storefront
   npm start
   ```

2. **Create Simple Backend** (for testing):
   - Create the `backend/public/index.php` file above
   - Run: `php -S localhost:8000 -t public`

3. **Test Everything**:
   - Visit http://localhost:3001/store/demo-store
   - See the beautiful UI
   - Test WhatsApp integration

4. **Later: Full Backend Setup**:
   - Follow Option B above for production-ready backend

---

## 🆘 Quick Troubleshooting

**Storefront won't start:**
```bash
cd storefront
rm -rf node_modules package-lock.json
npm install
npm start
```

**Port already in use:**
```bash
# Windows
netstat -ano | findstr :3001
taskkill /PID <PID> /F

# Or use different port
set PORT=3002 && npm start
```

**Backend issues:**
- Use the simple PHP server first (Option A)
- Full Laravel setup can be done later

---

## 🎉 You're Ready!

The storefront is **100% ready to run**. Just open a terminal and:

```bash
cd storefront
npm start
```

Then visit: **http://localhost:3001**

For the backend, use the simple PHP server for now, and set up full Laravel later when needed.

---

**Need more help? See [SETUP_GUIDE.md](./SETUP_GUIDE.md)**
