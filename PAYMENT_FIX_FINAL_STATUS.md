# Payment API Fix - Final Status

## ✅ What's Already Done
Based on your MySQL output, these are already in place:
- ✅ `owner_id` column exists in stores table
- ✅ `subscription_id` column exists in stores table  
- ✅ `stores_owner_id_index` index created
- ✅ `idx_stores_subscription` index created

## ⚠️ What Still Needs to Be Fixed
**Foreign Key Constraint** - Data type mismatch error:
```
ERROR 3780 (HY000): Referencing column 'subscription_id' and referenced column 'id' 
in foreign key constraint 'fk_stores_subscription' are incompatible.
```

### The Issue
- `subscriptions.id` is type `INT`
- `stores.subscription_id` was created as `BIGINT` (wrong type)
- Foreign keys require exact type match

### The Solution
Run these 2 commands in MySQL:

```sql
-- 1. Fix the data type
ALTER TABLE stores MODIFY COLUMN subscription_id INT NULL;

-- 2. Add the foreign key
ALTER TABLE stores ADD CONSTRAINT fk_stores_subscription 
FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;
```

## Why This Matters
The foreign key constraint ensures:
1. **Data integrity** - Can't set invalid subscription_id
2. **Automatic cleanup** - When subscription is deleted, store's subscription_id becomes NULL
3. **Database consistency** - Prevents orphaned references

## After Running the Fix

### Test Payment Flow
1. Open mobile app
2. Go to any store (ID 4 or 5)
3. Navigate to subscription/plans screen
4. Try to upgrade to Starter (₹299) or Business (₹599) plan
5. Payment should work without DATABASE_ERROR

### Verify in Database
```sql
-- Check the foreign key was created
SHOW CREATE TABLE stores;

-- Test creating a subscription
INSERT INTO subscriptions (store_id, plan_id, status, starts_at, ends_at, created_at, updated_at)
VALUES (4, 2, 'trial', NOW(), DATE_ADD(NOW(), INTERVAL 1 MONTH), NOW(), NOW());

-- Check it worked
SELECT * FROM subscriptions WHERE store_id = 4 ORDER BY id DESC LIMIT 1;
```

## Payment Flow After Fix

### 1. Create Subscription (Mobile App)
```
POST /api/v1/subscriptions
{
  "store_id": 4,
  "plan_id": 2
}
```
**Response:**
```json
{
  "success": true,
  "message": "Subscription created with 14-day free trial",
  "data": {
    "subscription_id": 8,
    "plan": "Starter",
    "status": "trial",
    "trial_ends_at": "2026-06-03 14:30:00",
    "ends_at": "2026-06-20 14:30:00"
  }
}
```

### 2. Create Payment Order
```
POST /api/v1/payments/create-order
{
  "subscription_id": 8,
  "amount": 299.00
}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "payment_id": 12,
    "razorpay_order_id": "order_abc123xyz",
    "amount": 299.00,
    "currency": "INR",
    "key_id": "rzp_test_YOUR_KEY_ID"
  }
}
```

### 3. User Pays (Razorpay Checkout)
- Mobile app opens Razorpay UI
- User enters card/UPI details
- Razorpay processes payment
- Returns: `payment_id`, `order_id`, `signature`

### 4. Verify Payment
```
POST /api/v1/payments/verify
{
  "razorpay_order_id": "order_abc123xyz",
  "razorpay_payment_id": "pay_xyz789abc",
  "razorpay_signature": "signature_hash"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Payment verified successfully",
  "data": {
    "payment_id": 12,
    "subscription_id": 8,
    "status": "success"
  }
}
```

### 5. Subscription Activated
- Subscription status changes from `trial` to `active`
- Store's `subscription_id` is updated to link to subscription
- User gets full plan features

## Razorpay Configuration

### Environment Variables (backend/.env)
```env
RAZORPAY_KEY_ID=rzp_test_YOUR_KEY_ID
RAZORPAY_KEY_SECRET=YOUR_KEY_SECRET
WEBHOOK_SECRET=YOUR_WEBHOOK_SECRET
```

### Test Mode vs Live Mode
Currently using **test mode** (key starts with `rzp_test_`):
- Use test cards: 4111 1111 1111 1111
- No real money charged
- For production, switch to live keys (start with `rzp_live_`)

## Common Issues & Solutions

### Issue: "AMOUNT_MISMATCH" error
**Cause:** Mobile app sending wrong amount
**Fix:** Ensure mobile app sends exact plan price (no GST added)

### Issue: "SUBSCRIPTION_EXISTS" error  
**Cause:** Store already has active subscription
**Fix:** Currently disabled for testing, but in production should prevent duplicate subscriptions

### Issue: "INVALID_SIGNATURE" error
**Cause:** Razorpay signature verification failed
**Fix:** Check RAZORPAY_KEY_SECRET is correct in .env

### Issue: "PAYMENT_NOT_FOUND" error
**Cause:** Payment record not created before verification
**Fix:** Ensure create-order was called successfully first

## Files Reference
- 📄 `RUN_THIS_NOW_PAYMENT_FIX.md` - Quick commands to run
- 📄 `RUN_THIS_FOREIGN_KEY_FIX.sql` - SQL commands for foreign key fix
- 📄 `PAYMENT_API_FIX_EXPLAINED.md` - Detailed explanation
- 📄 `FIX_FOREIGN_KEY_ISSUE.sql` - Diagnostic queries + fix
- 💻 `backend/public/api_payments.php` - Payment API code
- 💻 `backend/lib/Razorpay.php` - Razorpay integration
- 📱 `mobile-app/lib/screens/payment_screen.dart` - Mobile payment UI

## Next Steps
1. ✅ Run the 2 SQL commands above
2. ⏳ Test payment in mobile app
3. ⏳ If successful, consider switching to Razorpay live mode for production
4. ⏳ Set up Razorpay webhook for automatic payment status updates
