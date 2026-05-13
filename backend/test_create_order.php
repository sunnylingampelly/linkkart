<?php
// Test create order endpoint
$data = [
    'store_id' => 1,
    'product_id' => 1,
    'name' => 'Test Customer',
    'phone' => '+91 9999999999',
    'quantity' => 2,
    'total_price' => 138
];

$ch = curl_init('http://localhost:8000/api/v1/orders');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
echo "Response:\n";
echo json_encode(json_decode($response), JSON_PRETTY_PRINT) . "\n";
