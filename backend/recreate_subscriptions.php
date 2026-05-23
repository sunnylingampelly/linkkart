<?php
$pdo = new PDO('mysql:host=127.0.0.1;dbname=linkkart', 'root', '');
$pdo->exec("SET FOREIGN_KEY_CHECKS = 0");
$pdo->exec("DROP TABLE IF EXISTS invoices");
$pdo->exec("DROP TABLE IF EXISTS payments");
$pdo->exec("DROP TABLE IF EXISTS subscriptions");
$pdo->exec("DROP TABLE IF EXISTS plans");
$pdo->exec("SET FOREIGN_KEY_CHECKS = 1");

$sql = "
CREATE TABLE plans (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    billing_cycle ENUM('monthly', 'yearly') DEFAULT 'monthly',
    product_limit INT NOT NULL,
    order_limit INT NOT NULL,
    features JSON,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE subscriptions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    store_id BIGINT UNSIGNED NOT NULL,
    plan_id BIGINT UNSIGNED NOT NULL,
    status ENUM('trial', 'active', 'cancelled', 'expired', 'past_due') DEFAULT 'trial',
    trial_ends_at DATETIME NULL,
    starts_at DATETIME NOT NULL,
    ends_at DATETIME NOT NULL,
    cancelled_at DATETIME NULL,
    auto_renew BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES plans(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE stores ADD COLUMN IF NOT EXISTS subscription_id BIGINT UNSIGNED NULL AFTER slug;
ALTER TABLE stores ADD CONSTRAINT fk_stores_subscription FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;

INSERT INTO plans (name, slug, price, billing_cycle, product_limit, order_limit, features, sort_order) VALUES
('Free', 'free', 0.00, 'monthly', 5, 50, '[\"5 products maximum\", \"50 orders per month\", \"WhatsApp integration\", \"Basic store page\", \"LinkKart branding\"]', 1),
('Starter', 'starter', 299.00, 'monthly', 50, 999999, '[\"50 products\", \"Unlimited orders\", \"Remove LinkKart branding\", \"Custom store link\", \"Email support\"]', 2),
('Business', 'business', 599.00, 'monthly', 999999, 999999, '[\"Unlimited products\", \"Unlimited orders\", \"Priority email support\", \"Store analytics (views, clicks)\", \"Export data to Excel\"]', 3);
";

$statements = array_filter(array_map('trim', explode(';', $sql)));
foreach ($statements as $statement) {
    if (empty($statement)) continue;
    try {
        $pdo->exec($statement);
        echo "Executed statement successfully\n";
    } catch (PDOException $e) {
        echo "Error: " . $e->getMessage() . "\n";
    }
}
