# 🧪 Minimal Test APK - Crash Diagnosis

## 🎯 What I Did

Created a **super minimal version** of the app that removes ALL potential crash causes:

### Removed:
- ❌ Google Fonts (using system fonts only)
- ❌ Splash screen with animations
- ❌ Complex navigation
- ❌ API calls
- ❌ SharedPreferences
- ❌ Image loading
- ❌ All complex screens

### What's Left:
- ✅ Just a simple screen with "LinkKart" text
- ✅ Basic gradient background
- ✅ One button (does nothing yet)
- ✅ Providers (but not used)

## 📦 New Minimal APK

**Location**: `mobile-app/build/app/outputs/flutter-apk/app-debug.apk`

**Status**: Just built (fresh)

## 🚀 Install and Test

```bash
adb uninstall com.vashynova.linkkart
adb install mobile-app/build/app/outputs/flutter-apk/app-debug.apk
```

## 🎯 Expected Result

You should see:
- Purple gradient background
- White rounded square with store icon
- "LinkKart" text
- "App is working!" text
- White "Continue" button

## ❓ Two Scenarios

### Scenario 1: This Works ✅
**Meaning**: The crash was caused by:
- Google Fonts
- Splash screen animations
- Complex navigation
- Or one of the removed features

**Next Step**: I'll add features back one by one to find the culprit

### Scenario 2: Still Crashes ❌
**Meaning**: The problem is deeper:
- Android version incompatibility
- Device-specific issue
- Gradle/build configuration
- Missing system libraries

**Next Step**: I NEED the crash logs to proceed

## 🔍 If Still Crashes - GET LOGS

This is **CRITICAL** - without logs I'm working blind!

### Get Logs Now:

1. **Open CMD**
2. **Run**:
   ```bash
   adb logcat -c
   adb logcat > D:\linkkart\crash_log.txt
   ```
3. **Keep CMD open**
4. **Open app on phone**
5. **Wait for crash**
6. **Press Ctrl+C in CMD**
7. **Open** `D:\linkkart\crash_log.txt`
8. **Find lines with**:
   - "FATAL"
   - "AndroidRuntime"
   - "Exception"
   - "Error"
9. **Send me those lines**

## 📱 Alternative: Check Device Info

Maybe your device is too old or too new?

```bash
adb shell getprop ro.build.version.sdk
```

This shows Android API level:
- 21-23 = Android 5.x-6.x
- 24-25 = Android 7.x
- 26-27 = Android 8.x
- 28 = Android 9
- 29 = Android 10
- 30 = Android 11
- 31 = Android 12
- 32-33 = Android 13
- 34 = Android 14

**Send me this number!**

## 🎯 What This Test Tells Us

If this minimal app:
- **Works** → Problem is in removed features (fixable!)
- **Crashes** → Problem is in build config or device (need logs!)

## ⚡ Quick Test Command

```bash
adb uninstall com.vashynova.linkkart && adb install mobile-app/build/app/outputs/flutter-apk/app-debug.apk && echo "Now open the app!"
```

---

**Test this NOW and tell me:**
1. Does it work? (Yes/No)
2. If no, send crash logs
3. Send Android API level number
