# 🔧 Setup Backend for Real Device

## ✅ App is Working!

The crash is fixed! Now you need to connect to the backend.

---

## 🎯 The Error

```
Connection timed out
address = 10.0.2.2, port = 40896
url=http://10.0.2.2:8000/api/v1/seller/stores
```

**Problem**: `10.0.2.2` is for Android emulator, not real devices!

---

## 🔧 Solution (2 Steps)

### Step 1: Find Your Computer's IP Address

Open **Command Prompt** and run:

```bash
ipconfig
```

Look for **"IPv4 Address"** under your active network adapter:

```
Wireless LAN adapter Wi-Fi:
   IPv4 Address. . . . . . . . . . . : 192.168.1.100  ← THIS ONE!
```

**Write down this IP address!** (e.g., `192.168.1.100`)

---

### Step 2: Update API URL in App

I need to update the API URL in the app. **Tell me your IP address** and I'll update it!

Or you can do it manually:

1. Open: `mobile-app/lib/utils/constants.dart`
2. Find line: `static const String baseUrl = 'http://10.0.2.2:8000/api/v1';`
3. Change to: `static const String baseUrl = 'http://YOUR_IP:8000/api/v1';`
4. Example: `static const String baseUrl = 'http://192.168.1.100:8000/api/v1';`
5. Save file
6. Rebuild app:
   ```bash
   flutter build apk --debug
   ```
7. Reinstall:
   ```bash
   adb install mobile-app/build/app/outputs/flutter-apk/app-debug.apk
   ```

---

## 🚀 Step 3: Start Backend

Open **new terminal** and run:

```bash
cd D:\linkkart\backend
php artisan serve --host=0.0.0.0 --port=8000
```

**Keep this running!** You should see:

```
Starting Laravel development server: http://0.0.0.0:8000
```

---

## 🔥 Step 4: Allow Firewall

Windows might block the connection. Allow it:

1. Windows will show firewall popup
2. Click "Allow access"
3. Or manually:
   - Windows Defender Firewall
   - Allow an app
   - Find PHP
   - Check both Private and Public

---

## ✅ Step 5: Test Connection

### From Your Phone Browser:

Open browser on phone and go to:
```
http://YOUR_IP:8000
```

Example: `http://192.168.1.100:8000`

**Should see**: Laravel welcome page or API response

**If you see this** → Backend is accessible! ✅

---

## 📱 Step 6: Test App

1. Make sure backend is running
2. Make sure phone and computer are on **same WiFi**
3. Open LinkKart app
4. Try creating store again
5. Should work! ✅

---

## 🐛 Troubleshooting

### Error: Connection Refused

**Check**:
- [ ] Backend is running (`php artisan serve`)
- [ ] Using correct IP address
- [ ] Phone and computer on same WiFi
- [ ] Firewall allows PHP
- [ ] Port 8000 is not blocked

### Error: Connection Timed Out

**Check**:
- [ ] IP address is correct
- [ ] Backend is running with `--host=0.0.0.0`
- [ ] Windows Firewall allows connection
- [ ] Router doesn't block local connections

### Still Not Working?

Try this:

1. **Ping test** from phone:
   - Install "Network Utilities" app
   - Ping your computer's IP
   - Should get response

2. **Check backend logs**:
   - Look at terminal where backend is running
   - Should see incoming requests

3. **Try different port**:
   ```bash
   php artisan serve --host=0.0.0.0 --port=8080
   ```
   Then update app to use port 8080

---

## ⚡ Quick Commands

### Find IP:
```bash
ipconfig
```

### Start Backend:
```bash
cd D:\linkkart\backend
php artisan serve --host=0.0.0.0 --port=8000
```

### Rebuild App (after changing IP):
```bash
cd D:\linkkart\mobile-app
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk
```

---

## 🎯 What You Need

**Tell me**:
1. Your computer's IP address (from `ipconfig`)
2. Are phone and computer on same WiFi?

**I'll**:
1. Update the API URL in the app
2. Rebuild the APK
3. You install and test!

---

## 📞 Next Steps

1. **Run `ipconfig`** and tell me your IP
2. **I'll update the app** with correct IP
3. **Start backend** with the command above
4. **Install updated APK**
5. **Create your store!** 🎉

---

**The app is working! Just need to connect to backend!** 🚀
