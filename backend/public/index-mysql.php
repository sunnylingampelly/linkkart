<?php
/**
 * LinkKart Backend with MySQL Database
 * This version connects to a real MySQL database
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Database configuration
define('DB_HOST', 'localhost');
define('DB_NAME', 'linkkart');
define('DB_USER', 'root');
define('DB_PASS', ''); // Change if you have a password

// Connect to database
try {
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]
    );
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $e->getMessage()
    ]);
    exit;
}

// Helper function to send JSON response
function sendJson($data, $code = 200) {
    http_response_code($code);
    echo json_encode($data);
    exit;
}

// Get request URI and method
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

// Health check endpoint
if ($uri === '/api/health') {
    sendJson([
        'success' => true,
        'message' => 'LinkKart API is running with MySQL',
        'version' => '1.0.0',
        'database' => 'Connected',
        'timestamp' => date('c')
    ]);
}

// Get all stores (public - for homepage)
if ($uri === '/api/v1/stores' && $method === 'GET') {
    try {
        $stmt = $pdo->query("
            SELECT s.*, COUNT(p.id) as product_count
            FROM stores s
            LEFT JOIN products p ON s.id = p.store_id AND p.deleted_at IS NULL AND p.is_active = 1
            WHERE s.deleted_at IS NULL AND s.is_active = 1
            GROUP BY s.id
            ORDER BY s.created_at DESC
        ");
        
        $stores = $stmt->fetchAll();
        
        // Add store URLs
        foreach ($stores as &$store) {
            $store['store_url'] = 'https://linkkart.shop/store/' . $store['slug'];
        }
        
        sendJson([
            'success' => true,
            'data' => $stores
        ]);
        
    } catch (PDOException $e) {
        sendJson([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ], 500);
    }
}

// Get store by slug with products
if (preg_match('#^/api/v1/stores/(.+)$#', $uri, $matches)) {
    $slug = $matches[1];
    
    try {
        // Get store
        $stmt = $pdo->prepare("
            SELECT * FROM stores 
            WHERE slug = ? AND is_active = 1 AND deleted_at IS NULL
        ");
        $stmt->execute([$slug]);
        $store = $stmt->fetch();
        
        if (!$store) {
            sendJson([
                'success' => false,
                'message' => 'Store not found'
            ], 404);
        }
        
        // Get products
        $stmt = $pdo->prepare("
            SELECT 
                id, store_id, name, price, description, image, 
                is_active, click_count, created_at, updated_at,
                CONCAT('₹', FORMAT(price, 2)) as formatted_price
            FROM products 
            WHERE store_id = ? AND is_active = 1 AND deleted_at IS NULL
            ORDER BY created_at DESC
        ");
        $stmt->execute([$store['id']]);
        $products = $stmt->fetchAll();
        
        // Add WhatsApp URL to each product
        foreach ($products as &$product) {
            $message = urlencode("Hi, I want to order {$product['name']} - {$product['formatted_price']}");
            $phone = preg_replace('/[^0-9]/', '', $store['phone']);
            $product['whatsapp_url'] = "https://wa.me/{$phone}?text={$message}";
        }
        
        // Add computed fields to store
        $store['store_url'] = 'https://linkkart.shop/store/' . $store['slug'];
        $store['product_count'] = count($products);
        $store['products'] = $products;
        
        sendJson([
            'success' => true,
            'data' => $store
        ]);
        
    } catch (PDOException $e) {
        sendJson([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ], 500);
    }
}

// Track analytics
if ($uri === '/api/v1/analytics/track' && $method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
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
        
        // Update counters
        if ($data['event_type'] === 'store_view') {
            $pdo->prepare("UPDATE stores SET view_count = view_count + 1 WHERE id = ?")
                ->execute([$data['store_id']]);
        } elseif ($data['event_type'] === 'product_click' && isset($data['product_id'])) {
            $pdo->prepare("UPDATE products SET click_count = click_count + 1 WHERE id = ?")
                ->execute([$data['product_id']]);
        }
        
        sendJson([
            'success' => true,
            'message' => 'Event tracked successfully',
            'data' => [
                'id' => $pdo->lastInsertId(),
                'created_at' => date('c')
            ]
        ], 201);
        
    } catch (PDOException $e) {
        sendJson([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ], 500);
    }
}

// Create store
if ($uri === '/api/v1/seller/stores' && $method === 'POST') {
    $name = $_POST['name'] ?? '';
    $phone = $_POST['phone'] ?? '';
    
    if (empty($name) || empty($phone)) {
        sendJson([
            'success' => false,
            'message' => 'Name and phone are required'
        ], 422);
    }
    
    try {
        // Generate slug
        $slug = strtolower(preg_replace('/[^a-z0-9]+/i', '-', $name)) . '-' . substr(md5($name . time()), 0, 6);
        
        // Handle logo upload
        $logo = null;
        if (isset($_FILES['logo']) && $_FILES['logo']['error'] === UPLOAD_ERR_OK) {
            $uploadDir = __DIR__ . '/storage/logos/';
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0777, true);
            }
            
            $extension = pathinfo($_FILES['logo']['name'], PATHINFO_EXTENSION);
            $filename = uniqid() . '.' . $extension;
            $filepath = $uploadDir . $filename;
            
            if (move_uploaded_file($_FILES['logo']['tmp_name'], $filepath)) {
                $logo = '/storage/logos/' . $filename;
            }
        }
        
        // Insert store
        $stmt = $pdo->prepare("
            INSERT INTO stores (name, phone, logo, slug, is_active, view_count, created_at, updated_at)
            VALUES (?, ?, ?, ?, 1, 0, NOW(), NOW())
        ");
        
        $stmt->execute([$name, $phone, $logo, $slug]);
        $storeId = $pdo->lastInsertId();
        
        // Get created store
        $stmt = $pdo->prepare("SELECT * FROM stores WHERE id = ?");
        $stmt->execute([$storeId]);
        $store = $stmt->fetch();
        
        $store['store_url'] = 'https://linkkart.shop/store/' . $store['slug'];
        $store['product_count'] = 0;
        
        sendJson([
            'success' => true,
            'message' => 'Store created successfully',
            'data' => $store
        ], 201);
        
    } catch (PDOException $e) {
        sendJson([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ], 500);
    }
}

// Create product
if ($uri === '/api/v1/seller/products' && $method === 'POST') {
    $storeId = $_POST['store_id'] ?? '';
    $name = $_POST['name'] ?? '';
    $price = $_POST['price'] ?? '';
    $description = $_POST['description'] ?? null;
    
    if (empty($storeId) || empty($name) || empty($price)) {
        sendJson([
            'success' => false,
            'message' => 'Store ID, name, and price are required'
        ], 422);
    }
    
    try {
        // Handle image upload
        $image = null;
        if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
            $uploadDir = __DIR__ . '/storage/products/';
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0777, true);
            }
            
            $extension = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
            $filename = uniqid() . '.' . $extension;
            $filepath = $uploadDir . $filename;
            
            if (move_uploaded_file($_FILES['image']['tmp_name'], $filepath)) {
                $image = '/storage/products/' . $filename;
            }
        }
        
        // Generate a unique product_id
        $productIdStr = uniqid('prod_');
        $stockQuantity = $_POST['stock_quantity'] ?? 0;
        
        // Insert product
        $stmt = $pdo->prepare("
            INSERT INTO products (store_id, product_id, name, price, description, image, stock_quantity, is_active, click_count, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, 1, 0, NOW(), NOW())
        ");
        
        $stmt->execute([$storeId, $productIdStr, $name, $price, $description, $image, $stockQuantity]);
        $productId = $pdo->lastInsertId();
        
        // Get created product
        $stmt = $pdo->prepare("
            SELECT *, CONCAT('₹', FORMAT(price, 2)) as formatted_price 
            FROM products WHERE id = ?
        ");
        $stmt->execute([$productId]);
        $product = $stmt->fetch();
        
        sendJson([
            'success' => true,
            'message' => 'Product created successfully',
            'data' => $product
        ], 201);
        
    } catch (PDOException $e) {
        sendJson([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ], 500);
    }
}

// Get all stores (admin)
if ($uri === '/api/v1/admin/stores' && $method === 'GET') {
    try {
        $stmt = $pdo->query("
            SELECT s.*, COUNT(p.id) as product_count
            FROM stores s
            LEFT JOIN products p ON s.id = p.store_id AND p.deleted_at IS NULL
            WHERE s.deleted_at IS NULL
            GROUP BY s.id
            ORDER BY s.created_at DESC
        ");
        
        $stores = $stmt->fetchAll();
        
        sendJson([
            'success' => true,
            'data' => $stores
        ]);
        
    } catch (PDOException $e) {
        sendJson([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ], 500);
    }
}

// Default 404 response
sendJson([
    'success' => false,
    'message' => 'Endpoint not found: ' . $uri
], 404);
