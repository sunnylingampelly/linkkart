<?php
try {
    $pdo = new PDO('mysql:host=localhost;dbname=linkkart', 'root', '');
    $stmt = $pdo->query("SELECT * FROM orders LIMIT 5");
    
    echo "Orders data:\n";
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "\nOrder ID: {$row['id']}\n";
        foreach ($row as $key => $value) {
            $display = $value === null ? 'NULL' : $value;
            echo "  $key: $display\n";
        }
    }
} catch (Exception $e) {
    echo 'Error: ' . $e->getMessage();
}
