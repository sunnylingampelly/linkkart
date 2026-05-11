# 🚀 Start Everything - Quick Guide

## Your Setup:
- **Computer IP**: 192.168.1.2
- **Backend URL**: http://192.168.1.2:8000
- **API URL**: http://192.168.1.2:8000/api/v1

---

## ⚡ Quick Start (3 Commands)

### 1. Install Updated App
```bash
adb uninstall com.vashynova.linkkart && adb install mobile-app/build/app/outputs/flutter-apk/app-debug.apk
```

### 2. Start Backend
```bash
cd D:\linkkart\backend
php artisan serve --host=0.0.0.0 --port=8000
```

### 3. Open App on Phone
- Tap LinkKart icon
- Create your store! 🎉

---

## ✅ Checklist

Before opening app:
1. [ ] Backend is running (command above)
2. [ ] Windows Firewall allowed PHP (click "Allow" if popup)
3. [ ] Phone on same WiFi as computer
4. [ ] Updated app installed

---

## 🧪 Test Backend First

From your phone browser, visit:
```
http://192.168.1.2:8000
```

**Should see**: Laravel page or API response

**If this works** → App will work too! ✅

---

## 🎯 Create Your First Store

1. Open LinkKart app
2. Enter phone number (any 10 digits)
3. Enter OTP: **123456**
4. Enter store name
5. Upload logo (optional)
6. Tap "Create Store"
7. Done! 🎉

---

## 📊 What Happens Next

After creating store:
- Dashboard opens with 5 tabs
- Home shows statistics (0 initially)
- Products tab ready to add products
- Profile shows store info
- QR code ready to share

---

## 🛍️ Add Your First Product

1. Tap **Products** tab
2. Tap **+** button (bottom right)
3. Fill details:
   - Name: Product name
   - Price: Amount
   - Description: Details
   - Stock: Quantity
   - Image: Upload photo
4. Tap **Save**
5. Product appears in list! ✅

---

## 📲 Share Your Store

1. Tap **Profile** tab
2. Tap **"My QR Code"**
3. Share via:
   - WhatsApp
   - Copy link
   - Download QR

---

## 🐛 Troubleshooting

### App shows "Connection Error"
- Check backend is running
- Check firewall allowed PHP
- Test http://192.168.1.2:8000 in phone browser

### Backend not starting
- Check port 8000 is not in use
- Try: `netstat -ano | findstr :8000`
- Kill process if needed

### Phone can't reach backend
- Check both on same WiFi
- Check Windows Firewall
- Try disabling firewall temporarily to test

---

## 🎉 You're Ready!

**Install → Start Backend → Create Store → Add Products → Share!**

**Let's go!** 🚀
