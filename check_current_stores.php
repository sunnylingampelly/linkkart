<?php
/**
 * Check Current Stores in Database
 * Run this to see what stores currently exist
 */

// Database configuration
$host = 'localhost';
$dbname = 'linkkart';
$username = 'root';
$password = ''; // Update with your production password

echo "===========================================\n";
echo "CHECKING CURRENT STORES\n";
echo "===========================================\n\n";

try {
    // Connect to database
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "✅ Database connection successful\n\n";
    
    // Check if stores table exists
    $stmt = $pdo->query("SHOW TABLES LIKE 'stores'");
    if ($stmt->rowCount() === 0) {
        echo "❌ Stores table doesn't exist!\n";
        echo "Please import: COMPLETE_DATABASE_SETUP_PRODUCTION.sql\n";
        exit(1);
    }
    
    // Get total stores count
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM stores WHERE deleted_at IS NULL");
    $totalStores = $stmt->fetch()['count'];
    
    echo "TOTAL STORES: $totalStores\n";
    echo "-------------------------------------------\n\n";
    
    if ($totalStores === 0) {
        echo "❌ No stores found in database!\n\n";
        echo "SOLUTION:\n";
        echo "Import demo stores with:\n";
        echo "mysql -u root -p linkkart < ADD_DEMO_STORES_WITH_IMAGES.sql\n\n";
        exit(0);
    }
    
    // Get stores with details
    $stmt = $pdo->query("
        SELECT 
            id,
            name,
            slug,
            phone,
            logo,
            CASE 
                WHEN logo IS NULL OR logo = '' THEN '❌ No Logo'
                WHEN logo LIKE 'http%' THEN '✅ Full URL'
                ELSE '⚠️  Relative Path'
            END as logo_status,
            view_count,
            is_active,
            created_at
        FROM stores 
        WHERE deleted_at IS NULL
        ORDER BY created_at DESC
    ");
    
    $stores = $stmt->fetchAll();
    
    echo "STORES LIST:\n";
    echo "-------------------------------------------\n";
    
    $storesWithImages = 0;
    $storesWithoutImages = 0;
    $storesWithRelativePaths = 0;
    
    foreach ($stores as $store) {
        echo "\n";
        echo "ID: {$store['id']}\n";
        echo "Name: {$store['name']}\n";
        echo "Slug: {$store['slug']}\n";
        echo "Phone: {$store['phone']}\n";
        echo "Logo Status: {$store['logo_status']}\n";
        
        if ($store['logo']) {
            $logoPreview = strlen($store['logo']) > 60 
                ? substr($store['logo'], 0, 60) . '...' 
                : $store['logo'];
            echo "Logo URL: $logoPreview\n";
            
            if (strpos($store['logo'], 'http') === 0) {
                $storesWithImages++;
            } else {
                $storesWithRelativePaths++;
            }
        } else {
            echo "Logo URL: (none)\n";
            $storesWithoutImages++;
        }
        
        echo "Views: {$store['view_count']}\n";
        echo "Active: " . ($store['is_active'] ? 'Yes' : 'No') . "\n";
        echo "-------------------------------------------\n";
    }
    
    // Summary
    echo "\n";
    echo "SUMMARY:\n";
    echo "-------------------------------------------\n";
    echo "Total Stores: $totalStores\n";
    echo "✅ With Full URL Images: $storesWithImages\n";
    echo "⚠️  With Relative Paths: $storesWithRelativePaths\n";
    echo "❌ Without Images: $storesWithoutImages\n";
    echo "\n";
    
    // Recommendations
    if ($storesWithoutImages > 0 || $storesWithRelativePaths > 0) {
        echo "RECOMMENDATIONS:\n";
        echo "-------------------------------------------\n";
        
        if ($storesWithoutImages > 0) {
            echo "⚠️  $storesWithoutImages stores have no images\n";
            echo "   Fix: Import demo stores or update manually\n\n";
        }
        
        if ($storesWithRelativePaths > 0) {
            echo "⚠️  $storesWithRelativePaths stores have relative paths\n";
            echo "   These won't work on storefront!\n";
            echo "   Fix: Update to full URLs\n\n";
        }
        
        echo "QUICK FIX OPTIONS:\n";
        echo "\n";
        echo "Option 1: Import Demo Stores (Recommended)\n";
        echo "  mysql -u root -p linkkart < ADD_DEMO_STORES_WITH_IMAGES.sql\n";
        echo "\n";
        echo "Option 2: Generate Avatar Images\n";
        echo "  Run this SQL:\n";
        echo "  UPDATE stores \n";
        echo "  SET logo = CONCAT('https://ui-avatars.com/api/?name=', REPLACE(name, ' ', '+'), '&size=400&background=D4AF37&color=fff')\n";
        echo "  WHERE deleted_at IS NULL AND (logo IS NULL OR logo = '' OR logo NOT LIKE 'http%');\n";
        echo "\n";
    } else {
        echo "🎉 ALL STORES HAVE PROPER IMAGE URLS!\n";
        echo "\n";
        echo "NEXT STEPS:\n";
        echo "1. Rebuild storefront: cd storefront && npm run build\n";
        echo "2. Deploy to production\n";
        echo "3. Test at https://linkkart.shop\n";
    }
    
    // Check products
    echo "\n";
    echo "CHECKING PRODUCTS:\n";
    echo "-------------------------------------------\n";
    
    $stmt = $pdo->query("
        SELECT 
            s.name as store_name,
            COUNT(p.id) as product_count
        FROM stores s
        LEFT JOIN products p ON s.id = p.store_id AND p.deleted_at IS NULL
        WHERE s.deleted_at IS NULL
        GROUP BY s.id
        ORDER BY product_count DESC
    ");
    
    $storeProducts = $stmt->fetchAll();
    
    foreach ($storeProducts as $sp) {
        echo "{$sp['store_name']}: {$sp['product_count']} products\n";
    }
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM products WHERE deleted_at IS NULL");
    $totalProducts = $stmt->fetch()['count'];
    
    echo "\nTotal Products: $totalProducts\n";
    
    if ($totalProducts === 0) {
        echo "⚠️  No products found. Demo stores include sample products.\n";
    }
    
} catch (PDOException $e) {
    echo "❌ Database connection failed: " . $e->getMessage() . "\n";
    echo "\nPlease check:\n";
    echo "1. Database credentials are correct\n";
    echo "2. Database 'linkkart' exists\n";
    echo "3. MySQL server is running\n";
    exit(1);
}

echo "\n";
echo "===========================================\n";
echo "CHECK COMPLETE\n";
echo "===========================================\n";

