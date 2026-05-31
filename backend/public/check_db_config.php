<?php
/**
 * Database Configuration Checker
 * This script helps you verify your database configuration
 */

header('Content-Type: text/html; charset=utf-8');

echo "<!DOCTYPE html>
<html>
<head>
    <title>LinkKart Database Configuration Checker</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }
        .status {
            padding: 15px;
            margin: 15px 0;
            border-radius: 5px;
            font-weight: bold;
        }
        .success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .info {
            background: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }
        .warning {
            background: #fff3cd;
            color: #856404;
            border: 1px solid #ffeaa7;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background: #4CAF50;
            color: white;
        }
        code {
            background: #f4f4f4;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: monospace;
        }
        .section {
            margin: 30px 0;
        }
    </style>
</head>
<body>
    <div class='container'>
        <h1>🔍 LinkKart Database Configuration Checker</h1>";

// Load .env file
$envFile = __DIR__ . '/../.env';
$envExists = file_exists($envFile);

echo "<div class='section'>";
echo "<h2>1. Environment File Check</h2>";

if ($envExists) {
    echo "<div class='status success'>✅ .env file found at: " . $envFile . "</div>";
    
    // Parse .env file
    $envVars = [];
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        if (strpos($line, '=') === false) continue;
        list($key, $value) = explode('=', $line, 2);
        $envVars[trim($key)] = trim($value);
    }
    
    echo "<h3>Database Configuration from .env:</h3>";
    echo "<table>";
    echo "<tr><th>Setting</th><th>Value</th><th>Status</th></tr>";
    
    $dbHost = $envVars['DB_HOST'] ?? 'NOT SET';
    $dbDatabase = $envVars['DB_DATABASE'] ?? 'NOT SET';
    $dbUsername = $envVars['DB_USERNAME'] ?? 'NOT SET';
    $dbPassword = $envVars['DB_PASSWORD'] ?? '';
    
    echo "<tr><td><strong>DB_HOST</strong></td><td><code>$dbHost</code></td><td>" . ($dbHost !== 'NOT SET' ? '✅' : '❌') . "</td></tr>";
    echo "<tr><td><strong>DB_DATABASE</strong></td><td><code>$dbDatabase</code></td><td>" . ($dbDatabase !== 'NOT SET' ? '✅' : '❌') . "</td></tr>";
    echo "<tr><td><strong>DB_USERNAME</strong></td><td><code>$dbUsername</code></td><td>" . ($dbUsername !== 'NOT SET' ? '✅' : '❌') . "</td></tr>";
    echo "<tr><td><strong>DB_PASSWORD</strong></td><td><code>" . (empty($dbPassword) ? '(empty)' : str_repeat('*', strlen($dbPassword))) . "</code></td><td>" . (!empty($dbPassword) ? '✅' : '⚠️') . "</td></tr>";
    echo "</table>";
    
} else {
    echo "<div class='status error'>❌ .env file NOT found at: " . $envFile . "</div>";
    echo "<div class='status warning'>⚠️ Create a .env file with your database credentials</div>";
}

echo "</div>";

// Test database connection
echo "<div class='section'>";
echo "<h2>2. Database Connection Test</h2>";

if ($envExists && isset($dbHost) && $dbHost !== 'NOT SET') {
    try {
        $pdo = new PDO(
            "mysql:host=$dbHost;dbname=$dbDatabase;charset=utf8mb4",
            $dbUsername,
            $dbPassword,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
            ]
        );
        
        echo "<div class='status success'>✅ Database connection successful!</div>";
        
        // Get MySQL version
        $version = $pdo->query('SELECT VERSION()')->fetchColumn();
        echo "<p><strong>MySQL Version:</strong> $version</p>";
        
        // Check tables
        echo "<h3>Database Tables:</h3>";
        $stmt = $pdo->query("SHOW TABLES");
        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        if (count($tables) > 0) {
            echo "<table>";
            echo "<tr><th>Table Name</th><th>Row Count</th></tr>";
            
            $requiredTables = ['stores', 'products', 'analytics_events', 'admins', 'plans', 'subscriptions', 'payments', 'invoices'];
            
            foreach ($tables as $table) {
                $countStmt = $pdo->query("SELECT COUNT(*) FROM `$table`");
                $count = $countStmt->fetchColumn();
                $isRequired = in_array($table, $requiredTables);
                $icon = $isRequired ? '✅' : '📋';
                echo "<tr><td>$icon <strong>$table</strong></td><td>$count rows</td></tr>";
            }
            echo "</table>";
            
            // Check for missing required tables
            $missingTables = array_diff($requiredTables, $tables);
            if (!empty($missingTables)) {
                echo "<div class='status warning'>⚠️ Missing required tables: " . implode(', ', $missingTables) . "</div>";
                echo "<p>Run <code>COMPLETE_DATABASE_SETUP_PRODUCTION.sql</code> to create missing tables.</p>";
            } else {
                echo "<div class='status success'>✅ All required tables exist!</div>";
            }
            
        } else {
            echo "<div class='status warning'>⚠️ No tables found in database</div>";
            echo "<p>Run <code>COMPLETE_DATABASE_SETUP_PRODUCTION.sql</code> to create tables.</p>";
        }
        
    } catch (PDOException $e) {
        echo "<div class='status error'>❌ Database connection failed!</div>";
        echo "<div class='status error'><strong>Error:</strong> " . htmlspecialchars($e->getMessage()) . "</div>";
        echo "<div class='status info'>";
        echo "<strong>Common Solutions:</strong><br>";
        echo "• Check if MySQL server is running<br>";
        echo "• Verify database credentials in .env file<br>";
        echo "• Ensure database '$dbDatabase' exists<br>";
        echo "• Check if user '$dbUsername' has access to database<br>";
        echo "• Verify firewall settings if using remote database";
        echo "</div>";
    }
} else {
    echo "<div class='status warning'>⚠️ Cannot test connection - .env file not configured</div>";
}

