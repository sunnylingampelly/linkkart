-- Migration: Fix Store Subscriptions
-- Date: 2024-05-20
-- Description: Ensures all stores have a free plan subscription assigned

-- Step 1: Create free plan if it doesn't exist
INSERT IGNORE INTO plans (name, slug, price, product_limit, features, is_active, created_at, updated_at)
VALUES ('Free', 'free', 0.00, 5, '["5 Products", "Basic Analytics", "QR Code"]', 1, NOW(), NOW());

-- Step 2: Get free plan ID
SET @free_plan_id = (SELECT id FROM plans WHERE slug = 'free' LIMIT 1);

-- Step 3: Create subscriptions for stores without one
INSERT INTO subscriptions (store_id, plan_id, status, start_date, created_at, updated_at)
SELECT 
    s.id,
    @free_plan_id,
    'active',
    NOW(),
    NOW(),
    NOW()
FROM stores s
LEFT JOIN subscriptions sub ON s.subscription_id = sub.id
WHERE sub.id IS NULL;

-- Step 4: Link stores to their subscriptions
UPDATE stores s
LEFT JOIN subscriptions sub ON sub.store_id = s.id AND sub.status = 'active'
SET s.subscription_id = sub.id
WHERE s.subscription_id IS NULL AND sub.id IS NOT NULL;

-- Step 5: Verify the migration
SELECT 
    'Migration completed successfully' as message,
    COUNT(*) as stores_with_subscriptions
FROM stores s
WHERE s.subscription_id IS NOT NULL;
