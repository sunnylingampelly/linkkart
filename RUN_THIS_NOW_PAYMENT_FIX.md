# 🚨 QUICK FIX - Run This Now

## ✅ Status Update
Good news! The columns (`owner_id` and `subscription_id`) and indexes are already in your database. 

## ⚠️ Remaining Issue
There's a data type mismatch preventing the foreign key constraint. Run these commands:

```sql
-- Fix the data type mismatch
ALTER TABLE stores MODIFY COLUMN subscription_id INT NULL;

-- Add the foreign key constraint
ALTER TABLE stores ADD CONSTRAINT fk_stores_subscription 
FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;

-- Verify it worked
DESCRIBE stores;
```

## What Was The Problem?
The `subscription_id` column was created with the wrong data type. The `subscriptions.id` is `INT`, but `stores.subscription_id` was `BIGINT`, causing the foreign key constraint to fail.

## After Running These Commands
Test the payment flow in your mobile app. The DATABASE_ERROR should now be resolved!

## Files
- Foreign key fix: `RUN_THIS_FOREIGN_KEY_FIX.sql`
- Full explanation: `PAYMENT_API_FIX_EXPLAINED.md`
