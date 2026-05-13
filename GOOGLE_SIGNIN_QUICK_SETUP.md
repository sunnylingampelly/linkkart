# ⚡ Google Sign-In Quick Setup (5 Minutes)

## Your Code is Ready! Just Configure Firebase:

### 1️⃣ Get SHA-1 (2 minutes)
```bash
cd mobile-app\android
gradlew.bat signingReport
```
Copy the SHA-1 that looks like: `AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD`

### 2️⃣ Firebase Console (2 minutes)
1. Go to https://console.firebase.google.com/
2. Select your project
3. **Authentication** → **Sign-in method** → Enable **Google**
4. **Project Settings** → Your Android app → **Add SHA-1 fingerprint**
5. Download new **google-services.json**

### 3️⃣ Replace File (30 seconds)
Replace: `mobile-app/android/app/google-services.json`

### 4️⃣ Rebuild App (1 minute)
```bash
cd mobile-app
flutter clean
flutter pub get
flutter run
```

### 5️⃣ Test (30 seconds)
- Open app
- Click "Sign in with Google"
- Select account
- Done! ✅

## That's It!

Your app already has:
- ✅ Google Sign-In button on login screen
- ✅ Complete authentication flow
- ✅ User data saving
- ✅ Navigation to dashboard

Just configure Firebase and it works!

## Common Issues

**"sign_in_failed"** → Wrong SHA-1, add it again
**"Developer Error"** → Package name mismatch in Firebase
**"API not enabled"** → Enable Google Sign-In API in Google Cloud Console

## Why Google Sign-In?

- ✅ No OTP delivery issues
- ✅ Works instantly
- ✅ Users love it
- ✅ More reliable than SMS
- ✅ Free (no SMS costs)

**Follow the steps above and you're done!** 🎉
