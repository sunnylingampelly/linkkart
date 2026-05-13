<?php
// Test database connection
try {
    $pdo = new PDO(
        "mysql:host=localhost;dbname=linkkart;charset=utf8mb4",
        "root",
        "",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
    
    echo "✓ Database connected successfully\n\n";
    
    // Test stores query
    $stmt = $pdo->query("
        SELECT s.*, COUNT(p.id) as product_count
        FROM stores s
        LEFT JOIN products p ON s.id = p.store_id AND p.deleted_at IS NULL AND p.is_active = 1
        WHERE s.deleted_at IS NULL AND s.is_active = 1
        GROUP BY s.id
        ORDER BY s.created_at DESC
    ");
    
    $stores = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "✓ Found " . count($stores) . " stores\n\n";
    
    if (count($stores) > 0) {
        echo "Stores:\n";
        foreach ($stores as $store) {
            echo "  - {$store['name']} (ID: {$store['id']}, Products: {$store['product_count']})\n";
        }
    } else {
        echo "No stores found in database\n";
    }
    
} catch (PDOException $e) {
    echo "✗ Connection failed: " . $e->getMessage() . "\n";
}
