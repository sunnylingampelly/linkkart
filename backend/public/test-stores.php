<?php
// Test script to check stores in database

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

try {
    // Database connection
    $host = 'localhost';
    $dbname = 'linkkart';
    $username = 'root';
    $password = '';
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Get all stores
    $stmt = $pdo->query("SELECT * FROM stores ORDER BY id DESC");
    $stores = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'count' => count($stores),
        'data' => $stores
    ], JSON_PRETTY_PRINT);
    
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ], JSON_PRETTY_PRINT);
}
