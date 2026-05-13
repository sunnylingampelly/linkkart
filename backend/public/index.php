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

// Debug endpoint
if ($uri === '/api/debug') {
    sendJson([
        'success' => true,
        'uri' => $uri,
        'method' => $method,
        'request_uri' => $_SERVER['REQUEST_URI']
    ]);
}

// Get products by store ID
if (preg_match('#^/api/v1/seller/stores/(\d+)/products$#', $uri, $matches) && $method === 'GET') {
    $storeId = $matches[1];
    
    try {
        $stmt = $pdo->prepare("
            SELECT 
                id, store_id, name, price, description, image, 
                stock_quantity, is_active, click_count, created_at, updated_at,
                CONCAT('₹', FORMAT(price, 2)) as formatted_price
            FROM products 
            WHERE store_id = ? AND deleted_at IS NULL
            ORDER BY created_at DESC
        ");
        $stmt->execute([$storeId]);
        $products = $stmt->fetchAll();
        
        sendJson([
            'success' => true,
            'data' => $products
        ]);
        
    } catch (PDOException $e) {
        sendJson([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ], 500);
    }
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
            $store['store_url'] = 'http://localhost:3001/store/' . $store['slug'];
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

// Get store statistics (MUST come before generic store by slug endpoint)
if (preg_match('#^/api/v1/stores/(\d+)/statistics$#', $uri, $matches) && $method === 'GET') {
    $storeId = $matches[1];
    
    try {
        // Check if store exists
        $stmt = $pdo->prepare("SELECT id, name FROM stores WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$storeId]);
        $store = $stmt->fetch();
        
        if (!$store) {
            sendJson(['success' => false, 'message' => 'Store not found', 'store_id' => $storeId], 404);
        }
        
        // Get statistics
        $stats = [];
        
        // Total revenue (from orders table if exists, otherwise 0)
        $stmt = $pdo->prepare("
            SELECT COALESCE(SUM(total_price), 0) as total_revenue
            FROM orders 
            WHERE store_id = ? AND status != 'cancelled'
        ");
        $stmt->execute([$storeId]);
        $result = $stmt->fetch();
        $stats['total_revenue'] = (float)$result['total_revenue'];
        
        // Total orders
        $stmt = $pdo->prepare("SELECT COUNT(*) as total_orders FROM orders WHERE store_id = ?");
        $stmt->execute([$storeId]);
        $result = $stmt->fetch();
        $stats['total_orders'] = (int)$result['total_orders'];
        
        // Pending orders
        $stmt = $pdo->prepare("SELECT COUNT(*) as pending_orders FROM orders WHERE store_id = ? AND status = 'pending'");
        $stmt->execute([$storeId]);
        $result = $stmt->fetch();
        $stats['pending_orders'] = (int)$result['pending_orders'];
        
        // Total products
        $stmt = $pdo->prepare("
            SELECT COUNT(*) as total_products 
            FROM products 
            WHERE store_id = ? AND deleted_at IS NULL
        ");
        $stmt->execute([$storeId]);
        $result = $stmt->fetch();
        $stats['total_products'] = (int)$result['total_products'];
        
        // Total clicks (sum of all product clicks)
        $stmt = $pdo->prepare("
            SELECT COALESCE(SUM(click_count), 0) as total_clicks 
            FROM products 
            WHERE store_id = ? AND deleted_at IS NULL
        ");
        $stmt->execute([$storeId]);
        $result = $stmt->fetch();
        $stats['total_clicks'] = (int)$result['total_clicks'];
        
        // Total views
        $stmt = $pdo->prepare("SELECT view_count FROM stores WHERE id = ?");
        $stmt->execute([$storeId]);
        $result = $stmt->fetch();
        $stats['total_views'] = (int)($result['view_count'] ?? 0);
        
        // Revenue growth (mock data for now)
        $stats['revenue_growth'] = 12.5;
        
        sendJson([
            'success' => true,
            'data' => $stats
        ]);
        
    } catch (PDOException $e) {
        sendJson([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ], 500);
    }
}

// Get store products (MUST come before generic store by slug endpoint)
if (preg_match('#^/api/v1/stores/(\d+)/products$#', $uri, $matches) && $method === 'GET') {
    $storeId = $matches[1];
    
    try {
        $stmt = $pdo->prepare("
            SELECT 
                id, store_id, name, price, description, image, 
                stock_quantity, is_active, click_count, created_at, updated_at,
                CONCAT('₹', FORMAT(price, 2)) as formatted_price
            FROM products 
            WHERE store_id = ? AND deleted_at IS NULL
            ORDER BY created_at DESC
        ");
        $stmt->execute([$storeId]);
        $products = $stmt->fetchAll();
        
        // Convert numeric fields to proper types
        foreach ($products as &$product) {
            $product['id'] = (int)$product['id'];
            $product['store_id'] = (int)$product['store_id'];
            $product['price'] = (float)$product['price'];
            $product['stock_quantity'] = (int)$product['stock_quantity'];
            $product['is_active'] = (int)$product['is_active'];
            $product['click_count'] = (int)$product['click_count'];
        }
        
        sendJson([
            'success' => true,
            'data' => $products
        ]);
        
    } catch (PDOException $e) {
        sendJson([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ], 500);
    }
}

// Get store orders (MUST come before generic store by slug endpoint)
if (preg_match('#^/api/v1/stores/(\d+)/orders$#', $uri, $matches) && $method === 'GET') {
    $storeId = $matches[1];
    
    try {
        // Check if store exists
        $stmt = $pdo->prepare("SELECT id FROM stores WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$storeId]);
        if (!$stmt->fetch()) {
            sendJson(['success' => false, 'message' => 'Store not found'], 404);
        }
        
        // Get orders with customer and product details
        try {
            $stmt = $pdo->prepare("
                SELECT 
                    o.*,
                    COALESCE(c.name, CONCAT('Customer ', o.customer_id)) as customer_name,
                    COALESCE(c.phone, '') as customer_phone,
                    '' as customer_address,
                    p.name as product_name,
                    p.image as product_image,
                    CONCAT('₹', FORMAT(o.total_price, 2)) as formatted_amount
                FROM orders o
                LEFT JOIN customers c ON o.customer_id = c.id
                LEFT JOIN products p ON o.product_id = p.id
                WHERE o.store_id = ?
                ORDER BY o.created_at DESC
                LIMIT 100
            ");
            $stmt->execute([$storeId]);
            $orders = $stmt->fetchAll();
            
            // Convert numeric fields to proper types
            foreach ($orders as &$order) {
                $order['id'] = (int)$order['id'];
                $order['store_id'] = (int)$order['store_id'];
                $order['customer_id'] = (int)$order['customer_id'];
                $order['product_id'] = (int)$order['product_id'];
                $order['quantity'] = (int)$order['quantity'];
                $order['total_price'] = (float)$order['total_price'];
            }
        } catch (PDOException $e) {
            // Orders table might not exist yet
            $orders = [];
        }
        
        sendJson([
            'success' => true,
            'data' => $orders
        ]);
        
    } catch (PDOException $e) {
        sendJson([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ], 500);
    }
}

// Get store customers (MUST come before generic store by slug endpoint)
if (preg_match('#^/api/v1/stores/(\d+)/customers$#', $uri, $matches) && $method === 'GET') {
    $storeId = $matches[1];
    
    try {
        // Check if store exists
        $stmt = $pdo->prepare("SELECT id FROM stores WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$storeId]);
        if (!$stmt->fetch()) {
            sendJson(['success' => false, 'message' => 'Store not found'], 404);
        }
        
        // Get customers (return empty array if table doesn't exist)
        try {
            $stmt = $pdo->prepare("
                SELECT 
                    o.customer_id,
                    COALESCE(c.name, CONCAT('Customer ', o.customer_id)) as customer_name,
                    COALESCE(c.phone, '') as customer_phone,
                    COALESCE(c.email, '') as customer_email,
                    COUNT(*) as order_count,
                    SUM(o.total_price) as total_spent,
                    MAX(o.created_at) as last_order_date
                FROM orders o
                LEFT JOIN customers c ON o.customer_id = c.id
                WHERE o.store_id = ?
                GROUP BY o.customer_id
                ORDER BY total_spent DESC
                LIMIT 100
            ");
            $stmt->execute([$storeId]);
            $customers = $stmt->fetchAll();
            
            // Convert numeric fields to proper types
            foreach ($customers as &$customer) {
                $customer['customer_id'] = (int)$customer['customer_id'];
                $customer['order_count'] = (int)$customer['order_count'];
                $customer['total_spent'] = (float)$customer['total_spent'];
            }
        } catch (PDOException $e) {
            // Orders table might not exist yet
            $customers = [];
        }
        
        sendJson([
            'success' => true,
            'data' => $customers
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
        $store['store_url'] = 'http://localhost:3001/store/' . $store['slug'];
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
        
        $store['store_url'] = 'http://localhost:3001/store/' . $store['slug'];
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
    $stockQuantity = $_POST['stock_quantity'] ?? 0;
    
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
        
        // Insert product
        $stmt = $pdo->prepare("
            INSERT INTO products (store_id, name, price, description, image, stock_quantity, is_active, click_count, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, 1, 0, NOW(), NOW())
        ");
        
        $stmt->execute([$storeId, $name, $price, $description, $image, $stockQuantity]);
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

// Create order (from storefront)
if ($uri === '/api/v1/orders' && $method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $storeId = $data['store_id'] ?? null;
    $productId = $data['product_id'] ?? null;
    $customerName = $data['name'] ?? '';
    $customerPhone = $data['phone'] ?? '';
    $quantity = $data['quantity'] ?? 1;
    $totalPrice = $data['total_price'] ?? 0;
    
    if (empty($storeId) || empty($productId) || empty($customerName) || empty($customerPhone)) {
        sendJson([
            'success' => false,
            'message' => 'Store ID, Product ID, Name, and Phone are required'
        ], 422);
    }
    
    try {
        // Check if customer exists in customers table, if not create one
        $stmt = $pdo->prepare("SELECT id FROM customers WHERE phone = ?");
        $stmt->execute([$customerPhone]);
        $customer = $stmt->fetch();
        
        if (!$customer) {
            // Create new customer
            $stmt = $pdo->prepare("
                INSERT INTO customers (name, phone, email, created_at, updated_at)
                VALUES (?, ?, '', NOW(), NOW())
            ");
            $stmt->execute([$customerName, $customerPhone]);
            $customerId = $pdo->lastInsertId();
        } else {
            $customerId = $customer['id'];
        }
        
        // Create order
        $stmt = $pdo->prepare("
            INSERT INTO orders (store_id, customer_id, product_id, quantity, total_price, status, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, 'pending', NOW(), NOW())
        ");
        
        $stmt->execute([$storeId, $customerId, $productId, $quantity, $totalPrice]);
        $orderId = $pdo->lastInsertId();
        
        sendJson([
            'success' => true,
            'message' => 'Order created successfully',
            'data' => [
                'order_id' => $orderId,
                'customer_id' => $customerId,
                'status' => 'pending'
            ]
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
