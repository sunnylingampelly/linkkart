<?php
try {
    $pdo = new PDO('mysql:host=localhost;dbname=linkkart', 'root', '');
    
    // Check foreign keys on orders table
    $stmt = $pdo->query("
        SELECT 
            CONSTRAINT_NAME,
            COLUMN_NAME,
            REFERENCED_TABLE_NAME,
            REFERENCED_COLUMN_NAME
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = 'linkkart'
        AND TABLE_NAME = 'orders'
        AND REFERENCED_TABLE_NAME IS NOT NULL
    ");
    
    echo "Foreign keys on orders table:\n";
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  {$row['CONSTRAINT_NAME']}: {$row['COLUMN_NAME']} -> {$row['REFERENCED_TABLE_NAME']}.{$row['REFERENCED_COLUMN_NAME']}\n";
    }
    
    // Check if customers table exists
    $stmt = $pdo->query("SHOW TABLES LIKE 'customers'");
    if ($stmt->rowCount() > 0) {
        echo "\n✓ customers table exists\n";
    } else {
        echo "\n✗ customers table does NOT exist\n";
    }
    
} catch (Exception $e) {
    echo 'Error: ' . $e->getMessage();
}
