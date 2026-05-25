-- ============================================
-- PRODUCTION DATABASE UPDATE
-- ============================================
-- This script adds:
-- 1. Size features to products table
-- 2. Subscription system (plans, subscriptions, payments, invoices)
-- 3. Links stores to subscriptions
--
-- Run these commands ONE BY ONE in production MySQL
-- ============================================

-- ============================================
-- PART 1: ADD SIZE FEATURES TO PRODUCTS
-- ============================================

-- Add sizes column (JSON to store multiple sizes)
ALTER TABLE products 
ADD COLUMN sizes JSON DEFAULT NULL AFTER stock_quantity;

-- Add has_sizes flag
ALTER TABLE products 
ADD COLUMN has_sizes BOOLEAN DEFAULT FALSE AFTER sizes;

-- Add size chart image
ALTER TABLE products 
ADD COLUMN size_chart_image VARCHAR(255) DEFAULT NULL AFTER has_sizes;

-- Verify products table
SELECT 'Products table updated with size features' AS status;
DESCRIBE products;

-- ============================================
-- PART 2: CREATE SUBSCRIPTION SYSTEM TABLES
-- ============================================

-- Create Plans Table
CREATE TABLE IF NOT EXISTS plans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    billing_cycle ENUM('monthly', 'yearly') DEFAULT 'monthly',
    product_limit INT NOT NULL,
    order_limit INT NOT NULL,
    features JSON,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_plans_active (is_active),
    INDEX idx_plans_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Subscriptions Table
