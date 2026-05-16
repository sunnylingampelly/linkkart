# 🚀 Connect Mobile App to Production URLs

**Status:** API, Storefront, and Admin deployed to production ✅  
**Next Step:** Configure mobile app to use live URLs

---

## 🎯 What You Need

Before starting, make sure you have:

- [ ] Production API URL (e.g., `https://api.linkkart.shop`)
- [ ] Production Storefront URL (e.g., `https://linkkart.shop`)
- [ ] All 3 systems are working in production
- [ ] SSL certificates installed (HTTPS working)

---

## 📝 Step-by-Step Configuration

### Step 1: Update Mobile App Constants

Open the file: `mobile-app/lib/utils/constants.dart`

**Find this section:**
```dart
static const List<String> baseUrls = [
  'http://192.168.0.9:8000',   // Current PC IP (primary)
  'http://192.168.1.30:8000',
  // ... other local IPs
];

static String _baseUrl = 'http://192.168.0.9:8000';

static const String storefrontUrl = 'http://192.168.0.9:3002';
```

**Replace with your production URLs:**
```dart
static const List<String> baseUrls = [
  'https://api.linkkart.shop',      // Production API (primary)
  'http://192.168.0.9:8000',        // Local fallback for development
];

static String _baseUrl = 'https://api.linkkart.shop';

static const String storefrontUrl = 'https://linkkart.shop';
```

---

### Step 2: Update API Endpoints (if needed)

Check if there are any hardcoded URLs in other files:

**Search for local URLs:**
```bash
cd mobile-app
grep -r "localhost:8000" lib/
grep -r "192.168" lib/
grep -r "http://10.0.2.2" lib/
```

**Replace any found with production URLs**

---

### Step 3: Test Production API First

Before building the app, verify your production API is working:

**Test 1: Health Check**
```bash
curl https://api.linkkart.shop/api/health
```

**Expected Response:**
```json
{
  "success": true,
  "message": "LinkKart API is running with MySQL",
  "version": "1.0.0",
  "database": "Connected"
}
```

**Test 2: Get Stores**
```bash
curl https://api.linkkart.shop/api/v1/stores
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Store Name",
      "slug": "store-slug",
      ...
    }
  ]
}
```

**Test 3: Admin Login**
```bash
curl -X POST https://api.linkkart.shop/api/v1/admin/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@linkkart.com",
    "password": "password"
  }'
```

---

### Step 4: Clean and Rebuild Mobile App

**Important:** You must rebuild the app after changing URLs!

```bash
cd mobile-app

# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Build debug APK for testing
flutter build apk --debug

# Or run directly on connected device
flutter run
```

---

### Step 5: Test Mobile App with Production

Once the app is installed:

#### Test 1: App Startup
- Open the app
- Check console/logs for:
  ```
  ✅ API Discovery: Found reachable backend at https://api.linkkart.shop
  ```

#### Test 2: Create Store
- Try creating a new store
- Verify it appears in production database
- Check on storefront: `https://linkkart.shop`

#### Test 3: Add Products
- Add products to your store
- Verify images upload correctly
- Check products appear on storefront

#### Test 4: View Dashboard
- Check statistics load
- Verify orders display
- Test all tabs (Products, Orders, Customers)

#### Test 5: QR Code
- Generate QR code
- Scan it with another device
- Should open: `https://linkkart.shop/store/your-store-slug`

---

## 🔧 Configuration Files to Update

### File 1: `mobile-app/lib/utils/constants.dart`

```dart
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  // API Configuration - PRODUCTION
  static const List<String> baseUrls = [
    'https://api.linkkart.shop',      // Production API (primary)
    'http://192.168.0.9:8000',        // Local development fallback
  ];
  
  static String _baseUrl = 'https://api.linkkart.shop';
  
  static String get baseUrl => _baseUrl;
  static set baseUrl(String url) {
    _baseUrl = url.replaceAll(RegExp(r'/api/v1.*'), '');
  }

  static const String storefrontUrl = 'https://linkkart.shop';
  
  // Rest of the file remains the same...
}
```

### File 2: Check `mobile-app/android/app/src/main/AndroidManifest.xml`

Make sure you have internet permission:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### File 3: Check `mobile-app/lib/main.dart`

Ensure API discovery runs on startup:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Discover production API
  await AppConstants.discoverBaseUrl();
  
  runApp(MyApp());
}
```

---

## 🧪 Complete Testing Checklist

### Backend API Tests
- [ ] `https://api.linkkart.shop/api/health` returns success
- [ ] `https://api.linkkart.shop/api/v1/stores` returns stores
- [ ] Admin login works
- [ ] CORS headers present
- [ ] SSL certificate valid (HTTPS)

### Storefront Tests
- [ ] `https://linkkart.shop` loads homepage
- [ ] Stores display correctly
- [ ] Can view individual store pages
- [ ] WhatsApp buttons work
- [ ] Images load correctly

### Admin Dashboard Tests
- [ ] `https://admin.linkkart.shop` loads
- [ ] Can login with admin credentials
- [ ] Dashboard shows statistics
- [ ] Can view all stores
- [ ] All features work

