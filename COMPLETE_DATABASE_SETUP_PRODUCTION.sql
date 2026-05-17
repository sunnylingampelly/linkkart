-- ============================================
-- LINKKART COMPLETE DATABASE SETUP
-- Production-Ready Database Schema
-- ============================================
-- INSTRUCTIONS:
-- 1. Create database: CREATE DATABASE linkkart CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- 2. Select database: USE linkkart;
-- 3. Run this entire SQL file
-- ============================================

-- ============================================
-- CORE TABLES
-- ============================================

-- Stores Table
CREATE TABLE IF NOT EXISTS `stores` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `owner_id` INT NULL,
  `subscription_id` INT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `slug` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `view_count` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stores_slug_unique` (`slug`),
  KEY `stores_slug_index` (`slug`),
  KEY `stores_is_active_index` (`is_active`),
  KEY `stores_deleted_index` (`deleted_at`),
  KEY `stores_owner_index` (`owner_id`),
  KEY `stores_subscription_index` (`subscription_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Products Table
CREATE TABLE IF NOT EXISTS `products` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL CHECK (price >= 0),
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `images` json DEFAULT NULL,
  `stock_quantity` int(11) NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `click_count` int(11) NOT NULL DEFAULT 0 CHECK (click_count >= 0),
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_product_id_unique` (`product_id`),
  KEY `products_store_id_index` (`store_id`),
  KEY `products_product_id_index` (`product_id`),
  KEY `products_is_active_index` (`is_active`),
  KEY `products_deleted_index` (`deleted_at`),
  KEY `products_store_active_index` (`store_id`, `is_active`),
  CONSTRAINT `products_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Analytics Events Table
CREATE TABLE IF NOT EXISTS `analytics_events` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED DEFAULT NULL,
  `event_type` enum('store_view','product_click','whatsapp_click') NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `analytics_events_store_id_index` (`store_id`),
  KEY `analytics_events_product_id_index` (`product_id`),
  KEY `analytics_events_event_type_index` (`event_type`),
  KEY `analytics_events_created_at_index` (`created_at`),
  CONSTRAINT `analytics_events_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `analytics_events_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Admins Table
CREATE TABLE IF NOT EXISTS `admins` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admins_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- AUTHENTICATION & USER MANAGEMENT
-- ============================================

-- Users Table
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) UNIQUE NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20),
  `role` ENUM('admin', 'store_owner', 'customer') DEFAULT 'store_owner',
  `email_verified_at` TIMESTAMP NULL,
  `remember_token` VARCHAR(100) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` TIMESTAMP NULL,
  INDEX `idx_email` (`email`),
  INDEX `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ORDERS & CUSTOMERS
-- ============================================

-- Customers Table
CREATE TABLE IF NOT EXISTS `customers` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `customers_phone_index` (`phone`),
  KEY `customers_email_index` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Orders Table
CREATE TABLE IF NOT EXISTS `orders` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `total_price` decimal(10,2) NOT NULL,
  `status` enum('pending','completed','cancelled') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `orders_store_id_index` (`store_id`),
  KEY `orders_customer_id_index` (`customer_id`),
  KEY `orders_product_id_index` (`product_id`),
  KEY `orders_status_index` (`status`),
  CONSTRAINT `orders_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `orders_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `orders_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SUBSCRIPTION & PAYMENT SYSTEM
-- ============================================

-- Plans Table
CREATE TABLE IF NOT EXISTS `plans` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `slug` VARCHAR(50) UNIQUE NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `billing_cycle` ENUM('monthly', 'yearly') DEFAULT 'monthly',
  `product_limit` INT NOT NULL,
  `order_limit` INT NOT NULL,
  `features` JSON,
  `is_active` BOOLEAN DEFAULT TRUE,
  `sort_order` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_plans_active` (`is_active`),
  INDEX `idx_plans_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Subscriptions Table
CREATE TABLE IF NOT EXISTS `subscriptions` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `plan_id` INT NOT NULL,
  `status` ENUM('trial', 'active', 'cancelled', 'expired', 'past_due') DEFAULT 'trial',
  `trial_ends_at` DATETIME NULL,
  `starts_at` DATETIME NOT NULL,
  `ends_at` DATETIME NOT NULL,
  `cancelled_at` DATETIME NULL,
  `auto_renew` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`store_id`) REFERENCES `stores`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`plan_id`) REFERENCES `plans`(`id`),
  INDEX `idx_subscriptions_store` (`store_id`),
  INDEX `idx_subscriptions_plan` (`plan_id`),
  INDEX `idx_subscriptions_status` (`status`),
  INDEX `idx_subscriptions_ends` (`ends_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payments Table