CREATE TABLE IF NOT EXISTS subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    store_id INT NOT NULL,
    plan_id INT NOT NULL,
    status ENUM('trial', 'active', 'cancelled', 'expired', 'past_due') DEFAULT 'trial',
    trial_ends_at DATETIME NULL,
    starts_at DATETIME NOT NULL,
    ends_at DATETIME NOT NULL,
    cancelled_at DATETIME NULL,
    auto_renew BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES plans(id),
    INDEX idx_subscriptions_store (store_id),
    INDEX idx_subscriptions_plan (plan_id),
    INDEX idx_subscriptions_status (status),
    INDEX idx_subscriptions_ends (ends_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Payments Table
CREATE TABLE IF NOT EXISTS payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    subscription_id INT NOT NULL,
    razorpay_order_id VARCHAR(100) NULL,
    razorpay_payment_id VARCHAR(100) NULL,
    razorpay_signature VARCHAR(255) NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    status ENUM('pending', 'processing', 'success', 'failed', 'refunded') DEFAULT 'pending',
    payment_method VARCHAR(50) NULL,
    failure_reason TEXT NULL,
    paid_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE,
    INDEX idx_payments_subscription (subscription_id),
    INDEX idx_payments_status (status),
    INDEX idx_payments_razorpay_order (razorpay_order_id),
    INDEX idx_payments_razorpay_payment (razorpay_payment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Invoices Table
CREATE TABLE IF NOT EXISTS invoices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    subscription_id INT NOT NULL,
    payment_id INT NULL,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('draft', 'sent', 'paid', 'cancelled', 'overdue') DEFAULT 'draft',
    due_date DATE NOT NULL,
    paid_at DATETIME NULL,
    pdf_path VARCHAR(255) NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE,
    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE SET NULL,
    INDEX idx_invoices_subscription (subscription_id),
    INDEX idx_invoices_payment (payment_id),
    INDEX idx_invoices_status (status),
    INDEX idx_invoices_number (invoice_number),
    INDEX idx_invoices_due_date (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Verify subscription tables created
SELECT 'Subscription tables created' AS status;
SHOW TABLES LIKE '%plan%';
SHOW TABLES LIKE '%subscription%';
SHOW TABLES LIKE '%payment%';
SHOW TABLES LIKE '%invoice%';

-- ============================================
-- PART 3: INSERT DEFAULT PLANS
-- ============================================

-- Insert plans (use INSERT IGNORE to avoid duplicates)
INSERT IGNORE INTO plans (name, slug, price, billing_cycle, product_limit, order_limit, features, sort_order) VALUES
('Free', 'free', 0.00, 'monthly', 5, 50, 
 '["5 products maximum", "50 orders per month", "WhatsApp integration", "Basic store page", "LinkKart branding"]', 1),

('Starter', 'starter', 299.00, 'monthly', 50, 999999, 
 '["50 products", "Unlimited orders", "Remove LinkKart branding", "Custom store link", "Email support"]', 2),

('Business', 'business', 599.00, 'monthly', 999999, 999999, 
 '["Unlimited products", "Unlimited orders", "Priority email support", "Store analytics (views, clicks)", "Export data to Excel"]', 3);

-- Verify plans inserted
SELECT 'Plans inserted' AS status;
SELECT * FROM plans;

-- ============================================
-- PART 4: LINK STORES TO SUBSCRIPTIONS
-- ============================================

-- Add owner_id column if not exists (skip if error)
-- ALTER TABLE stores 
-- ADD COLUMN owner_id BIGINT(20) UNSIGNED NULL AFTER id;

-- Add subscription_id column if not exists (skip if error)
-- ALTER TABLE stores 
-- ADD COLUMN subscription_id INT NULL AFTER owner_id;

-- Modify subscription_id to correct type (INT to match subscriptions.id)
ALTER TABLE stores 
MODIFY COLUMN subscription_id INT NULL;

-- Add foreign key constraint
ALTER TABLE stores
ADD CONSTRAINT fk_stores_subscription 
FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;

-- Add index
CREATE INDEX idx_stores_subscription ON stores(subscription_id);

-- Verify stores table updated
SELECT 'Stores table linked to subscriptions' AS status;
DESCRIBE stores;

-- ============================================
-- PART 5: ASSIGN FREE PLAN TO EXISTING STORES
-- ============================================

-- Get the Free plan ID
SET @free_plan_id = (SELECT id FROM plans WHERE slug = 'free' LIMIT 1);

-- Create subscriptions for existing stores that don't have one
INSERT INTO subscriptions (store_id, plan_id, status, trial_ends_at, starts_at, ends_at, created_at, updated_at)
SELECT 
    s.id,
    @free_plan_id,
    'active',
    NULL,
    NOW(),
    DATE_ADD(NOW(), INTERVAL 1 YEAR),
    NOW(),
    NOW()
FROM stores s
WHERE s.subscription_id IS NULL
AND NOT EXISTS (
    SELECT 1 FROM subscriptions sub WHERE sub.store_id = s.id
);

-- Update stores with their subscription_id
UPDATE stores s
JOIN subscriptions sub ON sub.store_id = s.id
SET s.subscription_id = sub.id
WHERE s.subscription_id IS NULL;

-- Verify subscriptions created
SELECT 'Free plan assigned to existing stores' AS status;
SELECT 
    s.id,
    s.name,
    s.subscription_id,
    sub.status,
    p.name as plan_name
FROM stores s
LEFT JOIN subscriptions sub ON s.subscription_id = sub.id
LEFT JOIN plans p ON sub.plan_id = p.id;

-- ============================================
-- VERIFICATION SUMMARY
-- ============================================

SELECT '=== VERIFICATION SUMMARY ===' AS info;

-- Check products table has size columns
SELECT 
    'Products table' AS table_name,
    COUNT(*) as column_count
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'products' 
AND COLUMN_NAME IN ('sizes', 'has_sizes', 'size_chart_image');

-- Check subscription tables exist
SELECT 
    'Subscription tables' AS info,
    COUNT(*) as table_count
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME IN ('plans', 'subscriptions', 'payments', 'invoices');

-- Check plans exist
SELECT 
    'Plans' AS info,
    COUNT(*) as plan_count
FROM plans;

-- Check stores have subscriptions
SELECT 
    'Stores with subscriptions' AS info,
    COUNT(*) as store_count
FROM stores 
WHERE subscription_id IS NOT NULL;

-- Check foreign key exists
SELECT 
    'Foreign key constraint' AS info,
    COUNT(*) as constraint_count
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'stores'
AND CONSTRAINT_NAME = 'fk_stores_subscription';

SELECT '=== UPDATE COMPLETE ===' AS status;

-- ============================================
-- NOTES:
-- ============================================
-- 1. If you get "Duplicate column" errors, those columns already exist - skip those ALTER TABLE commands
-- 2. If you get "Table already exists" errors, those tables are already created - that's fine
-- 3. If you get "Duplicate entry" errors on INSERT, those plans already exist - that's fine
-- 4. All existing stores will be assigned the Free plan automatically
-- 5. New stores will need to be assigned a plan when created
-- ============================================
