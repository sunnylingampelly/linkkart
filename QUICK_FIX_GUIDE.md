# Quick Fix Guide - Network Connection Issue

## ✅ PROBLEM FIXED!

The 404 error was caused by **incorrect API endpoint configuration**.

---

## What Was Wrong

```
App was trying to access: http://192.168.1.25:8000/api.php/stores ❌
Backend actually uses:      http://192.168.1.25:8000/api/v1/stores ✅
```

---

## What I Fixed

**File**: `mobile-app/lib/utils/constants.dart`

Changed the base URL and endpoints to match the backend API structure:

```dart
// Base URL (removed /api.php)
static const List<String> baseUrls = [
  'http://192.168.1.25:8000',  // ✅ Correct
];

// Endpoints (added /api/v1 prefix)
static const String storesEndpoint = '/api/v1/stores';      // ✅
static const String productsEndpoint = '/api/v1/products';  // ✅
static const String analyticsEndpoint = '/api/v1/analytics'; // ✅
```

---

## What You Need to Do Now

### Step 1: Rebuild the APK

Run this command:
```bash
build-apk-fixed.bat
```

**Time**: 5-10 minutes

### Step 2: Install on Phone

APK will be at:
```
mobile-app\build\app\outputs\flutter-apk\app-release.apk
```

Transfer to phone and install.

### Step 3: Test

1. Open app
2. Create a store
3. Should work! ✅

---

## Backend Status

✅ Backend is running on: `192.168.1.25:8000`
✅ API endpoint verified: `/api/v1/stores`
✅ Returns 27 stores successfully

---

## If IP Changes

You have 2 options:

**Option 1**: Use API Settings in App
- Open app → Create Store screen
- Tap settings icon (top right)
- Enter new IP address
- Test connection
- Save

**Option 2**: Update Code and Rebuild
- Edit `mobile-app/lib/utils/constants.dart`
- Change IP in `baseUrls` array
- Run `build-apk-fixed.bat`

---

## Summary

| Item | Status |
|------|--------|
| Problem Identified | ✅ Wrong endpoint paths |
| Code Fixed | ✅ constants.dart updated |
| Backend Verified | ✅ Running on 192.168.1.25:8000 |
| API Tested | ✅ /api/v1/stores working |
| Build Script Ready | ✅ build-apk-fixed.bat |
| Next Step | 🔨 Rebuild APK |

---

**Ready to build!** Run `build-apk-fixed.bat` now.
