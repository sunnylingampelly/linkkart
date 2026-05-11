# 📱 Install LinkKart APK - Quick Guide

## 🎯 APK Location
```
mobile-app/build/app/outputs/flutter-apk/app-debug.apk
```

## 🚀 Installation Steps

### Method 1: Using ADB (Recommended)

1. **Connect your phone** to computer via USB
2. **Enable USB Debugging** on your phone
3. **Uninstall old version** (important!):
   ```bash
   adb uninstall com.vashynova.linkkart
   ```
4. **Install new APK**:
   ```bash
   adb install mobile-app/build/app/outputs/flutter-apk/app-debug.apk
   ```

### Method 2: Direct Transfer

1. **Copy APK** to your phone:
   - Via USB cable → Copy to Downloads folder
   - Via Google Drive/Dropbox → Upload and download on phone
   - Via WhatsApp → Send to yourself

2. **Install on phone**:
   - Open file manager
   - Navigate to Downloads
   - Tap on `app-debug.apk`
   - Allow "Install from unknown sources" if prompted
   - Tap Install

## ✅ What's Fixed

- ✅ **No more crashes on startup**
- ✅ **Works offline** (no internet needed for launch)
- ✅ **Google Fonts issue fixed**
- ✅ **Better error handling**
- ✅ **Corrupted data auto-cleanup**

## 🧪 Test Checklist

After installation, test these:

1. **Launch App**
   - [ ] App opens successfully
   - [ ] Splash screen shows
   - [ ] Welcome screen appears

2. **Phone Authentication**
   - [ ] Enter phone number
   - [ ] Receive OTP (use 123456 for testing)
   - [ ] Login successful

3. **Create Store**
   - [ ] Enter store name
   - [ ] Upload logo (optional)
   - [ ] Store created

4. **Add Product**
   - [ ] Navigate to Products tab
   - [ ] Tap + button
   - [ ] Fill product details
   - [ ] Upload image
   - [ ] Add stock quantity
   - [ ] Product saved

5. **View Dashboard**
   - [ ] Home tab shows stats
   - [ ] Products tab shows products
   - [ ] Profile tab works

6. **QR Code & Share**
   - [ ] Profile → QR Code
   - [ ] QR code displays
   - [ ] Share options work

## 🐛 If App Still Crashes

1. **Uninstall completely**:
   ```bash
   adb uninstall com.vashynova.linkkart
   ```

2. **Clear cache**:
   ```bash
   adb shell pm clear com.vashynova.linkkart
   ```

3. **Check logs**:
   ```bash
   adb logcat | grep -i "flutter"
   ```

4. **Send me the error** from logcat

## 📞 Backend Setup Required

Make sure backend is running:

1. **Start Laravel backend**:
   ```bash
   cd backend
   php artisan serve --host=0.0.0.0 --port=8000
   ```

2. **Update API URL** in app if needed:
   - For real device, use your computer's IP
   - Find IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
   - Example: `http://192.168.1.100:8000/api/v1`

## 🎉 Ready to Go!

Your LinkKart app is now ready to use. The crash issue has been fixed with:
- Google Fonts offline mode
- Better error handling
- Explicit SDK configuration
- Data validation

**Enjoy your beautiful, modern store management app! 🚀**
