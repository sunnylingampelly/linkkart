<?php
// Test products endpoint
$ch = curl_init('http://localhost:8000/api/v1/stores/1/products');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
$data = json_decode($response, true);

if ($httpCode == 200 && $data['success']) {
    echo "✓ Products endpoint working!\n";
    echo "Found " . count($data['data']) . " products\n\n";
    foreach ($data['data'] as $product) {
        echo "  - {$product['name']} ({$product['formatted_price']})\n";
    }
} else {
    echo "✗ Error\n";
    echo json_encode($data, JSON_PRETTY_PRINT) . "\n";
}
