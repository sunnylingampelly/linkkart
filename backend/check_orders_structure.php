<?php
try {
    $pdo = new PDO('mysql:host=localhost;dbname=linkkart', 'root', '');
    $stmt = $pdo->query('DESCRIBE orders');
    
    echo "Orders table structure:\n";
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  {$row['Field']} - {$row['Type']}\n";
    }
} catch (Exception $e) {
    echo 'Error: ' . $e->getMessage();
}
