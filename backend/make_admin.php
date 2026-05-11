<?php
$host = 'localhost';
$dbname = 'linkkart';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    
    // Make the user bizio@example.com or similar an admin if they exist
    // Or just make all current users admins for testing
    $pdo->exec("UPDATE users SET role = 'admin'");
    echo "All current users promoted to admin for testing.\n";
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
