# 🚀 DEPLOY DATABASE TO PRODUCTION - ACTION PLAN

## ⚡ QUICK START (5 Minutes)

### Step 1: Backup Current Database
```bash
# SSH into your production server
ssh your-server

# Backup current database
mysqldump -u root -p linkkart > backup_$(date +%Y%m%d_%H%M%S).sql

# Verify backup was created
ls -lh backup_*.sql
```

### Step 2: Import Complete Database
```bash
# Import the complete database setup
mysql -u root -p linkkart < COMPLETE_DATABASE_SETUP_PRODUCTION.sql

# This will:
# ✅ Create all 11 tables (if not exist)
# ✅ Add all foreign keys
# ✅ Insert default plans (Free, Starter, Business)
# ✅ Insert admin account
# ✅ Optimize all tables
```

### Step 3: Verify Database
```bash
# Run verification script
php verify_production_database.php

# Expected output:
# ✅ All 11 tables exist
# ✅ Subscription plans configured
# ✅ Admin account exists
# ✅ Foreign keys configured
# 🎉 DATABASE IS PRODUCTION READY!
```

### Step 4: Test from Mobile App
1. Open mobile app
2. Try adding a product → Should work ✅
3. Try creating subscription → Should work ✅
4. Check dashboard stats → Should load ✅

---

## 📋 DETAILED STEPS

### Option A: Using phpMyAdmin (Recommended for Beginners)

1. **Login to phpMyAdmin**
   - URL: Usually `https://your-domain.com/phpmyadmin`
   - Or via cPanel → phpMyAdmin

2. **Select Database**
   - Click on `linkkart` database in left sidebar

3. **Backup First (IMPORTANT!)**
   - Click "Export" tab
   - Click "Go" to download backup
   - Save file as `linkkart_backup_YYYYMMDD.sql`

4. **Import New Schema**
   - Click "Import" tab
   - Click "Choose File"
   - Select: `COMPLETE_DATABASE_SETUP_PRODUCTION.sql`
   - Scroll down and click "Go"
   - Wait for success message

5. **Verify**
   - Click "Structure" tab
   - You should see 11 tables:
     - admins
     - analytics_events
     - customers
     - invoices
     - orders
     - payments
     - plans
     - products
     - stores
     - subscriptions
     - users

### Option B: Using MySQL Command Line (Advanced)

```bash
# 1. Connect to your server
ssh user@your-server-ip

# 2. Navigate to project directory
cd /path/to/linkkart

# 3. Backup current database
mysqldump -u root -p linkkart > backup_$(date +%Y%m%d_%H%M%S).sql

# 4. Import complete database
mysql -u root -p linkkart < COMPLETE_DATABASE_SETUP_PRODUCTION.sql

# 5. Verify tables
mysql -u root -p linkkart -e "SHOW TABLES;"

# 6. Verify plans
mysql -u root -p linkkart -e "SELECT * FROM plans;"

# 7. Run verification script
php verify_production_database.php
```

---

## ✅ VERIFICATION CHECKLIST

After importing, verify these:

### Database Structure
- [ ] 11 tables exist
- [ ] All foreign keys are set
- [ ] All indexes are created
- [ ] No errors in import log

### Default Data
- [ ] 3 plans exist (Free ₹0, Starter ₹299, Business ₹599)
- [ ] Admin account exists (admin@linkkart.com)
- [ ] User account exists (admin@linkkart.com)

### API Tests
- [ ] `GET /api/health` returns success
- [ ] `GET /api/v1/plans` returns 3 plans
- [ ] `GET /api/v1/stores` returns stores list
- [ ] Product creation works from mobile app
- [ ] Subscription creation works from mobile app

---

## 🔍 WHAT THIS FIXES

### Issue 1: Product Creation Error ✅
**Before:** Database error when adding products  
**After:** Products created successfully with auto-generated product_id

### Issue 2: Subscription API Error ✅
**Before:** API 500 - Unable to create subscription  
**After:** Subscriptions created with 14-day free trial

### Issue 3: Missing Tables ✅
**Before:** orders, customers, subscription tables missing  
**After:** All 11 tables present and configured

### Issue 4: Missing Foreign Keys ✅
**Before:** No referential integrity  
**After:** All relationships properly defined

### Issue 5: No Default Plans ✅
**Before:** Empty plans table  
**After:** 3 plans ready (Free, Starter, Business)

---

## 📊 DATABASE TABLES OVERVIEW

