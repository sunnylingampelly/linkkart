<?php
/**
 * Migration Runner
 * Runs SQL migration files on the database
 * 
 * Usage: php run_migration.php <migration_file>
 * Example: php run_migration.php migrations/2024_05_20_fix_store_subscriptions.sql
 */

// Load environment variables
$envFile = __DIR__ . '/../.env';
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        if (strpos($line, '=') === false) continue;
        list($key, $value) = explode('=', $line, 2);
        $_ENV[trim($key)] = trim($value);
    }
}

// Database configuration
$host = $_ENV['DB_HOST'] ?? 'localhost';
$dbname = $_ENV['DB_DATABASE'] ?? 'linkkart';
$username = $_ENV['DB_USERNAME'] ?? 'root';
$password = $_ENV['DB_PASSWORD'] ?? '';

// Get migration file from command line argument
$migrationFile = $argv[1] ?? null;

if (!$migrationFile) {
    echo "❌ Error: Please specify a migration file\n";
    echo "Usage: php run_migration.php <migration_file>\n";
    echo "Example: php run_migration.php migrations/2024_05_20_fix_store_subscriptions.sql\n";
    exit(1);
}

// Check if file exists
if (!file_exists($migrationFile)) {
    // Try with migrations directory prefix
    $migrationFile = __DIR__ . '/migrations/' . basename($migrationFile);
    if (!file_exists($migrationFile)) {
        echo "❌ Error: Migration file not found: $migrationFile\n";
        exit(1);
    }
}

echo "🔄 Running migration: " . basename($migrationFile) . "\n";
echo "📁 File: $migrationFile\n";
echo "🗄️  Database: $dbname@$host\n";
echo "\n";

try {
    // Connect to database
    $pdo = new PDO(
        "mysql:host=$host;dbname=$dbname;charset=utf8mb4",
        $username,
        $password,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
        ]
    );
    
    echo "✅ Database connection successful\n\n";
    
    // Read migration file
    $sql = file_get_contents($migrationFile);
    
    // Split into individual statements (by semicolon)
    $statements = array_filter(
        array_map('trim', explode(';', $sql)),
        function($stmt) {
            // Remove comments and empty statements
            $stmt = preg_replace('/--.*$/m', '', $stmt);
            return !empty(trim($stmt));
        }
    );
    
    echo "📝 Found " . count($statements) . " SQL statements\n\n";
    
    // Execute each statement
    $successCount = 0;
    $errorCount = 0;
    
    foreach ($statements as $index => $statement) {
        $statement = trim($statement);
        if (empty($statement)) continue;
        
        try {
            // Show first 60 chars of statement
            $preview = substr($statement, 0, 60);
            if (strlen($statement) > 60) $preview .= '...';
            echo "▶️  Executing: $preview\n";
            
            $pdo->exec($statement);
            $successCount++;
            echo "   ✅ Success\n";
            
        } catch (PDOException $e) {
            $errorCount++;
            echo "   ❌ Error: " . $e->getMessage() . "\n";
            
            // Continue with other statements even if one fails
            // (some statements like INSERT IGNORE may "fail" but that's ok)
        }
        
        echo "\n";
    }
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    echo "📊 Migration Summary:\n";
    echo "   ✅ Successful: $successCount\n";
    echo "   ❌ Errors: $errorCount\n";
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
    
    // Run verification query if it exists
    echo "🔍 Verifying migration results...\n\n";
    
    try {
        $stmt = $pdo->query("
            SELECT 
                s.id,
                s.name,
                s.subscription_id,
                sub.status as subscription_status,
                p.name as plan_name,
                p.product_limit
            FROM stores s
            LEFT JOIN subscriptions sub ON s.subscription_id = sub.id
            LEFT JOIN plans p ON sub.plan_id = p.id
        ");
        
        $stores = $stmt->fetchAll();
        
        echo "📋 Store Status:\n";
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        
        foreach ($stores as $store) {
            $status = $store['subscription_id'] ? '✅' : '❌';
            $plan = $store['plan_name'] ?? 'No Plan';
            $limit = $store['product_limit'] ?? 'N/A';
            
            echo sprintf(
                "%s Store #%d: %s\n   Plan: %s (Limit: %s products)\n",
                $status,
                $store['id'],
                $store['name'],
                $plan,
                $limit
            );
        }
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
        
        // Check if all stores have subscriptions
        $storesWithoutSub = array_filter($stores, function($s) {
            return empty($s['subscription_id']);
        });
        
        if (empty($storesWithoutSub)) {
            echo "🎉 SUCCESS! All stores have subscriptions assigned.\n";
            echo "✅ Product creation should now work in the mobile app.\n";
        } else {
            echo "⚠️  WARNING: " . count($storesWithoutSub) . " store(s) still missing subscriptions.\n";
            echo "   You may need to run the migration again or check for errors.\n";
        }
        
    } catch (PDOException $e) {
        echo "⚠️  Could not verify results: " . $e->getMessage() . "\n";
    }
    
    echo "\n✅ Migration completed!\n";
    
} catch (PDOException $e) {
    echo "❌ Database connection failed: " . $e->getMessage() . "\n";
    exit(1);
}
