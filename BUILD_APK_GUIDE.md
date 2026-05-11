# 📱 Build & Install LinkKart APK

## 🎯 Complete Guide to Run on Your Android Phone

---

## Step 1: Find Your Computer's IP Address

### Windows:
```bash
ipconfig
```
Look for **"IPv4 Address"** under your WiFi adapter.
Example: `192.168.1.100`

### Mac/Linux:
```bash
ifconfig
```
Look for **"inet"** address.

**Write down your IP address!** You'll need it in the next step.

---

## Step 2: Update API URL for Your Phone

### Edit the file: `mobile-app/lib/utils/constants.dart`

Replace this line:
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator
```

With your computer's IP:
```dart
static const String baseUrl = 'http://YOUR_IP_HERE:8000/api/v1'; // Real device
```

**Example:**
```dart
static const String baseUrl = 'http://192.168.1.100:8000/api/v1'; // Real device
```

**Save the file!**

---

## Step 3: Start Backend with External Access

Open a new terminal and run:

```bash
cd backend
php -S 0.0.0.0:8000 -t public
```

**Important:** 
- Use `0.0.0.0` (not `localhost`) to allow external connections
- Keep this terminal running
- Your phone and computer must be on the **same WiFi network**

---

## Step 4: Build the APK

### Option A: Build Release APK (Recommended)

```bash
cd mobile-app
flutter build apk --release
```

**APK Location:**
```
mobile-app/build/app/outputs/flutter-apk/app-release.apk
```

### Option B: Build Debug APK (Faster, for testing)

```bash
cd mobile-app
flutter build apk --debug
```

**APK Location:**
```
mobile-app/build/app/outputs/flutter-apk/app-debug.apk
```

**Build time:** 2-5 minutes (first time may take longer)

---

## Step 5: Transfer APK to Your Phone

### Method 1: USB Cable
1. Connect phone to computer via USB
2. Copy APK file to phone's Downloads folder
3. Disconnect phone

### Method 2: Google Drive / Dropbox
1. Upload APK to cloud storage
2. Download on phone

### Method 3: Email
1. Email APK to yourself
2. Download on phone

### Method 4: ADB (If USB debugging enabled)
```bash
adb install mobile-app/build/app/outputs/flutter-apk/app-release.apk
```

---

## Step 6: Install APK on Your Phone

1. **Open File Manager** on your phone
2. **Navigate to Downloads** folder
3. **Tap on the APK file**
4. **Allow installation from unknown sources** (if prompted)
   - Settings → Security → Unknown Sources → Enable
5. **Tap "Install"**
6. **Wait for installation** to complete
7. **Tap "Open"** or find "LinkKart" in your app drawer

---

## Step 7: Test the App

### First Launch:
1. ✅ See beautiful splash screen
2. ✅ Welcome/onboarding screens
3. ✅ Phone authentication screen
4. ✅ Enter your phone number
5. ✅ Enter OTP: `123456` (test OTP for now)
6. ✅ Create your store
7. ✅ Start adding products!

### Test Features:
- ✅ Create store
- ✅ Add products with camera
- ✅ View products
- ✅ Generate QR code
- ✅ Share store link
- ✅ Open storefront on another device
- ✅ Order via WhatsApp

---

## 🔧 Troubleshooting

### Issue: "App not installed"
**Solution:** 
- Uninstall any previous version
- Enable "Unknown Sources" in settings
- Try again

### Issue: "Can't connect to backend"
**Solution:**
- Check if backend is running: `php -S 0.0.0.0:8000 -t public`
- Verify IP address is correct in constants.dart
- Make sure phone and computer are on **same WiFi**
- Try accessing `http://YOUR_IP:8000/api/health` in phone browser

### Issue: "Images not uploading"
**Solution:**
- Grant camera and storage permissions
- Check backend storage folder exists: `backend/storage/products/`

### Issue: "Products not loading"
**Solution:**
- Check backend is running
- Verify API URL is correct
- Check internet connection

---

## 📱 Enable USB Debugging (Optional)

If you want to run directly from Flutter:

1. **Enable Developer Options:**
   - Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings

2. **Enable USB Debugging:**
   - Settings → Developer Options
   - Enable "USB Debugging"

3. **Connect Phone:**
   ```bash
   cd mobile-app
   flutter devices  # Check if detected
   flutter run      # Run directly on phone
   ```

---

## 🚀 Quick Command Reference

### Build APK:
```bash
cd mobile-app
flutter build apk --release
```

### Install via ADB:
```bash
adb install mobile-app/build/app/outputs/flutter-apk/app-release.apk
```

### Run directly on phone:
```bash
cd mobile-app
flutter run
```

### Start backend:
```bash
cd backend
php -S 0.0.0.0:8000 -t public
```

---

## ✅ Pre-Installation Checklist

Before building APK:
- [ ] Updated API URL in `constants.dart` with your IP
- [ ] Backend is running with `0.0.0.0:8000`
- [ ] Phone and computer on same WiFi
- [ ] Saved all changes in code

After installation:
- [ ] App opens successfully
- [ ] Can create store
- [ ] Can add products
- [ ] Can take photos
- [ ] Can share QR code
- [ ] Backend connection works

---

## 🎯 What You'll Get

### Beautiful Mobile App:
- ✨ Light mode only (no dark mode)
- 📱 Native Android app
- 🚀 Fast and smooth
- 📸 Camera integration
- 🔗 QR code generation
- 💚 WhatsApp integration
- 📊 Real-time data sync

### No Demo Data:
- 🚫 No fake orders
- 🚫 No fake customers
- 🚫 No demo statistics
- ✅ Everything is real from MySQL

---

## 📝 Important Notes

### API URL:
- **Must use your computer's IP** (not localhost)
- **Must be on same WiFi** as your phone
- **Backend must run with 0.0.0.0** (not localhost)

### Backend:
```bash
# ✅ Correct (allows external connections)
php -S 0.0.0.0:8000 -t public

# ❌ Wrong (only localhost)
php -S localhost:8000 -t public
```

### APK Size:
- Release APK: ~20-30 MB
- Debug APK: ~40-50 MB

### Permissions:
App will request:
- 📸 Camera (for product photos)
- 📁 Storage (for saving images)
- 🌐 Internet (for API calls)

---

## 🔥 For Real SMS OTP

Currently using test OTP: `123456`

To enable **real SMS OTP**:
1. Follow instructions in `SETUP_REAL_MOBILE.md`
2. Configure Firebase Phone Authentication
3. Add SHA-256 certificate
4. Rebuild APK

---

## 🎉 You're Ready!

Your LinkKart app is now:
- ✅ Configured for real Android device
- ✅ Light mode only
- ✅ No fake data
- ✅ Ready to build APK
- ✅ Production-ready design

**Build the APK and install on your phone now!** 🚀

---

**Last Updated:** May 3, 2026
**Version:** 1.0.0
**Platform:** Android
