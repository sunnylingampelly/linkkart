<?php
$host = 'localhost';
$dbname = 'linkkart';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Check if column exists first
    $stmt = $pdo->query("SHOW COLUMNS FROM stores LIKE 'description'");
    if (!$stmt->fetch()) {
        $pdo->exec("ALTER TABLE stores ADD COLUMN description TEXT NULL AFTER logo");
        echo "Successfully added 'description' column to 'stores' table.\n";
    } else {
        echo "'description' column already exists in 'stores' table.\n";
    }
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
