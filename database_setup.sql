-- LinkKart Database Setup
-- Run this in phpMyAdmin SQL tab after creating the 'linkkart' database

-- Create stores table
CREATE TABLE `stores` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `slug` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `view_count` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stores_slug_unique` (`slug`),
  KEY `stores_slug_index` (`slug`),
  KEY `stores_is_active_index` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create products table
CREATE TABLE `products` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `images` json DEFAULT NULL,
  `stock_quantity` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `click_count` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_product_id_unique` (`product_id`),
  KEY `products_store_id_index` (`store_id`),
  KEY `products_product_id_index` (`product_id`),
  KEY `products_is_active_index` (`is_active`),
  CONSTRAINT `products_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create analytics_events table
CREATE TABLE `analytics_events` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED DEFAULT NULL,
  `event_type` enum('store_view','product_click','whatsapp_click') NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `analytics_events_store_id_index` (`store_id`),
  KEY `analytics_events_product_id_index` (`product_id`),
  KEY `analytics_events_event_type_index` (`event_type`),
  KEY `analytics_events_created_at_index` (`created_at`),
  CONSTRAINT `analytics_events_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `analytics_events_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create admins table
CREATE TABLE `admins` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admins_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert demo data
INSERT INTO `stores` (`id`, `name`, `phone`, `logo`, `slug`, `is_active`, `view_count`, `created_at`, `updated_at`) VALUES
(1, 'Demo Fashion Store', '+919876543210', NULL, 'demo-store', 1, 150, NOW(), NOW()),
(2, 'Tech Gadgets Hub', '+919876543211', NULL, 'tech-gadgets-hub', 1, 89, NOW(), NOW()),
(3, 'Home Decor Paradise', '+919876543212', NULL, 'home-decor-paradise', 1, 67, NOW(), NOW());

-- Insert demo products
INSERT INTO `products` (`id`, `store_id`, `product_id`, `name`, `price`, `description`, `image`, `images`, `stock_quantity`, `is_active`, `click_count`, `created_at`, `updated_at`) VALUES
(1, 1, 'LK-0001', 'Blue Cotton T-Shirt', 499.00, 'Comfortable 100% cotton t-shirt in blue color. Perfect for casual wear.', NULL, NULL, 50, 1, 25, NOW(), NOW()),
(2, 1, 'LK-0002', 'Black Denim Jeans', 1299.00, 'Stylish black denim jeans with perfect fit. Durable and comfortable.', NULL, NULL, 30, 1, 18, NOW(), NOW()),
(3, 1, 'LK-0003', 'White Sneakers', 1999.00, 'Classic white sneakers for everyday wear. Comfortable and stylish.', NULL, NULL, 20, 1, 32, NOW(), NOW()),
(4, 2, 'LK-0004', 'Wireless Earbuds', 2499.00, 'Premium wireless earbuds with noise cancellation. 24-hour battery life.', NULL, NULL, 100, 1, 45, NOW(), NOW()),
(5, 2, 'LK-0005', 'Smart Watch', 4999.00, 'Feature-rich smartwatch with fitness tracking and notifications.', NULL, NULL, 25, 1, 38, NOW(), NOW()),
(6, 3, 'LK-0006', 'Decorative Wall Art', 899.00, 'Beautiful wall art to enhance your living space.', NULL, NULL, 15, 1, 12, NOW(), NOW());

-- Insert demo admin (password: password)
INSERT INTO `admins` (`name`, `email`, `password`, `created_at`, `updated_at`) VALUES
('Admin', 'admin@linkkart.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NOW(), NOW());

-- Insert some analytics events
INSERT INTO `analytics_events` (`store_id`, `product_id`, `event_type`, `ip_address`, `created_at`, `updated_at`) VALUES
(1, NULL, 'store_view', '127.0.0.1', NOW(), NOW()),
(1, 1, 'product_click', '127.0.0.1', NOW(), NOW()),
(1, 1, 'whatsapp_click', '127.0.0.1', NOW(), NOW());
