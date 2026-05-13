<?php
$ch = curl_init('http://localhost:8000/api/v1/stores/1/customers');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);

echo "Customers Response:\n";
$data = json_decode($response, true);
echo json_encode($data, JSON_PRETTY_PRINT) . "\n";

// Check for null values
if (isset($data['data'])) {
    foreach ($data['data'] as $idx => $customer) {
        echo "\nCustomer $idx:\n";
        foreach ($customer as $key => $value) {
            $type = gettype($value);
            $display = $value === null ? 'NULL' : $value;
            echo "  $key: $display ($type)\n";
        }
    }
}
