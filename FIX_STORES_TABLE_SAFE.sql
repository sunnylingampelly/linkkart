-- ============================================
-- SAFE FIX FOR STORES TABLE
-- ============================================
-- This version checks if columns exist before adding them
-- Run this entire script in MySQL

-- Check and add owner_id column
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'stores' 
AND COLUMN_NAME = 'owner_id';

SET @query = IF(@col_exists = 0, 
    'ALTER TABLE stores ADD COLUMN owner_id BIGINT(20) UNSIGNED NULL AFTER id',
    'SELECT "owner_id column already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add subscription_id column
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'stores' 
AND COLUMN_NAME = 'subscription_id';

SET @query = IF(@col_exists = 0, 
    'ALTER TABLE stores ADD COLUMN subscription_id INT NULL AFTER owner_id',
    'SELECT "subscription_id column already exists" AS message');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add indexes (will fail silently if they exist)
ALTER TABLE stores ADD INDEX IF NOT EXISTS stores_owner_id_index (owner_id);
ALTER TABLE stores ADD INDEX IF NOT EXISTS idx_stores_subscription (subscription_id);

-- Add foreign key constraint (will fail if it exists, that's okay)
ALTER TABLE stores
ADD CONSTRAINT fk_stores_subscription 
FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;

-- Verify the changes
SELECT 'Stores table structure:' AS info;
DESCRIBE stores;

SELECT 'Current stores data:' AS info;
SELECT 
    id,
    name,
    owner_id,
    subscription_id,
    phone,
    slug
FROM stores;
