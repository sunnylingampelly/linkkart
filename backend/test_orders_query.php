<?php
try {
    $pdo = new PDO('mysql:host=localhost;dbname=linkkart', 'root', '');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $stmt = $pdo->prepare("
        SELECT 
            o.*,
            COALESCE(u.name, CONCAT('Customer ', o.customer_id)) as customer_name,
            COALESCE(u.phone, '') as customer_phone,
            u.address as customer_address,
            p.name as product_name,
            p.image as product_image,
            CONCAT('₹', FORMAT(o.total_price, 2)) as formatted_amount
        FROM orders o
        LEFT JOIN users u ON o.customer_id = u.id
        LEFT JOIN products p ON o.product_id = p.id
        WHERE o.store_id = ?
        ORDER BY o.created_at DESC
        LIMIT 100
    ");
    $stmt->execute([1]);
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Found " . count($orders) . " orders\n\n";
    foreach ($orders as $order) {
        echo "Order #{$order['id']}: {$order['customer_name']} - {$order['product_name']} - {$order['formatted_amount']}\n";
    }
} catch (Exception $e) {
    echo 'Error: ' . $e->getMessage() . "\n";
}
