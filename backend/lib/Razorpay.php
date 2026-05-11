<?php
/**
 * Simple Razorpay Integration for LinkKart
 * No external dependencies required
 */

class Razorpay {
    private $keyId;
    private $keySecret;
    private $baseUrl = 'https://api.razorpay.com/v1/';
    
    public function __construct($keyId, $keySecret) {
        $this->keyId = $keyId;
        $this->keySecret = $keySecret;
    }
    
    /**
     * Create an order
     */
    public function createOrder($amount, $currency = 'INR', $receipt = null, $notes = []) {
        $data = [
            'amount' => $amount * 100, // Convert to paise
            'currency' => $currency,
            'receipt' => $receipt ?: 'order_' . time(),
            'notes' => $notes
        ];
        
        return $this->request('POST', 'orders', $data);
    }
    
    /**
     * Fetch order details
     */
    public function fetchOrder($orderId) {
        return $this->request('GET', "orders/$orderId");
    }
    
    /**
     * Fetch payment details
     */
    public function fetchPayment($paymentId) {
        return $this->request('GET', "payments/$paymentId");
    }
    
    /**
     * Verify payment signature
     */
    public function verifySignature($orderId, $paymentId, $signature) {
        $expectedSignature = hash_hmac('sha256', $orderId . '|' . $paymentId, $this->keySecret);
        return hash_equals($expectedSignature, $signature);
    }
    
    /**
     * Capture payment
     */
    public function capturePayment($paymentId, $amount, $currency = 'INR') {
        $data = [
            'amount' => $amount * 100,
            'currency' => $currency
        ];
        
        return $this->request('POST', "payments/$paymentId/capture", $data);
    }
    
    /**
     * Refund payment
     */
    public function refundPayment($paymentId, $amount = null, $notes = []) {
        $data = ['notes' => $notes];
        if ($amount !== null) {
            $data['amount'] = $amount * 100;
        }
        
        return $this->request('POST', "payments/$paymentId/refund", $data);
    }
    
    /**
     * Make API request
     */
    private function request($method, $endpoint, $data = []) {
        $url = $this->baseUrl . $endpoint;
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_USERPWD, $this->keyId . ':' . $this->keySecret);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json'
        ]);
        
        if ($method === 'POST') {
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }

        // Disable SSL verification for local development (common issue on Windows cURL)
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);
        
        if ($error) {
            throw new Exception('Razorpay API Error: ' . $error);
        }
        
        $result = json_decode($response, true);
        
        if ($httpCode >= 400) {
            $errorMsg = $result['error']['description'] ?? 'Unknown error';
            throw new Exception('Razorpay API Error: ' . $errorMsg);
        }
        
        return $result;
    }
    
    /**
     * Verify webhook signature
     */
    public function verifyWebhookSignature($payload, $signature, $secret) {
        $expectedSignature = hash_hmac('sha256', $payload, $secret);
        return hash_equals($expectedSignature, $signature);
    }
}
