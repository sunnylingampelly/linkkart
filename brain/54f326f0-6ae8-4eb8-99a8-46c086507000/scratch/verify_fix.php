<?php
$storeId = 1;
$url = "http://192.168.1.25:8000/api/v1/seller/stores/$storeId/update";

$data = [
    'description' => 'This is a test description for Tara Fashions.',
    '_method' => 'POST' // The script handles POST for updates
];

$options = [
    'http' => [
        'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
        'method'  => 'POST',
        'content' => http_build_query($data),
        'ignore_errors' => true
    ]
];

$context  = stream_context_create($options);
$result = file_get_contents($url, false, $context);

echo "Response code: " . $http_response_header[0] . "\n";
echo "Response: " . $result . "\n";

// Also verify in DB
$host = 'localhost';
$dbname = 'linkkart';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $stmt = $pdo->prepare("SELECT description FROM stores WHERE id = ?");
    $stmt->execute([$storeId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "DB Description: " . $row['description'] . "\n";
} catch (PDOException $e) {
    echo "DB Error: " . $e->getMessage() . "\n";
}
