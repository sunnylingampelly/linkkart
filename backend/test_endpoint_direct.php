<?php
// Simulate the endpoint logic directly
$pdo = new PDO('mysql:host=localhost;dbname=linkkart', 'root', '');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

$uri = '/api/v1/stores/1/statistics';
$method = 'GET';

echo "Testing URI: $uri\n";
echo "Method: $method\n\n";

if (preg_match('#^/api/v1/stores/(\d+)/statistics$#', $uri, $matches) && $method === 'GET') {
    echo "✓ Pattern matched!\n";
    $storeId = $matches[1];
    echo "Store ID: $storeId\n\n";
    
    // Check if store exists
    $stmt = $pdo->prepare("SELECT id, name FROM stores WHERE id = ? AND deleted_at IS NULL");
    $stmt->execute([$storeId]);
    $store = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$store) {
        echo "✗ Store not found\n";
        var_dump($store);
    } else {
        echo "✓ Store found: {$store['name']}\n";
        
        // Get statistics
        $stats = [];
        
        // Total products
        $stmt = $pdo->prepare("
            SELECT COUNT(*) as total_products 
            FROM products 
            WHERE store_id = ? AND deleted_at IS NULL
        ");
        $stmt->execute([$storeId]);
        $stats['total_products'] = $stmt->fetch(PDO::FETCH_ASSOC)['total_products'];
        
        echo "\nStatistics:\n";
        print_r($stats);
    }
} else {
    echo "✗ Pattern did NOT match\n";
}
