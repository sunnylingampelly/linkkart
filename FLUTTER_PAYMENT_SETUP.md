# 💳 Flutter Payment Setup Guide

## ✅ What's Been Created

I've created complete payment screens for the Flutter mobile app:

### 📱 Screens Created

1. **`pricing_screen.dart`** - Shows all subscription plans
   - Beautiful card design for each plan
   - Free, Starter, and Business plans
   - "Most Popular" badge on Starter
   - Feature list for each plan
   - CTA buttons

2. **`payment_screen.dart`** - Handles Razorpay payment
   - Plan summary with features
   - Price breakdown (with GST)
   - 14-day trial information
   - Razorpay integration
   - Payment success/failure handling

3. **`plan.dart`** - Plan model
   - Complete plan data structure
   - JSON serialization
   - Helper methods

### 🔌 API Integration

Updated `api_service.dart` with:
- `getPlans()` - Fetch all plans
- `createSubscription()` - Create subscription
- `getSubscription()` - Get subscription details
- `createPaymentOrder()` - Create Razorpay order
- `verifyPayment()` - Verify payment signature
- `getPaymentHistory()` - Get payment history

---

## 🚀 Setup Instructions

### Step 1: Add Razorpay Dependency

Add to `mobile-app/pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Existing dependencies...
  http: ^1.1.0
  shared_preferences: ^2.2.2
  image_picker: ^1.0.4
  
  # Add this for Razorpay
  razorpay_flutter: ^1.3.6
```

Then run:
```bash
cd mobile-app
flutter pub get
```

---

### Step 2: Android Configuration

#### Update `mobile-app/android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34  // Update to 34
    
    defaultConfig {
        minSdkVersion 21  // Razorpay requires min 21
        targetSdkVersion 34
    }
}
```

#### Update `mobile-app/android/app/src/main/AndroidManifest.xml`:

Add inside `<application>` tag:

```xml
<application>
    <!-- Existing code... -->
    
    <!-- Razorpay Activity -->
    <activity
        android:name="com.razorpay.CheckoutActivity"
        android:configChanges="keyboard|keyboardHidden|orientation|screenSize"
        android:exported="true"
        android:theme="@style/CheckoutTheme">
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
        </intent-filter>
    </activity>
</application>
```

---

### Step 3: iOS Configuration (if needed)

#### Update `mobile-app/ios/Podfile`:

```ruby
platform :ios, '12.0'  # Razorpay requires iOS 12+
```

Then run:
```bash
cd mobile-app/ios
pod install
```

---

### Step 4: Import Plan Model

The Plan model is already created at `mobile-app/lib/models/plan.dart`.

Make sure to export it in your models file if you have one.

---

### Step 5: How to Use

#### Navigate to Pricing Screen:

```dart
import 'package:your_app/screens/pricing_screen.dart';

// From anywhere in your app
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PricingScreen(
      storeId: yourStoreId,
    ),
  ),
);
```

#### The Flow:

1. User opens **Pricing Screen**
2. Sees 3 plans (Free, Starter, Business)
3. Clicks on a plan:
   - **Free Plan**: Creates subscription immediately (14-day trial)
   - **Paid Plans**: Opens **Payment Screen**
4. **Payment Screen** shows:
   - Plan details
   - Price breakdown
   - GST calculation
   - Trial information
5. User clicks "Start Free Trial"
6. Razorpay opens (payment gateway)
7. User completes payment
8. Payment verified with backend
9. Subscription activated!

---

## 🎨 UI Features

### Pricing Screen
- ✅ Dark theme (matches your app)
- ✅ Purple accent color (#5B6CFF)
- ✅ Card-based design
- ✅ "Most Popular" badge
- ✅ Feature checkmarks
- ✅ Responsive layout
- ✅ Loading states
- ✅ Error handling

### Payment Screen
- ✅ Plan summary card
- ✅ Price breakdown
- ✅ GST calculation (18%)
- ✅ Trial information banner
- ✅ Processing state
- ✅ Success/failure handling
- ✅ Terms & conditions

---

## 💰 Payment Flow

### 1. Create Subscription
```dart
final subscription = await apiService.createSubscription(
  storeId,
  planId,
);
// Returns: {subscription_id, status, trial_ends_at}
```

### 2. Create Payment Order
```dart
final order = await apiService.createPaymentOrder(
  subscriptionId,
  amount,
);
// Returns: {razorpay_order_id, key_id, amount}
```

### 3. Open Razorpay
```dart
var options = {
  'key': orderData['key_id'],
  'amount': amount * 100, // Paise
  'order_id': orderData['razorpay_order_id'],
  'name': 'LinkKart',
  'description': 'Starter Plan Subscription',
};

