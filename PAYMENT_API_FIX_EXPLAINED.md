# Payment API Fix - Complete Explanation

## Problem Summary
The payment API is failing with `DATABASE_ERROR` when trying to create subscriptions or process payments in the mobile app.

## Root Cause
The `stores` table is missing two critical columns that the payment API code expects:
1. **`owner_id`** - Used to verify store ownership during payment
2. **`subscription_id`** - Used to link stores to their active subscriptions

### Why This Happened
The original database migration for the `stores` table (created in `backend/database/migrations/2024_01_01_000001_create_stores_table.php`) didn't include these columns. They were supposed to be added later by the subscription migration (`backend/database/migrations/create_subscription_tables.sql`), but that migration was never run on production.

## The Error Flow
1. User tries to upgrade plan in mobile app
2. Mobile app calls `/api/v1/subscriptions` (POST) to create subscription
3. Backend code in `api_payments.php` tries to query: `SELECT id, owner_id FROM stores WHERE id = ?`
4. **ERROR**: Column `owner_id` doesn't exist in stores table
5. API returns `DATABASE_ERROR` to mobile app

## The Fix

### Option 1: Run SQL Directly on Production (RECOMMENDED)
Use the file: **`FIX_STORES_TABLE_COMPLETE.sql`**

Run each command ONE BY ONE in your MySQL console:

```sql
-- Add owner_id column
ALTER TABLE stores 
ADD COLUMN owner_id BIGINT(20) UNSIGNED NULL AFTER id;

-- Add subscription_id column
ALTER TABLE stores 
ADD COLUMN subscription_id INT NULL AFTER owner_id;

-- Add indexes
ALTER TABLE stores ADD INDEX stores_owner_id_index (owner_id);
ALTER TABLE stores ADD INDEX idx_stores_subscription (subscription_id);

-- Add foreign key
ALTER TABLE stores
ADD CONSTRAINT fk_stores_subscription 
FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;
```

**Important Notes:**
- If you get "Duplicate column name" error, that column already exists - skip that command
- If you get "Duplicate key name" error, that index already exists - skip that command
- Run each ALTER TABLE separately, don't copy-paste all at once

### Option 2: Create Laravel Migration (For Future)
This won't fix production immediately, but will ensure the columns exist in future deployments.

## How Razorpay Integration Works

### Payment Flow
1. **Create Subscription** (`/api/v1/subscriptions` POST)
   - Creates subscription record with 14-day trial
   - Links subscription to store
   - Returns subscription_id

2. **Create Payment Order** (`/api/v1/payments/create-order` POST)
   - Takes subscription_id and amount
   - Validates amount matches plan price
   - Calls Razorpay API to create order
   - Returns razorpay_order_id and key_id

3. **User Pays** (Razorpay Checkout in Mobile App)
   - Mobile app opens Razorpay payment UI
   - User completes payment
   - Razorpay returns payment_id and signature

4. **Verify Payment** (`/api/v1/payments/verify` POST)
   - Backend verifies signature using Razorpay secret
   - Updates payment status to 'success'
   - Updates subscription status to 'active'

### Razorpay Library
Located at: `backend/lib/Razorpay.php`

Key methods:
- `createOrder()` - Creates Razorpay order
- `verifySignature()` - Verifies payment signature
- `fetchPayment()` - Gets payment details
- `capturePayment()` - Captures authorized payment
- `refundPayment()` - Refunds a payment

### Mobile App Integration
File: `mobile-app/lib/screens/payment_screen.dart`

Uses `razorpay_flutter` package to:
1. Display plan details and pricing
2. Create subscription via API
3. Create payment order via API
4. Open Razorpay checkout
5. Handle payment success/failure
6. Verify payment with backend

## Testing After Fix

1. **Run the SQL fix** on production database
2. **Verify columns exist**:
   ```sql
   DESCRIBE stores;
   ```
   You should see `owner_id` and `subscription_id` columns

3. **Test in mobile app**:
   - Open any store
   - Go to subscription/plans screen
   - Try to upgrade to Starter or Business plan
   - Payment should now work without DATABASE_ERROR

4. **Check subscription was created**:
   ```sql
   SELECT * FROM subscriptions ORDER BY id DESC LIMIT 5;
   ```

5. **Check store was linked**:
   ```sql
   SELECT id, name, subscription_id FROM stores WHERE id IN (4, 5);
   ```

## Why owner_id Can Be NULL
The `owner_id` column is for future user management features. Right now:
- Stores don't have user accounts yet
- The payment API checks `owner_id` but allows NULL values
- This is fine for current functionality

When you add user authentication later, you'll populate `owner_id` with the user's ID.

## Files Modified/Created
- ✅ `FIX_STORES_TABLE_COMPLETE.sql` - Main fix (run this)
- ✅ `FIX_STORES_TABLE_SAFE.sql` - Alternative with checks
- ✅ `PAYMENT_API_FIX_EXPLAINED.md` - This document

## Files to Review
- `backend/public/api_payments.php` - Payment API endpoints
- `backend/lib/Razorpay.php` - Razorpay integration
- `mobile-app/lib/screens/payment_screen.dart` - Mobile payment UI
- `backend/database/migrations/create_subscription_tables.sql` - Subscription schema

## Next Steps
1. ✅ Run `FIX_STORES_TABLE_COMPLETE.sql` on production
2. ⏳ Test payment in mobile app
3. ⏳ If still failing, check error logs for new issues
4. ⏳ Consider creating Laravel migration for future deployments
