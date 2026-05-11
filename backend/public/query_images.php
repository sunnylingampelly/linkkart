<?php
$host = '127.0.0.1';
$db   = 'linkkart';
$user = 'root';
$pass = '';

$dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";
try {
    $pdo = new PDO($dsn, $user, $pass);
    
    echo "--- PRODUCTS ---\n";
    $stmt = $pdo->query("SELECT id, name, image FROM products LIMIT 5");
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        print_r($row);
    }
    
    echo "\n--- STORES ---\n";
    $stmt = $pdo->query("SELECT id, name, logo FROM stores LIMIT 5");
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        print_r($row);
    }
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
