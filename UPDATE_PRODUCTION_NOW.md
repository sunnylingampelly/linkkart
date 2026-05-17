# 🚀 Update Production Backend - Quick Guide

**Issue:** Product add error (database error)  
**Fix:** Updated `backend/public/index.php`  
**Action:** Upload to production server

---

## ⚡ Quick Update (5 minutes)

### Method 1: SFTP Upload (Easiest) ⭐ RECOMMENDED

**Use FileZilla or WinSCP:**

1. **Connect to your server:**
   - Host: Your server IP or `linkkart.shop`
   - Username: Your SSH username
   - Password: Your SSH password
   - Port: 22

2. **Navigate to:**
   - Remote: `/var/www/backend/public/`
   - Local: `D:\linkkart\backend\public\`

3. **Backup current file (important!):**
   - Right-click `index.php` on server
   - Rename to `index.php.backup`

4. **Upload new file:**
   - Drag `index.php` from local to server
   - Overwrite when asked

5. **Done!** Test immediately

---

### Method 2: SSH Command (If you have SSH access)

```bash
# 1. Connect to server
ssh your-username@your-server-ip

# 2. Backup current file
cd /var/www/backend/public
cp index.php index.php.backup

# 3. Exit SSH
exit

# 4. Upload from your computer
scp D:\linkkart\backend\public\index.php your-username@your-server-ip:/var/www/backend/public/

# Done!
```

---

### Method 3: Copy-Paste (If you can edit files on server)

1. **SSH to server:**
```bash
ssh your-username@your-server-ip
```

2. **Backup and edit:**
```bash
cd /var/www/backend/public
cp index.php index.php.backup
nano index.php
```

3. **Find line ~546** (search for "Create product")

4. **Replace this:**
```php
try {
    // Handle image upload
    $image = null;
```

**With this:**
```php
try {
    // Generate unique product_id
    $productIdUnique = 'LK-' . strtoupper(uniqid());
    
    // Handle image upload
    $image = null;
```

5. **Find the INSERT statement** (few lines down):
```php
INSERT INTO products (store_id, name, price, description, image, stock_quantity, is_active, click_count, created_at, updated_at)
VALUES (?, ?, ?, ?, ?, ?, 1, 0, NOW(), NOW())
```

**Replace with:**
```php
INSERT INTO products (store_id, product_id, name, price, description, image, stock_quantity, is_active, click_count, created_at, updated_at)
VALUES (?, ?, ?, ?, ?, ?, ?, 1, 0, NOW(), NOW())
```

6. **Find the execute statement:**
```php
$stmt->execute([$storeId, $name, $price, $description, $image, $stockQuantity]);
```

**Replace with:**
```php
$stmt->execute([$storeId, $productIdUnique, $name, $price, $description, $image, $stockQuantity]);
```

7. **Save:** Ctrl+X, Y, Enter

---

## 🧪 Test After Update

### Test 1: API Health Check
```bash
curl https://api.linkkart.shop/api/health
```

Should still return success.

### Test 2: Add Product from Mobile App

1. Open mobile app
2. Go to Products tab
3. Tap "Add Product"
4. Fill in details
5. Save
6. **Should work now!** ✅

### Test 3: Verify Product Created

```bash
curl https://api.linkkart.shop/api/v1/stores/YOUR_STORE_ID/products
```

Should show your new product with a `product_id` field.

---

## 📋 Quick Checklist

- [ ] Backup current `index.php` on server
- [ ] Upload new `index.php` to server
- [ ] Test API health check
- [ ] Test adding product from app
- [ ] Verify product appears in list
- [ ] Check product has `product_id` field

---

## 🔄 Rollback (If Something Goes Wrong)

If the update causes issues:

```bash
# SSH to server
ssh your-username@your-server-ip

# Restore backup
cd /var/www/backend/public
cp index.php.backup index.php

# Done - back to previous version
```

---

## 💡 What Changed

**Only ONE file changed:** `backend/public/index.php`

**Changes:**
1. Added `product_id` generation: `$productIdUnique = 'LK-' . strtoupper(uniqid());`
2. Added `product_id` to INSERT query
3. Added `product_id` to execute parameters

**No database changes needed** - the `product_id` column already exists.

---

## ⚠️ Important Notes

1. **Backup first!** Always backup before updating production
2. **Test immediately** after uploading
3. **No downtime** - The update is instant
4. **No restart needed** - PHP files are read on each request
5. **Safe to update** - Only affects product creation

---

## 🎯 Recommended: Use SFTP

**Easiest and safest method:**

1. Download **FileZilla** (free): https://filezilla-project.org/
2. Connect to your server
3. Navigate to `/var/www/backend/public/`
4. Backup `index.php` (rename to `index.php.backup`)
5. Upload new `index.php` from `D:\linkkart\backend\public\`
6. Done!

**Time:** 2-3 minutes  
**Risk:** Very low (you have backup)  
**Downtime:** None

---

## ✅ After Update

Once uploaded:

1. **Test immediately** - Add a product from mobile app
2. **Verify it works** - Product should save successfully
3. **Check storefront** - Product should appear on https://linkkart.shop
4. **Monitor** - Watch for any errors in next 10-15 minutes

---

## 🆘 Need Help?

### Can't connect via SFTP?
- Check your server credentials
- Make sure port 22 is open
- Try SSH first to verify access

### Don't have SFTP access?
- Use your hosting control panel (cPanel, Plesk)
- Use File Manager in control panel
- Edit file directly in control panel

### File upload fails?
- Check file permissions
- Make sure you have write access
- Try uploading to a different location first

---

## 🚀 Quick Action Plan

**Right now, do this:**

1. **Open FileZilla** (or download it)
2. **Connect to your server**
3. **Go to** `/var/www/backend/public/`
4. **Rename** `index.php` to `index.php.backup`
5. **Upload** new `index.php` from your computer
6. **Test** by adding a product in mobile app
7. **Done!** ✅

**Time:** 5 minutes  
**Difficulty:** Easy  
**Risk:** Very low (you have backup)

---

**Upload the file now and test! The fix is ready to go! 🚀**
