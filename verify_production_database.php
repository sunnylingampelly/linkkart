<?php
/**
 * Production Database Verification Script
 * Run this after importing the database to verify everything is set up correctly
 */

// Database configuration
$host = 'localhost';
$dbname = 'linkkart';
$username = 'root';
$password = ''; // Update with your production password

echo "===========================================\n";
echo "LINKKART DATABASE VERIFICATION\n";
echo "===========================================\n\n";

try {
    // Connect to database
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "✅ Database connection successful\n\n";
    
    // Required tables
    $requiredTables = [
        'stores',
        'products',
        'analytics_events',
        'admins',
        'users',
        'customers',
        'orders',
        'plans',
        'subscriptions',
        'payments',
        'invoices'
    ];
    
    echo "CHECKING TABLES...\n";
    echo "-------------------------------------------\n";
    
    $missingTables = [];
    foreach ($requiredTables as $table) {
        $stmt = $pdo->query("SHOW TABLES LIKE '$table'");
        if ($stmt->rowCount() > 0) {
            echo "✅ $table\n";
        } else {
            echo "❌ $table (MISSING)\n";
            $missingTables[] = $table;
        }
    }
    
    echo "\n";
    
    if (!empty($missingTables)) {
        echo "❌ MISSING TABLES: " . implode(', ', $missingTables) . "\n";
        echo "⚠️  Please import COMPLETE_DATABASE_SETUP_PRODUCTION.sql\n\n";
        exit(1);
    }
    
    // Check table counts
    echo "CHECKING DATA...\n";
    echo "-------------------------------------------\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM stores WHERE deleted_at IS NULL");
    $storesCount = $stmt->fetch()['count'];
    echo "Stores: $storesCount\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM products WHERE deleted_at IS NULL");
    $productsCount = $stmt->fetch()['count'];
    echo "Products: $productsCount\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM plans");
    $plansCount = $stmt->fetch()['count'];
    echo "Plans: $plansCount ";
    if ($plansCount >= 3) {
        echo "✅\n";
    } else {
        echo "❌ (Expected 3, got $plansCount)\n";
    }
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM admins");
    $adminsCount = $stmt->fetch()['count'];
    echo "Admins: $adminsCount ";
    if ($adminsCount >= 1) {
        echo "✅\n";
    } else {
        echo "❌ (Expected at least 1)\n";
    }
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
    $usersCount = $stmt->fetch()['count'];
    echo "Users: $usersCount\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM orders");
    $ordersCount = $stmt->fetch()['count'];
    echo "Orders: $ordersCount\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM subscriptions");
    $subscriptionsCount = $stmt->fetch()['count'];
    echo "Subscriptions: $subscriptionsCount\n";
    
    echo "\n";
    
    // Check foreign keys
    echo "CHECKING FOREIGN KEYS...\n";
    echo "-------------------------------------------\n";
    
    $stmt = $pdo->query("
        SELECT 
            TABLE_NAME,
            CONSTRAINT_NAME,
            REFERENCED_TABLE_NAME
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = '$dbname'
        AND REFERENCED_TABLE_NAME IS NOT NULL
        ORDER BY TABLE_NAME
    ");
    
    $foreignKeys = $stmt->fetchAll();
    echo "Total Foreign Keys: " . count($foreignKeys) . "\n";
    
    foreach ($foreignKeys as $fk) {
        echo "  {$fk['TABLE_NAME']} → {$fk['REFERENCED_TABLE_NAME']}\n";
    }
    
    echo "\n";
    
    // Check indexes
    echo "CHECKING INDEXES...\n";
    echo "-------------------------------------------\n";
    
    $stmt = $pdo->query("
        SELECT 
            TABLE_NAME,
            COUNT(*) as index_count
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = '$dbname'
        GROUP BY TABLE_NAME
        ORDER BY TABLE_NAME
    ");
    
    $indexes = $stmt->fetchAll();
    foreach ($indexes as $idx) {
        echo "{$idx['TABLE_NAME']}: {$idx['index_count']} indexes\n";
    }
    
    echo "\n";
    
    // Check plans
    echo "CHECKING SUBSCRIPTION PLANS...\n";
    echo "-------------------------------------------\n";
    
    $stmt = $pdo->query("SELECT name, price, product_limit, order_limit FROM plans ORDER BY sort_order");
    $plans = $stmt->fetchAll();
    
    foreach ($plans as $plan) {
        echo "Plan: {$plan['name']}\n";
        echo "  Price: ₹{$plan['price']}\n";
        echo "  Products: {$plan['product_limit']}\n";
        echo "  Orders: {$plan['order_limit']}\n";
        echo "\n";
    }
    
    // Check admin credentials
    echo "CHECKING ADMIN CREDENTIALS...\n";
    echo "-------------------------------------------\n";
    
    $stmt = $pdo->query("SELECT name, email FROM admins");
    $admins = $stmt->fetchAll();
    
    foreach ($admins as $admin) {
        echo "Admin: {$admin['name']} ({$admin['email']})\n";
    }
    
    echo "\n";
    
    // Final summary
    echo "===========================================\n";
    echo "VERIFICATION SUMMARY\n";
    echo "===========================================\n";
    
    $allGood = true;
    
    if (count($requiredTables) === 11) {
        echo "✅ All 11 tables exist\n";
    } else {
        echo "❌ Missing tables\n";
        $allGood = false;
    }
    
    if ($plansCount >= 3) {
        echo "✅ Subscription plans configured\n";
    } else {
        echo "❌ Missing subscription plans\n";
        $allGood = false;
    }
    
    if ($adminsCount >= 1) {
        echo "✅ Admin account exists\n";
    } else {
        echo "❌ No admin account\n";
        $allGood = false;
    }
    
    if (count($foreignKeys) > 0) {
        echo "✅ Foreign keys configured\n";
    } else {
        echo "⚠️  No foreign keys found\n";
    }
    
    echo "\n";
    
    if ($allGood) {
        echo "🎉 DATABASE IS PRODUCTION READY!\n";
        echo "\nNext steps:\n";
        echo "1. Test product creation from mobile app\n";
        echo "2. Test subscription creation from mobile app\n";
        echo "3. Monitor API logs for errors\n";
    } else {
        echo "⚠️  DATABASE NEEDS ATTENTION\n";
        echo "\nPlease import: COMPLETE_DATABASE_SETUP_PRODUCTION.sql\n";
    }
    
    echo "\n";
    
} catch (PDOException $e) {
    echo "❌ Database connection failed: " . $e->getMessage() . "\n";
    echo "\nPlease check:\n";
    echo "1. Database credentials are correct\n";
    echo "2. Database 'linkkart' exists\n";
    echo "3. MySQL server is running\n";
    exit(1);
}

