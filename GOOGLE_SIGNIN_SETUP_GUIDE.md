# 🔐 Google Sign-In Setup Guide for LinkKart

## Current Status
✅ Google Sign-In button already added to login screen
✅ `google_sign_in` package already installed
✅ Firebase Auth service already has `signInWithGoogle()` method
✅ Code is ready - just needs Firebase configuration

## What You Need to Do

### Step 1: Enable Google Sign-In in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your LinkKart project
3. Go to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. Click **Enable** toggle
6. Enter your **Project support email** (your email)
7. Click **Save**

### Step 2: Get SHA-1 Certificate Fingerprint

#### For Debug Build (Development):
```bash
cd mobile-app/android
./gradlew signingReport
```

Or on Windows:
```bash
cd mobile-app\android
gradlew.bat signingReport
```

Look for the **SHA-1** under `Variant: debug` and copy it.

Example output:
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD  ← COPY THIS
SHA-256: ...
```

#### For Release Build (Production):
If you have a release keystore:
```bash
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```

### Step 3: Add SHA-1 to Firebase

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **Your apps** section
3. Click on your Android app
4. Scroll to **SHA certificate fingerprints**
5. Click **Add fingerprint**
6. Paste your SHA-1 from Step 2
7. Click **Save**

### Step 4: Download Updated google-services.json

1. Still in Firebase Console → Project Settings
2. Scroll to **Your apps** → Android app
3. Click **Download google-services.json**
4. Replace the old file at: `mobile-app/android/app/google-services.json`

### Step 5: Verify Android Configuration

Check `mobile-app/android/app/build.gradle`:

```gradle
android {
    ...
    defaultConfig {
        applicationId "com.linkkart.app"  // Your package name
        minSdkVersion 21  // Minimum 21 for Google Sign-In
        ...
    }
}

dependencies {
    ...
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

Check `mobile-app/android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Check `mobile-app/android/app/build.gradle` (at the bottom):

```gradle
apply plugin: 'com.google.gms.google-services'
```

### Step 6: Test Google Sign-In

1. **Rebuild the app:**
   ```bash
   cd mobile-app
   flutter clean
   flutter pub get
   flutter run
   ```

2. **On the login screen:**
   - Click "Sign in with Google" button
   - Select your Google account
   - Grant permissions
   - You should be signed in!

## Troubleshooting

### Error: "PlatformException(sign_in_failed)"
**Solution:** SHA-1 not added or wrong SHA-1
- Re-run `gradlew signingReport`
- Add SHA-1 to Firebase Console
- Download new `google-services.json`
- Rebuild app

### Error: "API not enabled"
**Solution:** Enable Google Sign-In API
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to **APIs & Services** → **Library**
4. Search for "Google Sign-In API"
5. Click **Enable**

### Error: "Developer Error"
**Solution:** Package name mismatch
- Check `applicationId` in `build.gradle` matches Firebase
- Check package name in Firebase Console
- They must be exactly the same

### Error: "Network error"
**Solution:** 
- Check internet connection
- Try on real device (not emulator)
- Check if Google Play Services is updated

### Google Sign-In works but app crashes after
**Solution:** Check if you're handling the user properly
- The code already saves user data
- Check if store creation screen works

## Testing Checklist

- [ ] SHA-1 added to Firebase Console
- [ ] Google Sign-In enabled in Firebase Authentication
- [ ] `google-services.json` downloaded and replaced
- [ ] App rebuilt with `flutter clean && flutter run`
- [ ] Tested on real Android device
- [ ] Google account selection appears
- [ ] Successfully signed in
- [ ] Redirected to Create Store or Dashboard

## Code Already Implemented

### Login Screen (`phone_auth_screen.dart`)
```dart
// Google Sign-In button already added
OutlinedButton.icon(
  onPressed: _signInWithGoogle,
  icon: FaIcon(FontAwesomeIcons.google),
  label: Text('Sign in with Google'),
)
```

### Auth Service (`firebase_auth_service.dart`)
```dart
Future<User?> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  if (googleUser == null) return null;
  
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  
  UserCredential userCredential = await _auth.signInWithCredential(credential);
  await _saveUser(userCredential.user);
  return userCredential.user;
}
```

## Benefits of Google Sign-In

✅ **No OTP issues** - No SMS delivery problems
✅ **Faster** - One-tap sign in
✅ **More reliable** - Works everywhere
✅ **Better UX** - Users prefer it
✅ **Free** - No SMS costs
✅ **Secure** - Google handles security

## Next Steps

1. Follow Steps 1-4 above to configure Firebase
2. Rebuild your app
3. Test Google Sign-In
4. If it works, you can make it the primary login method!

## Need Help?

If you get stuck:
1. Check the error message carefully
2. Verify SHA-1 is correct
3. Make sure `google-services.json` is updated
4. Try `flutter clean` and rebuild
5. Test on a real device (not emulator)

**Once configured, Google Sign-In will work perfectly!** 🚀
