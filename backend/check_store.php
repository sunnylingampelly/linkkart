<?php
try {
    $pdo = new PDO('mysql:host=localhost;dbname=linkkart', 'root', '');
    $stmt = $pdo->query("SELECT * FROM stores WHERE deleted_at IS NULL");
    $stores = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Stores in database:\n";
    foreach ($stores as $store) {
        echo "  ID: {$store['id']}, Name: {$store['name']}, Active: {$store['is_active']}\n";
    }
} catch (Exception $e) {
    echo 'Error: ' . $e->getMessage();
}
