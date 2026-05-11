# 🚀 Build APK NOW - Quick Steps

## Step 1: Find Your IP Address

```bash
ipconfig
```
**Write down your IPv4 Address** (e.g., 192.168.1.100)

---

## Step 2: Update API URL

**Edit:** `mobile-app/lib/utils/constants.dart`

**Change line 7 to:**
```dart
static const String baseUrl = 'http://YOUR_IP_HERE:8000/api/v1';
```

**Example:**
```dart
static const String baseUrl = 'http://192.168.1.100:8000/api/v1';
```

**SAVE THE FILE!**

---

## Step 3: Start Backend

**Open new terminal:**
```bash
cd backend
php -S 0.0.0.0:8000 -t public
```

**Keep this running!**

---

## Step 4: Build APK

**Open another terminal:**
```bash
cd mobile-app
flutter build apk --release
```

**Wait 2-5 minutes...**

---

## Step 5: Get Your APK

**APK Location:**
```
mobile-app/build/app/outputs/flutter-apk/app-release.apk
```

**Transfer to your phone and install!**

---

## ✅ Done!

Your LinkKart app is ready to install on your Android phone!

**Features:**
- ✨ Light mode only
- 🚫 No fake data
- 📱 Real mobile app
- 💚 WhatsApp integration
- 📸 Camera support
- 🔗 QR code generation

**Install and enjoy!** 🎉
