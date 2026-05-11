# 🚀 Start Phase 2 - Payment & Monetization

## ✅ Phase 1 Complete!

**Completion Date**: May 6, 2026  
**Status**: All security and foundation tasks complete  
**Security Score**: 10/10 ✅

---

## 🎯 Phase 2 Overview

**Duration**: 4 weeks (Weeks 3-6)  
**Goal**: Enable revenue generation through subscriptions  
**Priority**: 🔴 Critical for business

---

## 📅 Phase 2 Roadmap

### Week 3: Payment Gateway Integration

#### Day 15-17: Razorpay Integration
**Tasks:**
- [ ] Create Razorpay account
- [ ] Get API keys (test & live)
- [ ] Install Razorpay PHP SDK
- [ ] Create payment endpoints
- [ ] Test payment flow

**Endpoints to Create:**
```
POST /api/v1/payments/create-order
POST /api/v1/payments/verify
POST /api/v1/payments/webhook
GET  /api/v1/payments/history
```

**Estimated Time**: 3 days

---

#### Day 18-19: Subscription Plans
**Tasks:**
- [ ] Create `subscriptions` table
- [ ] Create `plans` table
- [ ] Define pricing plans (Free, Starter, Business, Enterprise)
- [ ] Implement plan limits (products, orders)
- [ ] Add plan upgrade/downgrade logic

**Pricing Plans:**
```
Free:       ₹0/month    - 5 products, 10 orders/month
Starter:    ₹299/month  - 50 products, unlimited orders
Business:   ₹599/month  - Unlimited products, advanced analytics
Enterprise: ₹1,499/month - Multiple stores, API access
```

**Estimated Time**: 2 days

---

#### Day 20-21: Billing System
**Tasks:**
- [ ] Generate invoices automatically
- [ ] Send payment reminders
- [ ] Handle failed payments
- [ ] Implement grace period (3 days)
- [ ] Add payment history page

**Estimated Time**: 2 days

---

### Week 4-5: Subscription Features

#### Day 22-25: Plan Enforcement
**Tasks:**
- [ ] Check plan limits before actions
- [ ] Show upgrade prompts when limit reached
- [ ] Disable features for expired subscriptions
- [ ] Add "Upgrade" buttons in UI
- [ ] Create pricing page

**Example Logic:**
```php
// Check if store can add more products
if ($store->products()->count() >= $store->subscription->plan->product_limit) {
    return response()->json([
        'success' => false,
        'message' => 'Product limit reached. Please upgrade your plan.',
        'upgrade_url' => '/pricing'
    ], 403);
}
```

**Estimated Time**: 4 days

---

#### Day 26-28: Trial Period
**Tasks:**
- [ ] Implement 14-day free trial
- [ ] Auto-create trial subscription on signup
- [ ] Send trial expiry reminders (7 days, 3 days, 1 day)
- [ ] Convert trial to paid subscription
- [ ] Handle trial cancellations

**Estimated Time**: 3 days

---

### Week 6: Admin Revenue Dashboard

#### Day 29-32: Revenue Tracking
**Tasks:**
- [ ] Create revenue dashboard
- [ ] Show MRR (Monthly Recurring Revenue)
- [ ] Show ARR (Annual Recurring Revenue)
- [ ] Track churn rate
- [ ] Show subscription analytics

**Metrics to Display:**
- Total Revenue
- Active Subscriptions
- New Subscriptions (this month)
- Cancelled Subscriptions
- Average Revenue Per User (ARPU)
- Customer Lifetime Value (LTV)

**Estimated Time**: 4 days

---

#### Day 33-35: Financial Reports
**Tasks:**
- [ ] Generate monthly revenue reports
- [ ] Export to CSV/PDF
- [ ] Show revenue by plan
- [ ] Show revenue by region
- [ ] Tax calculation (GST)

**Estimated Time**: 3 days

---

## 🎯 Phase 2 Goals

### Business Goals
1. ✅ Enable subscription payments
2. ✅ Generate recurring revenue
3. ✅ Track financial metrics
4. ✅ Automate billing
5. ✅ Enforce plan limits

