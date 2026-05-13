<?php
$uri = '/api/v1/stores/1/statistics';
$pattern = '#^/api/v1/stores/(\d+)/statistics$#';

if (preg_match($pattern, $uri, $matches)) {
    echo "✓ Pattern matches!\n";
    echo "Store ID: {$matches[1]}\n";
} else {
    echo "✗ Pattern does NOT match\n";
}

// Test what the server is actually receiving
$ch = curl_init('http://localhost:8000/api/debug?test=/api/v1/stores/1/statistics');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);

echo "\nServer debug response:\n";
echo $response . "\n";
