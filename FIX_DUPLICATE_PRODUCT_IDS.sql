-- Fix duplicate product_id issue
-- This script will clean up any duplicate product_ids and regenerate them

-- Step 1: Remove the unique constraint temporarily
ALTER TABLE products DROP INDEX products_product_id_unique;

-- Step 2: Clear all existing product_ids
UPDATE products SET product_id = NULL;

-- Step 3: Regenerate product_ids sequentially
SET @row_number = 0;
UPDATE products 
SET product_id = CONCAT('LK-', LPAD((@row_number := @row_number + 1), 4, '0'))
ORDER BY id;

-- Step 4: Add the unique constraint back
ALTER TABLE products ADD UNIQUE KEY products_product_id_unique (product_id);

-- Verify the fix
SELECT id, product_id, name FROM products ORDER BY id;
