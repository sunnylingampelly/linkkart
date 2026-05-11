-- ============================================
-- Phase 1: Database Constraints & Indexes
-- ============================================

-- Add foreign key constraints
-- ============================================

-- Products -> Stores
ALTER TABLE products 
ADD CONSTRAINT fk_products_store 
FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE;

-- Analytics Events -> Stores
ALTER TABLE analytics_events 
ADD CONSTRAINT fk_analytics_store 
FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE;

-- Analytics Events -> Products
ALTER TABLE analytics_events 
ADD CONSTRAINT fk_analytics_product 
FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;


-- Add indexes for performance
-- ============================================

-- Stores table indexes
CREATE INDEX idx_stores_slug ON stores(slug);
CREATE INDEX idx_stores_active ON stores(is_active);
CREATE INDEX idx_stores_deleted ON stores(deleted_at);
CREATE INDEX idx_stores_owner ON stores(owner_id);

-- Products table indexes
CREATE INDEX idx_products_store ON products(store_id);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_deleted ON products(deleted_at);
CREATE INDEX idx_products_store_active ON products(store_id, is_active);

-- Analytics events indexes
CREATE INDEX idx_analytics_store ON analytics_events(store_id);
CREATE INDEX idx_analytics_product ON analytics_events(product_id);
CREATE INDEX idx_analytics_event_type ON analytics_events(event_type);
CREATE INDEX idx_analytics_created ON analytics_events(created_at);


-- Add unique constraints
-- ============================================

-- Stores slug must be unique
ALTER TABLE stores ADD UNIQUE KEY unique_slug (slug);

-- Product ID must be unique
ALTER TABLE products ADD UNIQUE KEY unique_product_id (product_id);

-- User email must be unique (already done in users table creation)


-- Clean up duplicate data
-- ============================================

-- Remove duplicate stores (keeping the first one of each name)
DELETE s1 FROM stores s1
INNER JOIN stores s2 
WHERE s1.id > s2.id 
AND s1.name = s2.name 
AND s1.deleted_at IS NULL 
AND s2.deleted_at IS NULL;

-- Update any orphaned products (products without valid store_id)
UPDATE products 
SET deleted_at = NOW() 
WHERE store_id NOT IN (SELECT id FROM stores WHERE deleted_at IS NULL)
AND deleted_at IS NULL;


-- Add default values and constraints
-- ============================================

-- Ensure view_count is never negative
ALTER TABLE stores 
MODIFY COLUMN view_count INT DEFAULT 0 CHECK (view_count >= 0);

-- Ensure click_count is never negative
ALTER TABLE products 
MODIFY COLUMN click_count INT DEFAULT 0 CHECK (click_count >= 0);

-- Ensure price is never negative
ALTER TABLE products 
MODIFY COLUMN price DECIMAL(10,2) NOT NULL CHECK (price >= 0);

-- Ensure stock_quantity is never negative
ALTER TABLE products 
MODIFY COLUMN stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0);


-- Optimize table storage
-- ============================================

OPTIMIZE TABLE stores;
OPTIMIZE TABLE products;
OPTIMIZE TABLE analytics_events;
OPTIMIZE TABLE users;
