<?php
/**
 * LinkKart API - Standalone Version
 * Direct MySQL connection for reliable API responses
 */

// Simple .env loader
function loadEnv($path) {
    if (!file_exists($path)) return;
    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        list($name, $value) = explode('=', $line, 2);
        $_ENV[trim($name)] = trim($value);
        putenv(trim($name) . '=' . trim($value));
    }
}
loadEnv(__DIR__ . '/../.env');

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Handle preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Load JWT library
require_once __DIR__ . '/../lib/JWT.php';

// Database connection - read from environment variables
$host = $_ENV['DB_HOST'] ?? getenv('DB_HOST') ?: 'localhost';
$dbname = $_ENV['DB_DATABASE'] ?? getenv('DB_DATABASE') ?: 'linkkart';
$username = $_ENV['DB_USERNAME'] ?? getenv('DB_USERNAME') ?: 'root';
$password = $_ENV['DB_PASSWORD'] ?? getenv('DB_PASSWORD') ?: '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $e->getMessage()
    ]);
    exit;
}

// Get request path
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

// Normalize URI (strip the script name or directory if present)
// This handles cases where the app is running in a subdirectory
$scriptName = $_SERVER['SCRIPT_NAME']; 
$baseDir = dirname($scriptName);
if ($baseDir !== '/' && $baseDir !== '\\') {
    if (strpos($uri, $baseDir) === 0) {
        $uri = substr($uri, strlen($baseDir));
    }
}

// Further normalize by removing the script filename if present in URI
$scriptFile = basename($scriptName);
$uri = str_replace('/' . $scriptFile, '', $uri);

// Ensure $uri starts with /
if (empty($uri)) $uri = '/';
if ($uri[0] !== '/') $uri = '/' . $uri;

// Health check for mobile app discovery
if ($uri === '/api/health') {
    sendJson([
        'success' => true,
        'status' => 'healthy',
        'timestamp' => time()
    ]);
}

// Database configuration check endpoint
if ($uri === '/api/check-db' || $uri === '/check_db_config.php' || $uri === '/check-db') {
    $diagnostics = [
        'timestamp' => date('Y-m-d H:i:s'),
        'database_config' => [
            'host' => $host,
            'database' => $dbname,
            'username' => $username,
            'password_set' => !empty($password)
        ],
        'connection_status' => 'connected',
        'checks' => []
    ];
    
    try {
        // Check tables
        $stmt = $pdo->query("SHOW TABLES");
        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        $diagnostics['checks']['tables'] = [
            'status' => 'success',
            'count' => count($tables),
            'tables' => $tables
        ];
        
        // Check required tables
        $requiredTables = ['stores', 'products', 'analytics_events', 'admins'];
        $missingTables = array_diff($requiredTables, $tables);
        
        if (!empty($missingTables)) {
            $diagnostics['checks']['required_tables'] = [
                'status' => 'warning',
                'missing' => array_values($missingTables)
            ];
        } else {
            $diagnostics['checks']['required_tables'] = [
                'status' => 'success',
                'message' => 'All required tables exist'
            ];
        }
        
        // Check stores count
        if (in_array('stores', $tables)) {
            $stmt = $pdo->query("SELECT COUNT(*) FROM stores");
            $storeCount = $stmt->fetchColumn();
            $diagnostics['checks']['stores'] = [
                'status' => 'success',
                'count' => $storeCount
            ];
        }
        
        // Check products count
        if (in_array('products', $tables)) {
            $stmt = $pdo->query("SELECT COUNT(*) FROM products");
            $productCount = $stmt->fetchColumn();
            $diagnostics['checks']['products'] = [
                'status' => 'success',
                'count' => $productCount
            ];
        }
        
        $diagnostics['overall_status'] = empty($missingTables) ? 'HEALTHY' : 'NEEDS_ATTENTION';
        
    } catch (PDOException $e) {
        $diagnostics['checks']['error'] = [
            'status' => 'failed',
            'error' => $e->getMessage()
        ];
        $diagnostics['overall_status'] = 'ERROR';
    }
    
    sendJson($diagnostics);
}

