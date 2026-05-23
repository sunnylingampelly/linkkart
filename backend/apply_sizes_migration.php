<?php
$pdo = new PDO('mysql:host=127.0.0.1;dbname=linkkart', 'root', '');
$pdo->exec("ALTER TABLE products ADD COLUMN sizes JSON DEFAULT NULL AFTER stock_quantity");
$pdo->exec("ALTER TABLE products ADD COLUMN has_sizes BOOLEAN DEFAULT FALSE AFTER sizes");
$pdo->exec("ALTER TABLE products ADD COLUMN size_chart_image VARCHAR(255) DEFAULT NULL AFTER has_sizes");
echo "Columns added successfully\n";