### Mobile App Tests
- [ ] App connects to production API
- [ ] Can create new store
- [ ] Can add products
- [ ] Images upload successfully
- [ ] Dashboard loads statistics
- [ ] QR code generates correct URL
- [ ] Store appears on storefront
- [ ] Products visible on storefront

---

## 🐛 Troubleshooting

### Issue 1: "Network Error" in Mobile App

**Cause:** App still trying to connect to local IP

**Solution:**
```bash
# 1. Verify constants.dart has production URL
cat mobile-app/lib/utils/constants.dart | grep baseUrl

# 2. Clean and rebuild
cd mobile-app
flutter clean
flutter pub get
flutter build apk --debug

# 3. Uninstall old app from device
# 4. Install new APK
```

### Issue 2: "SSL Handshake Failed"

**Cause:** SSL certificate issue

**Solution:**
```bash
# Test SSL certificate
curl -v https://api.linkkart.shop/api/health

# If certificate is invalid, reinstall:
sudo certbot --nginx -d api.linkkart.shop --force-renewal
```

### Issue 3: "CORS Error"

**Cause:** Backend not allowing mobile app requests

**Solution:**
Check backend CORS configuration in `backend/public/index.php`:
```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
```

### Issue 4: Images Not Uploading

**Cause:** File permissions or storage path issue

**Solution:**
```bash
# On server
sudo chown -R www-data:www-data /var/www/backend/public/storage
sudo chmod -R 775 /var/www/backend/public/storage
```

### Issue 5: App Shows Old Data

**Cause:** App cache

**Solution:**
- Uninstall app completely
- Clear app data
- Reinstall fresh build

---

## 📱 Build Production APK

Once everything is tested and working:

### Step 1: Update Version

Edit `mobile-app/pubspec.yaml`:
```yaml
version: 1.0.0+1  # Increment this for each release
```

### Step 2: Build Release APK

```bash
cd mobile-app

# Build release APK (optimized, smaller size)
flutter build apk --release

# Or build app bundle for Play Store
flutter build appbundle --release
```

### Step 3: Locate APK

**Release APK location:**
```
mobile-app/build/app/outputs/flutter-apk/app-release.apk
```

**App Bundle location (for Play Store):**
```
mobile-app/build/app/outputs/bundle/release/app-release.aab
```

### Step 4: Test Release APK

```bash
# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk

# Or share APK file for manual installation
```

---

## 🌐 Distribution Options

### Option 1: Direct Download from Website

1. Upload APK to your server:
```bash
scp build/app/outputs/flutter-apk/app-release.apk \
  root@YOUR_SERVER:/var/www/storefront/public/downloads/
```

2. Create download page on storefront:
```
https://linkkart.shop/download
```

3. Users download and install APK

### Option 2: Google Play Store

1. Create Google Play Developer account ($25)
2. Create app listing
3. Upload app bundle (`.aab` file)
4. Fill in store listing details
5. Submit for review
6. Wait for approval (1-3 days)

### Option 3: Internal Testing

1. Share APK via email/WhatsApp
2. Users enable "Install from Unknown Sources"
3. Install APK manually
4. Collect feedback

---

## 🔄 Update Process

When you make changes and need to update:

### For Development Testing:
```bash
cd mobile-app
flutter run  # Hot reload works for most changes
```

### For Production Release:
```bash
cd mobile-app

# 1. Update version in pubspec.yaml
# version: 1.0.1+2

# 2. Clean and build
flutter clean
flutter pub get
flutter build apk --release

# 3. Test new APK
# 4. Distribute to users
```

---

## 📊 Monitoring Production

### Check API Logs
```bash
# On server
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/www/backend/storage/logs/laravel.log
```

### Check Database
```bash
# Connect to database
mysql -u linkkart_user -p linkkart

# Check recent stores
SELECT * FROM stores ORDER BY created_at DESC LIMIT 10;

# Check recent products
SELECT * FROM products ORDER BY created_at DESC LIMIT 10;
```

### Monitor Server Resources
```bash
# Check server load
htop

# Check disk space
df -h

# Check memory
free -h
```

---

## ✅ Final Checklist

Before releasing to users:

### Technical
- [ ] Mobile app connects to production API
- [ ] All features tested and working
- [ ] Images upload and display correctly
- [ ] QR codes generate correct URLs
- [ ] App doesn't crash
- [ ] Performance is acceptable
- [ ] Release APK built and tested

### Business
- [ ] Admin credentials changed from default
- [ ] Razorpay payment gateway configured
- [ ] Terms & conditions added
- [ ] Privacy policy added
- [ ] Support contact information added
- [ ] App icon and branding correct

### Distribution
- [ ] APK uploaded to website or Play Store
- [ ] Download instructions created
- [ ] User guide/tutorial prepared
- [ ] Support system ready

---

## 🎉 You're Ready!

Your mobile app is now configured to work with production URLs!

**Next Steps:**
1. Update constants.dart with production URLs ✅
2. Rebuild the app ✅
3. Test thoroughly ✅
4. Build release APK ✅
5. Distribute to users ✅

**Production URLs:**
- API: `https://api.linkkart.shop`
- Storefront: `https://linkkart.shop`
- Admin: `https://admin.linkkart.shop`

**Good luck with your launch! 🚀**
