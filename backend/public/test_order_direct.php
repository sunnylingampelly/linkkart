<?php
$_SERVER['REQUEST_URI'] = '/api/v1/orders';
$_SERVER['REQUEST_METHOD'] = 'POST';

$postData = json_encode([
    'store_id' => 1,
    'product_id' => 1,
    'name' => 'John Luxury Doe',
    'phone' => '+919876543210',
    'address' => '123 Fashion Street, Mumbai 400001',
    'quantity' => 2,
    'total_price' => 998.00
]);

// Mock php://input
function mock_file_get_contents($filename) {
    global $postData;
    if ($filename === 'php://input') {
        return $postData;
    }
    return \file_get_contents($filename);
}

// Rename built-in to mock it? Actually, it's easier to just pass the data differently or run the server.
