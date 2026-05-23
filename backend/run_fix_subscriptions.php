<?php
$pdo = new PDO('mysql:host=127.0.0.1;dbname=linkkart', 'root', '');
$sql = file_get_contents(__DIR__ . '/fix_subscriptions_final.sql');

$statements = array_filter(array_map('trim', explode(';', $sql)));

foreach ($statements as $statement) {
    if (empty($statement)) continue;
    try {
        $pdo->exec($statement);
        echo "Executed: " . substr($statement, 0, 50) . "...\n";
    } catch (PDOException $e) {
        echo "Error: " . $e->getMessage() . "\n";
    }
}
echo "All done!\n";
