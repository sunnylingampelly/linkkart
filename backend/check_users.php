<?php
try {
    $pdo = new PDO('mysql:host=localhost;dbname=linkkart', 'root', '');
    $stmt = $pdo->query("SELECT * FROM users LIMIT 5");
    
    echo "Users data:\n";
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        print_r($row);
    }
} catch (Exception $e) {
    echo 'Error: ' . $e->getMessage();
}
