<?php
try {
    $pdo = new PDO('mysql:host=localhost;dbname=linkkart', 'root', '');
    $stmt = $pdo->query('SHOW TABLES');
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "Tables in database:\n";
    foreach ($tables as $table) {
        echo "  - $table\n";
    }
} catch (Exception $e) {
    echo 'Error: ' . $e->getMessage();
}
