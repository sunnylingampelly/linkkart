# 🚀 Install Improved App - Quick Guide

## ✅ What's New

1. **Splash screen fixed** - No more bottom pixels!
2. **Product ID added** - Every product gets unique ID (LK-0001, LK-0002, etc.)
3. **Multiple images** - Products can have multiple photos
4. **Complete flow** - All features reviewed and working

---

## 📦 Step 1: Update Database

Open **phpMyAdmin** and run this SQL:

```sql
USE linkkart;

-- Add product_id column
ALTER TABLE `products` 
ADD COLUMN `product_id` varchar(255) NOT NULL AFTER `store_id`,
ADD UNIQUE KEY `products_product_id_unique` (`product_id`),
ADD KEY `products_product_id_index` (`product_id`);

-- Add images column for multiple photos
ALTER TABLE `products` 
ADD COLUMN `images` json DEFAULT NULL AFTER `image`;

-- Generate product_id for existing products
UPDATE `products` SET `product_id` = CONCAT('LK-', LPAD(id, 4, '0'));
```

**Or** import the file: `UPDATE_DATABASE_FOR_PRODUCT_ID.sql`

---

## 🚀 Step 2: Install Updated App

```bash
adb uninstall com.vashynova.linkkart
adb install mobile-app/build/app/outputs/flutter-apk/app-debug.apk
```

---

## 🔥 Step 3: Start Backend

```bash
cd D:\linkkart\backend
php artisan serve --host=0.0.0.0 --port=8000
```

---

## 🎉 Step 4: Test New Features

### Test Splash Screen:
- Open app
- Check no bottom pixels
- Full-screen gradient ✅

### Test Product ID:
- Add new product
- See product ID: LK-0001, LK-0002, etc. ✅

### Test Multiple Images:
- Backend ready for multiple images
- Frontend displays all images ✅

### Test Complete Flow:
- Login → Create Store → Dashboard
- Add Products → View Products
- Generate QR → Share Store ✅

---

## ⚡ Quick Commands

### All in One:
```bash
# Update app
adb uninstall com.vashynova.linkkart && adb install mobile-app/build/app/outputs/flutter-apk/app-debug.apk

# Start backend (in new terminal)
cd D:\linkkart\backend && php artisan serve --host=0.0.0.0 --port=8000
```

---

## 🎯 What to Expect

### Splash Screen:
- No bottom line/pixels
- Full-screen purple gradient
- Smooth animation

### Products:
- Product ID visible (LK-0001, LK-0002, etc.)
- Stock badges (green if available, red if out)
- Multiple images support
- Professional cards

### Dashboard:
- All 5 tabs working
- Real statistics
- Quick actions
- Beautiful UI

---

## 🐛 If Database Update Fails

If you get "column already exists" error, it means you already have the column. Skip that part!

Or drop and recreate:
```sql
DROP TABLE IF EXISTS `products`;
-- Then run the full database_setup.sql
```

---

## 🎉 Enjoy!

All improvements are live! Install and test now! 🚀

**Your app is now more professional and feature-complete!** ✨
