<?php
// Public API endpoint for stores list

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    // Database connection
    $host = 'localhost';
    $dbname = 'linkkart';
    $username = 'root';
    $password = '';
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Get all active stores with product count
    $stmt = $pdo->query("
        SELECT 
            s.*,
            COUNT(p.id) as products_count
        FROM stores s
        LEFT JOIN products p ON s.id = p.store_id
        WHERE s.is_active = 1
        GROUP BY s.id
        ORDER BY s.created_at DESC
    ");
    
    $stores = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format response
    echo json_encode([
        'success' => true,
        'data' => $stores
    ]);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error',
        'error' => $e->getMessage()
    ]);
}
