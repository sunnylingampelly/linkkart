# 🚀 Build Production APK - Quick Guide

**Your Production URLs:**
- ✅ API: https://api.linkkart.shop
- ✅ Storefront: https://linkkart.shop
- ✅ Admin: https://admin.linkkart.shop/login

**Status:** Mobile app updated with production URLs ✅

---

## ⚡ Quick Steps to Build APK

### Step 1: Clean Previous Build (30 seconds)

```bash
cd mobile-app
flutter clean
flutter pub get
```

### Step 2: Build Debug APK for Testing (2-3 minutes)

```bash
flutter build apk --debug
```

**APK Location:**
```
mobile-app/build/app/outputs/flutter-apk/app-debug.apk
```

### Step 3: Install and Test (5 minutes)

**Option A: Connected Device**
```bash
flutter install
```

**Option B: Manual Install**
1. Copy `app-debug.apk` to your phone
2. Install it
3. Open the app

### Step 4: Test with Production

Once installed, test these:

- [ ] App opens successfully
- [ ] Check console logs show: `✅ API Discovery: Found reachable backend at https://api.linkkart.shop`
- [ ] Create a new store
- [ ] Add products with images
- [ ] View dashboard statistics
- [ ] Generate QR code
- [ ] Scan QR code - should open `https://linkkart.shop/store/your-store`

### Step 5: Build Release APK (3-5 minutes)

Once testing is successful:

```bash
flutter build apk --release
```

**Release APK Location:**
```
mobile-app/build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Test Production APIs First

Before building, verify your production APIs are working:

### Test 1: API Health
```bash
curl https://api.linkkart.shop/api/health
```

**Expected:**
```json
{
  "success": true,
  "message": "LinkKart API is running with MySQL"
}
```

### Test 2: Get Stores
```bash
curl https://api.linkkart.shop/api/v1/stores
```

**Expected:**
```json
{
  "success": true,
  "data": [...]
}
```

### Test 3: Storefront
Open in browser: https://linkkart.shop

Should show your storefront homepage with stores.

### Test 4: Admin Dashboard
Open in browser: https://admin.linkkart.shop/login

Should show admin login page.

---

## 📱 Complete Build Commands

### For Testing (Debug Build)
```bash
cd mobile-app
flutter clean
flutter pub get
flutter build apk --debug
flutter install  # If device connected
```

### For Production (Release Build)
```bash
cd mobile-app
flutter clean
flutter pub get
flutter build apk --release
```

### For Play Store (App Bundle)
```bash
cd mobile-app
flutter clean
flutter pub get
flutter build appbundle --release
```

---

## 📂 APK Locations

After building, find your APKs here:

**Debug APK:**
```
mobile-app/build/app/outputs/flutter-apk/app-debug.apk
```

**Release APK:**
```
mobile-app/build/app/outputs/flutter-apk/app-release.apk
```

**App Bundle (for Play Store):**
```
mobile-app/build/app/outputs/bundle/release/app-release.aab
```

---

## 🔍 What Changed

I've updated your mobile app configuration:

### Before (Local):
```dart
static String _baseUrl = 'http://192.168.0.9:8000';
static const String storefrontUrl = 'http://192.168.0.9:3002';
```

### After (Production):
```dart
static String _baseUrl = 'https://api.linkkart.shop';
static const String storefrontUrl = 'https://linkkart.shop';
```

---

## ✅ Testing Checklist

### Before Building:
- [x] Production URLs updated in constants.dart ✅
- [ ] Production API is accessible
- [ ] Production Storefront is accessible
- [ ] Production Admin is accessible

### After Building Debug APK:
- [ ] App installs successfully
- [ ] App connects to production API
- [ ] Can create store
- [ ] Can add products
- [ ] Images upload correctly
- [ ] Dashboard loads data
- [ ] QR code generates correct URL
- [ ] Store appears on production storefront

### After Building Release APK:
- [ ] Release APK installs
- [ ] All features work
- [ ] Performance is good
- [ ] No crashes
- [ ] Ready to distribute

---

## 🐛 Troubleshooting

### Issue: "Network Error"

**Check 1: API is accessible**
```bash
curl https://api.linkkart.shop/api/health
```

**Check 2: SSL certificate is valid**
```bash
curl -v https://api.linkkart.shop/api/health
```

**Check 3: CORS is enabled**
Should see these headers:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
```

**Solution:**
- Verify production API is running
- Check SSL certificate is valid
- Ensure CORS headers are present

### Issue: "App shows old data"

**Solution:**
```bash
# Uninstall old app completely
adb uninstall com.linkkart.app

# Rebuild and install
flutter clean
flutter pub get
flutter build apk --debug
flutter install
```

### Issue: "Images not uploading"

**Check server permissions:**
```bash
# On your server
sudo chown -R www-data:www-data /var/www/backend/public/storage
sudo chmod -R 775 /var/www/backend/public/storage
```

### Issue: "QR code shows wrong URL"

**Verify storefront URL in constants.dart:**
```dart
static const String storefrontUrl = 'https://linkkart.shop';
```

Should NOT have trailing slash or /login

---

## 📤 Distribution Options

### Option 1: Direct Download

1. Upload APK to your server:
```bash
scp mobile-app/build/app/outputs/flutter-apk/app-release.apk \
  user@server:/var/www/html/downloads/linkkart.apk
```

2. Share download link:
```
https://linkkart.shop/downloads/linkkart.apk
```

### Option 2: WhatsApp/Email

1. Locate APK: `mobile-app/build/app/outputs/flutter-apk/app-release.apk`
2. Share via WhatsApp or Email
3. Users download and install

### Option 3: Google Play Store

1. Build app bundle:
```bash
flutter build appbundle --release
```

2. Upload to Play Console:
   - Go to https://play.google.com/console
   - Create app listing
   - Upload `app-release.aab`
   - Submit for review

---

## 🎯 Quick Commands Reference

```bash
# Clean and rebuild
cd mobile-app
flutter clean && flutter pub get

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Install on connected device
flutter install

# Run on connected device
flutter run

# Build for Play Store
flutter build appbundle --release

# Check APK size
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

---

## 📊 Expected Build Times

- **Clean:** 10-20 seconds
- **Pub get:** 10-30 seconds
- **Debug build:** 2-3 minutes
- **Release build:** 3-5 minutes
- **App bundle:** 3-5 minutes

---

## 🎉 You're Ready!

Your mobile app is now configured for production!

**Next Steps:**
1. ✅ URLs updated to production
2. ⏳ Build debug APK and test
3. ⏳ Build release APK
4. ⏳ Distribute to users

**Run this now:**
```bash
cd mobile-app
flutter clean
flutter pub get
flutter build apk --debug
```

**Then test the app and verify it connects to:**
- https://api.linkkart.shop
- https://linkkart.shop

**Good luck! 🚀**
