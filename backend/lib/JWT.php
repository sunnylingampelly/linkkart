<?php
/**
 * Simple JWT Implementation for LinkKart
 * No external dependencies required
 */

class JWT {
    private static $secret_key = 'LinkKart_Secret_Key_2026_Change_In_Production';
    private static $algorithm = 'HS256';
    
    /**
     * Generate JWT token
     */
    public static function encode($payload, $expiry = 3600) {
        $header = [
            'typ' => 'JWT',
            'alg' => self::$algorithm
        ];
        
        // Add expiry to payload
        $payload['iat'] = time();
        $payload['exp'] = time() + $expiry;
        
        // Encode header and payload
        $headerEncoded = self::base64UrlEncode(json_encode($header));
        $payloadEncoded = self::base64UrlEncode(json_encode($payload));
        
        // Create signature
        $signature = hash_hmac('sha256', "$headerEncoded.$payloadEncoded", self::$secret_key, true);
        $signatureEncoded = self::base64UrlEncode($signature);
        
        // Return JWT
        return "$headerEncoded.$payloadEncoded.$signatureEncoded";
    }
    
    /**
     * Decode and verify JWT token
     */
    public static function decode($token) {
        $parts = explode('.', $token);
        
        if (count($parts) !== 3) {
            throw new Exception('Invalid token format');
        }
        
        list($headerEncoded, $payloadEncoded, $signatureEncoded) = $parts;
        
        // Verify signature
        $signature = self::base64UrlDecode($signatureEncoded);
        $expectedSignature = hash_hmac('sha256', "$headerEncoded.$payloadEncoded", self::$secret_key, true);
        
        if (!hash_equals($signature, $expectedSignature)) {
            throw new Exception('Invalid token signature');
        }
        
        // Decode payload
        $payload = json_decode(self::base64UrlDecode($payloadEncoded), true);
        
        // Check expiry
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            throw new Exception('Token has expired');
        }
        
        return $payload;
    }
    
    /**
     * Get token from Authorization header
     */
    public static function getTokenFromHeader() {
        $headers = getallheaders();
        
        if (isset($headers['Authorization'])) {
            $auth = $headers['Authorization'];
            if (preg_match('/Bearer\s+(.*)$/i', $auth, $matches)) {
                return $matches[1];
            }
        }
        
        return null;
    }
    
    /**
     * Verify token from request
     */
    public static function verifyRequest() {
        $token = self::getTokenFromHeader();
        
        if (!$token) {
            throw new Exception('No token provided');
        }
        
        return self::decode($token);
    }
    
    /**
     * Base64 URL encode
     */
    private static function base64UrlEncode($data) {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
    
    /**
     * Base64 URL decode
     */
    private static function base64UrlDecode($data) {
        return base64_decode(strtr($data, '-_', '+/'));
    }
    
    /**
     * Set custom secret key
     */
    public static function setSecretKey($key) {
        self::$secret_key = $key;
    }
}