razorpay.open(options);
```

### 4. Handle Success
```dart
void _handlePaymentSuccess(PaymentSuccessResponse response) {
  // Verify with backend
  await apiService.verifyPayment(
    response.orderId,
    response.paymentId,
    response.signature,
  );
  
  // Show success message
  // Navigate back
}
```

---

## 🧪 Testing

### Test with Razorpay Test Mode

**Test Card Details:**
- Card Number: `4111 1111 1111 1111`
- Expiry: Any future date
- CVV: Any 3 digits
- Name: Any name

**Test UPI:**
- UPI ID: `success@razorpay`

**Test Netbanking:**
- Select any bank
- Use "success" as credentials

---

## 🔧 Configuration

### Update Razorpay Keys

In `backend/public/api_payments.php`:

```php
$razorpayKeyId = 'rzp_test_YOUR_KEY_ID';
$razorpayKeySecret = 'YOUR_KEY_SECRET';
```

Get keys from: https://dashboard.razorpay.com/app/keys

---

## 📱 Screenshots Flow

### 1. Pricing Screen
```
┌─────────────────────────┐
│  Choose Your Plan       │
├─────────────────────────┤
│                         │
│  ┌─────────────────┐   │
│  │ Free - ₹0/mo    │   │
│  │ ✓ 5 products    │   │
│  │ ✓ 50 orders     │   │
│  │ [Start Free]    │   │
│  └─────────────────┘   │
│                         │
│  ┌─────────────────┐   │
│  │ ⭐ MOST POPULAR │   │
│  │ Starter-₹299/mo │   │
│  │ ✓ 50 products   │   │
│  │ ✓ Unlimited     │   │
│  │ [Choose Plan]   │   │
│  └─────────────────┘   │
│                         │
│  ┌─────────────────┐   │
│  │ Business-₹599   │   │
│  │ ✓ Unlimited     │   │
│  │ ✓ Analytics     │   │
│  │ [Choose Plan]   │   │
│  └─────────────────┘   │
└─────────────────────────┘
```

### 2. Payment Screen
```
┌─────────────────────────┐
│  Payment                │
├─────────────────────────┤
│                         │
│  ┌─────────────────┐   │
│  │ 👑 Starter Plan │   │
│  │ Monthly         │   │
│  │                 │   │
│  │ ✓ 50 products   │   │
│  │ ✓ Unlimited     │   │
│  └─────────────────┘   │
│                         │
│  ┌─────────────────┐   │
│  │ Subscription    │   │
│  │         ₹299.00 │   │
│  │ GST (18%)       │   │
│  │          ₹53.82 │   │
│  │ ─────────────── │   │
│  │ Total   ₹352.82 │   │
│  └─────────────────┘   │
│                         │
│  ℹ️ 14 Days Free Trial │
│  You won't be charged  │
│  now. Payment starts   │
│  after trial ends.     │
│                         │
│  [Start Free Trial]    │
└─────────────────────────┘
```

### 3. Razorpay Screen
```
┌─────────────────────────┐
│  Razorpay Checkout      │
├─────────────────────────┤
│  Pay ₹352.82            │
│                         │
│  [Card]  [UPI]  [Net]  │
│                         │
│  Card Number            │
│  ┌───────────────────┐ │
│  │ 4111 1111 1111    │ │
│  └───────────────────┘ │
│                         │
│  Expiry        CVV      │
│  ┌──────┐  ┌────────┐ │
│  │12/25 │  │ 123    │ │
│  └──────┘  └────────┘ │
│                         │
│  [Pay ₹352.82]         │
└─────────────────────────┘
```

---

## ✅ Checklist

### Before Testing
- [ ] Add `razorpay_flutter` to pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] Update Android minSdkVersion to 21
- [ ] Add Razorpay activity to AndroidManifest.xml
- [ ] Update Razorpay keys in backend
- [ ] Start backend API (port 8000)

### Testing Steps
- [ ] Open app
- [ ] Navigate to pricing screen
- [ ] See all 3 plans
- [ ] Click on Starter plan
- [ ] See payment screen
- [ ] Click "Start Free Trial"
- [ ] Razorpay opens
- [ ] Enter test card details
- [ ] Complete payment
- [ ] See success message
- [ ] Subscription activated

---

## 🐛 Troubleshooting

### Issue: Razorpay not opening
**Solution**: Check AndroidManifest.xml has Razorpay activity

### Issue: Payment fails immediately
**Solution**: Verify Razorpay keys are correct

### Issue: "Unauthorized" error
**Solution**: Make sure auth token is set in AppConstants

### Issue: Network error
**Solution**: Check backend is running on port 8000

### Issue: Build fails
**Solution**: Update minSdkVersion to 21 in build.gradle

---

## 📚 Resources

- [Razorpay Flutter Docs](https://razorpay.com/docs/payments/payment-gateway/flutter-integration/)
- [Razorpay Test Cards](https://razorpay.com/docs/payments/payments/test-card-details/)
- [Razorpay Dashboard](https://dashboard.razorpay.com/)

---

## 🎉 Summary

**Created:**
- ✅ Pricing screen with 3 plans
- ✅ Payment screen with Razorpay
- ✅ Plan model
- ✅ API integration
- ✅ Complete payment flow

**Next Steps:**
1. Add `razorpay_flutter` dependency
2. Update Android configuration
3. Test with Razorpay test mode
4. Get live Razorpay keys for production

**The payment system is ready to use!** 💰

