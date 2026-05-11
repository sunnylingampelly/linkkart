-- FINAL FIX for Product ID Duplicates
-- Copy and paste this ENTIRE script into phpMyAdmin SQL tab

-- Step 1: Make product_id nullable temporarily
ALTER TABLE products MODIFY COLUMN product_id VARCHAR(255) NULL;

-- Step 2: Remove the unique constraint
ALTER TABLE products DROP INDEX IF EXISTS products_product_id_unique;

-- Step 3: Clear all existing product_ids
UPDATE products SET product_id = NULL;

-- Step 4: Regenerate product_ids sequentially
SET @row_number = 0;
UPDATE products 
SET product_id = CONCAT('LK-', LPAD((@row_number := @row_number + 1), 4, '0'))
ORDER BY id;

-- Step 5: Make product_id NOT NULL again
ALTER TABLE products MODIFY COLUMN product_id VARCHAR(255) NOT NULL;

-- Step 6: Add the unique constraint back
ALTER TABLE products ADD UNIQUE KEY products_product_id_unique (product_id);

-- Step 7: Ensure images column is properly set as JSON (nullable)
ALTER TABLE products MODIFY COLUMN images JSON NULL;

-- Step 8: Set default empty array for images if NULL
UPDATE products SET images = '[]' WHERE images IS NULL;

-- Step 9: Verify the fix - Check your products
SELECT 
    id, 
    product_id, 
    name, 
    price, 
    stock_quantity,
    image,
    images,
    created_at
FROM products 
ORDER BY id;
