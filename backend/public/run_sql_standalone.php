<?php
$host = 'localhost';
$dbname = 'linkkart';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $sql = file_get_contents('../../update_database_orders.sql');
    $pdo->exec($sql);
    echo "Successfully created customers and orders tables!\n";
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
