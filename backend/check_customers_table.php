<?php
try {
    $pdo = new PDO('mysql:host=localhost;dbname=linkkart', 'root', '');
    
    echo "Customers table structure:\n";
    $stmt = $pdo->query('DESCRIBE customers');
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  {$row['Field']} - {$row['Type']}\n";
    }
    
    echo "\nCustomers data:\n";
    $stmt = $pdo->query('SELECT * FROM customers LIMIT 5');
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        print_r($row);
    }
    
} catch (Exception $e) {
    echo 'Error: ' . $e->getMessage();
}
