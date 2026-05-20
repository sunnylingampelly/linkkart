# 🔍 Test These URLs Now

## Issue
Product creation failing with DATABASE_ERROR in mobile app.

## Root Cause
Backend using hardcoded database credentials instead of reading from production `.env` file.

## Diagnostic URLs (Test These Now)

### 1. Database Configuration Check
```
https://api.linkkart.shop/api/check-db
```

**What it shows:**
- Current database configuration (host, database name, username)
- Connection status
- List of all tables in database
- Missing required tables
- Store and product counts

**Expected if working:**
```json
{
  "overall_status": "HEALTHY",
  "connection_status": "connected",
  "checks": {
    "tables": { "status": "success", "count": 8 },
    "required_tables": { "status": "success" },
    "stores": { "count": 5 },
    "products": { "count": 10 }
  }
}
```

**If failing, you'll see:**
```json
{
  "overall_status": "ERROR",
  "checks": {
    "error": {
      "status": "failed",
      "error": "Access denied for user 'root'@'localhost'"
    }
  }
}
```

---

### 2. Product Creation Test
```
https://api.linkkart.shop/api/test-product
```

**What it does:**
- Tests database connection
- Checks if products table exists
- Verifies table structure
- Attempts to create and delete a test product

**Expected if working:**
```json
{
  "overall_status": "ALL_CHECKS_PASSED",
  "checks": {
    "db_connection": { "status": "success" },
    "products_table": { "status": "success" },
    "test_insertion": { "status": "success" }
  }
}
```

---

### 3. API Health Check
```
https://api.linkkart.shop/api/health
```

**Expected:**
```json
{
  "success": true,
  "status": "healthy",
  "timestamp": 1234567890
}
```

---

## What to Do Based on Results

### Scenario 1: Database Connection Failed
**Error:** "Access denied" or "Unknown database"

**Solution:**
1. SSH into your production server
2. Edit `/path/to/backend/.env`
3. Update database credentials:
   ```env
   DB_HOST=localhost
   DB_DATABASE=linkkart
   DB_USERNAME=your_actual_username
   DB_PASSWORD=your_actual_password
   ```
4. Save and test again

---

### Scenario 2: Missing Tables
**Error:** "Table 'products' doesn't exist"

**Solution:**
1. Upload `COMPLETE_DATABASE_SETUP_PRODUCTION.sql` to server
2. Run: `mysql -u username -p linkkart < COMPLETE_DATABASE_SETUP_PRODUCTION.sql`
3. Test again

---

### Scenario 3: No Stores Found
**Warning:** "No stores found"

**Solution:**
1. Create a store in the mobile app first
2. Or run: `ADD_DEMO_STORES_WITH_IMAGES.sql`
3. Then try creating products

---

### Scenario 4: Everything Passes But Mobile App Still Fails
**Possible causes:**
- Mobile app cache
- Wrong API URL in mobile app
- Network/firewall issue

**Solution:**
1. Clear mobile app data
2. Verify API URL in `mobile-app/lib/utils/constants.dart`
3. Check server firewall allows connections

---

## Quick Action Steps

1. **Test URL 1:** `https://api.linkkart.shop/api/check-db`
2. **Copy the JSON response**
3. **Share it with me** so I can diagnose the exact issue
4. **Follow the specific solution** based on the error

---

## Files Updated

✅ `backend/public/index.php` - Added diagnostic endpoints
✅ `backend/public/api.php` - Added diagnostic endpoints  
✅ Both now read database credentials from `.env` file

## Upload These Files to Production

After testing, upload these updated files:
- `backend/public/index.php`
- `backend/public/api.php`

---

**Start here:** Test `https://api.linkkart.shop/api/check-db` and share the result!
