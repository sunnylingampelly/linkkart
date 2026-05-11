# 🔧 Fix Database Error - Step by Step

## Error: Duplicate entry '' for key 'products_product_id_unique'

**Problem**: The product_id column exists but is empty, and we're trying to add a UNIQUE constraint on empty values.

---

## ✅ Solution (Copy & Paste Each Step)

### Step 1: Drop the problematic unique key

```sql
USE linkkart;
ALTER TABLE `products` DROP INDEX IF EXISTS `products_product_id_unique`;
```

**Click "Go"** → Should say "0 rows affected" ✅

---

### Step 2: Generate product IDs for all products

```sql
UPDATE `products` 
SET `product_id` = CONCAT('LK-', LPAD(id, 4, '0'))
WHERE `product_id` IS NULL OR `product_id` = '' OR `product_id` = '0';
```

**Click "Go"** → Should say "X rows affected" ✅

---

### Step 3: Verify product IDs are generated

```sql
SELECT id, product_id, name FROM products;
```

**Click "Go"** → Should see LK-0001, LK-0002, etc. ✅

---

### Step 4: Now add the unique constraint

```sql
ALTER TABLE `products` ADD UNIQUE KEY `products_product_id_unique` (`product_id`);
```

**Click "Go"** → Should say "0 rows affected" ✅

---

### Step 5: Add images column

```sql
ALTER TABLE `products` ADD COLUMN `images` json DEFAULT NULL AFTER `image`;
```

**Click "Go"** → Should work or say "column exists" ✅

---

### Step 6: Add stock_quantity column

```sql
ALTER TABLE `products` ADD COLUMN `stock_quantity` int(11) NOT NULL DEFAULT 0 AFTER `images`;
```

**Click "Go"** → Should work or say "column exists" ✅

---

### Step 7: Final verification

```sql
SELECT id, product_id, name, stock_quantity FROM products LIMIT 5;
```

**Should see**:
```
id | product_id | name              | stock_quantity
1  | LK-0001    | Product Name 1    | 0
2  | LK-0002    | Product Name 2    | 0
```

✅ **Done!**

---

## 🎯 Alternative: One-Shot Fix

If you want to run everything at once:

```sql
USE linkkart;

-- Drop unique key
ALTER TABLE `products` DROP INDEX IF EXISTS `products_product_id_unique`;

-- Generate product IDs
UPDATE `products` 
SET `product_id` = CONCAT('LK-', LPAD(id, 4, '0'))
WHERE `product_id` IS NULL OR `product_id` = '' OR `product_id` = '0';

-- Add unique key
ALTER TABLE `products` ADD UNIQUE KEY `products_product_id_unique` (`product_id`);

-- Add images column
ALTER TABLE `products` ADD COLUMN IF NOT EXISTS `images` json DEFAULT NULL AFTER `image`;

-- Add stock_quantity
ALTER TABLE `products` ADD COLUMN IF NOT EXISTS `stock_quantity` int(11) NOT NULL DEFAULT 0 AFTER `images`;

-- Verify
SELECT id, product_id, name, stock_quantity FROM products LIMIT 5;
```

**Click "Go"** → All done! ✅

---

## 🐛 If Still Getting Errors:

### Error: "Column 'product_id' cannot be null"

**Fix**:
```sql
ALTER TABLE `products` MODIFY `product_id` varchar(255) NULL;
UPDATE `products` SET `product_id` = CONCAT('LK-', LPAD(id, 4, '0'));
ALTER TABLE `products` MODIFY `product_id` varchar(255) NOT NULL;
```

### Error: "Duplicate entry 'LK-0001'"

**Fix**: Some products already have IDs
```sql
UPDATE `products` 
SET `product_id` = CONCAT('LK-', LPAD(id, 4, '0'))
WHERE `product_id` IS NULL OR `product_id` = '';
```

---

## ✅ After This Works:

1. **Install updated app**:
   ```bash
   adb install mobile-app/build/app/outputs/flutter-apk/app-debug.apk
   ```

2. **Enable Firebase Phone Auth**:
   - Go to Firebase Console
   - Enable Phone authentication

3. **Test the app!** 🎉

---

**This will fix the database error!** 🚀
