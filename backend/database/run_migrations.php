<?php
/**
 * Run Database Migrations
 */

// Database connection
$host = 'localhost';
$dbname = 'linkkart';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "Connected to database successfully!\n\n";
    
    // Migration files
    $migrations = [
        'create_users_table.sql',
        'add_constraints_and_indexes.sql',
        'create_subscription_tables.sql'
    ];
    
    foreach ($migrations as $migration) {
        $file = __DIR__ . '/migrations/' . $migration;
        
        if (!file_exists($file)) {
            echo "❌ Migration file not found: $migration\n";
            continue;
        }
        
        echo "Running migration: $migration\n";
        
        $sql = file_get_contents($file);
        
        // Split by semicolon and execute each statement
        $statements = array_filter(array_map('trim', explode(';', $sql)));
        
        foreach ($statements as $statement) {
            if (empty($statement) || strpos($statement, '--') === 0) {
                continue;
            }
            
            try {
                $pdo->exec($statement);
                echo ".";
            } catch (PDOException $e) {
                $errorMsg = $e->getMessage();
                
                // Ignore these common errors when re-running migrations
                $ignorableErrors = [
                    'Duplicate key name',
                    'Duplicate entry',
                    'already exists',
                    'Can\'t DROP',
                    'check that column/key exists',
                    'Multiple primary key defined'
                ];
                
                $shouldIgnore = false;
                foreach ($ignorableErrors as $ignorable) {
                    if (stripos($errorMsg, $ignorable) !== false) {
                        $shouldIgnore = true;
                        break;
                    }
                }
                
                if (!$shouldIgnore) {
                    echo "\n⚠️  Warning: " . $errorMsg . "\n";
                    echo "Statement: " . substr($statement, 0, 100) . "...\n";
                }
            }
        }
        
        echo "\n✅ Migration completed: $migration\n\n";
    }
    
    echo "✅ All migrations completed successfully!\n";
    
} catch (PDOException $e) {
    echo "❌ Database connection failed: " . $e->getMessage() . "\n";
    exit(1);
}
