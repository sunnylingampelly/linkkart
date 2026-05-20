# Fix Product Creation Database Error

## Issue
Getting "API Error: 500 - DATABASE_ERROR" when trying to create products in the mobile app on production server.

## Root Causes (Possible)

### 1. **Database Connection Issue**
- Production `.env` file might have wrong database credentials
- Database server might be down or unreachable

### 2. **Missing Products Table**
- The `products` table might not exist in production database
- Table structure might be different from expected

### 3. **Foreign Key Constraint**
- Store ID doesn't exist in the `stores` table
- Foreign key constraint `products_store_id_foreign` is failing

### 4. **CHECK Constraint Violation**
- Price, stock_quantity, or click_count might be negative
- Data type mismatch (string instead of number)

### 5. **Storage Directory Permissions**
- `/storage/products/` directory doesn't exist or isn't writable
- Server can't save uploaded images

## Fixes Applied

### 1. **Improved Error Handling**
Updated `backend/public/index.php` to provide detailed error information:
- Logs full error message and code
- Returns debug info in API response
- Better error tracking

### 2. **Enhanced Data Validation**
Added strict validation before database insertion:
- Type casting: `(int)$storeId`, `(float)$price`, `(int)$stockQuantity`
- Range validation: ensures no negative values
- Store existence check before creating product

### 3. **Created Diagnostic Script**
Created `backend/public/test_product_creation.php` to test:
- Database connection
- Table existence and structure
- Store data availability
- Test product insertion
- Storage directory permissions

## How to Diagnose

### Step 1: Run Diagnostic Script
Visit: `https://api.linkkart.shop/test_product_creation.php`

This will show you exactly what's failing:
```json
{
  "overall_status": "SOME_CHECKS_FAILED",
  "checks": {
    "db_connection": { "status": "success" },
    "products_table": { "status": "failed", "error": "..." },
    "test_insertion": { "status": "failed", "error": "..." }
  }
}
```

### Step 2: Check Production Database

**SSH into your production server and run:**

```bash
# Connect to MySQL
mysql -u your_username -p

# Select database
USE linkkart;

# Check if products table exists
SHOW TABLES LIKE 'products';

# Check table structure
DESCRIBE products;

# Check if stores exist
SELECT COUNT(*) FROM stores;

# Try manual product insertion
INSERT INTO products (store_id, product_id, name, price, stock_quantity, is_active, click_count, created_at, updated_at)
VALUES (1, 'TEST-123', 'Test Product', 99.99, 10, 1, 0, NOW(), NOW());
```

### Step 3: Check Production .env File

**On production server:**
```bash
cd /path/to/backend
cat .env
```

Verify these settings:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1  # or your database host
DB_PORT=3306
DB_DATABASE=linkkart
DB_USERNAME=your_db_user
DB_PASSWORD=your_db_password
```

### Step 4: Check Error Logs

**On production server:**
```bash
# Check PHP error log
tail -f /var/log/php_errors.log

# Or check Apache/Nginx error log
tail -f /var/log/apache2/error.log
tail -f /var/log/nginx/error.log
```

## Quick Fixes

### Fix 1: Missing Products Table
If the products table doesn't exist, run:
```bash
mysql -u your_username -p linkkart < COMPLETE_DATABASE_SETUP_PRODUCTION.sql
```

### Fix 2: Wrong Database Credentials
Update production `.env` file with correct credentials:
```bash
nano /path/to/backend/.env
```

### Fix 3: Storage Directory Permissions
```bash
cd /path/to/backend/public
mkdir -p storage/products
chmod -R 777 storage
```

### Fix 4: Foreign Key Issue
Check if the store exists:
```sql
SELECT id, name FROM stores WHERE id = YOUR_STORE_ID;
```

If store doesn't exist, create it first in the mobile app.

## Testing After Fix

### Test 1: API Endpoint Directly
```bash
curl -X POST https://api.linkkart.shop/api/v1/seller/products \
  -F "store_id=1" \
  -F "name=Test Product" \
  -F "price=99.99" \
  -F "stock_quantity=10" \
  -F "description=Test Description"
```

### Test 2: Mobile App
1. Open mobile app
2. Go to Products tab
3. Click "Add Product"
4. Fill in details
5. Click Save

### Test 3: Check Database
```sql
SELECT * FROM products ORDER BY id DESC LIMIT 5;
```

## Expected Behavior After Fix

✅ Product creation should work without errors
✅ Products should appear in the mobile app immediately
✅ Images should upload and display correctly
✅ Stock quantity should be tracked properly

## Next Steps

1. **Run the diagnostic script first**: `https://api.linkkart.shop/test_product_creation.php`
2. **Share the output** so I can identify the exact issue
3. **Apply the specific fix** based on the diagnostic results
4. **Test product creation** in the mobile app

## Production Deployment Checklist

Before deploying to production, ensure:

- [ ] Database tables are created (`COMPLETE_DATABASE_SETUP_PRODUCTION.sql`)
- [ ] `.env` file has correct production credentials
- [ ] Storage directories exist and are writable
- [ ] Foreign key constraints are properly set up
- [ ] Demo stores are added (optional: `ADD_DEMO_STORES_WITH_IMAGES.sql`)
- [ ] API endpoints are accessible from mobile app
- [ ] CORS headers are configured correctly
- [ ] Error logging is enabled

## Contact Points

If you need help:
1. Share the diagnostic script output
2. Share relevant error logs
3. Share database table structure (`DESCRIBE products`)
4. Share a screenshot of the mobile app error

---

**Status**: Fixes applied, awaiting diagnostic results
**Priority**: HIGH - Blocking product creation in production
**Impact**: Users cannot add products to their stores
