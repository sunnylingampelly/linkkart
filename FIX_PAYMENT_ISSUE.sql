-- Fix Payment/Subscription Issue
-- Add missing owner_id column to stores table

-- Step 1: Check if owner_id column exists
-- If you get an error "Duplicate column name 'owner_id'", skip to Step 3

-- Add owner_id column
ALTER TABLE stores 
ADD COLUMN owner_id BIGINT(20) UNSIGNED NULL AFTER id;

-- Step 2: Add index for owner_id
ALTER TABLE stores
ADD INDEX stores_owner_id_index (owner_id);

-- Step 3: Verify the fix
SELECT 
    s.id,
    s.name,
    s.owner_id,
    s.subscription_id
FROM stores s
LIMIT 5;
