<?php
/**
 * Verify Database Structure
 */

$host = 'localhost';
$dbname = 'linkkart';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "✅ Connected to database successfully!\n\n";
    
    // Check tables
    echo "📊 TABLES:\n";
    echo "=" . str_repeat("=", 50) . "\n";
    $stmt = $pdo->query("SHOW TABLES");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    foreach ($tables as $table) {
        echo "  ✓ $table\n";
    }
    echo "\n";
    
    // Check foreign keys
    echo "🔗 FOREIGN KEYS:\n";
    echo "=" . str_repeat("=", 50) . "\n";
    $stmt = $pdo->query("
        SELECT 
            TABLE_NAME,
            CONSTRAINT_NAME,
            REFERENCED_TABLE_NAME
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = '$dbname'
        AND REFERENCED_TABLE_NAME IS NOT NULL
    ");
    $foreignKeys = $stmt->fetchAll();
    if (empty($foreignKeys)) {
        echo "  ⚠️  No foreign keys found\n";
    } else {
        foreach ($foreignKeys as $fk) {
            echo "  ✓ {$fk['TABLE_NAME']}.{$fk['CONSTRAINT_NAME']} -> {$fk['REFERENCED_TABLE_NAME']}\n";
        }
    }
    echo "\n";
    
    // Check indexes
    echo "📇 INDEXES:\n";
    echo "=" . str_repeat("=", 50) . "\n";
    foreach ($tables as $table) {
        $stmt = $pdo->query("SHOW INDEX FROM $table");
        $indexes = $stmt->fetchAll();
        $indexNames = array_unique(array_column($indexes, 'Key_name'));
        echo "  $table:\n";
        foreach ($indexNames as $indexName) {
            if ($indexName !== 'PRIMARY') {
                echo "    ✓ $indexName\n";
            }
        }
    }
    echo "\n";
    
    // Check users table
    echo "👥 USERS TABLE:\n";
    echo "=" . str_repeat("=", 50) . "\n";
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
    $result = $stmt->fetch();
    echo "  Total users: {$result['count']}\n";
    
    $stmt = $pdo->query("SELECT name, email, role FROM users");
    $users = $stmt->fetchAll();
    foreach ($users as $user) {
        echo "  ✓ {$user['name']} ({$user['email']}) - {$user['role']}\n";
    }
    echo "\n";
    
    // Check stores
    echo "🏪 STORES TABLE:\n";
    echo "=" . str_repeat("=", 50) . "\n";
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM stores WHERE deleted_at IS NULL");
    $result = $stmt->fetch();
    echo "  Active stores: {$result['count']}\n\n";
    
    // Check products
    echo "📦 PRODUCTS TABLE:\n";
    echo "=" . str_repeat("=", 50) . "\n";
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM products WHERE deleted_at IS NULL");
    $result = $stmt->fetch();
    echo "  Active products: {$result['count']}\n\n";
    
    echo "✅ Database verification complete!\n";
    
} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
