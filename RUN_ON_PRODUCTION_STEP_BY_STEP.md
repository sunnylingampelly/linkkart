# Production Database Update - Step by Step

## What This Updates
1. ✅ Adds **size features** to products (sizes, has_sizes, size_chart_image)
2. ✅ Creates **subscription system** (plans, subscriptions, payments, invoices)
3. ✅ Links **stores to subscriptions**
4. ✅ Assigns **Free plan** to all existing stores

## Before You Start

### Backup Your Database
```bash
mysqldump -u linkkart -p linkkart > backup_before_update_$(date +%Y%m%d).sql
```

### Connect to MySQL
```bash
mysql -u linkkart -p linkkart
```

## Step 1: Add Size Features to Products

Copy and paste these commands ONE BY ONE:

```sql
-- Add sizes column
ALTER TABLE products ADD COLUMN sizes JSON DEFAULT NULL AFTER stock_quantity;

-- Add has_sizes flag
ALTER TABLE products ADD COLUMN has_sizes BOOLEAN DEFAULT FALSE AFTER sizes;

-- Add size chart image
ALTER TABLE products ADD COLUMN size_chart_image VARCHAR(255) DEFAULT NULL AFTER has_sizes;

-- Verify
DESCRIBE products;
```

**Expected:** You should see `sizes`, `has_sizes`, and `size_chart_image` columns.

**If error "Duplicate column":** Skip that command, column already exists.

---

## Step 2: Create Subscription Tables

### 2a. Create Plans Table
```sql
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
```

### 2b. Create Subscriptions Table
```sql
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
```

### 2c. Create Payments Table
```sql
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
```

### 2d. Create Invoices Table
```sql
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
```

### 2e. Verify Tables Created
```sql
SHOW TABLES;
```

**Expected:** You should see `plans`, `subscriptions`, `payments`, `invoices` tables.

---

## Step 3: Insert Default Plans

```sql
INSERT IGNORE INTO plans (name, slug, price, billing_cycle, product_limit, order_limit, features, sort_order) VALUES
('Free', 'free', 0.00, 'monthly', 5, 50, 
 '["5 products maximum", "50 orders per month", "WhatsApp integration", "Basic store page", "LinkKart branding"]', 1),

('Starter', 'starter', 299.00, 'monthly', 50, 999999, 
 '["50 products", "Unlimited orders", "Remove LinkKart branding", "Custom store link", "Email support"]', 2),

('Business', 'business', 599.00, 'monthly', 999999, 999999, 
 '["Unlimited products", "Unlimited orders", "Priority email support", "Store analytics (views, clicks)", "Export data to Excel"]', 3);
```

### Verify Plans
```sql
SELECT * FROM plans;
```

**Expected:** You should see 3 plans (Free, Starter, Business).

---

## Step 4: Link Stores to Subscriptions

### 4a. Fix subscription_id Data Type (if needed)
```sql
ALTER TABLE stores MODIFY COLUMN subscription_id INT NULL;
```

**If error "Unknown column":** Run this first:
```sql
ALTER TABLE stores ADD COLUMN subscription_id INT NULL AFTER owner_id;
```

### 4b. Add Foreign Key Constraint
```sql
ALTER TABLE stores ADD CONSTRAINT fk_stores_subscription 
FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;
```

**If error "Duplicate foreign key":** Skip, already exists.

### 4c. Add Index
```sql
CREATE INDEX idx_stores_subscription ON stores(subscription_id);
```

**If error "Duplicate key name":** Skip, already exists.

---

## Step 5: Assign Free Plan to Existing Stores

### 5a. Create Subscriptions for Existing Stores
```sql
SET @free_plan_id = (SELECT id FROM plans WHERE slug = 'free' LIMIT 1);

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
```

### 5b. Update Stores with Subscription IDs
```sql
UPDATE stores s
JOIN subscriptions sub ON sub.store_id = s.id
SET s.subscription_id = sub.id
WHERE s.subscription_id IS NULL;
```

### 5c. Verify
```sql
SELECT 
    s.id,
    s.name,
    s.subscription_id,
    sub.status,
    p.name as plan_name,
    p.price
FROM stores s
LEFT JOIN subscriptions sub ON s.subscription_id = sub.id
LEFT JOIN plans p ON sub.plan_id = p.id;
```

**Expected:** All stores should have a subscription with "Free" plan.

---

## Step 6: Final Verification

```sql
-- Check products have size columns
SELECT COUNT(*) as size_columns_count
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'products' 
AND COLUMN_NAME IN ('sizes', 'has_sizes', 'size_chart_image');
-- Expected: 3

-- Check subscription tables exist
SELECT COUNT(*) as subscription_tables_count
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME IN ('plans', 'subscriptions', 'payments', 'invoices');
-- Expected: 4

-- Check plans exist
SELECT COUNT(*) as plans_count FROM plans;
-- Expected: 3

-- Check stores have subscriptions
SELECT COUNT(*) as stores_with_subscriptions
FROM stores WHERE subscription_id IS NOT NULL;
-- Expected: Should match your total store count
```

---

## ✅ Done!

Your production database now has:
- ✅ Size features for products
- ✅ Complete subscription system
- ✅ All stores assigned to Free plan
- ✅ Ready for payment processing

## What's Next?

1. **Test in mobile app:**
   - Create product with sizes
   - View subscription plans
   - Try upgrading to paid plan

2. **Monitor subscriptions:**
   ```sql
   SELECT * FROM subscriptions ORDER BY created_at DESC LIMIT 10;
   ```

3. **Check payments:**
   ```sql
   SELECT * FROM payments ORDER BY created_at DESC LIMIT 10;
   ```

## Troubleshooting

### If you get errors:
- **"Duplicate column"** → Column already exists, skip that command
- **"Table already exists"** → Table already created, skip that command
- **"Duplicate entry"** → Data already inserted, skip that command
- **"Foreign key constraint fails"** → Check if referenced table/column exists

### Need to rollback?
```bash
mysql -u linkkart -p linkkart < backup_before_update_YYYYMMDD.sql
```

## Files
- 📄 **`PRODUCTION_UPDATE_COMPLETE.sql`** - Complete SQL script (all commands in one file)
- 📄 **`RUN_ON_PRODUCTION_STEP_BY_STEP.md`** - This file (step-by-step guide)
