# ⚡ LinkKart - Immediate Action Plan

## 🎯 WHAT TO DO RIGHT NOW

This document tells you exactly what to do in the next 7 days to move forward.

---

## 📅 DAY 1: Security Foundation

### Morning (4 hours)
**Task 1: Add Input Validation (2 hours)**

File: `backend/public/api.php`

Add validation to store creation:
```php
// Before inserting store, validate:
if (empty($name) || strlen($name) < 3) {
    sendJson(['success' => false, 'message' => 'Store name must be at least 3 characters'], 422);
}

if (!preg_match('/^[0-9]{10}$/', $phone)) {
    sendJson(['success' => false, 'message' => 'Phone must be 10 digits'], 422);
}
```

**Task 2: Fix SQL Injection (2 hours)**

Replace all direct SQL with prepared statements:
```php
// BAD (current):
$stmt = $pdo->query("SELECT * FROM stores WHERE slug = '$slug'");

// GOOD (change to):
$stmt = $pdo->prepare("SELECT * FROM stores WHERE slug = ?");
$stmt->execute([$slug]);
```

### Afternoon (4 hours)
**Task 3: Add Rate Limiting (2 hours)**

Create file: `backend/public/rate-limiter.php`
```php
<?php
function checkRateLimit($ip, $limit = 100) {
    $key = "rate_limit_$ip";
    $count = apcu_fetch($key) ?: 0;
    
    if ($count >= $limit) {
        http_response_code(429);
        echo json_encode(['success' => false, 'message' => 'Too many requests']);
        exit;
    }
    
    apcu_store($key, $count + 1, 60); // 60 seconds
}
```

**Task 4: Clean Database (2 hours)**

Run these SQL commands:
```sql
-- Remove duplicate stores
DELETE FROM stores WHERE id IN (5,6,7,8,9,10,11);

-- Add unique constraint on slug
ALTER TABLE stores ADD UNIQUE KEY unique_slug (slug);

-- Add indexes for performance
CREATE INDEX idx_stores_active ON stores(is_active);
CREATE INDEX idx_products_store_active ON products(store_id, is_active);
```

---

## 📅 DAY 2: Error Handling

### Morning (4 hours)
**Task 1: Add Error Logging (2 hours)**

Create file: `backend/public/logger.php`
```php
<?php
function logError($message, $context = []) {
    $logFile = __DIR__ . '/../storage/logs/api.log';
    $timestamp = date('Y-m-d H:i:s');
    $contextStr = json_encode($context);
    $logMessage = "[$timestamp] $message | Context: $contextStr\n";
    file_put_contents($logFile, $logMessage, FILE_APPEND);
}
```

**Task 2: Improve Error Messages (2 hours)**

Update api.php to return better errors:
```php
catch (PDOException $e) {
    logError('Database error', ['error' => $e->getMessage()]);
    sendJson([
        'success' => false,
        'message' => 'Something went wrong. Please try again.',
        'error_code' => 'DATABASE_ERROR'
    ], 500);
}
```

### Afternoon (4 hours)
**Task 3: Add Try-Catch Everywhere (4 hours)**

Wrap all database operations in try-catch blocks in api.php

---

## 📅 DAY 3: Payment Gateway Setup

### Morning (4 hours)
**Task 1: Create Razorpay Account (1 hour)**
1. Go to https://razorpay.com
2. Sign up for account
3. Complete KYC
4. Get test API keys

**Task 2: Install Razorpay SDK (1 hour)**
```bash
cd backend
composer require razorpay/razorpay
```

**Task 3: Create Payment Endpoint (2 hours)**

Add to api.php:
```php
// Create Razorpay order
if ($uri === '/api/v1/payments/create-order' && $method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $api = new Razorpay\Api\Api('YOUR_KEY_ID', 'YOUR_KEY_SECRET');
    
    $order = $api->order->create([
        'amount' => $data['amount'] * 100, // Amount in paise
        'currency' => 'INR',
        'receipt' => 'order_' . time()
    ]);
    
    sendJson(['success' => true, 'order' => $order]);
}
```

