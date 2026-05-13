<?php
// Test API endpoint
$ch = curl_init('http://localhost:8000/api/v1/stores');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
echo "Response:\n";
echo $response . "\n";

$data = json_decode($response, true);
if ($data && isset($data['success']) && $data['success']) {
    echo "\n✓ API is working!\n";
    echo "Found " . count($data['data']) . " stores\n";
} else {
    echo "\n✗ API error\n";
}
