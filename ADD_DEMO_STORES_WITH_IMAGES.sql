-- ============================================
-- ADD DEMO STORES WITH IMAGES
-- ============================================

-- First, let's check if we have any stores
-- SELECT * FROM stores WHERE deleted_at IS NULL;

-- Insert demo stores with proper image URLs
-- Using placeholder images from a CDN for now

INSERT INTO stores (name, phone, logo, description, slug, is_active, view_count, created_at, updated_at) VALUES
('Luxury Fashion Boutique', '+919876543210', 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&h=400&fit=crop', 'Premium designer clothing and accessories for the modern fashionista', 'luxury-fashion-boutique', 1, 245, NOW(), NOW()),

('Tech Gadgets Pro', '+919876543211', 'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=400&h=400&fit=crop', 'Latest smartphones, laptops, and tech accessories at best prices', 'tech-gadgets-pro', 1, 189, NOW(), NOW()),

('Home Decor Paradise', '+919876543212', 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400&h=400&fit=crop', 'Beautiful home decor items to transform your living space', 'home-decor-paradise', 1, 156, NOW(), NOW()),

('Organic Wellness Store', '+919876543213', 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&h=400&fit=crop', 'Natural and organic health products for a better lifestyle', 'organic-wellness-store', 1, 134, NOW(), NOW()),

('Sports & Fitness Hub', '+919876543214', 'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=400&h=400&fit=crop', 'Premium sports equipment and fitness gear for athletes', 'sports-fitness-hub', 1, 198, NOW(), NOW()),

('Artisan Jewelry Collection', '+919876543215', 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400&h=400&fit=crop', 'Handcrafted jewelry pieces with unique designs', 'artisan-jewelry-collection', 1, 167, NOW(), NOW()),

('Kids Wonderland', '+919876543216', 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=400&h=400&fit=crop', 'Toys, clothes, and essentials for your little ones', 'kids-wonderland', 1, 223, NOW(), NOW()),

('Gourmet Food Market', '+919876543217', 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=400&fit=crop', 'Premium ingredients and gourmet food products', 'gourmet-food-market', 1, 178, NOW(), NOW())

ON DUPLICATE KEY UPDATE 
    logo = VALUES(logo),
    description = VALUES(description),
    updated_at = NOW();

-- Add some products for these stores
INSERT INTO products (store_id, product_id, name, price, description, image, stock_quantity, is_active, click_count, created_at, updated_at)
SELECT 
    s.id,
    CONCAT('LK-', LPAD(FLOOR(RAND() * 10000), 4, '0')),
    CASE 
        WHEN s.slug = 'luxury-fashion-boutique' THEN 'Designer Silk Dress'
        WHEN s.slug = 'tech-gadgets-pro' THEN 'Wireless Earbuds Pro'
        WHEN s.slug = 'home-decor-paradise' THEN 'Modern Wall Art'
        WHEN s.slug = 'organic-wellness-store' THEN 'Organic Green Tea'
        WHEN s.slug = 'sports-fitness-hub' THEN 'Yoga Mat Premium'
        WHEN s.slug = 'artisan-jewelry-collection' THEN 'Silver Necklace'
        WHEN s.slug = 'kids-wonderland' THEN 'Educational Toy Set'
        WHEN s.slug = 'gourmet-food-market' THEN 'Italian Olive Oil'
    END,
    CASE 
        WHEN s.slug = 'luxury-fashion-boutique' THEN 4999.00
        WHEN s.slug = 'tech-gadgets-pro' THEN 2499.00
        WHEN s.slug = 'home-decor-paradise' THEN 1299.00
        WHEN s.slug = 'organic-wellness-store' THEN 599.00
        WHEN s.slug = 'sports-fitness-hub' THEN 1999.00
        WHEN s.slug = 'artisan-jewelry-collection' THEN 3499.00
        WHEN s.slug = 'kids-wonderland' THEN 899.00
        WHEN s.slug = 'gourmet-food-market' THEN 1499.00
    END,
    CASE 
        WHEN s.slug = 'luxury-fashion-boutique' THEN 'Elegant silk dress perfect for special occasions'
        WHEN s.slug = 'tech-gadgets-pro' THEN 'Premium wireless earbuds with noise cancellation'
        WHEN s.slug = 'home-decor-paradise' THEN 'Beautiful modern wall art to enhance your space'
        WHEN s.slug = 'organic-wellness-store' THEN 'Pure organic green tea from the Himalayas'
        WHEN s.slug = 'sports-fitness-hub' THEN 'Professional grade yoga mat with extra cushioning'
        WHEN s.slug = 'artisan-jewelry-collection' THEN 'Handcrafted sterling silver necklace'
        WHEN s.slug = 'kids-wonderland' THEN 'Educational toy set for ages 3-6'
        WHEN s.slug = 'gourmet-food-market' THEN 'Extra virgin olive oil from Italy'
    END,
    CASE 
        WHEN s.slug = 'luxury-fashion-boutique' THEN 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&h=400&fit=crop'
        WHEN s.slug = 'tech-gadgets-pro' THEN 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400&h=400&fit=crop'
        WHEN s.slug = 'home-decor-paradise' THEN 'https://images.unsplash.com/photo-1513519245088-0e12902e35ca?w=400&h=400&fit=crop'
        WHEN s.slug = 'organic-wellness-store' THEN 'https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?w=400&h=400&fit=crop'
        WHEN s.slug = 'sports-fitness-hub' THEN 'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400&h=400&fit=crop'
        WHEN s.slug = 'artisan-jewelry-collection' THEN 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=400&h=400&fit=crop'
        WHEN s.slug = 'kids-wonderland' THEN 'https://images.unsplash.com/photo-1558060370-d644479cb6f7?w=400&h=400&fit=crop'
        WHEN s.slug = 'gourmet-food-market' THEN 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&h=400&fit=crop'
    END,
    50,
    1,
    FLOOR(RAND() * 100),
    NOW(),
    NOW()
FROM stores s
WHERE s.slug IN (
    'luxury-fashion-boutique',
    'tech-gadgets-pro',
    'home-decor-paradise',
    'organic-wellness-store',
    'sports-fitness-hub',
    'artisan-jewelry-collection',
    'kids-wonderland',
    'gourmet-food-market'
)
AND NOT EXISTS (
    SELECT 1 FROM products p 
    WHERE p.store_id = s.id 
    LIMIT 1
);

-- Verify the stores
SELECT 
    id,
    name,
    slug,
    phone,
    CASE 
        WHEN logo IS NOT NULL AND logo != '' THEN '✅ Has Logo'
        ELSE '❌ No Logo'
    END as logo_status,
    view_count,
    is_active
FROM stores 
WHERE deleted_at IS NULL
ORDER BY created_at DESC;