### Afternoon (4 hours)
**Task 4: Test Payment Flow (4 hours)**
1. Create test payment page
2. Test with Razorpay test cards
3. Verify payment success
4. Handle payment failure

---

## 📅 DAY 4: Subscription System

### Morning (4 hours)
**Task 1: Create Subscriptions Table (1 hour)**

Run SQL:
```sql
CREATE TABLE subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    store_id INT NOT NULL,
    plan VARCHAR(50) NOT NULL,
    status ENUM('active', 'cancelled', 'expired') DEFAULT 'active',
    starts_at DATETIME NOT NULL,
    ends_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE
);

CREATE TABLE plans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    product_limit INT NOT NULL,
    order_limit INT NOT NULL,
    features JSON
);

-- Insert plans
INSERT INTO plans (name, price, product_limit, order_limit, features) VALUES
('Free', 0, 5, 10, '["Basic analytics", "WhatsApp integration"]'),
('Starter', 299, 50, 999999, '["Remove branding", "Custom link", "Basic analytics"]'),
('Business', 599, 999999, 999999, '["Everything in Starter", "Advanced analytics", "Priority support"]'),
('Enterprise', 1499, 999999, 999999, '["Everything in Business", "Multiple stores", "API access"]');
```

**Task 2: Create Subscription Endpoints (3 hours)**

Add to api.php:
```php
// Get subscription plans
if ($uri === '/api/v1/plans' && $method === 'GET') {
    $stmt = $pdo->query("SELECT * FROM plans ORDER BY price ASC");
    $plans = $stmt->fetchAll();
    sendJson(['success' => true, 'data' => $plans]);
}

// Subscribe to plan
if ($uri === '/api/v1/subscriptions/subscribe' && $method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $stmt = $pdo->prepare("
        INSERT INTO subscriptions (store_id, plan, starts_at, ends_at)
        VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 1 MONTH))
    ");
    $stmt->execute([$data['store_id'], $data['plan']]);
    
    sendJson(['success' => true, 'message' => 'Subscription activated']);
}
```

### Afternoon (4 hours)
**Task 3: Implement Plan Limits (4 hours)**

Add limit checking before adding products:
```php
// Check product limit
$stmt = $pdo->prepare("
    SELECT p.product_limit, COUNT(pr.id) as current_products
    FROM subscriptions s
    JOIN plans p ON s.plan = p.name
    LEFT JOIN products pr ON pr.store_id = s.store_id
    WHERE s.store_id = ? AND s.status = 'active'
    GROUP BY p.product_limit
");
$stmt->execute([$storeId]);
$result = $stmt->fetch();

if ($result['current_products'] >= $result['product_limit']) {
    sendJson([
        'success' => false,
        'message' => 'Product limit reached. Please upgrade your plan.',
        'upgrade_required' => true
    ], 403);
}
```

---

## 📅 DAY 5: Email Notifications

### Morning (4 hours)
**Task 1: Set Up SendGrid (1 hour)**
1. Create account at https://sendgrid.com
2. Verify email domain
3. Get API key
4. Install SDK: `composer require sendgrid/sendgrid`

**Task 2: Create Email Templates (3 hours)**

Create file: `backend/templates/welcome-email.html`
```html
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #5B6CFF; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; }
        .button { background: #5B6CFF; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Welcome to LinkKart! 🎉</h1>
        </div>
        <div class="content">
            <p>Hi {{name}},</p>
            <p>Your store <strong>{{store_name}}</strong> is now live!</p>
            <p>Your store URL: <a href="{{store_url}}">{{store_url}}</a></p>
            <p><a href="{{store_url}}" class="button">View Your Store</a></p>
        </div>
    </div>
</body>
</html>
```

### Afternoon (4 hours)
**Task 3: Send Welcome Email (4 hours)**

