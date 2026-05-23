# 🚨 DO THIS NOW - Payment Fix

## The Problem
You're copying multiple commands at once. MySQL is getting confused by the error messages mixed with commands.

## The Solution
**Copy ONE command at a time.** Wait for it to finish. Then copy the next one.

---

## Step 1: Check Current Types
Copy this, paste, press Enter:
```sql
DESCRIBE stores;
```
Look for `subscription_id` - note its type (probably `bigint` or `int`)

---

## Step 2: Fix the Data Type
Copy this, paste, press Enter:
```sql
ALTER TABLE stores MODIFY COLUMN subscription_id INT NULL;
```
Should say: `Query OK, 0 rows affected`

---

## Step 3: Add Foreign Key
Copy this, paste, press Enter:
```sql
ALTER TABLE stores ADD CONSTRAINT fk_stores_subscription FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;
```
Should say: `Query OK` OR `Duplicate foreign key` (both are fine)

---

## Step 4: Verify
Copy this, paste, press Enter:
```sql
SHOW CREATE TABLE stores\G
```
Look for `CONSTRAINT fk_stores_subscription` in the output

---

## ✅ Done!
Now test payment in your mobile app. The DATABASE_ERROR should be fixed.

---

## If Step 3 Fails
If you still get the incompatible error, run this first:
```sql
SELECT COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'stores' AND COLUMN_NAME = 'subscription_id';
```
Then:
```sql
SELECT COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'subscriptions' AND COLUMN_NAME = 'id';
```
Send me both results and I'll help further.
