-- ============================================
-- FIX SUBSCRIPTION ERROR
-- Run this SQL on your production database
-- ============================================

-- Plans Table
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

-- Subscriptions Table
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

-- Payments Table
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

-- Invoices Table
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

-- Insert Default Plans
INSERT IGNORE INTO plans (name, slug, price, billing_cycle, product_limit, order_limit, features, sort_order) VALUES
('Free', 'free', 0.00, 'monthly', 5, 50, 
 '["5 products maximum", "50 orders per month", "WhatsApp integration", "Basic store page", "LinkKart branding"]', 1),

('Starter', 'starter', 299.00, 'monthly', 50, 999999, 
 '["50 products", "Unlimited orders", "Remove LinkKart branding", "Custom store link", "Email support"]', 2),

('Business', 'business', 599.00, 'monthly', 999999, 999999, 
 '["Unlimited products", "Unlimited orders", "Priority email support", "Store analytics (views, clicks)", "Export data to Excel"]', 3);

-- Add subscription_id column to stores table (if not exists)
SET @dbname = DATABASE();
SET @tablename = 'stores';
SET @columnname = 'subscription_id';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' INT NULL AFTER owner_id')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add foreign key constraint (if not exists)
SET @fk_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
                  WHERE CONSTRAINT_NAME = 'fk_stores_subscription' 
                  AND TABLE_NAME = 'stores' 
                  AND TABLE_SCHEMA = DATABASE());

SET @preparedStatement = IF(@fk_exists > 0,
  'SELECT 1',
  'ALTER TABLE stores ADD CONSTRAINT fk_stores_subscription FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL'
);

PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Create index (if not exists)
SET @index_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
                     WHERE TABLE_NAME = 'stores' 
                     AND INDEX_NAME = 'idx_stores_subscription' 
                     AND TABLE_SCHEMA = DATABASE());

SET @preparedStatement = IF(@index_exists > 0,
  'SELECT 1',
  'CREATE INDEX idx_stores_subscription ON stores(subscription_id)'
);

PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Verify installation
SELECT 'Subscription tables created successfully!' AS status;
SELECT COUNT(*) AS plans_count FROM plans;
SELECT 'If you see 3 plans above, installation is complete!' AS message;