Add to api.php after store creation:
```php
function sendWelcomeEmail($email, $name, $storeName, $storeUrl) {
    $email = new \SendGrid\Mail\Mail();
    $email->setFrom("hello@linkkart.com", "LinkKart");
    $email->setSubject("Welcome to LinkKart!");
    $email->addTo($email, $name);
    
    $template = file_get_contents(__DIR__ . '/../templates/welcome-email.html');
    $template = str_replace('{{name}}', $name, $template);
    $template = str_replace('{{store_name}}', $storeName, $template);
    $template = str_replace('{{store_url}}', $storeUrl, $template);
    
    $email->addContent("text/html", $template);
    
    $sendgrid = new \SendGrid('YOUR_SENDGRID_API_KEY');
    $sendgrid->send($email);
}
```

---

## 📅 DAY 6: Mobile App Testing

### Morning (4 hours)
**Task 1: Test Mobile App (4 hours)**
1. Open mobile app in Android Studio/VS Code
2. Update API URLs to point to your backend
3. Test login/register
4. Test store creation
5. Test product upload
6. Fix any bugs found

### Afternoon (4 hours)
**Task 2: Fix Critical Bugs (4 hours)**
- Fix authentication issues
- Fix image upload
- Fix API integration
- Test on real device

---

## 📅 DAY 7: Testing & Documentation

### Morning (4 hours)
**Task 1: End-to-End Testing (4 hours)**
1. Test complete user flow:
   - Register → Create Store → Add Products → View Store → Order via WhatsApp
2. Test on different browsers
3. Test on mobile devices
4. Fix any bugs found

### Afternoon (4 hours)
**Task 2: Write Documentation (4 hours)**

Create file: `USER_GUIDE.md`
```markdown
# LinkKart User Guide

## Getting Started
1. Sign up at linkkart.com
2. Create your store
3. Add products
4. Share your store link

## Adding Products
1. Go to Products page
2. Click "Add Product"
3. Fill in details
4. Upload image
5. Click "Save"

## Managing Orders
1. Customer orders via WhatsApp
2. You receive WhatsApp message
3. Confirm order
4. Share payment details
5. Mark as completed
```

---

## ✅ CHECKLIST FOR WEEK 1

### Security ✅
- [ ] Input validation added
- [ ] SQL injection fixed
- [ ] Rate limiting implemented
- [ ] Database cleaned
- [ ] Error logging added

### Payment ✅
- [ ] Razorpay account created
- [ ] Payment endpoint created
- [ ] Test payment successful

### Subscription ✅
- [ ] Subscriptions table created
- [ ] Plans defined
- [ ] Subscription endpoints created
- [ ] Plan limits enforced

### Communication ✅
- [ ] SendGrid set up
- [ ] Welcome email template created
- [ ] Email sending working

### Testing ✅
- [ ] Mobile app tested
- [ ] End-to-end flow tested
- [ ] Documentation written

---

## 🎯 SUCCESS CRITERIA

By end of Week 1, you should have:
1. ✅ Secure platform (no major vulnerabilities)
2. ✅ Payment gateway working
3. ✅ Subscription system functional
4. ✅ Email notifications working
5. ✅ Mobile app tested
6. ✅ Documentation ready

---

## 📞 NEED HELP?

### Resources
- **Razorpay Docs**: https://razorpay.com/docs/
- **SendGrid Docs**: https://docs.sendgrid.com/
- **Laravel Docs**: https://laravel.com/docs
- **React Docs**: https://react.dev/

### Community
- **Stack Overflow**: For technical questions
- **GitHub Issues**: For bug reports
- **Discord/Slack**: For real-time help

---

## 🚀 AFTER WEEK 1

Once you complete Week 1, move to:
- **Week 2**: Order management system
- **Week 3**: Product search & filters
- **Week 4**: Store analytics dashboard
- **Week 5**: Performance optimization
- **Week 6**: Launch preparation

---

**Start with Day 1 and work through each task. You've got this! 💪**
