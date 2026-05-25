# 🚀 Production Database Update - Quick Summary

## What You're Adding
1. **Size Features** - Products can now have multiple sizes with size charts
2. **Subscription System** - Complete monetization with plans, payments, and invoices
3. **Store Subscriptions** - Each store gets assigned a plan (Free by default)

## Files Created for You

### Option 1: Complete SQL File (Fastest)
📄 **`PRODUCTION_UPDATE_COMPLETE.sql`**
- All commands in one file
- Copy entire file and run in MySQL
- Has verification queries built-in

### Option 2: Step-by-Step Guide (Safest)
📄 **`RUN_ON_PRODUCTION_STEP_BY_STEP.md`**
- Detailed instructions for each step
- Explains what each command does
- Includes troubleshooting

## Quick Start

### 1. Backup First!
```bash
mysqldump -u linkkart -p linkkart > backup_$(date +%Y%m%d).sql
```

### 2. Connect to MySQL
```bash
mysql -u linkkart -p linkkart
```

### 3. Run the Update

**Option A: Run complete file**
```bash
mysql -u linkkart -p linkkart < PRODUCTION_UPDATE_COMPLETE.sql
```

**Option B: Copy commands manually**
Open `PRODUCTION_UPDATE_COMPLETE.sql` and copy commands one by one into MySQL.

## What Gets Created

### New Columns in Products Table
- `sizes` (JSON) - Store multiple sizes like ["S", "M", "L", "XL"]
- `has_sizes` (BOOLEAN) - Flag if product has sizes
- `size_chart_image` (VARCHAR) - URL to size chart image

### New Tables
- `plans` - Subscription plans (Free, Starter, Business)
- `subscriptions` - Store subscriptions with trial/active status
- `payments` - Razorpay payment records
- `invoices` - Invoice generation and tracking

### Updated Stores Table
- `subscription_id` (INT) - Links store to active subscription
- Foreign key constraint to subscriptions table

## Default Plans

| Plan | Price | Products | Orders | Features |
|------|-------|----------|--------|----------|
| Free | ₹0 | 5 | 50/month | Basic features, LinkKart branding |
| Starter | ₹299 | 50 | Unlimited | Remove branding, custom link |
| Business | ₹599 | Unlimited | Unlimited | Analytics, priority support |

## After Running

### Verify Everything Worked
```sql
-- Check products have size columns
DESCRIBE products;

-- Check subscription tables exist
SHOW TABLES LIKE '%plan%';
SHOW TABLES LIKE '%subscription%';

-- Check plans inserted
SELECT * FROM plans;

-- Check stores have subscriptions
SELECT s.id, s.name, p.name as plan 
FROM stores s 
JOIN subscriptions sub ON s.subscription_id = sub.id 
JOIN plans p ON sub.plan_id = p.id;
```

### Expected Results
- ✅ Products table has 3 new columns
- ✅ 4 new tables created (plans, subscriptions, payments, invoices)
- ✅ 3 plans inserted (Free, Starter, Business)
- ✅ All existing stores assigned to Free plan
- ✅ Foreign key constraint linking stores to subscriptions

## Common Issues

### "Duplicate column name"
**Cause:** Column already exists
**Solution:** Skip that ALTER TABLE command

### "Table already exists"
**Cause:** Table was already created
**Solution:** Skip that CREATE TABLE command

### "Duplicate entry for key"
**Cause:** Plans already inserted
**Solution:** Skip the INSERT command

### "Foreign key constraint fails"
**Cause:** Referenced table doesn't exist yet
**Solution:** Run CREATE TABLE commands first, then ALTER TABLE

## Testing After Update

### Test 1: Create Product with Sizes
In mobile app:
1. Add new product
2. Enable "Has Sizes"
3. Add sizes: S, M, L, XL
4. Upload size chart image
5. Save product

### Test 2: View Subscription Plans
In mobile app:
1. Go to subscription/plans screen
2. Should see 3 plans (Free, Starter, Business)
3. Current plan should show "Free"

### Test 3: Try Upgrading Plan
In mobile app:
1. Select Starter or Business plan
2. Click "Upgrade"
3. Should open payment screen
4. Complete payment flow

## Rollback (If Needed)

If something goes wrong:
```bash
mysql -u linkkart -p linkkart < backup_YYYYMMDD.sql
```

## Need Help?

If you encounter errors:
1. Check the error message
2. Look in "Common Issues" section above
3. Check `RUN_ON_PRODUCTION_STEP_BY_STEP.md` for detailed troubleshooting
4. Send me the error message

## Summary

✅ **Size Features** - Products can have multiple sizes
✅ **Subscription System** - Complete monetization ready
✅ **Free Plan** - All existing stores get Free plan
✅ **Payment Ready** - Razorpay integration ready to use
✅ **Backward Compatible** - Existing products/stores work as before

Your production database will be fully updated and ready for the new features!
