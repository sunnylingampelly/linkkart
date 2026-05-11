<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$pdo = new PDO("mysql:host=localhost;dbname=linkkart", "root", "");
$stmt = $pdo->query("SELECT * FROM stores WHERE deleted_at IS NULL AND is_active = 1");
$stores = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode([
    'success' => true,
    'data' => $stores,
    'count' => count($stores)
], JSON_PRETTY_PRINT);
