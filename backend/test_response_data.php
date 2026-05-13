<?php
function testEndpointData($url, $name) {
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    echo "=== $name ===\n";
    echo "HTTP: $httpCode\n";
    echo "Response:\n";
    echo json_encode(json_decode($response), JSON_PRETTY_PRINT) . "\n\n";
}

testEndpointData('http://localhost:8000/api/v1/stores/1/statistics', 'Statistics');
testEndpointData('http://localhost:8000/api/v1/stores/1/customers', 'Customers');
testEndpointData('http://localhost:8000/api/v1/stores/1/products', 'Products');