echo "</div>";

// PHP Configuration
echo "<div class='section'>";
echo "<h2>3. PHP Configuration</h2>";
echo "<table>";
echo "<tr><th>Setting</th><th>Value</th></tr>";
echo "<tr><td><strong>PHP Version</strong></td><td>" . phpversion() . "</td></tr>";
echo "<tr><td><strong>PDO MySQL</strong></td><td>" . (extension_loaded('pdo_mysql') ? '✅ Enabled' : '❌ Disabled') . "</td></tr>";
echo "<tr><td><strong>Upload Max Size</strong></td><td>" . ini_get('upload_max_filesize') . "</td></tr>";
echo "<tr><td><strong>Post Max Size</strong></td><td>" . ini_get('post_max_size') . "</td></tr>";
echo "<tr><td><strong>Memory Limit</strong></td><td>" . ini_get('memory_limit') . "</td></tr>";
echo "</table>";
echo "</div>";

// Storage Directory Check
echo "<div class='section'>";
echo "<h2>4. Storage Directory Check</h2>";
$storageDir = __DIR__ . '/storage/products/';
echo "<table>";
echo "<tr><th>Check</th><th>Status</th></tr>";
echo "<tr><td><strong>Directory Exists</strong></td><td>" . (is_dir($storageDir) ? '✅ Yes' : '❌ No') . "</td></tr>";
echo "<tr><td><strong>Writable</strong></td><td>" . (is_writable($storageDir) ? '✅ Yes' : '❌ No') . "</td></tr>";
echo "<tr><td><strong>Path</strong></td><td><code>$storageDir</code></td></tr>";
echo "</table>";

if (!is_dir($storageDir) || !is_writable($storageDir)) {
    echo "<div class='status warning'>⚠️ Storage directory issue detected</div>";
    echo "<p><strong>Fix:</strong> Run these commands on your server:</p>";
    echo "<code>mkdir -p " . $storageDir . "</code><br>";
    echo "<code>chmod -R 777 " . dirname($storageDir) . "</code>";
}
echo "</div>";

// Razorpay Configuration Check
echo "<div class='section'>";
echo "<h2>5. Razorpay Configuration Check</h2>";
$razorpayKeyId = getenv('RAZORPAY_KEY_ID') ?: ($_ENV['RAZORPAY_KEY_ID'] ?? 'NOT SET');
$razorpayKeySecret = getenv('RAZORPAY_KEY_SECRET') ?: ($_ENV['RAZORPAY_KEY_SECRET'] ?? 'NOT SET');

$isIdPlaceholder = in_array($razorpayKeyId, ['your_razorpay_key_here', 'your_razorpay_key', 'rzp_test_YOUR_KEY_ID', 'NOT SET']);
$isSecretPlaceholder = in_array($razorpayKeySecret, ['your_razorpay_secret_here', 'YOUR_KEY_SECRET', 'NOT SET']);

echo "<table>";
echo "<tr><th>Setting</th><th>Value</th><th>Status</th></tr>";
echo "<tr><td><strong>RAZORPAY_KEY_ID</strong></td><td><code>" . htmlspecialchars(substr($razorpayKeyId, 0, 8)) . "... (length: " . strlen($razorpayKeyId) . ")</code></td><td>" . (!$isIdPlaceholder ? '✅ Loaded' : '❌ Missing or Placeholder') . "</td></tr>";
echo "<tr><td><strong>RAZORPAY_KEY_SECRET</strong></td><td><code>" . htmlspecialchars(substr($razorpayKeySecret, 0, 4)) . "... (length: " . strlen($razorpayKeySecret) . ")</code></td><td>" . (!$isSecretPlaceholder ? '✅ Loaded' : '❌ Missing or Placeholder') . "</td></tr>";
echo "</table>";

if ($isIdPlaceholder || $isSecretPlaceholder) {
    echo "<div class='status error'>❌ Razorpay Credentials are missing or using placeholder values!</div>";
} else {
    echo "<div class='status success'>✅ Razorpay credentials loaded successfully from environment.</div>";
}
echo "</div>";

// Recommendations
echo "<div class='section'>";
echo "<h2>5. Recommendations</h2>";

$recommendations = [];

if (!$envExists) {
    $recommendations[] = "Create a .env file with your database credentials";
}

if (isset($dbPassword) && empty($dbPassword)) {
    $recommendations[] = "Set a strong database password for security";
}

if (!extension_loaded('pdo_mysql')) {
    $recommendations[] = "Enable PDO MySQL extension in PHP";
}

if (!is_dir($storageDir) || !is_writable($storageDir)) {
    $recommendations[] = "Create and set permissions for storage directory";
}

if (empty($recommendations)) {
    echo "<div class='status success'>✅ Everything looks good! No recommendations.</div>";
} else {
    echo "<ul>";
    foreach ($recommendations as $rec) {
        echo "<li>$rec</li>";
    }
    echo "</ul>";
}

echo "</div>";

echo "<div class='section'>";
echo "<p style='text-align: center; color: #666; margin-top: 30px;'>";
echo "LinkKart Database Configuration Checker v1.0<br>";
echo "Generated: " . date('Y-m-d H:i:s');
echo "</p>";
echo "</div>";

echo "</div>
</body>
</html>";
?>
