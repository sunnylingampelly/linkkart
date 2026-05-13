<?php
$url = 'http://localhost:8000/api/v1/stores/1/statistics';
$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);

echo "Testing: $url\n";
echo "Response: $response\n";
