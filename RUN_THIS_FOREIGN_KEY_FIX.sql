-- ============================================
-- QUICK FIX: Foreign Key Data Type Mismatch
-- ============================================
-- Run these commands ONE BY ONE

-- Check current data types (just to see the issue)
DESCRIBE stores;
DESCRIBE subscriptions;

-- Fix: Modify subscription_id to match subscriptions.id type (INT)
ALTER TABLE stores MODIFY COLUMN subscription_id INT NULL;

-- Now add the foreign key constraint
ALTER TABLE stores
ADD CONSTRAINT fk_stores_subscription 
FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;

-- Verify it worked
SHOW CREATE TABLE stores;
