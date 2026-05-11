# Firebase Phone Authentication Setup Guide

## 🔥 Step-by-Step: Enable Phone OTP in Firebase

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **linkkart-76fe1**

---

### Step 2: Enable Phone Authentication

1. **In the left sidebar**, click on **"Build"** → **"Authentication"**
2. Click on **"Get Started"** (if first time) or **"Sign-in method"** tab
3. In the **Sign-in providers** list, find **"Phone"**
4. Click on **"Phone"**
5. Toggle the **"Enable"** switch to ON
6. Click **"Save"**

✅ **Phone authentication is now enabled!**

---

### Step 3: Add SHA-1 Fingerprint (IMPORTANT for Android)

Phone authentication on Android requires SHA-1 fingerprint for security.

#### Get Your SHA-1 Fingerprint:

**Option A: Debug SHA-1 (for testing)**
```bash
cd mobile-app/android
./gradlew signingReport
```

Or on Windows:
```bash
cd mobile-app/android
gradlew.bat signingReport
```

Look for output like:
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:...
SHA1: A1:B2:C3:D4:E5:F6:... ← COPY THIS
SHA-256: XX:XX:XX:...
```

**Option B: Quick Method (Debug Key)**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### Add SHA-1 to Firebase:

1. In Firebase Console, go to **Project Settings** (gear icon ⚙️ at top left)
2. Scroll down to **"Your apps"** section
3. Find your Android app: **com.linkkart.app**
4. Click **"Add fingerprint"**
5. Paste your **SHA-1** fingerprint
6. Click **"Save"**

✅ **SHA-1 fingerprint added!**

---

### Step 4: Download Updated google-services.json (Optional but Recommended)

After adding SHA-1:
1. In Firebase Console → **Project Settings**
2. Scroll to **"Your apps"** → **Android app**
3. Click **"google-services.json"** download button
4. Replace the file at: `mobile-app/android/app/google-services.json`

---

### Step 5: Configure Phone Number Testing (Optional - for Development)

To test without using real SMS (saves money during development):

1. In Firebase Console → **Authentication** → **Sign-in method**
2. Scroll down to **"Phone numbers for testing"**
3. Click **"Add phone number"**
4. Add test numbers with verification codes:
   - Phone: `+91 9999999999`
   - Code: `123456`
   - Click **"Add"**

Now you can test with this number without receiving real SMS!

---

### Step 6: Set Up App Verification (Important for Production)

Firebase uses **reCAPTCHA** or **SafetyNet** to prevent abuse.

#### For Development:
- Firebase automatically uses **SafetyNet** on Android
- No additional setup needed

#### For Production:
1. In Firebase Console → **Authentication** → **Settings** tab
2. Under **"App verification"**, ensure **SafetyNet** is enabled
3. Consider enabling **"App Check"** for additional security

---

### Step 7: Enable Phone Authentication Quota (Optional)

By default, Firebase allows:
- **10 SMS per phone number per day**
- **50,000 verifications per month (FREE)**

To increase limits:
1. Go to **Authentication** → **Settings** → **Usage**
2. Click **"Upgrade"** if you need more
3. Or contact Firebase support for quota increase

---

## 🎯 Quick Checklist

Before building your app, make sure:

- [ ] ✅ Phone authentication is **enabled** in Firebase Console
- [ ] ✅ SHA-1 fingerprint is **added** to Firebase project
- [ ] ✅ `google-services.json` is in `mobile-app/android/app/`
- [ ] ✅ Package name matches: `com.linkkart.app`
- [ ] ✅ (Optional) Test phone numbers added for development

---

## 🧪 Testing Phone Authentication

### Test with Real Phone Number:
1. Build and install the APK on your Android device
2. Open the app
3. Enter your real phone number (e.g., `+91 9876543210`)
4. You'll receive an SMS with 6-digit code
5. Enter the code to verify

### Test with Test Phone Number (No SMS):
1. Add test number in Firebase Console (see Step 5)
2. In the app, enter the test number (e.g., `+91 9999999999`)
3. Enter the test code you configured (e.g., `123456`)
4. Verification succeeds without SMS!

---

## 🚨 Common Issues & Solutions

### Issue 1: "This app is not authorized to use Firebase Authentication"
**Solution**: 
- Make sure SHA-1 fingerprint is added
- Rebuild the app after adding SHA-1
- Wait 5-10 minutes for Firebase to propagate changes

### Issue 2: "SMS not received"
**Solution**:
- Check phone number format (must include country code: `+91`)
- Verify phone authentication is enabled in Firebase
- Check Firebase quota (10 SMS per number per day)
- Try test phone numbers instead

### Issue 3: "Invalid verification code"
**Solution**:
- Make sure you're entering the correct 6-digit code
- Code expires after 60 seconds - request new code
- Check if you're using test number with correct test code

### Issue 4: "SafetyNet verification failed"
**Solution**:
- Add SHA-1 fingerprint to Firebase
- Make sure Google Play Services is installed on device
- Use a real Android device (not emulator for production testing)

---

## 💰 Cost Breakdown (FREE Tier)

| Service | Free Tier | Cost After |
|---------|-----------|------------|
| Phone Auth | 50,000 verifications/month | $0.01 per verification |
| SMS (India) | Included in verification | ~₹0.15 per SMS |
| SMS (USA) | Included in verification | ~$0.01 per SMS |

**For your business:**
- First 50,000 users/month = **FREE** ✅
- After that = ₹0.75 per user (very affordable!)

---

## 📱 Next Steps After Firebase Setup

1. **Build the APK**:
   ```bash
   cd mobile-app
   flutter build apk --release
   ```

2. **Install on your Android phone**:
   - Transfer APK to phone
   - Enable "Install from unknown sources"
   - Install and test

3. **Test the complete flow**:
   - Welcome screen
   - Phone number entry
   - OTP verification
   - Store creation
   - Dashboard access

4. **Deploy to Production**:
   - Get release SHA-1 fingerprint
   - Add to Firebase
   - Build signed release APK
   - Upload to Google Play Store

---

## 🔗 Useful Links

- [Firebase Phone Auth Docs](https://firebase.google.com/docs/auth/android/phone-auth)
- [Firebase Console](https://console.firebase.google.com/)
- [Get SHA-1 Fingerprint Guide](https://developers.google.com/android/guides/client-auth)
- [Firebase Pricing](https://firebase.google.com/pricing)

---

## ✅ Summary

Your Firebase project is configured with:
- **Project ID**: linkkart-76fe1
- **Package Name**: com.linkkart.app
- **API Key**: AIzaSyC_P8ybrYEFm6yiw4EoOGRvjQiOBacOrEg

**What you need to do NOW:**
1. ✅ Enable Phone authentication in Firebase Console
2. ✅ Get SHA-1 fingerprint and add to Firebase
3. ✅ (Optional) Add test phone numbers
4. ✅ Build APK and test on your phone

**Time needed**: 5-10 minutes

Let me know when you've completed these steps and we'll build the APK! 🚀
