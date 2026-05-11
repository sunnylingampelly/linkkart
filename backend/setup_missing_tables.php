<?php
$host = 'localhost';
$dbname = 'linkkart';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Creating missing tables...\n";

    $pdo->exec("
        CREATE TABLE IF NOT EXISTS subscriptions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            store_id INT NOT NULL,
            plan_id INT NOT NULL,
            status ENUM('trial', 'active', 'expired', 'cancelled') DEFAULT 'trial',
            trial_ends_at DATETIME NULL,
            starts_at DATETIME NULL,
            ends_at DATETIME NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX (store_id),
            INDEX (plan_id)
        ) ENGINE=InnoDB;
    ");
    echo "- Table 'subscriptions' created/verified.\n";

    $pdo->exec("
        CREATE TABLE IF NOT EXISTS payments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            subscription_id INT NOT NULL,
            amount DECIMAL(10, 2) NOT NULL,
            currency VARCHAR(10) DEFAULT 'INR',
            razorpay_order_id VARCHAR(255) NULL,
            razorpay_payment_id VARCHAR(255) NULL,
            razorpay_signature TEXT NULL,
            status ENUM('pending', 'success', 'failed') DEFAULT 'pending',
            paid_at DATETIME NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX (subscription_id),
            INDEX (razorpay_order_id)
        ) ENGINE=InnoDB;
    ");
    echo "- Table 'payments' created/verified.\n";

    // Also check if stores table has subscription_id column
    $stmt = $pdo->query("SHOW COLUMNS FROM stores LIKE 'subscription_id'");
    if (!$stmt->fetch()) {
        $pdo->exec("ALTER TABLE stores ADD COLUMN subscription_id INT NULL AFTER owner_id");
        echo "- Column 'subscription_id' added to 'stores' table.\n";
    }

    // Ensure plans table has content if empty
    $stmt = $pdo->query("SELECT COUNT(*) FROM plans");
    if ($stmt->fetchColumn() == 0) {
        $pdo->exec("
            INSERT INTO plans (name, price, product_limit, order_limit, features, is_active, sort_order) VALUES
            ('Free', 0, 5, 10, '[\"5 Products\", \"WhatsApp Ordering\", \"Basic Analytics\"]', 1, 1),
            ('Starter', 299, 50, 100, '[\"50 Products\", \"WhatsApp Ordering\", \"Custom Store Link\", \"Email Support\"]', 1, 2),
            ('Business', 999, 500, 1000, '[\"Unlimited Products\", \"Priority Support\", \"Advanced Analytics\", \"Custom Domain\"]', 1, 3)
        ");
        echo "- Default plans inserted.\n";
    }

    echo "\nDatabase setup complete.\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
