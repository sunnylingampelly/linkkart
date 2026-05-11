# ⚡ Quick Setup - 3 Steps!

## 🎯 Do These 3 Things Now:

---

## 1️⃣ Update Database (2 minutes)

Open **phpMyAdmin** → Select `linkkart` → SQL tab → Paste this:

```sql
USE linkkart;

ALTER TABLE `products` ADD COLUMN `product_id` varchar(255) NOT NULL AFTER `store_id`;
ALTER TABLE `products` ADD UNIQUE KEY `products_product_id_unique` (`product_id`);
ALTER TABLE `products` ADD COLUMN `images` json DEFAULT NULL AFTER `image`;
ALTER TABLE `products` ADD COLUMN `stock_quantity` int(11) NOT NULL DEFAULT 0 AFTER `images`;
UPDATE `products` SET `product_id` = CONCAT('LK-', LPAD(id, 4, '0'));
```

Click **"Go"** ✅

**If error "column exists"** → It's okay, skip to step 2!

---

## 2️⃣ Enable Firebase Phone Auth (3 minutes)

1. **Go to**: https://console.firebase.google.com
2. **Select**: linkkart-76fe1
3. **Click**: Authentication → Sign-in method
4. **Enable**: Phone
5. **Save** ✅

**Optional - Add test number**:
- Phone: +919876543210
- Code: 123456

---

## 3️⃣ Install Updated App (1 minute)

```bash
adb uninstall com.vashynova.linkkart
adb install mobile-app/build/app/outputs/flutter-apk/app-debug.apk
```

---

## 🎉 Done!

Now you have:
- ✅ Product IDs (LK-0001, LK-0002, etc.)
- ✅ Multiple images support
- ✅ **Real Firebase Phone Auth**
- ✅ Real SMS OTP

---

## 🧪 Test It:

1. Open app
2. Enter your phone number
3. **Receive real OTP via SMS** 📱
4. Enter OTP
5. Login! ✅

---

## 🐛 If OTP Not Received:

1. Check Firebase Phone Auth is enabled
2. Use test number: +919876543210 with OTP: 123456
3. Check phone format: +91XXXXXXXXXX

---

**That's it! 3 simple steps!** 🚀

**Your app now has real Firebase authentication!** 🔥
