-- Add sizes column to products table
ALTER TABLE products ADD COLUMN sizes JSON DEFAULT NULL AFTER stock_quantity;
ALTER TABLE products ADD COLUMN has_sizes BOOLEAN DEFAULT FALSE AFTER sizes;
ALTER TABLE products ADD COLUMN size_chart_image VARCHAR(255) DEFAULT NULL AFTER has_sizes;
