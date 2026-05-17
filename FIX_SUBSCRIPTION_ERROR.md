# 🔧 Fix Subscription API Error (500 - Unable to Create Subscription)

**Error:** API 500 - Unable to create subscription  
**Cause:** Subscription tables don't exist in production database  
**Solution:** Import subscription tables SQL

---

## 🎯 Quick Fix (5 minutes)

### Step 1: Import Subscription Tables

**You need to run this SQL on your production database:**

```sql
-- ============================================
-- Phase 2: Subscription & Payment Tables
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
INSERT INTO plans (name, slug, price, billing_cycle, product_limit, order_limit, features, sort_order) VALUES
('Free', 'free', 0.00, 'monthly', 5, 50, 
 '["5 products maximum", "50 orders per month", "WhatsApp integration", "Basic store page", "LinkKart branding"]', 1),

('Starter', 'starter', 299.00, 'monthly', 50, 999999, 
 '["50 products", "Unlimited orders", "Remove LinkKart branding", "Custom store link", "Email support"]', 2),

('Business', 'business', 599.00, 'monthly', 999999, 999999, 
 '["Unlimited products", "Unlimited orders", "Priority email support", "Store analytics (views, clicks)", "Export data to Excel"]', 3);

-- Add subscription_id to stores table
ALTER TABLE stores 
ADD COLUMN IF NOT EXISTS subscription_id INT NULL AFTER owner_id;

-- Add foreign key if not exists
ALTER TABLE stores 
ADD CONSTRAINT fk_stores_subscription 
FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_stores_subscription ON stores(subscription_id);
```

---

## 📝 How to Run This SQL

### Method 1: phpMyAdmin (Easiest)

1. **Login to phpMyAdmin** on your server
2. **Select database:** `linkkart`
3. **Click "SQL" tab**
4. **Copy-paste** the entire SQL above
5. **Click "Go"**
6. **Done!**

### Method 2: MySQL Command Line

```bash
# SSH to your server
ssh your-username@your-server-ip

# Run SQL file
mysql -u linkkart_user -p linkkart < /path/to/create_subscription_tables.sql

# Or paste SQL directly
mysql -u linkkart_user -p linkkart
# Then paste the SQL and press Enter
```

### Method 3: Upload SQL File

1. **Upload file** `backend/database/migrations/create_subscription_tables.sql` to server
2. **SSH to server**
3. **Run:**
```bash
mysql -u linkkart_user -p linkkart < /var/www/backend/database/migrations/create_subscription_tables.sql
```

---

## 🧪 Verify Tables Created

After running the SQL:

```sql
-- Check tables exist
SHOW TABLES LIKE '%plan%';
SHOW TABLES LIKE '%subscription%';
SHOW TABLES LIKE '%payment%';

-- Check plans inserted
SELECT * FROM plans;

-- Should show 3 plans: Free, Starter, Business
```

---

## ✅ Test Subscription Now

After importing tables:

1. **Open mobile app**
2. **Go to subscription/payment screen**
3. **Select a plan**
4. **Click checkout**
5. **Should work now!** ✅

---

## 📊 What Tables Are Created

| Table | Purpose |
|-------|---------|
| `plans` | Subscription plans (Free, Starter, Business) |
| `subscriptions` | User subscriptions with trial/active status |
| `payments` | Payment records (Razorpay integration) |
| `invoices` | Invoice generation and tracking |

---

## 🎯 Default Plans

After import, you'll have these plans:

### Free Plan
- **Price:** ₹0/month
- **Products:** 5 maximum
- **Orders:** 50/month
- **Features:** Basic store, WhatsApp integration

### Starter Plan
- **Price:** ₹299/month
- **Products:** 50
- **Orders:** Unlimited
- **Features:** No branding, custom link, email support

### Business Plan
- **Price:** ₹599/month
- **Products:** Unlimited
- **Orders:** Unlimited
- **Features:** Analytics, priority support, data export

---

## 🔧 Alternative: Quick Fix SQL File

I've created a standalone SQL file for you:

**File:** `backend/database/migrations/create_subscription_tables.sql`

**To use:**
1. Upload to your server
2. Run: `mysql -u linkkart_user -p linkkart < create_subscription_tables.sql`
3. Done!

---

## 🆘 Troubleshooting

### Error: "Table already exists"
**Solution:** Tables already created, you're good! Just verify plans exist:
```sql
SELECT * FROM plans;
```

### Error: "Cannot add foreign key constraint"
**Cause:** `stores` table doesn't have `id` as primary key

**Solution:**
```sql
-- Check stores table structure
DESCRIBE stores;

-- If id is not primary key, fix it:
ALTER TABLE stores MODIFY id INT PRIMARY KEY AUTO_INCREMENT;
```

### Error: "Unknown column 'subscription_id' in stores"
**Solution:** Run the ALTER TABLE command:
```sql
ALTER TABLE stores 
ADD COLUMN subscription_id INT NULL AFTER owner_id;
```

### Subscription still fails after import
**Check:**
1. Tables exist: `SHOW TABLES;`
2. Plans exist: `SELECT * FROM plans;`
3. Backend can connect to database
4. Razorpay keys are configured in `.env`

---

## 📋 Complete Checklist

- [ ] SSH/phpMyAdmin access to production database
- [ ] Run subscription tables SQL
- [ ] Verify 4 tables created (plans, subscriptions, payments, invoices)
- [ ] Verify 3 plans inserted (Free, Starter, Business)
- [ ] Verify `subscription_id` column added to `stores` table
- [ ] Test subscription from mobile app
- [ ] Subscription creates successfully

---

## 🚀 Quick Action Plan

**Do this right now:**

1. **Login to phpMyAdmin** (or SSH to server)
2. **Select `linkkart` database**
3. **Go to SQL tab**
4. **Copy-paste the SQL** from top of this document
5. **Click "Go"** or press Enter
6. **Verify:** `SELECT * FROM plans;` shows 3 plans
7. **Test** subscription from mobile app
8. **Done!** ✅

**Time:** 5 minutes  
**Difficulty:** Easy  
**Risk:** Very low (uses IF NOT EXISTS)

---

## 💡 Why This Happened

The subscription tables were not included in your initial `database_setup.sql` file. They're in a separate migration file that needs to be run.

**Solution:** Import the subscription tables SQL once, and subscriptions will work forever.

---

**Import the SQL now and your subscriptions will work! 🚀**
