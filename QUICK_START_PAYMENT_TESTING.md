# ⚡ Quick Start - Payment Testing

## 🚀 Run These Commands Now

### 1. Install Flutter Dependencies (2 minutes)

```bash
cd mobile-app
flutter pub get
```

**What this does:** Downloads the `razorpay_flutter` package and all dependencies.

---

### 2. Start Backend API (1 minute)

Open a new terminal:

```bash
cd backend/public
php -S 192.168.1.2:8000 api.php
```

**Keep this running!** The mobile app needs this to work.

**Test it works:**
```bash
curl http://192.168.1.2:8000/api/health
```

Should return: `{"status":"ok"}`

---

### 3. Run Mobile App (2 minutes)

Open another terminal:

```bash
cd mobile-app
flutter run
```

**Or use Android Studio / VS Code:**
- Press F5 or click Run button
- Select your device/emulator

---

## 🧪 Test the Payment Flow (5 minutes)

### Step 1: Navigate to Pricing Screen

Add this code somewhere in your app (like a button):

```dart
import 'package:linkkart/screens/pricing_screen.dart';

// On button press:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PricingScreen(storeId: 1), // Use your store ID
  ),
);
```

### Step 2: See the Plans

You should see:
- ✅ Free Plan (₹0/month)
- ✅ Starter Plan (₹299/month) - Most Popular
- ✅ Business Plan (₹599/month)

### Step 3: Click on Starter Plan

- Opens Payment Screen
- Shows plan details
- Shows price: ₹299 + GST ₹53.82 = **₹352.82**

### Step 4: Click "Start Free Trial"

- Razorpay checkout opens
- Enter test card details:
  - **Card:** 4111 1111 1111 1111
  - **Expiry:** 12/25
  - **CVV:** 123
  - **Name:** Test User

### Step 5: Complete Payment

- Payment processes
- Success message shows
- Subscription activated! ✅

---

## 🔧 Before Testing - Update Razorpay Keys

### Get Test Keys:

1. Go to https://dashboard.razorpay.com/
2. Sign up / Login
3. Go to **Settings → API Keys**
4. Click **Generate Test Keys**
5. Copy **Key ID** and **Key Secret**

### Update Backend:

Open `backend/public/api_payments.php` and update lines 8-9:

```php
$razorpayKeyId = 'rzp_test_YOUR_KEY_ID';      // Replace this
$razorpayKeySecret = 'YOUR_KEY_SECRET';        // Replace this
```

**Save the file!**

---

## 💳 Test Cards

### Success Card:
```
Card Number: 4111 1111 1111 1111
Expiry: 12/25
CVV: 123
Name: Test User
```

### Failure Card (to test error handling):
```
Card Number: 4111 1111 1111 1112
Expiry: 12/25
CVV: 123
Name: Test User
```

### Test UPI:
```
UPI ID: success@razorpay
```

---

## 🐛 Quick Troubleshooting

### "razorpay_flutter not found"
```bash
cd mobile-app
flutter clean
flutter pub get
```

### "Cannot connect to backend"
- Check backend is running: `http://192.168.1.2:8000/api/health`
- Make sure phone and computer are on same WiFi
- Check IP address is correct (192.168.1.2)

### "Payment fails immediately"
- Check Razorpay keys are updated in `api_payments.php`
- Make sure you're using TEST keys (rzp_test_...)

### "Build fails"
```bash
cd mobile-app
flutter clean
flutter pub get
flutter run
```

---

## 📊 Check if Payment Worked

### Check Database:

```sql
-- Check subscriptions
SELECT * FROM subscriptions ORDER BY id DESC LIMIT 5;

-- Check payments
SELECT * FROM payments ORDER BY id DESC LIMIT 5;

-- Check revenue
SELECT SUM(amount) as total_revenue FROM payments WHERE status = 'completed';
```

### Check Backend Logs:

```bash
tail -f backend/storage/logs/laravel.log
```

---

## ✅ Success Checklist

After testing, you should have:

- [ ] Flutter dependencies installed
- [ ] Backend API running
- [ ] Mobile app running
- [ ] Razorpay keys updated
- [ ] Pricing screen opens
- [ ] All 3 plans visible
- [ ] Payment screen opens
- [ ] Razorpay checkout opens
- [ ] Test payment succeeds
- [ ] Success message shows
- [ ] Subscription created in database

---

## 🎯 What's Next?

### 1. Add Navigation (15 minutes)
- Add "Upgrade" button in your app
- See `HOW_TO_ADD_PRICING_TO_APP.md`

### 2. Handle Plan Limits (30 minutes)
- Check product count before adding
- Show upgrade prompt when limit reached

### 3. Show Current Plan (20 minutes)
- Display current plan in settings
- Show features included

### 4. Production Setup (1 hour)
- Get live Razorpay keys
- Test with real card
- Deploy to production

---

## 📁 Important Files

### Flutter:
- `mobile-app/lib/screens/pricing_screen.dart` - Pricing UI
- `mobile-app/lib/screens/payment_screen.dart` - Payment UI
- `mobile-app/lib/models/plan.dart` - Plan model
- `mobile-app/lib/services/api_service.dart` - API calls

### Backend:
- `backend/public/api_payments.php` - Payment endpoints
- `backend/lib/Razorpay.php` - Razorpay integration

### Documentation:
- `PAYMENT_INTEGRATION_COMPLETE.md` - Full guide
- `HOW_TO_ADD_PRICING_TO_APP.md` - Integration guide
- `QUICK_START_PAYMENT_TESTING.md` - This file

---

## 🎉 Summary

**3 Commands to Start:**
```bash
# Terminal 1
cd mobile-app && flutter pub get

# Terminal 2
cd backend/public && php -S 192.168.1.2:8000 api.php

# Terminal 3
cd mobile-app && flutter run
```

**Then:**
1. Update Razorpay keys
2. Navigate to pricing screen
3. Test payment with test card
4. Done! ✅

**Total Time:** ~10 minutes

---

**Created:** May 6, 2026  
**Status:** Ready to Test ✅  

🚀 **Let's test payments now!**
