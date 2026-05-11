# 🎯 Install App with Correct IP (192.168.1.2)

## ✅ App Updated!

I've updated the app to use your computer's IP: **192.168.1.2**

---

## 🚀 Step 1: Install Updated App

```bash
adb uninstall com.vashynova.linkkart
adb install mobile-app/build/app/outputs/flutter-apk/app-debug.apk
```

---

## 🔥 Step 2: Start Backend

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

## 🔒 Step 3: Allow Firewall (Important!)

When you start the backend, Windows might show a firewall popup:

**"Windows Defender Firewall has blocked some features of this app"**

✅ **Click "Allow access"** (check both Private and Public networks)

This allows your phone to connect to the backend!

---

## 📱 Step 4: Test Connection

### From Your Phone Browser:

Open browser on your phone and go to:
```
http://192.168.1.2:8000
```

**Should see**: Laravel welcome page or some response

**If you see this** → Backend is accessible! ✅

---

## 🎉 Step 5: Open LinkKart App

1. Make sure backend is still running
2. Make sure phone is on **same WiFi** as computer
3. Open LinkKart app
4. Try creating store
5. Should work now! ✅

---

## ✅ Checklist

Before testing:
- [ ] Backend is running (`php artisan serve --host=0.0.0.0 --port=8000`)
- [ ] Windows Firewall allows PHP (clicked "Allow access")
- [ ] Phone is on same WiFi as computer (192.168.1.x network)
- [ ] Updated app is installed
- [ ] Can access `http://192.168.1.2:8000` from phone browser

---

## 🐛 If Still Not Working

### Test 1: Check Backend is Running
In the terminal where backend is running, you should see:
```
Starting Laravel development server: http://0.0.0.0:8000
[Sun May  3 22:30:00 2026] PHP 8.x.x Development Server (http://0.0.0.0:8000) started
```

### Test 2: Check Phone Can Reach Computer
From phone browser, visit:
```
http://192.168.1.2:8000
```

If this doesn't work:
- Check Windows Firewall settings
- Make sure both devices on same WiFi
- Try restarting backend

### Test 3: Check Backend Logs
When you try to create store in app, you should see requests in backend terminal:
```
[Sun May  3 22:30:00 2026] 192.168.1.x:xxxxx Accepted
[Sun May  3 22:30:00 2026] 192.168.1.x:xxxxx [200]: POST /api/v1/seller/stores
```

---

## ⚡ Quick Commands

### Install App:
```bash
adb uninstall com.vashynova.linkkart && adb install mobile-app/build/app/outputs/flutter-apk/app-debug.apk
```

### Start Backend:
```bash
cd D:\linkkart\backend
php artisan serve --host=0.0.0.0 --port=8000
```

### Test from Phone Browser:
```
http://192.168.1.2:8000
```

---

## 🎯 Expected Flow

1. **Install app** → Done ✅
2. **Start backend** → Terminal shows "Server started"
3. **Allow firewall** → Click "Allow access"
4. **Test browser** → See Laravel page
5. **Open app** → Create store works! 🎉

---

**Install the updated app and start the backend!** 🚀

**Your IP: 192.168.1.2**
**Backend URL: http://192.168.1.2:8000**
**API URL: http://192.168.1.2:8000/api/v1**