### Technical Goals
1. ✅ Razorpay integration
2. ✅ Subscription management
3. ✅ Payment webhooks
4. ✅ Invoice generation
5. ✅ Revenue dashboard

---

## 💰 Revenue Projections

### Month 1 (After Phase 2)
- **Target**: 10 paying stores
- **Average Plan**: ₹450/month
- **MRR**: ₹4,500
- **ARR**: ₹54,000

### Month 3
- **Target**: 100 paying stores
- **MRR**: ₹45,000
- **ARR**: ₹5,40,000

### Month 6
- **Target**: 500 paying stores
- **MRR**: ₹2,25,000
- **ARR**: ₹27,00,000

### Year 1
- **Target**: 2,000 paying stores
- **MRR**: ₹9,00,000
- **ARR**: ₹1,08,00,000

---

## 📊 Success Metrics

### Technical KPIs
- Payment success rate: >95%
- Webhook processing: <1s
- Invoice generation: <2s
- Dashboard load time: <2s

### Business KPIs
- Trial to paid conversion: >20%
- Monthly churn rate: <10%
- Average plan: ₹450/month
- Payment failure rate: <5%

---

## 🛠️ Tools & Services Needed

### Payment Gateway
- **Razorpay** (recommended for India)
  - Easy integration
  - UPI, Cards, Net Banking
  - Automatic settlements
  - Webhook support
  - Cost: 2% per transaction

### Email Service
- **SendGrid** or **Mailgun**
  - Invoice emails
  - Payment reminders
  - Trial expiry notifications
  - Cost: ~₹1,000/month

### PDF Generation
- **TCPDF** or **mPDF** (PHP libraries)
  - Invoice generation
  - Financial reports
  - Free, open-source

---

## 📝 Database Schema

### Subscriptions Table
```sql
CREATE TABLE subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    store_id INT NOT NULL,
    plan_id INT NOT NULL,
    status ENUM('trial', 'active', 'cancelled', 'expired'),
    trial_ends_at DATETIME NULL,
    starts_at DATETIME NOT NULL,
    ends_at DATETIME NOT NULL,
    auto_renew BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES stores(id),
    FOREIGN KEY (plan_id) REFERENCES plans(id)
);
```

