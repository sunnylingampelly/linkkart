-- ============================================
-- UPDATE PLANS - SIMPLE PRODUCT LIMITS ONLY
-- ============================================
-- Run this on production database

-- Update existing plans with new limits and remove feature restrictions
UPDATE plans SET
    name = 'Free Trial',
    price = 0.00,
    billing_cycle = 'lifetime',
    product_limit = 5,
    features = JSON_ARRAY(
        '5 Products',
        'Unlimited Orders',
        'WhatsApp Integration',
        'QR Code Store',
        'Analytics Dashboard',
        'Size Variants',
        'Multiple Images',
        'Custom Branding'
    ),
    is_active = 1
WHERE id = 1;

UPDATE plans SET
    name = 'Starter',
    price = 399.00,
    billing_cycle = 'monthly',
    product_limit = 10,
    features = JSON_ARRAY(
        '10 Products',
        'Unlimited Orders',
        'WhatsApp Integration',
        'QR Code Store',
        'Analytics Dashboard',
        'Size Variants',
        'Multiple Images',
        'Custom Branding',
        'Priority Support'
    ),
    is_active = 1
WHERE id = 2;

UPDATE plans SET
    name = 'Business',
    price = 599.00,
    billing_cycle = 'monthly',
    product_limit = 999999,
    features = JSON_ARRAY(
        'Unlimited Products',
        'Unlimited Orders',
        'WhatsApp Integration',
        'QR Code Store',
        'Analytics Dashboard',
        'Size Variants',
        'Multiple Images',
        'Custom Branding',
        'Priority Support',
        '24/7 Support'
    ),
    is_active = 1
WHERE id = 3;

-- Verify the changes
SELECT id, name, price, billing_cycle, product_limit, features 
FROM plans 
ORDER BY price ASC;

-- Update any existing subscriptions to ensure they have the correct limits
UPDATE subscriptions s
JOIN plans p ON s.plan_id = p.id
SET s.updated_at = NOW();

SELECT 'Plans updated successfully!' as status;
