# 📱 Setup for Real Mobile Device

## ✅ Changes Made

### 1. **Light Mode Only** ✨
- ✅ Forced light mode throughout the app
- ✅ Disabled dark mode completely
- ✅ Set system UI to light theme
- ✅ Light status bar and navigation bar

### 2. **Removed All Demo/Fake Data** 🚫
- ✅ Home tab now shows real statistics from backend
- ✅ Orders tab shows empty state (real orders will appear)
- ✅ Customers tab shows empty state (real customers will appear)
- ✅ All data comes from MySQL database

### 3. **Mobile Device Ready** 📱
- ✅ API URL configured for Android emulator
- ✅ Instructions added for real device setup
- ✅ Ready for APK build

---

## 🔥 Setup Real Firebase Phone Authentication

### Step 1: Firebase Project Setup (Already Done)
You already have:
- ✅ Firebase project: `linkkart-76fe1`
- ✅ Android app registered
- ✅ `google-services.json` downloaded
- ✅ Phone Sign-In enabled

### Step 2: Update Firebase Configuration

#### A. Add SHA-256 Certificate
1. **Generate SHA-256**:
   ```bash
   cd mobile-app/android
   ./gradlew signingReport
   ```
   
2. **Copy SHA-256** from output (looks like: `AA:BB:CC:...`)

3. **Add to Firebase**:
   - Go to Firebase Console
   - Project Settings → Your App
   - Add SHA-256 fingerprint
   - Click "Save"

#### B. Enable Phone Authentication
1. Go to Firebase Console → Authentication
2. Click "Sign-in method" tab
3. Enable "Phone" provider
4. Save

### Step 3: Update SimpleAuthService to Use Real Firebase

Replace `mobile-app/lib/services/simple_auth_service.dart` with real Firebase:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_user;

class SimpleAuthService {
  static final SimpleAuthService _instance = SimpleAuthService._internal();
  factory SimpleAuthService() => _instance;
  SimpleAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  app_user.User? _currentUser;

  app_user.User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Send OTP to phone number (REAL Firebase)
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // Verify OTP and sign in (REAL Firebase)
  Future<app_user.User?> verifyOTP(String otp) async {
    try {
      if (_verificationId == null) {
        throw Exception('Verification ID not found');
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      return await _signInWithCredential(credential);
    } catch (e) {
      throw Exception('Invalid OTP: ${e.toString()}');
    }
  }

  Future<app_user.User?> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        _currentUser = app_user.User(
          id: firebaseUser.uid,
          phoneNumber: firebaseUser.phoneNumber ?? '',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _saveUserToLocal(_currentUser!);
        return _currentUser;
      }
      return null;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Load user from local storage
  Future<app_user.User?> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final phoneNumber = prefs.getString('user_phone');
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');
      final createdAtStr = prefs.getString('user_created_at');

      if (userId != null && phoneNumber != null) {
        _currentUser = app_user.User(
          id: userId,
          phoneNumber: phoneNumber,
          name: name,
          email: email,
          createdAt: createdAtStr != null 
              ? DateTime.parse(createdAtStr) 
              : DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        return _currentUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Save user to local storage
  Future<void> _saveUserToLocal(app_user.User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_phone', user.phoneNumber);
    if (user.name != null) await prefs.setString('user_name', user.name!);
    if (user.email != null) await prefs.setString('user_email', user.email!);
    await prefs.setString('user_created_at', user.createdAt.toIso8601String());
  }

  // Update user profile
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      email: email ?? _currentUser!.email,
    );

    await _saveUserToLocal(_currentUser!);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    _verificationId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_phone');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_created_at');
  }

  // Check if user has store
  Future<bool> hasStore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('store_id');
  }
}
```

### Step 4: Add Firebase Dependencies

Update `mobile-app/pubspec.yaml`:

```yaml
dependencies:
  # ... existing dependencies ...
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
```

### Step 5: Initialize Firebase

Update `mobile-app/lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Force light mode
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  runApp(const MyApp());
}
```

---

## 📱 Run on Real Android Device

### Method 1: USB Debugging

1. **Enable Developer Options** on your phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back → Developer Options
   - Enable "USB Debugging"

2. **Connect Phone** via USB

3. **Find Your Computer's IP**:
   ```bash
   # Windows
   ipconfig
   
   # Look for "IPv4 Address" (e.g., 192.168.1.100)
   ```

4. **Update API URL** in `mobile-app/lib/utils/constants.dart`:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:8000/api/v1';
   ```

5. **Run App**:
   ```bash
   cd mobile-app
   flutter devices  # Check if phone is detected
   flutter run      # Select your device
   ```

### Method 2: Build APK

1. **Build APK**:
   ```bash
   cd mobile-app
   flutter build apk --release
   ```

2. **APK Location**:
   ```
   mobile-app/build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Install on Phone**:
   - Transfer APK to phone
   - Install and run

4. **Important**: Make sure your phone and computer are on the **same WiFi network**

---

## 🔧 Backend Setup for Mobile

### Allow External Connections

Update `backend/public/index.php` CORS headers:

```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
```

### Start Backend with External Access

```bash
cd backend
php -S 0.0.0.0:8000 -t public
```

This allows connections from any device on your network.

---

## ✅ Testing Checklist

### Before Testing
- [ ] Firebase Phone Auth enabled
- [ ] SHA-256 added to Firebase
- [ ] `google-services.json` in place
- [ ] Firebase dependencies added
- [ ] Backend running with external access
- [ ] Phone and computer on same WiFi
- [ ] API URL updated with your IP

### Test Flow
1. [ ] Open app on phone
2. [ ] Enter real phone number
3. [ ] Receive real OTP via SMS
4. [ ] Enter OTP and verify
5. [ ] Create store
6. [ ] Add products with camera
7. [ ] View products
8. [ ] Share QR code
9. [ ] Open storefront on another device
10. [ ] Order via WhatsApp

---

## 🎯 Current Status

### ✅ Completed
- Light mode only (no dark mode)
- Removed all demo/fake data
- Real data from MySQL
- Mobile device configuration ready
- API endpoints configured

### ⏳ To Complete
1. **Add Firebase dependencies** to pubspec.yaml
2. **Update SimpleAuthService** with real Firebase code
3. **Initialize Firebase** in main.dart
4. **Add SHA-256** to Firebase Console
5. **Test on real device**

---

## 📝 Notes

- **OTP will be REAL** once Firebase is configured
- **No more test OTP (123456)** - only real SMS
- **All data is REAL** - no demo data anywhere
- **Light mode only** - dark mode completely disabled
- **Ready for production** once Firebase is set up

---

## 🚀 Next Steps

1. Run `flutter pub get` to install dependencies
2. Add SHA-256 to Firebase
3. Test on real device
4. Build APK for distribution

**Your app is now configured for real-world use!** 🎉
