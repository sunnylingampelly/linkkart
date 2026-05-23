<?php
$pdo = new PDO('mysql:host=127.0.0.1;dbname=linkkart', 'root', '');
$stmt = $pdo->query("DESCRIBE stores");
$cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
print_r($cols);
