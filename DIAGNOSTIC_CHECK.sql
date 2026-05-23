-- Run this to see what's actually in your database
-- Copy the ENTIRE output and send it to me

SELECT '=== STORES TABLE STRUCTURE ===' AS info;
DESCRIBE stores;

SELECT '=== SUBSCRIPTIONS TABLE STRUCTURE ===' AS info;
DESCRIBE subscriptions;

SELECT '=== EXISTING FOREIGN KEYS ON STORES ===' AS info;
SELECT 
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'stores'
AND REFERENCED_TABLE_NAME IS NOT NULL;

SELECT '=== DATA TYPE COMPARISON ===' AS info;
SELECT 
    'stores.subscription_id' AS column_name,
    COLUMN_TYPE
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'stores' 
AND COLUMN_NAME = 'subscription_id'
UNION ALL
SELECT 
    'subscriptions.id' AS column_name,
    COLUMN_TYPE
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'subscriptions' 
AND COLUMN_NAME = 'id';
