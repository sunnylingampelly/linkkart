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
    if ($httpCode == 200 && $data['success'] && isset($data['data'])) {
        echo "   " . json_encode($data['data'], JSON_PRETTY_PRINT) . "\n";
    }
    echo "\n";
}

echo "=== FINAL COMPREHENSIVE TEST ===\n\n";

testEndpoint('http://localhost:8000/api/v1/stores/1/statistics', 'Statistics');
testEndpoint('http://localhost:8000/api/v1/stores/1/customers', 'Customers');
testEndpoint('http://localhost:8000/api/v1/stores/1/orders', 'Orders');
testEndpoint('http://localhost:8000/api/v1/stores/1/products', 'Products');
