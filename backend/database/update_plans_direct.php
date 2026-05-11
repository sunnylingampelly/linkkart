<?php
$pdo = new PDO("mysql:host=localhost;dbname=linkkart;charset=utf8mb4", 'root', '');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Updating plans...\n";

// Delete existing plans
$pdo->exec("DELETE FROM plans");
echo "✓ Deleted old plans\n";

// Insert new simple plans
$pdo->exec("
INSERT INTO plans (name, slug, price, billing_cycle, product_limit, order_limit, features, sort_order) VALUES
('Free', 'free', 0.00, 'monthly', 5, 50, 
 '[\"5 products maximum\", \"50 orders per month\", \"WhatsApp integration\", \"Basic store page\", \"LinkKart branding\"]', 1),

('Starter', 'starter', 299.00, 'monthly', 50, 999999, 
 '[\"50 products\", \"Unlimited orders\", \"Remove LinkKart branding\", \"Custom store link\", \"Email support\"]', 2),

('Business', 'business', 599.00, 'monthly', 999999, 999999, 
 '[\"Unlimited products\", \"Unlimited orders\", \"Priority email support\", \"Store analytics (views, clicks)\", \"Export data to Excel\"]', 3)
");

echo "✓ Inserted new plans\n\n";

// Show plans
$stmt = $pdo->query("SELECT * FROM plans ORDER BY sort_order");
$plans = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "Current Plans:\n";
echo str_repeat("=", 60) . "\n";
foreach ($plans as $plan) {
    echo "\n{$plan['name']} - ₹{$plan['price']}/month\n";
    echo "  Products: {$plan['product_limit']}\n";
    echo "  Orders: " . ($plan['order_limit'] == 999999 ? 'Unlimited' : $plan['order_limit']) . "\n";
    $features = json_decode($plan['features'], true);
    echo "  Features:\n";
    foreach ($features as $feature) {
        echo "    • $feature\n";
    }
}

echo "\n✅ Plans updated successfully!\n";
