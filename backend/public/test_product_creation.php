<?php
/**
 * Test Product Creation - Diagnostic Script
 * This script tests the product creation process step by step
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Load environment variables
$envFile = __DIR__ . '/../.env';
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        list($key, $value) = explode('=', $line, 2);
        $_ENV[trim($key)] = trim($value);
    }
}

$diagnostics = [
    'timestamp' => date('Y-m-d H:i:s'),
    'checks' => []
];

// 1. Check database connection
try {
    $host = $_ENV['DB_HOST'] ?? '127.0.0.1';
    $dbname = $_ENV['DB_DATABASE'] ?? 'linkkart';
    $username = $_ENV['DB_USERNAME'] ?? 'root';
    $password = $_ENV['DB_PASSWORD'] ?? '';
    
    $diagnostics['checks']['db_config'] = [
        'host' => $host,
        'database' => $dbname,
        'username' => $username,
        'password_set' => !empty($password)
    ];
    
    $pdo = new PDO(
        "mysql:host=$host;dbname=$dbname;charset=utf8mb4",
        $username,
        $password,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
    
    $diagnostics['checks']['db_connection'] = [
        'status' => 'success',
        'message' => 'Database connection successful'
    ];
    
} catch (PDOException $e) {
    $diagnostics['checks']['db_connection'] = [
        'status' => 'failed',
        'error' => $e->getMessage(),
        'code' => $e->getCode()
    ];
    echo json_encode($diagnostics, JSON_PRETTY_PRINT);
    exit;
}

// 2. Check if products table exists
try {
    $stmt = $pdo->query("SHOW TABLES LIKE 'products'");
    $tableExists = $stmt->rowCount() > 0;
    
    $diagnostics['checks']['products_table'] = [
        'exists' => $tableExists,
        'status' => $tableExists ? 'success' : 'failed'
    ];
    
    if (!$tableExists) {
        echo json_encode($diagnostics, JSON_PRETTY_PRINT);
        exit;
    }
    
} catch (PDOException $e) {
    $diagnostics['checks']['products_table'] = [
        'status' => 'failed',
        'error' => $e->getMessage()
    ];
    echo json_encode($diagnostics, JSON_PRETTY_PRINT);
    exit;
}

// 3. Check products table structure
try {
    $stmt = $pdo->query("DESCRIBE products");
    $columns = $stmt->fetchAll();
    
    $columnNames = array_column($columns, 'Field');
    $requiredColumns = ['id', 'store_id', 'product_id', 'name', 'price', 'description', 'image', 'stock_quantity', 'is_active', 'click_count'];
    $missingColumns = array_diff($requiredColumns, $columnNames);
    
    $diagnostics['checks']['table_structure'] = [
        'status' => empty($missingColumns) ? 'success' : 'failed',
        'columns_found' => $columnNames,
        'missing_columns' => array_values($missingColumns)
    ];
    
} catch (PDOException $e) {
    $diagnostics['checks']['table_structure'] = [
        'status' => 'failed',
        'error' => $e->getMessage()
    ];
}

// 4. Check if stores table exists and has data
try {
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM stores");
    $storeCount = $stmt->fetch()['count'];
    
    $diagnostics['checks']['stores_table'] = [
        'status' => 'success',
        'store_count' => $storeCount
    ];
    
    if ($storeCount > 0) {
        $stmt = $pdo->query("SELECT id, name, slug FROM stores LIMIT 1");
        $sampleStore = $stmt->fetch();
        $diagnostics['checks']['sample_store'] = $sampleStore;
    }
    
} catch (PDOException $e) {
    $diagnostics['checks']['stores_table'] = [
        'status' => 'failed',
        'error' => $e->getMessage()
    ];
}

// 5. Test product insertion
try {
    // Get first store ID
    $stmt = $pdo->query("SELECT id FROM stores LIMIT 1");
    $store = $stmt->fetch();
    
    if (!$store) {
        $diagnostics['checks']['test_insertion'] = [
            'status' => 'skipped',
            'reason' => 'No stores found in database'
        ];
    } else {
        $storeId = $store['id'];
        $productId = 'TEST-' . uniqid();
        
        // Try to insert a test product
        $stmt = $pdo->prepare("
            INSERT INTO products (store_id, product_id, name, price, description, stock_quantity, is_active, click_count, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, 1, 0, NOW(), NOW())
        ");
        
        $testResult = $stmt->execute([
            $storeId,
            $productId,
            'Test Product',
            99.99,
            'Test Description',
            10
        ]);
        
        if ($testResult) {
            $insertedId = $pdo->lastInsertId();
            
            // Delete the test product
            $stmt = $pdo->prepare("DELETE FROM products WHERE id = ?");
            $stmt->execute([$insertedId]);
            
            $diagnostics['checks']['test_insertion'] = [
                'status' => 'success',
                'message' => 'Test product created and deleted successfully',
                'test_product_id' => $productId
            ];
        }
    }
    
} catch (PDOException $e) {
    $diagnostics['checks']['test_insertion'] = [
        'status' => 'failed',
        'error' => $e->getMessage(),
        'code' => $e->getCode(),
        'sql_state' => $e->errorInfo[0] ?? null
    ];
}

// 6. Check storage directory permissions
$storageDir = __DIR__ . '/storage/products/';
$diagnostics['checks']['storage_directory'] = [
    'path' => $storageDir,
    'exists' => is_dir($storageDir),
    'writable' => is_writable($storageDir),
    'parent_writable' => is_writable(__DIR__ . '/storage/')
];

// Final summary
$allPassed = true;
foreach ($diagnostics['checks'] as $check) {
    if (isset($check['status']) && $check['status'] === 'failed') {
        $allPassed = false;
        break;
    }
}

$diagnostics['overall_status'] = $allPassed ? 'ALL_CHECKS_PASSED' : 'SOME_CHECKS_FAILED';

echo json_encode($diagnostics, JSON_PRETTY_PRINT);
