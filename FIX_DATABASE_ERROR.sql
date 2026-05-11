-- Fix Duplicate Entry Error for product_id
-- Run this in phpMyAdmin SQL tab

USE linkkart;

-- Step 1: Check current state
SELECT id, product_id, name FROM products;

-- Step 2: Drop the unique key if it exists (to allow updates)
ALTER TABLE `products` DROP INDEX IF EXISTS `products_product_id_unique`;

-- Step 3: Generate product_id for ALL products (including empty ones)
UPDATE `products` 
SET `product_id` = CONCAT('LK-', LPAD(id, 4, '0'))
WHERE `product_id` IS NULL OR `product_id` = '' OR `product_id` = '0';

-- Step 4: Verify all products have unique product_id
SELECT id, product_id, name FROM products;

-- Step 5: Now add the unique constraint
ALTER TABLE `products` ADD UNIQUE KEY `products_product_id_unique` (`product_id`);

-- Step 6: Add images column if not exists
ALTER TABLE `products` ADD COLUMN IF NOT EXISTS `images` json DEFAULT NULL AFTER `image`;

-- Step 7: Add stock_quantity if not exists
ALTER TABLE `products` ADD COLUMN IF NOT EXISTS `stock_quantity` int(11) NOT NULL DEFAULT 0 AFTER `images`;

-- Final verification
SELECT id, product_id, name, stock_quantity FROM products;

SELECT 'Database updated successfully!' AS status;
