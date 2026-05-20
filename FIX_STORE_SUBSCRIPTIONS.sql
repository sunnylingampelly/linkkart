-- Fix Store Subscriptions
-- This ensures all stores have a free plan subscription

-- First, check if free plan exists
SELECT * FROM plans WHERE slug = 'free' OR name LIKE '%Free%';

-- If free plan doesn't exist, create it
INSERT IGNORE INTO plans (name, slug, price, product_limit, features, is_active, created_at, updated_at)
VALUES ('Free', 'free', 0.00, 5, '["5 Products", "Basic Analytics", "QR Code"]', 1, NOW(), NOW());

-- Get the free plan ID
SET @free_plan_id = (SELECT id FROM plans WHERE slug = 'free' LIMIT 1);

-- Create subscriptions for stores that don't have one
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

-- Update stores to link to their new subscriptions
UPDATE stores s
LEFT JOIN subscriptions sub ON sub.store_id = s.id AND sub.status = 'active'
SET s.subscription_id = sub.id
WHERE s.subscription_id IS NULL AND sub.id IS NOT NULL;

-- Verify the fix
SELECT 
    s.id as store_id,
    s.name as store_name,
    s.subscription_id,
    sub.status as subscription_status,
    p.name as plan_name,
    p.product_limit
FROM stores s
LEFT JOIN subscriptions sub ON s.subscription_id = sub.id
LEFT JOIN plans p ON sub.plan_id = p.id;
