<?php
require 'api.php';

$sql = file_get_contents('../../update_database_orders.sql');

try {
    $pdo->exec($sql);
    echo "Successfully created customers and orders tables!\n";
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
