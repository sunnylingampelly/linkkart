<?php
$ch = curl_init('http://localhost:8000/api/v1/stores/1/statistics');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);

echo "Statistics Response:\n";
echo json_encode(json_decode($response), JSON_PRETTY_PRINT) . "\n";
