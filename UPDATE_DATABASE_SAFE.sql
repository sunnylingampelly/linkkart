-- Safe Database Update - Preserves Existing Data
-- Run this in phpMyAdmin SQL tab

USE linkkart;

-- Check if columns exist before adding
SET @dbname = DATABASE();
SET @tablename = "products";

-- Add product_id column if it doesn't exist
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'product_id');

SET @query = IF(@col_exists = 0,
    'ALTER TABLE `products` ADD COLUMN `product_id` varchar(255) NOT NULL AFTER `store_id`',
    'SELECT "product_id column already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add unique key for product_id if it doesn't exist
SET @index_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND INDEX_NAME = 'products_product_id_unique');

SET @query = IF(@index_exists = 0,
    'ALTER TABLE `products` ADD UNIQUE KEY `products_product_id_unique` (`product_id`)',
    'SELECT "product_id unique key already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add images column if it doesn't exist
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'images');

SET @query = IF(@col_exists = 0,
    'ALTER TABLE `products` ADD COLUMN `images` json DEFAULT NULL AFTER `image`',
    'SELECT "images column already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add stock_quantity column if it doesn't exist
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'stock_quantity');

SET @query = IF(@col_exists = 0,
    'ALTER TABLE `products` ADD COLUMN `stock_quantity` int(11) NOT NULL DEFAULT 0 AFTER `images`',
    'SELECT "stock_quantity column already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Generate product_id for existing products that don't have one
UPDATE `products` 
SET `product_id` = CONCAT('LK-', LPAD(id, 4, '0')) 
WHERE `product_id` = '' OR `product_id` IS NULL;

-- Verify the changes
SELECT 'Database updated successfully!' AS status;
SELECT * FROM `products` LIMIT 5;