### Plans Table
```sql
CREATE TABLE plans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    billing_cycle ENUM('monthly', 'yearly') DEFAULT 'monthly',
    product_limit INT NOT NULL,
    order_limit INT NOT NULL,
    features JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Payments Table
```sql
CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    subscription_id INT NOT NULL,
    razorpay_order_id VARCHAR(100),
    razorpay_payment_id VARCHAR(100),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    status ENUM('pending', 'success', 'failed'),
    payment_method VARCHAR(50),
    paid_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id)
);
```

### Invoices Table
```sql
CREATE TABLE invoices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    subscription_id INT NOT NULL,
    payment_id INT NULL,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('draft', 'sent', 'paid', 'cancelled'),
    due_date DATE NOT NULL,
    paid_at DATETIME NULL,
    pdf_path VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id),
    FOREIGN KEY (payment_id) REFERENCES payments(id)
);
```

---

## 🔧 Implementation Steps

### Step 1: Razorpay Setup (Day 15)
1. Create Razorpay account at https://razorpay.com
2. Complete KYC verification
3. Get test API keys
4. Install Razorpay PHP SDK: `composer require razorpay/razorpay`
5. Test with sample payment

### Step 2: Database Setup (Day 16)
1. Create migration files
2. Run migrations
3. Insert default plans
4. Test database structure

### Step 3: Payment Endpoints (Day 17)
1. Create order endpoint
2. Verify payment endpoint
3. Webhook handler
4. Payment history endpoint
5. Test all endpoints

### Step 4: Subscription Logic (Day 18-19)
1. Create subscription on signup
2. Check plan limits
3. Upgrade/downgrade logic
4. Trial period handling
5. Auto-renewal logic

### Step 5: Billing System (Day 20-21)
1. Invoice generation
2. Email notifications
3. Payment reminders
4. Failed payment handling
5. Grace period logic

### Step 6: UI Integration (Day 22-25)
1. Pricing page
2. Upgrade prompts
3. Subscription management
4. Payment history page
5. Invoice download

### Step 7: Trial System (Day 26-28)
1. Auto-create trial on signup
2. Trial expiry reminders
3. Trial to paid conversion
4. Trial cancellation
5. Test trial flow

### Step 8: Revenue Dashboard (Day 29-32)
1. MRR/ARR calculations
2. Subscription analytics
3. Churn tracking
4. Revenue charts
5. Export functionality

### Step 9: Financial Reports (Day 33-35)
1. Monthly reports
2. Revenue by plan
3. Revenue by region
4. Tax calculations
5. PDF export

---

## 🧪 Testing Checklist

### Payment Flow
- [ ] Create Razorpay order
- [ ] Complete test payment
- [ ] Verify payment webhook
- [ ] Check payment status
- [ ] Generate invoice

### Subscription Flow
- [ ] Create trial subscription
- [ ] Upgrade to paid plan
- [ ] Downgrade plan
- [ ] Cancel subscription
- [ ] Renew subscription

### Plan Limits
- [ ] Block action when limit reached
- [ ] Show upgrade prompt
- [ ] Allow action after upgrade
- [ ] Track usage correctly

### Billing
- [ ] Generate invoice
- [ ] Send invoice email
- [ ] Send payment reminder
- [ ] Handle failed payment
- [ ] Apply grace period

### Dashboard
- [ ] Calculate MRR correctly
- [ ] Calculate ARR correctly
- [ ] Track churn rate
- [ ] Show revenue charts
- [ ] Export reports

---

## 💡 Quick Wins

### Week 3 Quick Wins
1. **Razorpay Integration** (Day 15-17) - Start accepting payments
2. **Basic Subscription** (Day 18-19) - Enable recurring revenue
3. **Invoice Generation** (Day 20-21) - Professional billing

### Week 4-5 Quick Wins
1. **Plan Enforcement** (Day 22-25) - Monetize features
2. **Trial Period** (Day 26-28) - Increase conversions

### Week 6 Quick Wins
1. **Revenue Dashboard** (Day 29-32) - Track business metrics
2. **Financial Reports** (Day 33-35) - Business intelligence

---

## 📚 Resources

### Razorpay Documentation
- [Getting Started](https://razorpay.com/docs/)
- [PHP Integration](https://razorpay.com/docs/payments/server-integration/php/)
- [Webhooks](https://razorpay.com/docs/webhooks/)
- [Subscriptions](https://razorpay.com/docs/subscriptions/)

### PHP Libraries
- [Razorpay PHP SDK](https://github.com/razorpay/razorpay-php)
- [TCPDF](https://tcpdf.org/) - PDF generation
- [PHPMailer](https://github.com/PHPMailer/PHPMailer) - Email sending

### Business Resources
- [SaaS Metrics](https://www.forentrepreneurs.com/saas-metrics-2/)
- [Subscription Billing](https://stripe.com/guides/subscription-billing)
- [Pricing Strategies](https://www.priceintelligently.com/)

---

## 🎯 Success Criteria

Phase 2 will be complete when:

- ✅ Razorpay integration working
- ✅ Users can subscribe to plans
- ✅ Payments are processed automatically
- ✅ Invoices are generated
- ✅ Plan limits are enforced
- ✅ Trial period works
- ✅ Revenue dashboard shows metrics
- ✅ Financial reports can be exported

---

## 🚀 Let's Start!

**Next Action**: Create Razorpay account and get API keys

**Timeline**: 4 weeks (28 days)

**Goal**: Enable recurring revenue and reach ₹4,500 MRR

---

**Ready to build the revenue engine! 💰**

**Phase 2 Start Date**: May 7, 2026  
**Phase 2 End Date**: June 3, 2026  
**Let's go! 🚀**

