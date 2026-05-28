-- ============================================
-- CHECK AND FIX SIZES ISSUE
-- ============================================

-- Step 1: Check if columns exist
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'linkkart' 
  AND TABLE_NAME = 'products'
  AND COLUMN_NAME IN ('sizes', 'has_sizes', 'size_chart_image')
ORDER BY ORDINAL_POSITION;

-- Step 2: If columns don't exist, add them
-- (Run this only if Step 1 shows no results)

ALTER TABLE products 
ADD COLUMN IF NOT EXISTS has_sizes TINYINT(1) DEFAULT 0 AFTER stock_quantity,
ADD COLUMN IF NOT EXISTS sizes JSON NULL AFTER has_sizes,
ADD COLUMN IF NOT EXISTS size_chart_image VARCHAR(255) NULL AFTER sizes;

-- Step 3: Check existing products with sizes
SELECT 
    id,
    name,
    stock_quantity,
    has_sizes,
    sizes,
    size_chart_image
FROM products 
WHERE deleted_at IS NULL
ORDER BY id DESC
LIMIT 10;

-- Step 4: Test data - Check if sizes are stored correctly
SELECT 
    id,
    name,
    has_sizes,
    JSON_VALID(sizes) as is_valid_json,
    sizes,
    stock_quantity
FROM products 
WHERE has_sizes = 1 
  AND deleted_at IS NULL
LIMIT 5;

SELECT 'Database check complete!' as status;