// Product creation test endpoint
if ($uri === '/api/test-product' || $uri === '/test_product_creation.php' || $uri === '/test-product') {
    $diagnostics = [
        'timestamp' => date('Y-m-d H:i:s'),
        'checks' => []
    ];
    
    // Check database connection
    $diagnostics['checks']['db_connection'] = [
        'status' => 'success',
        'message' => 'Database connected',
        'config' => [
            'host' => $host,
            'database' => $dbname,
            'user' => $username
        ]
    ];
    
    try {
        // Check products table
        $stmt = $pdo->query("SHOW TABLES LIKE 'products'");
        $tableExists = $stmt->rowCount() > 0;
        
        $diagnostics['checks']['products_table'] = [
            'exists' => $tableExists,
            'status' => $tableExists ? 'success' : 'failed'
        ];
        
        if ($tableExists) {
            // Check table structure
            $stmt = $pdo->query("DESCRIBE products");
            $columns = $stmt->fetchAll();
            $columnNames = array_column($columns, 'Field');
            
            $diagnostics['checks']['table_structure'] = [
                'status' => 'success',
                'columns' => $columnNames
            ];
            
            // Check if stores exist
            $stmt = $pdo->query("SELECT COUNT(*) FROM stores");
            $storeCount = $stmt->fetchColumn();
            
            $diagnostics['checks']['stores'] = [
                'status' => 'success',
                'count' => $storeCount
            ];
            
            // Try test insertion if stores exist
            if ($storeCount > 0) {
                $stmt = $pdo->query("SELECT id FROM stores LIMIT 1");
                $store = $stmt->fetch();
                $storeId = $store['id'];
                
                $testProductId = 'TEST-' . uniqid();
                
                $stmt = $pdo->prepare("
                    INSERT INTO products (store_id, product_id, name, price, stock_quantity, is_active, click_count, created_at, updated_at)
                    VALUES (?, ?, ?, ?, ?, 1, 0, NOW(), NOW())
                ");
                
                $result = $stmt->execute([$storeId, $testProductId, 'Test Product', 99.99, 10]);
                
                if ($result) {
                    $insertedId = $pdo->lastInsertId();
                    
                    // Delete test product
                    $stmt = $pdo->prepare("DELETE FROM products WHERE id = ?");
                    $stmt->execute([$insertedId]);
                    
                    $diagnostics['checks']['test_insertion'] = [
                        'status' => 'success',
                        'message' => 'Test product created and deleted successfully'
                    ];
                }
            } else {
                $diagnostics['checks']['test_insertion'] = [
                    'status' => 'skipped',
                    'reason' => 'No stores found'
                ];
            }
        }
        
        $diagnostics['overall_status'] = 'ALL_CHECKS_PASSED';
        
    } catch (PDOException $e) {
        $diagnostics['checks']['error'] = [
            'status' => 'failed',
            'error' => $e->getMessage(),
            'code' => $e->getCode()
        ];
        $diagnostics['overall_status'] = 'SOME_CHECKS_FAILED';
    }
    
    sendJson($diagnostics);
}

// Store subscription check endpoint
if ($uri === '/api/check-stores' || $uri === '/api/stores-status') {
    try {
        $stmt = $pdo->query("
            SELECT 
                s.id,
                s.name,
                s.slug,
                s.subscription_id,
                sub.status as subscription_status,
                sub.plan_id,
                p.name as plan_name,
                p.slug as plan_slug,
                p.product_limit,
                (SELECT COUNT(*) FROM products WHERE store_id = s.id AND deleted_at IS NULL) as product_count
            FROM stores s
            LEFT JOIN subscriptions sub ON s.subscription_id = sub.id
            LEFT JOIN plans p ON sub.plan_id = p.id
            WHERE s.deleted_at IS NULL
        ");
        
        $stores = $stmt->fetchAll();
        
        $issues = [];
        foreach ($stores as $store) {
            if (empty($store['subscription_id'])) {
                $issues[] = "Store '{$store['name']}' (ID: {$store['id']}) has no subscription";
            }
            if (empty($store['plan_id'])) {
                $issues[] = "Store '{$store['name']}' (ID: {$store['id']}) has no plan assigned";
            }
        }
        
        sendJson([
            'success' => true,
            'stores' => $stores,
            'issues' => $issues,
            'needs_fix' => !empty($issues),
            'fix_instructions' => empty($issues) ? null : 'Run FIX_STORE_SUBSCRIPTIONS.sql to assign free plans to stores'
        ]);
        
    } catch (PDOException $e) {
        sendJson([
            'success' => false,
            'error' => $e->getMessage()
        ], 500);
    }
}

// Handle method override for PUT/DELETE via POST
if ($method === 'POST' && isset($_POST['_method'])) {
    $method = strtoupper($_POST['_method']);
}

// Serve static files from storage directory
if (strpos($uri, '/storage/') === 0) {
    // Normalize path for Windows/Unix
    $cleanUri = ltrim($uri, '/');
    $filePath = __DIR__ . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $cleanUri);
    
    if (file_exists($filePath) && !is_dir($filePath)) {
        $ext = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
        $mimeTypes = [
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'png' => 'image/png',
            'gif' => 'image/gif',
            'webp' => 'image/webp',
            'svg' => 'image/svg+xml'
        ];
        
        if (isset($mimeTypes[$ext])) {
            header('Content-Type: ' . $mimeTypes[$ext]);
            header('Cache-Control: public, max-age=31536000');
            header('Content-Length: ' . filesize($filePath));
            readfile($filePath);
            exit;
        }
    }
}

// Flutter App & Standard Checkout Aliases
if ($uri === '/api/create-order' || $uri === '/api/payments/create-order' || $uri === '/payments/create-order') {
    $uri = '/api/v1/payments/create-order';
}
if ($uri === '/api/verify-payment' || $uri === '/api/payments/verify' || $uri === '/payments/verify') {
    $uri = '/api/v1/payments/verify';
}
if ($uri === '/api/plans' || $uri === '/plans') {
    $uri = '/api/v1/plans';
}
if ($uri === '/api/subscriptions' || $uri === '/subscriptions') {
    $uri = '/api/v1/subscriptions';
}
if ($uri === '/api/payments/history' || $uri === '/payments/history') {
    $uri = '/api/v1/payments/history';
}
if ($uri === '/api/analytics' || $uri === '/analytics') {
    $uri = '/api/v1/analytics';
}
if ($uri === '/api/stores' || $uri === '/stores') {
    $uri = '/api/v1/stores';
}
if ($uri === '/api/products' || $uri === '/products') {
    $uri = '/api/v1/products';
}

// Load payment endpoints (after $uri and $method are defined)
require_once __DIR__ . '/api_payments.php';

// Helper functions
function sendJson($data, $code = 200) {
    http_response_code($code);
    echo json_encode($data, JSON_PRETTY_PRINT);
    exit;
}

function logError($message, $context = []) {
    $logFile = __DIR__ . '/storage/logs/api.log';
    $timestamp = date('Y-m-d H:i:s');
    $contextStr = json_encode($context);
    $logMessage = "[$timestamp] $message | Context: $contextStr\n";
    @file_put_contents($logFile, $logMessage, FILE_APPEND);
}

function validateInput($data, $rules) {
    $errors = [];
    
    foreach ($rules as $field => $rule) {
        $value = $data[$field] ?? null;
        
        if (strpos($rule, 'required') !== false && empty($value)) {
            $errors[$field] = ucfirst($field) . ' is required';
            continue;
        }
        
        if (strpos($rule, 'min:') !== false && !empty($value)) {
            preg_match('/min:(\d+)/', $rule, $matches);
            $min = (int)$matches[1];
            if (strlen($value) < $min) {
                $errors[$field] = ucfirst($field) . " must be at least $min characters";
            }
        }
        
        if (strpos($rule, 'max:') !== false && !empty($value)) {
            preg_match('/max:(\d+)/', $rule, $matches);
            $max = (int)$matches[1];
            if (strlen($value) > $max) {
                $errors[$field] = ucfirst($field) . " must not exceed $max characters";
            }
        }
        
        if (strpos($rule, 'phone') !== false && !empty($value)) {
            // Remove all non-digit characters for validation
            $digitsOnly = preg_replace('/[^0-9]/', '', $value);
            // Accept 10 digits (Indian) or 12 digits (with country code like +91)
            if (strlen($digitsOnly) < 10 || strlen($digitsOnly) > 13) {
                $errors[$field] = 'Phone must be 10-13 digits';
            }
        }
        
        if (strpos($rule, 'email') !== false && !empty($value)) {
            if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                $errors[$field] = 'Invalid email format';
            }
        }
        
        if (strpos($rule, 'numeric') !== false && !empty($value)) {
            if (!is_numeric($value)) {
                $errors[$field] = ucfirst($field) . ' must be a number';
            }
        }
    }
    
    return $errors;
}

// Rate limiting
function checkRateLimit($ip) {
    $cacheFile = __DIR__ . '/storage/cache/rate_limit_' . md5($ip) . '.txt';
    $limit = 100; // requests per minute
    $window = 60; // seconds
    
    if (file_exists($cacheFile)) {
        $data = json_decode(file_get_contents($cacheFile), true);
        $elapsed = time() - $data['start'];
        
        if ($elapsed < $window) {
            if ($data['count'] >= $limit) {
                sendJson([
                    'success' => false,
                    'message' => 'Too many requests. Please try again later.',
                    'error_code' => 'RATE_LIMIT_EXCEEDED'
                ], 429);
            }
            $data['count']++;
        } else {
            $data = ['start' => time(), 'count' => 1];
        }
    } else {
        $data = ['start' => time(), 'count' => 1];
    }
    
    @file_put_contents($cacheFile, json_encode($data));
}

// Check rate limit for all requests
checkRateLimit($_SERVER['REMOTE_ADDR'] ?? 'unknown');

// Authentication helper
function requireAuth() {
    try {
        $payload = JWT::verifyRequest();
        return $payload;
    } catch (Exception $e) {
        sendJson([
            'success' => false,
            'message' => 'Unauthorized: ' . $e->getMessage(),
            'error_code' => 'UNAUTHORIZED'
        ], 401);
    }
}

function optionalAuth() {
    try {
        return JWT::verifyRequest();
    } catch (Exception $e) {
        return null;
    }
}

// Check if user owns the store
function checkStoreOwnership($pdo, $userId, $storeId) {
    $stmt = $pdo->prepare("SELECT id FROM stores WHERE id = ? AND owner_id = ?");
    $stmt->execute([$storeId, $userId]);
    return $stmt->fetch() !== false;
}

// ============================================
// AUTHENTICATION ENDPOINTS
// ============================================

