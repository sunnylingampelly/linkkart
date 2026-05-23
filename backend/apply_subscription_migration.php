<?php
$pdo = new PDO('mysql:host=127.0.0.1;dbname=linkkart', 'root', '');
$sql = file_get_contents(__DIR__ . '/database/migrations/create_subscription_tables.sql');

// Split SQL into individual statements
$statements = array_filter(array_map('trim', explode(';', $sql)));

foreach ($statements as $statement) {
    if (empty($statement)) continue;
    try {
        $pdo->exec($statement);
        echo "Executed: " . substr($statement, 0, 50) . "...\n";
    } catch (PDOException $e) {
        echo "Error executing statement: " . $e->getMessage() . "\n";
    }
}

echo "Subscription tables created successfully\n";
