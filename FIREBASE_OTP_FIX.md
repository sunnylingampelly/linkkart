# 🔥 Firebase OTP Not Working - Fix Guide

## ❌ Problem Found

Your `google-services.json` has an empty `oauth_client` array, which means the **SHA-1 fingerprint** hasn't been added to Firebase. This is **required** for phone authentication to work.

---

## ✅ Solution: Add SHA-1 Fingerprint

### Step 1: Get Your SHA-1 Fingerprint

Open terminal in your project and run:

```bash
cd mobile-app/android
./gradlew signingReport
```

**On Windows:**
```bash
cd mobile-app\android
gradlew signingReport
```

Look for output like this:
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:...
SHA1: A1:B2:C3:D4:E5:F6:... ← COPY THIS
SHA-256: XX:XX:XX:...
```

**Copy the SHA1 value** (it looks like: `A1:B2:C3:D4:E5:F6:...`)

---

### Step 2: Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **linkkart-76fe1**
3. Click the **gear icon** (⚙️) → **Project Settings**
4. Scroll down to **Your apps** section
5. Find your Android app: `com.vashynova.linkkart`
6. Click **Add fingerprint** button
7. Paste your **SHA-1** fingerprint
8. Click **Save**

---

### Step 3: Download New google-services.json

1. In Firebase Console, same page
2. Click **Download google-services.json** button
3. Replace the file at: `mobile-app/android/app/google-services.json`

---

### Step 4: Enable Phone Authentication

1. In Firebase Console, go to **Authentication**
2. Click **Sign-in method** tab
3. Find **Phone** in the list
4. Click on it
5. Toggle **Enable**
6. Click **Save**

---

### Step 5: Rebuild the App

```bash
cd mobile-app
flutter clean
flutter pub get
flutter build apk --debug
```

---

## 🧪 Test OTP

After completing all steps:

1. Install the new APK
2. Open the app
3. Enter phone number
4. Click "Continue"
5. You should receive OTP! ✅

---

## 🐛 Still Not Working?

### Check 1: Firebase Console Logs

1. Go to Firebase Console
2. Click **Authentication** → **Users**
3. Try sending OTP
4. Check if any errors appear

### Check 2: Phone Number Format

Make sure you're entering:
- **10 digits only**: `9876543210`
- **No spaces or special characters**
- App will add `+91` automatically

### Check 3: Test Phone Numbers

For testing without real SMS, add test phone numbers:

1. Firebase Console → **Authentication**
2. **Sign-in method** tab
3. Scroll to **Phone numbers for testing**
4. Add: `+919876543210` with code `123456`
5. Now you can test without real SMS

---

## 📱 Alternative: Use Test Mode

If you want to test without SMS:

### Add Test Phone Number:

1. Firebase Console → **Authentication** → **Sign-in method**
2. Scroll to **Phone numbers for testing**
3. Click **Add phone number**
4. Phone: `+918639424962`
5. Code: `123456`
6. Save

Now when you enter `8639424962`, it will accept `123456` as OTP without sending SMS!

---

## 🔍 Quick Debug

### Check if Firebase is initialized:

Look for this in app logs:
```
Firebase initialized successfully
```

### Check if OTP is being sent:

Look for these logs:
```
Sending OTP to: +919876543210
Code sent successfully
```

### Check for errors:

Look for:
```
Verification failed: [error message]
```

---

## ⚠️ Common Issues

### Issue 1: "invalid-phone-number"
**Solution:** Make sure phone number is 10 digits, no spaces

### Issue 2: "too-many-requests"
**Solution:** Wait 1 hour or use test phone number

### Issue 3: "network-request-failed"
**Solution:** Check internet connection

### Issue 4: No SMS received
**Solution:** 
- Check phone number is correct
- Check SMS inbox and spam
- Try test phone number instead

---

## 🎯 Summary

**To fix OTP:**

1. ✅ Get SHA-1 fingerprint: `gradlew signingReport`
2. ✅ Add to Firebase Console
3. ✅ Download new google-services.json
4. ✅ Enable Phone Authentication
5. ✅ Rebuild app
6. ✅ Test!

**Or use test phone number for quick testing:**
- Phone: `+918639424962`
- OTP: `123456`

---

## 📞 Need Help?

If still not working, send me:
1. Screenshot of Firebase Console → Authentication → Sign-in method
2. SHA-1 fingerprint you added
3. Error message from app logs

---

**Most likely fix:** Add SHA-1 fingerprint to Firebase Console! 🔥