// REGISTER
if ($uri === '/api/v1/auth/register' && $method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate input
    $errors = validateInput($data, [
        'name' => 'required|min:3|max:255',
        'email' => 'required|email',
        'password' => 'required|min:6',
        'phone' => 'required|phone'
    ]);
    
    if (!empty($errors)) {
        sendJson([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $errors
        ], 422);
    }
    
    try {
        // Check if email already exists
        $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
        $stmt->execute([$data['email']]);
        if ($stmt->fetch()) {
            sendJson([
                'success' => false,
                'message' => 'Email already registered',
                'error_code' => 'EMAIL_EXISTS'
            ], 422);
        }
        
        // Hash password
        $passwordHash = password_hash($data['password'], PASSWORD_BCRYPT);
        
        // Create user
        $stmt = $pdo->prepare("
            INSERT INTO users (name, email, password, phone, role, created_at, updated_at)
            VALUES (?, ?, ?, ?, 'store_owner', NOW(), NOW())
        ");
        
        $stmt->execute([
            $data['name'],
            $data['email'],
            $passwordHash,
            $data['phone']
        ]);
        
        $userId = $pdo->lastInsertId();
        
        // Generate JWT token
        $token = JWT::encode([
            'user_id' => $userId,
            'email' => $data['email'],
            'role' => 'store_owner'
        ], 86400); // 24 hours
        
        sendJson([
            'success' => true,
            'message' => 'Registration successful',
            'data' => [
                'user' => [
                    'id' => $userId,
                    'name' => $data['name'],
                    'email' => $data['email'],
                    'phone' => $data['phone'],
                    'role' => 'store_owner'
                ],
                'token' => $token,
                'token_type' => 'Bearer',
                'expires_in' => 86400
            ]
        ], 201);
        
    } catch (PDOException $e) {
        logError('Error registering user', ['error' => $e->getMessage(), 'data' => $data]);
        sendJson([
            'success' => false,
            'message' => 'Unable to register. Please try again.',
            'error_code' => 'DATABASE_ERROR'
        ], 500);
    }
}

// LOGIN
if ($uri === '/api/v1/auth/login' && $method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate input
    $errors = validateInput($data, [
        'email' => 'required|email',
        'password' => 'required'
    ]);
    
    if (!empty($errors)) {
        sendJson([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $errors
        ], 422);
    }
    
    try {
        // Get user
        $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
        $stmt->execute([$data['email']]);
        $user = $stmt->fetch();
        
        if (!$user || !password_verify($data['password'], $user['password'])) {
            sendJson([
                'success' => false,
                'message' => 'Invalid email or password',
                'error_code' => 'INVALID_CREDENTIALS'
            ], 401);
        }
        
        // Generate JWT token
        $token = JWT::encode([
            'user_id' => $user['id'],
            'email' => $user['email'],
            'role' => $user['role']
        ], 86400); // 24 hours
        
        sendJson([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => [
                    'id' => $user['id'],
                    'name' => $user['name'],
                    'email' => $user['email'],
                    'phone' => $user['phone'],
                    'role' => $user['role']
                ],
                'token' => $token,
                'token_type' => 'Bearer',
                'expires_in' => 86400
            ]
        ]);
        
    } catch (PDOException $e) {
        logError('Error logging in', ['error' => $e->getMessage(), 'email' => $data['email']]);
        sendJson([
            'success' => false,
            'message' => 'Unable to login. Please try again.',
            'error_code' => 'DATABASE_ERROR'
        ], 500);
    }
}

// GET CURRENT USER
if ($uri === '/api/v1/auth/me' && $method === 'GET') {
    $auth = requireAuth();
    
    try {
        $stmt = $pdo->prepare("SELECT id, name, email, phone, role, created_at FROM users WHERE id = ?");
        $stmt->execute([$auth['user_id']]);
        $user = $stmt->fetch();
        
        if (!$user) {
            sendJson([
                'success' => false,
                'message' => 'User not found',
                'error_code' => 'USER_NOT_FOUND'
            ], 404);
        }
        
        sendJson([
            'success' => true,
            'data' => $user
        ]);
        
    } catch (PDOException $e) {
        logError('Error fetching user', ['error' => $e->getMessage(), 'user_id' => $auth['user_id']]);
        sendJson([
            'success' => false,
            'message' => 'Unable to fetch user. Please try again.',
            'error_code' => 'DATABASE_ERROR'
        ], 500);
    }
}

// REFRESH TOKEN
if ($uri === '/api/v1/auth/refresh' && $method === 'POST') {
    $auth = requireAuth();
    
    // Generate new token
    $token = JWT::encode([
        'user_id' => $auth['user_id'],
        'email' => $auth['email'],
        'role' => $auth['role']
    ], 86400); // 24 hours
    
    sendJson([
        'success' => true,
        'message' => 'Token refreshed',
        'data' => [
            'token' => $token,
            'token_type' => 'Bearer',
            'expires_in' => 86400
        ]
    ]);
}

// LOGOUT (client-side token removal, but we log it)
if ($uri === '/api/v1/auth/logout' && $method === 'POST') {
    $auth = requireAuth();
    
    logError('User logged out', ['user_id' => $auth['user_id']]);
    
    sendJson([
        'success' => true,
        'message' => 'Logged out successfully'
    ]);
}

