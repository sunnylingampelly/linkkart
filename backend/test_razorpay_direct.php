<?php
require_once __DIR__ . '/lib/Razorpay.php';
$keyId = 'rzp_test_Svsf9HTBN2tSr7';
$keySecret = 'N0UO2JPzkVYyqmbze6br9QiS';

$razorpay = new Razorpay($keyId, $keySecret);
try {
    echo "Creating test order...\n";
    $order = $razorpay->createOrder(100, 'INR', 'test_' . time());
    echo "Success! Order ID: " . $order['id'] . "\n";
    print_r($order);
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
