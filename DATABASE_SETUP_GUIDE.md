# 🗄️ Database Setup Guide - LinkKart with XAMPP

## ✅ Step-by-Step Setup

### Step 1: Start XAMPP Services

1. Open **XAMPP Control Panel**
2. Start **Apache** ✅
3. Start **MySQL** ✅

---

### Step 2: Create Database

#### Option A: Using phpMyAdmin (Recommended)

1. Open browser and go to:
   ```
   http://localhost/phpmyadmin
   ```

2. Click **"New"** in the left sidebar

3. Enter database name: `linkkart`

4. Select collation: `utf8mb4_unicode_ci`

5. Click **"Create"**

#### Option B: Using MySQL Command Line

```bash
mysql -u root -p
CREATE DATABASE linkkart CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit;
```

---

### Step 3: Import Database Structure

1. In phpMyAdmin, select the `linkkart` database

2. Click on the **"SQL"** tab

3. Copy the contents of `database_setup.sql` file

4. Paste into the SQL editor

5. Click **"Go"**

**Or simply run this file:**
- Click **"Import"** tab
- Choose file: `database_setup.sql`
- Click **"Go"**

---

### Step 4: Verify Tables Created

You should see 4 tables:
- ✅ `stores` (3 demo stores)
- ✅ `products` (6 demo products)
- ✅ `analytics_events` (3 demo events)
- ✅ `admins` (1 admin user)

---

### Step 5: Switch to MySQL Backend

#### Stop the current PHP server:
Press `Ctrl+C` in the terminal where backend is running

#### Rename the files:
```bash
cd backend/public
mv index.php index-demo.php
mv index-mysql.php index.php
```

**Or manually:**
1. Rename `index.php` to `index-demo.php` (backup)
2. Rename `index-mysql.php` to `index.php` (activate MySQL version)

#### Start the server again:
```bash
cd backend
php -S localhost:8000 -t public
```

---

### Step 6: Test the Connection

#### Test 1: Health Check
```bash
curl http://localhost:8000/api/health
```

**Expected Response:**
```json
{
  "success": true,
  "message": "LinkKart API is running with MySQL",
  "version": "1.0.0",
  "database": "Connected",
  "timestamp": "2026-05-03T..."
}
```

#### Test 2: Get Store
```bash
curl http://localhost:8000/api/v1/stores/demo-store
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Demo Fashion Store",
    "phone": "+919876543210",
    "products": [...]
  }
}
```

---

### Step 7: Test in Browser

Visit the storefront:
```
http://localhost:3001/store/demo-store
```

You should see:
- ✅ Store data from MySQL database
- ✅ 3 products loaded from database
- ✅ Real-time analytics tracking

---

## 🎯 Demo Data Included

### Stores (3)
1. **Demo Fashion Store** - `/store/demo-store`
2. **Tech Gadgets Hub** - `/store/tech-gadgets-hub`
3. **Home Decor Paradise** - `/store/home-decor-paradise`

### Products (6)
- Blue Cotton T-Shirt (₹499)
- Black Denim Jeans (₹1,299)
- White Sneakers (₹1,999)
- Wireless Earbuds (₹2,499)
- Smart Watch (₹4,999)
- Decorative Wall Art (₹899)

### Admin User
- **Email:** admin@linkkart.com
- **Password:** password

---

## 🔧 Configuration

If your MySQL has a password, edit `backend/public/index.php`:

```php
// Database configuration
define('DB_HOST', 'localhost');
define('DB_NAME', 'linkkart');
define('DB_USER', 'root');
define('DB_PASS', 'your_password_here'); // Change this
```

---

## 🧪 Test All Features

### 1. View Stores
```
http://localhost:3001/store/demo-store
http://localhost:3001/store/tech-gadgets-hub
http://localhost:3001/store/home-decor-paradise
```

### 2. Create New Store (API)
```bash
curl -X POST http://localhost:8000/api/v1/seller/stores \
  -F "name=My New Store" \
  -F "phone=+1234567890"
```

### 3. Add Product (API)
```bash
curl -X POST http://localhost:8000/api/v1/seller/products \
  -F "store_id=1" \
  -F "name=New Product" \
  -F "price=999" \
  -F "description=Amazing product"
```

### 4. View All Stores (Admin)
```bash
curl http://localhost:8000/api/v1/admin/stores
```

---

## 📊 Database Schema

```
stores
├── id (Primary Key)
├── name
├── phone
├── logo
├── slug (Unique)
├── is_active
├── view_count
└── timestamps

products
├── id (Primary Key)
├── store_id (Foreign Key → stores)
├── name
├── price
├── description
├── image
├── is_active
├── click_count
└── timestamps

analytics_events
├── id (Primary Key)
├── store_id (Foreign Key → stores)
├── product_id (Foreign Key → products)
├── event_type (enum)
├── ip_address
├── user_agent
├── metadata (JSON)
└── timestamps

admins
├── id (Primary Key)
├── name
├── email (Unique)
├── password (Hashed)
└── timestamps
```

---

## ✅ Verification Checklist

- [ ] XAMPP MySQL is running
- [ ] Database `linkkart` created
- [ ] All 4 tables created
- [ ] Demo data inserted
- [ ] Backend switched to MySQL version
- [ ] PHP server restarted
- [ ] Health check returns "Connected"
- [ ] Store page loads from database
- [ ] Products display correctly
- [ ] Analytics tracking works

---

## 🐛 Troubleshooting

### Error: "Database connection failed"
- Check XAMPP MySQL is running
- Verify database name is `linkkart`
- Check username/password in `index.php`

### Error: "Table doesn't exist"
- Run the SQL script in phpMyAdmin
- Verify all 4 tables are created

### Error: "Access denied"
- Check MySQL username (default: `root`)
- Check MySQL password (default: empty)
- Update credentials in `index.php`

### No data showing
- Verify demo data was inserted
- Check browser console for errors
- Test API directly with curl

---

## 🎉 Success!

Once everything is working:
- ✅ Real MySQL database connected
- ✅ Demo data loaded
- ✅ Storefront showing database data
- ✅ Analytics tracking to database
- ✅ Ready for production use

---

## 🚀 Next Steps

1. **Add more stores** via API or mobile app
2. **Upload product images** 
3. **View analytics** in admin dashboard
4. **Customize demo data** in database
5. **Deploy to production** server

---

**Your LinkKart platform is now running with a real database!** 🎉
