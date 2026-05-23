# 🔴 START HERE - Fresh MySQL Session

## The Problem
Your MySQL session has old error messages mixed with new commands. This is confusing MySQL.

## The Solution

### Step 1: Exit MySQL
In your current MySQL session, type:
```
exit;
```
Press Enter.

### Step 2: Reconnect to MySQL
```bash
mysql -u linkkart -p linkkart
```
Enter your password.

### Step 3: Run Diagnostic
After you see a clean `mysql>` prompt, copy and paste this ENTIRE block:

```sql
SELECT '=== stores.subscription_id type ===' AS info;
SELECT COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'stores' AND COLUMN_NAME = 'subscription_id';

SELECT '=== subscriptions.id type ===' AS info;
SELECT COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'subscriptions' AND COLUMN_NAME = 'id';
```

**Send me the output** and I'll tell you exactly what to run next.

---

## Why This Matters
The foreign key is failing because the data types don't match. I need to see:
- What type is `stores.subscription_id` currently?
- What type is `subscriptions.id`?

Once I know this, I can give you the exact command to fix it.

---

## Alternative: Just Test Payment
If you want to skip the foreign key constraint for now, you can test the payment in your mobile app. The foreign key is optional - it just provides data integrity. The payment API should work without it as long as the `owner_id` and `subscription_id` columns exist (which they do).

Try the payment in your mobile app and let me know if you still get DATABASE_ERROR.
