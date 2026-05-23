-- ============================================
-- FIX STORES TABLE - Add Missing Columns
-- ============================================
-- This fixes the payment API DATABASE_ERROR issue
-- Run these commands ONE BY ONE in your MySQL console

-- Step 1: Add owner_id column
-- If you get error "Duplicate column name 'owner_id'", skip to Step 2
ALTER TABLE stores 
ADD COLUMN owner_id BIGINT(20) UNSIGNED NULL AFTER id;

-- Step 2: Add subscription_id column
-- If you get error "Duplicate column name 'subscription_id'", skip to Step 3
ALTER TABLE stores 
ADD COLUMN subscription_id INT NULL AFTER owner_id;

-- Step 3: Add index for owner_id
-- If you get error "Duplicate key name", skip to Step 4
ALTER TABLE stores
ADD INDEX stores_owner_id_index (owner_id);

-- Step 4: Add index for subscription_id
-- If you get error "Duplicate key name", skip to Step 5
ALTER TABLE stores
ADD INDEX idx_stores_subscription (subscription_id);

-- Step 5: Add foreign key constraint for subscription_id
-- If you get error "Duplicate foreign key", skip to Step 6
ALTER TABLE stores
ADD CONSTRAINT fk_stores_subscription 
FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;

-- Step 6: Verify the changes
DESCRIBE stores;

-- Step 7: Check current stores data
SELECT 
    id,
    name,
    owner_id,
    subscription_id,
    phone,
    slug
FROM stores;

-- ============================================
-- NOTES:
-- ============================================
-- 1. Run each ALTER TABLE command separately
-- 2. If you get "Duplicate" error, that means it already exists - just skip that step
-- 3. After running these, test payment in mobile app
-- 4. The owner_id can remain NULL for now (it's for future user management)
-- 5. The subscription_id will be set automatically when subscriptions are created