CREATE TABLE IF NOT EXISTS `payments` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `subscription_id` INT NOT NULL,
  `razorpay_order_id` VARCHAR(100) NULL,
  `razorpay_payment_id` VARCHAR(100) NULL,
  `razorpay_signature` VARCHAR(255) NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'INR',
  `status` ENUM('pending', 'processing', 'success', 'failed', 'refunded') DEFAULT 'pending',
  `payment_method` VARCHAR(50) NULL,
  `failure_reason` TEXT NULL,
  `paid_at` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions`(`id`) ON DELETE CASCADE,
  INDEX `idx_payments_subscription` (`subscription_id`),
  INDEX `idx_payments_status` (`status`),
  INDEX `idx_payments_razorpay_order` (`razorpay_order_id`),
  INDEX `idx_payments_razorpay_payment` (`razorpay_payment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Invoices Table
CREATE TABLE IF NOT EXISTS `invoices` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `subscription_id` INT NOT NULL,
  `payment_id` INT NULL,
  `invoice_number` VARCHAR(50) UNIQUE NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `tax_amount` DECIMAL(10,2) DEFAULT 0,
  `discount_amount` DECIMAL(10,2) DEFAULT 0,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `status` ENUM('draft', 'sent', 'paid', 'cancelled', 'overdue') DEFAULT 'draft',
  `due_date` DATE NOT NULL,
  `paid_at` DATETIME NULL,
  `pdf_path` VARCHAR(255) NULL,
  `notes` TEXT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE SET NULL,
  INDEX `idx_invoices_subscription` (`subscription_id`),
  INDEX `idx_invoices_payment` (`payment_id`),
  INDEX `idx_invoices_status` (`status`),
  INDEX `idx_invoices_number` (`invoice_number`),
  INDEX `idx_invoices_due_date` (`due_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ADD FOREIGN KEY CONSTRAINTS
-- ============================================

-- Add foreign keys to stores table
ALTER TABLE `stores` 
ADD CONSTRAINT `fk_stores_owner` 
FOREIGN KEY (`owner_id`) REFERENCES `users`(`id`) ON DELETE SET NULL;

ALTER TABLE `stores` 
ADD CONSTRAINT `fk_stores_subscription` 
FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions`(`id`) ON DELETE SET NULL;

-- ============================================
-- INSERT DEFAULT DATA
-- ============================================

-- Insert Default Admin (password: password)
INSERT IGNORE INTO `admins` (`name`, `email`, `password`, `created_at`, `updated_at`) VALUES
('Admin', 'admin@linkkart.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NOW(), NOW());

-- Insert Default User/Admin (password: admin123)
INSERT IGNORE INTO `users` (`name`, `email`, `password`, `phone`, `role`, `created_at`, `updated_at`) VALUES
('Admin', 'admin@linkkart.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '8639424962', 'admin', NOW(), NOW());

-- Insert Default Plans
INSERT IGNORE INTO `plans` (`name`, `slug`, `price`, `billing_cycle`, `product_limit`, `order_limit`, `features`, `sort_order`) VALUES
('Free', 'free', 0.00, 'monthly', 5, 50, 
 '["5 products maximum", "50 orders per month", "WhatsApp integration", "Basic store page", "LinkKart branding"]', 1),

('Starter', 'starter', 299.00, 'monthly', 50, 999999, 
 '["50 products", "Unlimited orders", "Remove LinkKart branding", "Custom store link", "Email support"]', 2),

('Business', 'business', 599.00, 'monthly', 999999, 999999, 
 '["Unlimited products", "Unlimited orders", "Priority email support", "Store analytics (views, clicks)", "Export data to Excel"]', 3);

-- ============================================
-- OPTIMIZE TABLES
-- ============================================

OPTIMIZE TABLE `stores`;
OPTIMIZE TABLE `products`;
OPTIMIZE TABLE `analytics_events`;
OPTIMIZE TABLE `admins`;
OPTIMIZE TABLE `users`;
OPTIMIZE TABLE `customers`;
OPTIMIZE TABLE `orders`;
OPTIMIZE TABLE `plans`;
OPTIMIZE TABLE `subscriptions`;
OPTIMIZE TABLE `payments`;
OPTIMIZE TABLE `invoices`;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these to verify everything is set up correctly:
-- 
-- SELECT COUNT(*) as total_tables FROM information_schema.tables WHERE table_schema = 'linkkart';
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'linkkart' ORDER BY table_name;
-- SELECT * FROM plans;
-- SELECT * FROM admins;
-- SELECT * FROM users;
-- 
-- Expected: 11 tables total
-- ============================================