// ============================================
// GET ALL STORES (Homepage)
// ============================================
if ($uri === '/api/v1/stores' && $method === 'GET') {
    try {
        $stmt = $pdo->query("
            SELECT 
                s.id,
                s.name,
                s.slug,
                s.phone,
                s.logo,
                s.is_active,
                s.view_count,
                s.created_at,
                COUNT(p.id) as product_count
            FROM stores s
            LEFT JOIN products p ON s.id = p.store_id 
                AND p.deleted_at IS NULL 
                AND p.is_active = 1
            WHERE s.deleted_at IS NULL 
                AND s.is_active = 1
            GROUP BY s.id
            ORDER BY s.created_at DESC
        ");
        
        $stores = $stmt->fetchAll();
        
        // Add computed fields
        foreach ($stores as &$store) {
            $store['store_url'] = 'https://linkkart.shop/store/' . $store['slug'];
            $store['product_count'] = (int)$store['product_count'];
        }
        
        sendJson([
            'success' => true,
            'data' => $stores,
            'count' => count($stores)
        ]);
        
    } catch (PDOException $e) {
        logError('Error fetching stores', ['error' => $e->getMessage()]);
        sendJson([
            'success' => false,
            'message' => 'Unable to fetch stores. Please try again.',
            'error_code' => 'DATABASE_ERROR'
        ], 500);
    }
}

// ============================================
// GET STORE PRODUCTS (by store ID)
// ============================================
if (preg_match('#^/api/v1/stores/(\d+)/products$#', $uri, $matches) && $method === 'GET') {
    $storeId = $matches[1];
    
    try {
        // Check if store exists
        $stmt = $pdo->prepare("SELECT id FROM stores WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$storeId]);
        if (!$stmt->fetch()) {
            sendJson([
                'success' => false,
                'message' => 'Store not found',
                'error_code' => 'STORE_NOT_FOUND'
            ], 404);
        }
        
        // Get products
        $stmt = $pdo->prepare("
            SELECT 
                id,
                store_id,
                product_id,
                name,
                price,
                description,
                image,
                images,
                stock_quantity,
                sizes,
                has_sizes,
                size_chart_image,
                is_active,
                click_count,
                created_at,
                updated_at
            FROM products 
            WHERE store_id = ? 
                AND deleted_at IS NULL
            ORDER BY created_at DESC
        ");
        $stmt->execute([$storeId]);
        $products = $stmt->fetchAll();

        // Parse JSON fields and types
        foreach ($products as &$product) {
            $product['id'] = (int)$product['id'];
            $product['store_id'] = (int)$product['store_id'];
            $product['price'] = (float)$product['price'];
            $product['stock_quantity'] = (int)$product['stock_quantity'];
            $product['click_count'] = (int)$product['click_count'];
            $product['is_active'] = (bool)$product['is_active'];
            $product['has_sizes'] = (bool)$product['has_sizes'];

            if (!empty($product['sizes'])) {
                $product['sizes'] = json_decode($product['sizes'], true);
            }
            if (!empty($product['images'])) {
                $decoded = json_decode($product['images'], true);
                if (json_last_error() === JSON_ERROR_NONE) {
                    $product['images'] = $decoded;
                }
            }
        }
        
        sendJson([
            'success' => true,
            'data' => $products,
            'count' => count($products)
        ]);
        
    } catch (PDOException $e) {
        logError('Error fetching products', ['store_id' => $storeId, 'error' => $e->getMessage()]);
        sendJson([
            'success' => false,
            'message' => 'Unable to fetch products. Please try again.',
            'error_code' => 'DATABASE_ERROR'
        ], 500);
    }
}

// ============================================
// SEARCH STORE BY PHONE
// ============================================
if ($uri === '/api/v1/stores/search-by-phone' && $method === 'GET') {
    $phone = $_GET['phone'] ?? '';
    
    if (empty($phone)) {
        sendJson(['success' => false, 'message' => 'Phone number is required'], 400);
    }
    
    try {
        // Normalize search phone
        $cleanPhone = preg_replace('/[^0-9]/', '', $phone);
        $last10 = (strlen($cleanPhone) >= 10) ? substr($cleanPhone, -10) : $cleanPhone;
        
        // Search by exact phone OR matching the last 10 digits
        // We also try matching against a cleaned version of the phone column if possible
        $stmt = $pdo->prepare("
            SELECT * FROM stores 
            WHERE (phone = ? OR phone LIKE ? OR REPLACE(REPLACE(REPLACE(phone, ' ', ''), '+', ''), '-', '') LIKE ?) 
            AND deleted_at IS NULL 
            ORDER BY created_at DESC LIMIT 1
        ");
        $stmt->execute([$phone, "%$last10", "%$last10"]);
        $store = $stmt->fetch();
        
        if (!$store) {
            sendJson(['success' => false, 'message' => 'Store not found'], 404);
        }
        
        // Add computed fields
        $store['store_url'] = 'https://linkkart.shop/store/' . $store['slug'];
        
        sendJson([
            'success' => true,
            'data' => $store
        ]);
    } catch (PDOException $e) {
        sendJson(['success' => false, 'message' => 'Database error: ' . $e->getMessage()], 500);
    }
}

// ============================================
// GET STORE BY SLUG OR ID (Store Page)
// ============================================
if (preg_match('#^/api/v1/stores/([^/]+)$#', $uri, $matches) && $method === 'GET') {
    $slug = $matches[1];
    
    try {
        // Get store using prepared statement - check both slug and id
        $stmt = $pdo->prepare("
            SELECT * FROM stores 
            WHERE (slug = ? OR id = ?) 
                AND is_active = 1 
                AND deleted_at IS NULL
        ");
        $stmt->execute([$slug, $slug]);
        $store = $stmt->fetch();
        
        if (!$store) {
            sendJson([
                'success' => false,
                'message' => 'Store not found',
                'error_code' => 'STORE_NOT_FOUND'
            ], 404);
        }
        
        // Get products using prepared statement
        $stmt = $pdo->prepare("
            SELECT 
                id,
                store_id,
                product_id,
                name,
                price,
                description,
                image,
                images,
                stock_quantity,
                sizes,
                has_sizes,
                size_chart_image,
                is_active,
                click_count,
                created_at,
                updated_at
            FROM products 
            WHERE store_id = ? 
                AND is_active = 1 
                AND deleted_at IS NULL
            ORDER BY created_at DESC
        ");
        $stmt->execute([$store['id']]);
        $products = $stmt->fetchAll();
        
        // Parse JSON fields for each product
        foreach ($products as &$product) {
            // Parse sizes JSON
            if (!empty($product['sizes'])) {
                $product['sizes'] = json_decode($product['sizes'], true);
            }
            // Parse images JSON
            if (!empty($product['images'])) {
                $decoded = json_decode($product['images'], true);
                if (json_last_error() === JSON_ERROR_NONE) {
                    $product['images'] = $decoded;
                }
            }
            // Convert has_sizes to boolean
            $product['has_sizes'] = (bool)$product['has_sizes'];
        }
        
        // Add computed fields
        $store['store_url'] = 'https://linkkart.shop/store/' . $store['slug'];
        $store['product_count'] = count($products);
        $store['products'] = $products;
        
        sendJson([
            'success' => true,
            'data' => $store
        ]);
        
    } catch (PDOException $e) {
        logError('Error fetching store', ['slug' => $slug, 'error' => $e->getMessage()]);
        sendJson([
            'success' => false,
            'message' => 'Unable to fetch store. Please try again.',
            'error_code' => 'DATABASE_ERROR'
        ], 500);
    }
}

// ============================================
// UPDATE STORE
// ============================================
if ((preg_match('#^/api/v1/stores/(\d+)$#', $uri, $matches) && ($method === 'PUT' || $method === 'PATCH')) || 
    (preg_match('#^/api/v1/seller/stores/(\d+)/update$#', $uri, $matches) && $method === 'POST') ||
    (preg_match('#^/api/v1/stores/(\d+)$#', $uri, $matches) && $method === 'POST')) {
    $storeId = $matches[1];
    
    $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
    if (strpos($contentType, 'multipart/form-data') !== false || strpos($contentType, 'application/x-www-form-urlencoded') !== false) {
        $data = $_POST;
        if (isset($_FILES['logo']) && $_FILES['logo']['error'] === UPLOAD_ERR_OK) {
            $uploadDir = __DIR__ . '/storage/stores/';
            if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
            $ext = pathinfo($_FILES['logo']['name'], PATHINFO_EXTENSION);
            $filename = uniqid() . '.' . $ext;
            if (move_uploaded_file($_FILES['logo']['tmp_name'], $uploadDir . $filename)) {
                $data['logo'] = '/storage/stores/' . $filename;
            }
        }
    } else {
        $data = json_decode(file_get_contents('php://input'), true) ?? [];
    }
    
    // Validate input
    $errors = validateInput($data, [
        'name' => 'min:3|max:255',
        'phone' => 'phone',
        'description' => 'max:1000'
    ]);
    
    if (!empty($errors)) {
        sendJson(['success' => false, 'message' => 'Validation failed', 'errors' => $errors], 422);
    }
    
    try {
        // Check if store exists
        $stmt = $pdo->prepare("SELECT id FROM stores WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$storeId]);
        if (!$stmt->fetch()) {
            sendJson(['success' => false, 'message' => 'Store not found', 'error_code' => 'STORE_NOT_FOUND'], 404);
        }
        
        $updates = [];
        $params  = [];

        if (isset($data['name']) && !empty($data['name'])) {
            $updates[] = 'name = ?';
            $params[]  = $data['name'];
            
            // Also update slug if name changes
            $slug = strtolower(trim(preg_replace('/[^A-Za-z0-9-]+/', '-', $data['name'])));
            $updates[] = 'slug = ?';
            $params[]  = $slug;
        }
        if (isset($data['phone']) && !empty($data['phone'])) {
            $updates[] = 'phone = ?';
            $params[]  = $data['phone'];
        }
        if (isset($data['description'])) {
            $updates[] = 'description = ?';
            $params[]  = $data['description'];
        }
        if (isset($data['logo'])) {
            $updates[] = 'logo = ?';
            $params[]  = $data['logo'];
        }
        if (isset($data['is_active'])) {
            $updates[] = 'is_active = ?';
            $params[]  = $data['is_active'] ? 1 : 0;
        }

        if (empty($updates)) {
            sendJson(['success' => false, 'message' => 'Nothing to update'], 422);
        }

        $updates[] = 'updated_at = NOW()';
        $params[]  = $storeId;

        $sql = 'UPDATE stores SET ' . implode(', ', $updates) . ' WHERE id = ? AND deleted_at IS NULL';
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);

        // Return updated store
        $stmt = $pdo->prepare('SELECT id, name, phone, slug, logo, description, view_count, is_active, created_at, updated_at FROM stores WHERE id = ?');
        $stmt->execute([$storeId]);
        $store = $stmt->fetch();
        $store['store_url'] = 'https://linkkart.shop/store/' . $store['slug'];
        
        sendJson(['success' => true, 'message' => 'Store updated successfully', 'data' => $store]);

    } catch (PDOException $e) {
        logError('Error updating store', ['store_id' => $storeId, 'error' => $e->getMessage()]);
        sendJson(['success' => false, 'message' => 'Unable to update store.', 'error_code' => 'DATABASE_ERROR'], 500);
    }
}

// ============================================
// GET STORE STATISTICS
// ============================================
if (preg_match('#^/api/v1/stores/(\d+)/statistics$#', $uri, $matches) && $method === 'GET') {
    $storeId = $matches[1];
    
    try {
        $stmt = $pdo->prepare("SELECT view_count FROM stores WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$storeId]);
        $store = $stmt->fetch();
        
        if (!$store) {
            sendJson(['success' => false, 'message' => 'Store not found', 'error_code' => 'STORE_NOT_FOUND'], 404);
        }
        
        $stmt = $pdo->prepare("SELECT COUNT(*) as total_products, SUM(click_count) as total_clicks FROM products WHERE store_id = ? AND deleted_at IS NULL");
        $stmt->execute([$storeId]);
        $productStats = $stmt->fetch();
        
        $stmt = $pdo->prepare("
            SELECT 
                COUNT(CASE WHEN status != 'cancelled' THEN 1 END) as total_orders, 
                SUM(CASE WHEN status = 'completed' THEN total_price ELSE 0 END) as total_revenue,
                COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_orders
            FROM orders 
            WHERE store_id = ?
        ");
        $stmt->execute([$storeId]);
        $orderStats = $stmt->fetch();
        
        sendJson([
            'success' => true,
            'data' => [
                'total_revenue' => (float)($orderStats['total_revenue'] ?? 0),
                'total_orders' => (int)($orderStats['total_orders'] ?? 0),
                'pending_orders' => (int)($orderStats['pending_orders'] ?? 0),
                'total_products' => (int)$productStats['total_products'],
                'total_views' => (int)$store['view_count'],
                'total_clicks' => (int)$productStats['total_clicks'] ?? 0
            ]
        ]);
    } catch (PDOException $e) {
        logError('Error fetching statistics', ['store_id' => $storeId, 'error' => $e->getMessage()]);
        sendJson(['success' => false, 'message' => 'Unable to fetch statistics.', 'error_code' => 'DATABASE_ERROR'], 500);
    }
}

// ============================================
// TRACK ANALYTICS
// ============================================
if ($uri === '/api/v1/analytics/track' && $method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate input
    $errors = validateInput($data, [
        'event_type' => 'required'
    ]);
    
    if (!empty($errors)) {
        sendJson([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $errors
        ], 422);
    }
    
    try {
        $stmt = $pdo->prepare("
            INSERT INTO analytics_events 
            (store_id, product_id, event_type, ip_address, user_agent, metadata, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())
        ");
        
        $stmt->execute([
            $data['store_id'] ?? null,
            $data['product_id'] ?? null,
            $data['event_type'] ?? 'store_view',
            $_SERVER['REMOTE_ADDR'] ?? null,
            $_SERVER['HTTP_USER_AGENT'] ?? null,
            json_encode($data['metadata'] ?? [])
        ]);
        
        // Update counters using prepared statements
        if (isset($data['store_id']) && $data['event_type'] === 'store_view') {
            $stmt = $pdo->prepare("UPDATE stores SET view_count = view_count + 1 WHERE id = ?");
            $stmt->execute([$data['store_id']]);
        }
        
        if (isset($data['product_id']) && $data['event_type'] === 'product_click') {
            $stmt = $pdo->prepare("UPDATE products SET click_count = click_count + 1 WHERE id = ?");
            $stmt->execute([$data['product_id']]);
        }
        
        sendJson([
            'success' => true,
            'message' => 'Event tracked'
        ], 201);
        
    } catch (PDOException $e) {
        logError('Error tracking analytics', ['error' => $e->getMessage(), 'data' => $data]);
        sendJson([
            'success' => false,
            'message' => 'Unable to track event. Please try again.',
            'error_code' => 'DATABASE_ERROR'
        ], 500);
    }
}

// ============================================
// CREATE ORDER
// ============================================
if ($uri === '/api/v1/orders' && $method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate input
    $errors = validateInput($data, [
        'store_id' => 'required|numeric',
        'product_id' => 'required|numeric',
        'name' => 'required|min:2',
        'phone' => 'required|min:8',
        'quantity' => 'required|numeric',
        'total_price' => 'required|numeric'
    ]);
    
    if (!empty($errors)) {
        sendJson([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $errors
        ], 422);
    }
    
    try {
        $pdo->beginTransaction();
        
        // 1. Find or create customer
        $stmt = $pdo->prepare("SELECT id FROM customers WHERE store_id = ? AND phone = ?");
        $stmt->execute([$data['store_id'], $data['phone']]);
        $customer = $stmt->fetch();
        
        if ($customer) {
            $customerId = $customer['id'];
            // Update address/name if needed
            $stmt = $pdo->prepare("UPDATE customers SET name = ?, address = ?, updated_at = NOW() WHERE id = ?");
            $stmt->execute([$data['name'], $data['address'] ?? null, $customerId]);
        } else {
            $stmt = $pdo->prepare("INSERT INTO customers (store_id, name, phone, address, created_at, updated_at) VALUES (?, ?, ?, ?, NOW(), NOW())");
            $stmt->execute([$data['store_id'], $data['name'], $data['phone'], $data['address'] ?? null]);
            $customerId = $pdo->lastInsertId();
        }
        
        // 2. Create order
        $stmt = $pdo->prepare("INSERT INTO orders (store_id, customer_id, product_id, quantity, total_price, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, 'pending', NOW(), NOW())");
        $stmt->execute([$data['store_id'], $customerId, $data['product_id'], $data['quantity'], $data['total_price']]);
        $orderId = $pdo->lastInsertId();
        
        $pdo->commit();
        
        sendJson([
            'success' => true,
            'message' => 'Order created successfully',
            'data' => [
                'order_id' => $orderId,
                'customer_id' => $customerId
            ]
        ], 201);
        
    } catch (PDOException $e) {
        $pdo->rollBack();
        logError('Error creating order', ['error' => $e->getMessage(), 'data' => $data]);
        sendJson([
            'success' => false,
            'message' => 'Unable to create order. Please try again.',
            'error_code' => 'DATABASE_ERROR'
        ], 500);
    }
}

// ============================================
// GET STORE ORDERS
// ============================================
if (preg_match('#^/api/v1/stores/(\d+)/orders$#', $uri, $matches) && $method === 'GET') {
    $storeId = $matches[1];
    // For MVP local development, we skip strict auth. In production, restore this.
    // $auth = requireAuth();
    // if (!checkStoreOwnership($pdo, $auth['user_id'], $storeId)) {
    //     sendJson(['success' => false, 'message' => 'Unauthorized'], 403);
    // }
    try {
        $stmt = $pdo->prepare("
            SELECT o.*, c.name as customer_name, c.phone as customer_phone, c.address as customer_address, p.name as product_name, p.image as product_image
            FROM orders o
            JOIN customers c ON o.customer_id = c.id
            JOIN products p ON o.product_id = p.id
            WHERE o.store_id = ?
            ORDER BY o.created_at DESC
        ");
        $stmt->execute([$storeId]);
        $orders = $stmt->fetchAll();
        sendJson(['success' => true, 'data' => $orders]);
    } catch (PDOException $e) {
        sendJson(['success' => false, 'message' => 'Database error'], 500);
    }
}

// ============================================
// GET STORE CUSTOMERS
// ============================================
if (preg_match('#^/api/v1/stores/(\d+)/customers$#', $uri, $matches) && $method === 'GET') {
    $storeId = $matches[1];
    // For MVP local development, we skip strict auth. In production, restore this.
    // $auth = requireAuth();
    // if (!checkStoreOwnership($pdo, $auth['user_id'], $storeId)) {
    //     sendJson(['success' => false, 'message' => 'Unauthorized'], 403);
    // }
    try {
        $stmt = $pdo->prepare("
            SELECT c.*, COUNT(o.id) as total_orders, SUM(o.total_price) as total_spent
            FROM customers c
            LEFT JOIN orders o ON c.id = o.customer_id AND o.status != 'cancelled'
            WHERE c.store_id = ?
            GROUP BY c.id
            ORDER BY c.created_at DESC
        ");
        $stmt->execute([$storeId]);
        $customers = $stmt->fetchAll();
        sendJson(['success' => true, 'data' => $customers]);
    } catch (PDOException $e) {
        sendJson(['success' => false, 'message' => 'Database error'], 500);
    }
}

// ============================================
// UPDATE ORDER STATUS
// ============================================
if (preg_match('#^/api/v1/orders/(\d+)/status$#', $uri, $matches) && $method === 'PUT') {
    $orderId = $matches[1];
    // $auth = requireAuth();
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['status']) || !in_array($data['status'], ['pending', 'completed', 'cancelled'])) {
        sendJson(['success' => false, 'message' => 'Invalid status'], 400);
    }
    
    try {
        // For MVP local development, we skip strict auth. In production, restore this.
        // Verify ownership
        // $stmt = $pdo->prepare("
        //     SELECT o.id FROM orders o 
        //     JOIN stores s ON o.store_id = s.id 
        //     WHERE o.id = ? AND s.owner_id = ?
        // ");
        // $stmt->execute([$orderId, $auth['user_id']]);
        // if (!$stmt->fetch()) {
        //     sendJson(['success' => false, 'message' => 'Unauthorized'], 403);
        // }
        
        $stmt = $pdo->prepare("UPDATE orders SET status = ?, updated_at = NOW() WHERE id = ?");
        $stmt->execute([$data['status'], $orderId]);
        
        // Decrease stock if marked as completed
        if ($data['status'] === 'completed') {
            $stmt = $pdo->prepare("SELECT product_id, quantity FROM orders WHERE id = ?");
            $stmt->execute([$orderId]);
            $order = $stmt->fetch();
            if ($order) {
                $stmt = $pdo->prepare("UPDATE products SET stock_quantity = GREATEST(0, stock_quantity - ?) WHERE id = ?");
                $stmt->execute([$order['quantity'], $order['product_id']]);
            }
        }
        
        sendJson(['success' => true, 'message' => 'Order status updated']);
    } catch (PDOException $e) {
        sendJson(['success' => false, 'message' => 'Database error'], 500);
    }
}

// ============================================
// HEALTH CHECK
// ============================================
if ($uri === '/api/health' && $method === 'GET') {
    try {
        // Test database
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM stores");
        $result = $stmt->fetch();
        
        sendJson([
            'success' => true,
            'message' => 'LinkKart API is running',
            'version' => '1.0.0',
            'database' => 'Connected',
            'stores_count' => (int)$result['count'],
            'timestamp' => date('c')
        ]);
    } catch (PDOException $e) {
        sendJson([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ], 500);
    }
}

// ============================================
// CREATE STORE
// ============================================
if (($uri === '/api/v1/stores' || $uri === '/api/v1/seller/stores') && $method === 'POST') {
    // Handle both JSON and multipart form data
    $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
    
    if (strpos($contentType, 'multipart/form-data') !== false) {
        // Multipart form data (with file upload)
        $data = $_POST;
        
        // Handle logo upload
        if (isset($_FILES['logo']) && $_FILES['logo']['error'] === UPLOAD_ERR_OK) {
            $uploadDir = __DIR__ . '/storage/stores/';
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0755, true);
            }
            
            $extension = pathinfo($_FILES['logo']['name'], PATHINFO_EXTENSION);
            $filename = uniqid() . '.' . $extension;
            $filepath = $uploadDir . $filename;
            
            if (move_uploaded_file($_FILES['logo']['tmp_name'], $filepath)) {
                $data['logo'] = '/storage/stores/' . $filename;
            }
        }
    } else {
        // JSON data
        $data = json_decode(file_get_contents('php://input'), true);
    }
    
    // Validate input
    $errors = validateInput($data, [
        'name' => 'required|min:3|max:255',
        'phone' => 'required|phone'
    ]);
    
    if (!empty($errors)) {
        sendJson([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $errors
        ], 422);
    }
    
    try {
        // Check if store already exists with this phone number
        $cleanPhone = preg_replace('/[^0-9]/', '', $data['phone']);
        $last10 = (strlen($cleanPhone) >= 10) ? substr($cleanPhone, -10) : $cleanPhone;
        
        $stmt = $pdo->prepare("
            SELECT * FROM stores 
            WHERE (phone = ? OR phone LIKE ? OR REPLACE(REPLACE(REPLACE(phone, ' ', ''), '+', ''), '-', '') LIKE ?) 
            AND deleted_at IS NULL 
            ORDER BY created_at DESC LIMIT 1
        ");
        $stmt->execute([$data['phone'], "%$last10", "%$last10"]);
        $existingStore = $stmt->fetch();
        
        if ($existingStore) {
            sendJson([
                'success' => true,
                'message' => 'Welcome back! Found your existing store.',
                'data' => $existingStore
            ], 200);
        }

        // Generate slug
        $slug = strtolower(trim(preg_replace('/[^A-Za-z0-9-]+/', '-', $data['name'])));
        
        // Make slug unique
        $originalSlug = $slug;
        $stmt = $pdo->prepare("SELECT id FROM stores WHERE slug = ?");
        $stmt->execute([$slug]);
        while ($stmt->fetch()) {
            $slug = $originalSlug . '-' . substr(md5(uniqid()), 0, 6);
            $stmt->execute([$slug]);
        }
        
        // Insert store
        $stmt = $pdo->prepare("
            INSERT INTO stores (name, slug, phone, logo, is_active, created_at, updated_at)
            VALUES (?, ?, ?, ?, 1, NOW(), NOW())
        ");
        
        $stmt->execute([
            $data['name'],
            $slug,
            $data['phone'],
            $data['logo'] ?? null
        ]);
        
        $storeId = $pdo->lastInsertId();
        
        // Get the complete store data
        $stmt = $pdo->prepare("
            SELECT id, name, slug, phone, logo, is_active, view_count, created_at, updated_at
            FROM stores 
            WHERE id = ?
        ");
        $stmt->execute([$storeId]);
        $store = $stmt->fetch();
        
        sendJson([
            'success' => true,
            'message' => 'Store created successfully',
            'data' => [
                'id' => (int)$store['id'],
                'name' => $store['name'],
                'slug' => $store['slug'],
                'phone' => $store['phone'],
                'logo' => $store['logo'],
                'is_active' => (int)$store['is_active'],
                'view_count' => (int)$store['view_count'],
                'product_count' => 0,
                'store_url' => 'https://linkkart.shop/store/' . $store['slug'],
                'created_at' => $store['created_at'],
                'updated_at' => $store['updated_at']
            ]
        ], 201);
        
    } catch (PDOException $e) {
        logError('Error creating store', ['error' => $e->getMessage(), 'data' => $data]);
        sendJson([
            'success' => false,
            'message' => 'Unable to create store. Please try again.',
            'error_code' => 'DATABASE_ERROR'
        ], 500);
    }
}


// ============================================
// DELETE STORE (Soft Delete)
// ============================================
if (preg_match('#^/api/v1/stores/(\d+)$#', $uri, $matches) && $method === 'DELETE') {
    $storeId = $matches[1];
    
    try {
        // Check if store exists
        $stmt = $pdo->prepare("SELECT id FROM stores WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$storeId]);
        if (!$stmt->fetch()) {
            sendJson([
                'success' => false,
                'message' => 'Store not found',
                'error_code' => 'STORE_NOT_FOUND'
            ], 404);
        }
        
        // Soft delete
        $stmt = $pdo->prepare("UPDATE stores SET deleted_at = NOW() WHERE id = ?");
        $stmt->execute([$storeId]);
        
        sendJson([
            'success' => true,
            'message' => 'Store deleted successfully'
        ]);
        
    } catch (PDOException $e) {
        logError('Error deleting store', ['store_id' => $storeId, 'error' => $e->getMessage()]);
        sendJson([
            'success' => false,
            'message' => 'Unable to delete store. Please try again.',
            'error_code' => 'DATABASE_ERROR'
        ], 500);
    }
}

// ============================================
// CREATE PRODUCT
// ============================================
if (($uri === '/api/v1/products' || $uri === '/api/v1/seller/products') && $method === 'POST') {
    // Handle both JSON and multipart form data
    $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
    
    if (strpos($contentType, 'multipart/form-data') !== false) {
        // Multipart form data (with file upload)
        $data = $_POST;
        
        // Handle image upload
        if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
            $uploadDir = __DIR__ . '/storage/products/';
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0755, true);
            }
            
            $extension = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
            $filename = uniqid() . '.' . $extension;
            $filepath = $uploadDir . $filename;
            
            if (move_uploaded_file($_FILES['image']['tmp_name'], $filepath)) {
                $data['image'] = '/storage/products/' . $filename;
            }
        }
    } else {
        // JSON data
        $data = json_decode(file_get_contents('php://input'), true);
    }
    
    // Validate input
    $errors = validateInput($data, [
        'store_id' => 'required|numeric',
        'name' => 'required|min:3|max:255',
        'price' => 'required|numeric'
    ]);
    
    if (!empty($errors)) {
        sendJson([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $errors
        ], 422);
    }
    
    try {
        // Check if store exists and get plan limits
        $stmt = $pdo->prepare("
            SELECT s.id, p.product_limit 
            FROM stores s
            LEFT JOIN subscriptions sub ON s.subscription_id = sub.id
            LEFT JOIN plans p ON sub.plan_id = p.id
            WHERE s.id = ? AND s.deleted_at IS NULL
        ");
        $stmt->execute([$data['store_id']]);
        $storeData = $stmt->fetch();

        if (!$storeData) {
            sendJson([
                'success' => false,
                'message' => 'Store not found',
                'error_code' => 'STORE_NOT_FOUND'
            ], 404);
        }

        // Check product limit
        $limit = $storeData['product_limit'] ?? 5; // Default to 5 if no plan (trial/free)
        
        $stmt = $pdo->prepare("SELECT COUNT(*) as total FROM products WHERE store_id = ? AND deleted_at IS NULL");
        $stmt->execute([$data['store_id']]);
        $currentCount = $stmt->fetch()['total'];

        if ($currentCount >= $limit) {
            sendJson([
                'success' => false,
                'message' => "Product limit reached for your current plan ($limit items). Please upgrade to add more.",
                'error_code' => 'PLAN_LIMIT_REACHED',
                'limit' => $limit
            ], 403);
        }
        
        // Generate product_id
        $productId = 'PRD' . time() . rand(1000, 9999);
        
        // Handle sizes
        $hasSizes = isset($data['has_sizes']) && ($data['has_sizes'] === '1' || $data['has_sizes'] === 1 || $data['has_sizes'] === true);
        $sizes = null;
        $sizeChartImage = null;
        $stockQuantity = 0;
        
        if ($hasSizes && isset($data['sizes'])) {
            // Sizes is already JSON string from mobile app
            $sizes = is_string($data['sizes']) ? $data['sizes'] : json_encode($data['sizes']);
            
            // Calculate total stock from sizes
            $sizesArray = json_decode($sizes, true);
            if (is_array($sizesArray)) {
                $stockQuantity = array_sum($sizesArray);
            }
            
            // Handle size chart image upload
            if (isset($_FILES['size_chart_image']) && $_FILES['size_chart_image']['error'] === UPLOAD_ERR_OK) {
                $uploadDir = __DIR__ . '/storage/products/';
                if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
                $extension = pathinfo($_FILES['size_chart_image']['name'], PATHINFO_EXTENSION);
                $filename = 'size_chart_' . uniqid() . '.' . $extension;
                $filepath = $uploadDir . $filename;
                if (move_uploaded_file($_FILES['size_chart_image']['tmp_name'], $filepath)) {
                    $sizeChartImage = '/storage/products/' . $filename;
                }
            }
        } else {
            // No sizes, use provided stock quantity
            $stockQuantity = $data['stock_quantity'] ?? 0;
        }
        
        // Insert product
        $stmt = $pdo->prepare("
            INSERT INTO products 
            (store_id, product_id, name, price, description, image, images, stock_quantity, has_sizes, sizes, size_chart_image, is_active, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())
        ");
        
        $stmt->execute([
            $data['store_id'],
            $productId,
            $data['name'],
            $data['price'],
            $data['description'] ?? null,
            $data['image'] ?? null,
            isset($data['images']) ? json_encode($data['images']) : null,
            $stockQuantity,
            $hasSizes ? 1 : 0,
            $sizes,
            $sizeChartImage
        ]);
        
        $id = $pdo->lastInsertId();
        
        // Get the complete product data
        $stmt = $pdo->prepare("SELECT * FROM products WHERE id = ?");
        $stmt->execute([$id]);
        $product = $stmt->fetch();
        
        // Parse sizes if present
        $productSizes = null;
        if (!empty($product['sizes'])) {
            $productSizes = json_decode($product['sizes'], true);
        }
        
        sendJson([
            'success' => true,
            'message' => 'Product created successfully',
            'data' => [
                'id' => (int)$product['id'],
                'store_id' => (int)$product['store_id'],
                'product_id' => $product['product_id'],
                'name' => $product['name'],
                'price' => $product['price'],
                'description' => $product['description'],
                'image' => $product['image'],
                'images' => $product['images'],
                'stock_quantity' => (int)$product['stock_quantity'],
                'has_sizes' => (bool)$product['has_sizes'],
                'sizes' => $productSizes,
                'size_chart_image' => $product['size_chart_image'],
                'is_active' => (int)$product['is_active'],
                'click_count' => (int)$product['click_count'],
                'created_at' => $product['created_at'],
                'updated_at' => $product['updated_at']
            ]
        ], 201);
        
    } catch (PDOException $e) {
        logError('Error creating product', ['error' => $e->getMessage(), 'data' => $data]);
        sendJson([
            'success' => false,
            'message' => 'Unable to create product. Please try again.',
            'error_code' => 'DATABASE_ERROR'
        ], 500);
    }
}

// ============================================
// UPDATE PRODUCT
// ============================================
if ((preg_match('#^/api/v1/products/(\d+)$#', $uri, $matches) && ($method === 'PUT' || $method === 'PATCH')) || 
    (preg_match('#^/api/v1/products/(\d+)/update$#', $uri, $matches) && $method === 'POST') ||
    (preg_match('#^/api/v1/seller/products/(\d+)/update$#', $uri, $matches) && $method === 'POST')) {
    $productId = $matches[1];
    
    $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
    if (strpos($contentType, 'multipart/form-data') !== false || strpos($contentType, 'application/x-www-form-urlencoded') !== false) {
        $data = $_POST;
        if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
            $uploadDir = __DIR__ . '/storage/products/';
            if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
            $ext = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
            $filename = uniqid() . '.' . $ext;
            if (move_uploaded_file($_FILES['image']['tmp_name'], $uploadDir . $filename)) {
                $data['image'] = '/storage/products/' . $filename;
            }
        }
        // Handle size chart image upload
        if (isset($_FILES['size_chart_image']) && $_FILES['size_chart_image']['error'] === UPLOAD_ERR_OK) {
            $uploadDir = __DIR__ . '/storage/products/';
            if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
            $ext = pathinfo($_FILES['size_chart_image']['name'], PATHINFO_EXTENSION);
            $filename = 'size_chart_' . uniqid() . '.' . $ext;
            if (move_uploaded_file($_FILES['size_chart_image']['tmp_name'], $uploadDir . $filename)) {
                $data['size_chart_image'] = '/storage/products/' . $filename;
            }
        }
    } else {
        $data = json_decode(file_get_contents('php://input'), true) ?? [];
    }
    
    // Validate input
    $errors = validateInput($data, [
        'name' => 'min:3|max:255',
        'price' => 'numeric'
    ]);
    
    if (!empty($errors)) {
        sendJson([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $errors
        ], 422);
    }
    
    try {
        // Check if product exists
        $stmt = $pdo->prepare("SELECT id FROM products WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$productId]);
        if (!$stmt->fetch()) {
            sendJson([
                'success' => false,
                'message' => 'Product not found',
                'error_code' => 'PRODUCT_NOT_FOUND'
            ], 404);
        }
        
        // Build update query
        $updates = [];
        $params = [];
        
        if (isset($data['name'])) {
            $updates[] = "name = ?";
            $params[] = $data['name'];
        }
        if (isset($data['price'])) {
            $updates[] = "price = ?";
            $params[] = $data['price'];
        }
        if (isset($data['description'])) {
            $updates[] = "description = ?";
            $params[] = $data['description'];
        }
        if (isset($data['image'])) {
            $updates[] = "image = ?";
            $params[] = $data['image'];
        }
        if (isset($data['images'])) {
            $updates[] = "images = ?";
            $params[] = json_encode($data['images']);
        }
        
        // Handle sizes
        if (isset($data['has_sizes'])) {
            $hasSizes = $data['has_sizes'] === '1' || $data['has_sizes'] === 1 || $data['has_sizes'] === true;
            $updates[] = "has_sizes = ?";
            $params[] = $hasSizes ? 1 : 0;
            
            if ($hasSizes && isset($data['sizes'])) {
                // Sizes is already JSON string from mobile app
                $sizes = is_string($data['sizes']) ? $data['sizes'] : json_encode($data['sizes']);
                $updates[] = "sizes = ?";
                $params[] = $sizes;
                
                // Calculate total stock from sizes
                $sizesArray = json_decode($sizes, true);
                if (is_array($sizesArray)) {
                    $stockQuantity = array_sum($sizesArray);
                    $updates[] = "stock_quantity = ?";
                    $params[] = $stockQuantity;
                }
            } else {
                // Clear sizes if has_sizes is false
                $updates[] = "sizes = NULL";
                $updates[] = "size_chart_image = NULL";
            }
        }
        
        // Handle size chart image
        if (isset($data['size_chart_image'])) {
            $updates[] = "size_chart_image = ?";
            $params[] = $data['size_chart_image'];
        }
        
        // Handle stock quantity (only if sizes not enabled)
        if (isset($data['stock_quantity']) && (!isset($data['has_sizes']) || !$data['has_sizes'])) {
            $updates[] = "stock_quantity = ?";
            $params[] = $data['stock_quantity'];
        }
        
        if (isset($data['is_active'])) {
            $updates[] = "is_active = ?";
            $params[] = $data['is_active'] ? 1 : 0;
        }
        
        if (empty($updates)) {
            sendJson([
                'success' => false,
                'message' => 'No fields to update'
            ], 422);
        }
        
        $updates[] = "updated_at = NOW()";
        $params[] = $productId;
        
        $sql = "UPDATE products SET " . implode(', ', $updates) . " WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        
        // Get the updated product data
        $stmt = $pdo->prepare("SELECT * FROM products WHERE id = ?");
        $stmt->execute([$productId]);
        $product = $stmt->fetch();
        
        // Parse sizes if present
        $productSizes = null;
        if (!empty($product['sizes'])) {
            $productSizes = json_decode($product['sizes'], true);
        }
        
        sendJson([
            'success' => true,
            'message' => 'Product updated successfully',
            'data' => [
                'id' => (int)$product['id'],
                'store_id' => (int)$product['store_id'],
                'product_id' => $product['product_id'],
                'name' => $product['name'],
                'price' => $product['price'],
                'description' => $product['description'],
                'image' => $product['image'],
                'images' => $product['images'],
                'stock_quantity' => (int)$product['stock_quantity'],
                'has_sizes' => (bool)$product['has_sizes'],
                'sizes' => $productSizes,
                'size_chart_image' => $product['size_chart_image'],
                'is_active' => (int)$product['is_active'],
                'click_count' => (int)$product['click_count'],
                'created_at' => $product['created_at'],
                'updated_at' => $product['updated_at']
            ]
        ]);
        
    } catch (PDOException $e) {
        logError('Error updating product', ['product_id' => $productId, 'error' => $e->getMessage()]);
        sendJson([
            'success' => false,
            'message' => 'Unable to update product. Please try again.',
            'error_code' => 'DATABASE_ERROR'
        ], 500);
    }
}

// ============================================
// DELETE PRODUCT (Soft Delete)
// ============================================
if ((preg_match('#^/api/v1/products/(\d+)$#', $uri, $matches) || preg_match('#^/api/v1/seller/products/(\d+)$#', $uri, $matches)) && $method === 'DELETE') {
    $productId = $matches[1];
    
    try {
        // Check if product exists
        $stmt = $pdo->prepare("SELECT id FROM products WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$productId]);
        if (!$stmt->fetch()) {
            sendJson([
                'success' => false,
                'message' => 'Product not found',
                'error_code' => 'PRODUCT_NOT_FOUND'
            ], 404);
        }
        
        // Soft delete
        $stmt = $pdo->prepare("UPDATE products SET deleted_at = NOW() WHERE id = ?");
        $stmt->execute([$productId]);
        
        sendJson([
            'success' => true,
            'message' => 'Product deleted successfully'
        ]);
        
    } catch (PDOException $e) {
        logError('Error deleting product', ['product_id' => $productId, 'error' => $e->getMessage()]);
        sendJson([
            'success' => false,
            'message' => 'Unable to delete product. Please try again.',
            'error_code' => 'DATABASE_ERROR'
        ], 500);
    }
}

// ============================================
// 404 - NOT FOUND
// ============================================
sendJson([
    'success' => false,
    'message' => 'Endpoint not found',
    'requested_uri' => $uri,
    'method' => $method
], 404);
