-- ============================================
-- ADD SIZE COLUMNS TO PRODUCTS TABLE
-- ============================================
-- Run these commands ONE BY ONE in production MySQL

-- Step 1: Add sizes column (JSON)
ALTER TABLE products 
ADD COLUMN sizes JSON DEFAULT NULL AFTER stock_quantity;

-- Step 2: Add has_sizes flag
ALTER TABLE products 
ADD COLUMN has_sizes BOOLEAN DEFAULT FALSE AFTER sizes;

-- Step 3: Add size chart image
ALTER TABLE products 
ADD COLUMN size_chart_image VARCHAR(255) DEFAULT NULL AFTER has_sizes;

-- Step 4: Verify columns were added
DESCRIBE products;

-- Step 5: Check current products
SELECT id, name, has_sizes, sizes FROM products LIMIT 5;

-- ============================================
-- OPTIONAL: Test with one product
-- ============================================
-- Update product ID 1 to have sizes (change ID as needed)
UPDATE products 
SET 
    has_sizes = 1,
    sizes = '{"S": 10, "M": 15, "L": 20, "XL": 10, "XXL": 5}'
WHERE id = 1;

-- Verify the update
SELECT id, name, has_sizes, sizes FROM products WHERE id = 1;

-- ============================================
-- NOTES:
-- ============================================
-- 1. If you get "Duplicate column" error, column already exists - skip that step
-- 2. After running this, refresh storefront to see size selection
-- 3. Use mobile app to add sizes to products going forward
-- 4. Sizes format: {"S": 10, "M": 15, "L": 20, "XL": 5}
--    where numbers are stock quantities
