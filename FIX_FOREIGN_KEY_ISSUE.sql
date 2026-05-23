-- ============================================
-- FIX FOREIGN KEY DATA TYPE MISMATCH
-- ============================================

-- Step 1: Check current data types
SELECT 
    'stores.subscription_id type:' AS info,
    COLUMN_TYPE 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'stores' 
AND COLUMN_NAME = 'subscription_id';

SELECT 
    'subscriptions.id type:' AS info,
    COLUMN_TYPE 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'subscriptions' 
AND COLUMN_NAME = 'id';

-- Step 2: Check if there are any existing values in subscription_id
SELECT 
    'Stores with subscription_id:' AS info,
    COUNT(*) as count
FROM stores 
WHERE subscription_id IS NOT NULL;

-- Step 3: Fix the data type mismatch
-- The subscriptions.id is INT, so stores.subscription_id should also be INT (not BIGINT)
-- First, drop the column and recreate it with correct type

ALTER TABLE stores 
MODIFY COLUMN subscription_id INT NULL;

-- Step 4: Now add the foreign key constraint
ALTER TABLE stores
ADD CONSTRAINT fk_stores_subscription 
FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;

-- Step 5: Verify the constraint was created
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'stores'
AND CONSTRAINT_NAME = 'fk_stores_subscription';

-- Step 6: Verify final structure
DESCRIBE stores;