```
┌─────────────────────────────────────────────┐
│           LINKKART DATABASE                 │
├─────────────────────────────────────────────┤
│                                             │
│  CORE TABLES                                │
│  ├── stores (store information)            │
│  ├── products (product catalog)            │
│  ├── analytics_events (tracking)           │
│  └── admins (admin auth)                   │
│                                             │
│  USER MANAGEMENT                            │
│  └── users (JWT authentication)            │
│                                             │
│  ORDERS & CUSTOMERS                         │
│  ├── customers (customer info)             │
│  └── orders (order management)             │
│                                             │
│  SUBSCRIPTION SYSTEM                        │
│  ├── plans (subscription plans)            │
│  ├── subscriptions (store subscriptions)   │
│  ├── payments (payment tracking)           │
│  └── invoices (invoice generation)         │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 🎯 SUBSCRIPTION PLANS

| Plan | Price | Products | Orders | Trial |
|------|-------|----------|--------|-------|
| **Free** | ₹0/month | 5 | 50/month | ✅ 14 days |
| **Starter** | ₹299/month | 50 | Unlimited | ✅ 14 days |
| **Business** | ₹599/month | Unlimited | Unlimited | ✅ 14 days |

### Features Breakdown

**Free Plan:**
- 5 products maximum
- 50 orders per month
- WhatsApp integration
- Basic store page
- LinkKart branding

**Starter Plan:**
- 50 products
- Unlimited orders
- Remove LinkKart branding
- Custom store link
- Email support

**Business Plan:**
- Unlimited products
- Unlimited orders
- Priority email support
- Store analytics (views, clicks)
- Export data to Excel

---

## 🔐 ADMIN CREDENTIALS

**Email:** admin@linkkart.com  
**Password:** password  
**Phone:** 8639424962

⚠️ **IMPORTANT:** Change this password after first login!

---

## 🧪 TESTING PROCEDURES

### Test 1: Product Creation
```bash
# From mobile app:
1. Login to app
2. Go to Products tab
3. Click "Add Product"
4. Fill in:
   - Name: Test Product
   - Price: 999
   - Description: Test description
5. Click Save

Expected: ✅ Product created successfully
```

### Test 2: Subscription Creation
```bash
# From mobile app:
1. Go to Payment/Subscription screen
2. Select "Starter" plan (₹299)
3. Click "Subscribe"
4. Should show: "14-day free trial started"

Expected: ✅ Subscription created with trial status
```

### Test 3: API Health Check
```bash
curl https://api.linkkart.shop/api/health

Expected:
{
  "success": true,
  "status": "healthy",
  "timestamp": 1234567890
}
```

### Test 4: Get Plans
```bash
curl https://api.linkkart.shop/api/v1/plans

Expected:
{
  "success": true,
  "data": [
    {"name": "Free", "price": 0, ...},
    {"name": "Starter", "price": 299, ...},
    {"name": "Business", "price": 599, ...}
  ]
}
```

---

## 🚨 TROUBLESHOOTING

### Error: "Table already exists"
**Solution:** This is OK! The SQL uses `CREATE TABLE IF NOT EXISTS`

### Error: "Duplicate entry for key 'PRIMARY'"
**Solution:** This is OK! The SQL uses `INSERT IGNORE` for default data

### Error: "Cannot add foreign key constraint"
**Solution:** 
1. Check if parent tables exist first
2. Import the SQL file again (it creates tables in correct order)

### Error: "Access denied for user"
**Solution:** Update database credentials in:
- `backend/public/index.php`
- `backend/public/api.php`
- `backend/public/api_payments.php`

### Error: "Unknown database 'linkkart'"
**Solution:**
```sql
CREATE DATABASE linkkart CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

---

## 📞 SUPPORT & MONITORING

### Check API Logs
```bash
# View recent errors
tail -f backend/public/storage/logs/api.log

# Search for specific errors
grep "Database error" backend/public/storage/logs/api.log
```

### Check MySQL Logs
```bash
# View MySQL error log
tail -f /var/log/mysql/error.log
```

### Monitor Database Size
```sql
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS "Size (MB)"
FROM information_schema.TABLES
WHERE table_schema = 'linkkart'
ORDER BY (data_length + index_length) DESC;
```

---

## 🎉 SUCCESS CRITERIA

Your database is ready when:

✅ All 11 tables exist  
✅ 3 subscription plans are configured  
✅ Admin account is accessible  
✅ Product creation works from mobile app  
✅ Subscription creation works from mobile app  
✅ No errors in API logs  
✅ All foreign keys are set  
✅ All indexes are created  

---

## 📝 POST-DEPLOYMENT TASKS

### Immediate (Today)
- [ ] Change admin password
- [ ] Test all mobile app features
- [ ] Monitor error logs for 1 hour
- [ ] Test payment flow with Razorpay test mode

### This Week
- [ ] Set up automated database backups
- [ ] Configure monitoring alerts
- [ ] Test with real users
- [ ] Optimize slow queries if any

### Ongoing
- [ ] Daily database backups
- [ ] Weekly performance review
- [ ] Monthly security audit
- [ ] Scale as needed

---

## 🔄 ROLLBACK PLAN

If something goes wrong:

```bash
# 1. Stop the application
# (if using systemd or similar)

# 2. Restore from backup
mysql -u root -p linkkart < backup_YYYYMMDD_HHMMSS.sql

# 3. Verify restoration
mysql -u root -p linkkart -e "SHOW TABLES;"

# 4. Restart application
```

---

## 📚 RELATED FILES

- `COMPLETE_DATABASE_SETUP_PRODUCTION.sql` - Complete database schema
- `PRODUCTION_DATABASE_AUDIT_COMPLETE.md` - Detailed audit report
- `verify_production_database.php` - Verification script
- `IMPORT_THIS_SQL_NOW.sql` - Subscription tables only (superseded)

---

**Ready to deploy? Follow Step 1 above! 🚀**

**Questions? Check the troubleshooting section or review the audit document.**

