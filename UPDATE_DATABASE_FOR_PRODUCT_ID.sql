-- Update existing database to add product_id and images columns
-- Run this if you already have the database set up

USE linkkart;

-- Add product_id column
ALTER TABLE `products` 
ADD COLUMN `product_id` varchar(255) NOT NULL AFTER `store_id`,
ADD UNIQUE KEY `products_product_id_unique` (`product_id`),
ADD KEY `products_product_id_index` (`product_id`);

-- Add images column for multiple images
ALTER TABLE `products` 
ADD COLUMN `images` json DEFAULT NULL AFTER `image`;

-- Add stock_quantity if not exists
ALTER TABLE `products` 
ADD COLUMN `stock_quantity` int(11) NOT NULL DEFAULT 0 AFTER `images`;

-- Generate product_id for existing products
UPDATE `products` SET `product_id` = CONCAT('LK-', LPAD(id, 4, '0')) WHERE `product_id` = '' OR `product_id` IS NULL;

-- Verify the changes
SELECT * FROM `products` LIMIT 5;
