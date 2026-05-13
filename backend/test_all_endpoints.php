<?php
function testEndpoint($url, $name) {
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    $data = json_decode($response, true);
    $status = ($httpCode == 200 && $data['success']) ? '✓' : '✗';
    
    echo "$status $name (HTTP $httpCode)\n";
    if ($httpCode != 200 || !$data['success']) {
        echo "   Response: " . json_encode($data) . "\n";
    } else if (isset($data['data'])) {
        if (is_array($data['data'])) {
            echo "   Data: " . count($data['data']) . " items\n";
        } else {
            echo "   Data: " . json_encode($data['data']) . "\n";
        }
    }
    echo "\n";
}

echo "Testing Mobile App Endpoints:\n";
echo "================================\n\n";

testEndpoint('http://localhost:8000/api/v1/stores/1/statistics', 'Store Statistics');
testEndpoint('http://localhost:8000/api/v1/stores/1/orders', 'Store Orders');
testEndpoint('http://localhost:8000/api/v1/stores/1/customers', 'Store Customers');
testEndpoint('http://localhost:8000/api/v1/stores/1/products', 'Store Products');
testEndpoint('http://localhost:8000/api/v1/seller/stores/1/products', 'Store Products (Seller)');
testEndpoint('http://localhost:8000/api/v1/stores', 'All Stores');
