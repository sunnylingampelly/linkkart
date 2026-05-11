<?php
$ch = curl_init('http://localhost:8000/api/v1/orders');

$data = json_encode([
    'store_id' => 1,
    'product_id' => 1,
    'name' => 'John Luxury Doe',
    'phone' => '+919876543210',
    'address' => '123 Fashion Street, Mumbai 400001',
    'quantity' => 2,
    'total_price' => 998.00
]);

curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Content-Length: ' . strlen($data)
]);

$response = curl_exec($ch);
curl_close($ch);

echo "Response from API:\n";
echo $response . "\n";
