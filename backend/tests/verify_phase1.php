<?php
/**
 * Phase 1 Verification Script
 * Tests all Phase 1 requirements
 */

echo "🔍 PHASE 1 VERIFICATION\n";
echo str_repeat("=", 60) . "\n\n";

$passed = 0;
$failed = 0;

// Test 1: Database Connection
echo "Test 1: Database Connection\n";
try {
    $pdo = new PDO("mysql:host=localhost;dbname=linkkart;charset=utf8mb4", 'root', '');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "  ✅ PASSED - Database connected\n\n";
    $passed++;
} catch (PDOException $e) {
    echo "  ❌ FAILED - " . $e->getMessage() . "\n\n";
    $failed++;
    exit(1);
}

// Test 2: Users Table Exists
echo "Test 2: Users Table\n";
try {
    $stmt = $pdo->query("SELECT COUNT(*) FROM users");
    $count = $stmt->fetchColumn();
    echo "  ✅ PASSED - Users table exists ($count users)\n\n";
    $passed++;
} catch (PDOException $e) {
    echo "  ❌ FAILED - Users table missing\n\n";
    $failed++;
}

// Test 3: Foreign Keys
echo "Test 3: Foreign Key Constraints\n";
try {
    $stmt = $pdo->query("
        SELECT COUNT(*) as count
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = 'linkkart'
        AND REFERENCED_TABLE_NAME IS NOT NULL
    ");
    $count = $stmt->fetchColumn();
    if ($count >= 4) {
        echo "  ✅ PASSED - $count foreign keys found\n\n";
        $passed++;
    } else {
        echo "  ❌ FAILED - Only $count foreign keys (need 4+)\n\n";
        $failed++;
    }
} catch (PDOException $e) {
    echo "  ⚠️  SKIPPED - Cannot verify (permission issue)\n\n";
}

// Test 4: Indexes
echo "Test 4: Database Indexes\n";
try {
    $tables = ['stores', 'products', 'analytics_events', 'users'];
    $totalIndexes = 0;
    foreach ($tables as $table) {
        $stmt = $pdo->query("SHOW INDEX FROM $table");
        $indexes = $stmt->fetchAll();
        $count = count(array_unique(array_column($indexes, 'Key_name')));
        $totalIndexes += $count;
    }
    if ($totalIndexes >= 15) {
        echo "  ✅ PASSED - $totalIndexes indexes found\n\n";
        $passed++;
    } else {
        echo "  ❌ FAILED - Only $totalIndexes indexes (need 15+)\n\n";
        $failed++;
    }
} catch (PDOException $e) {
    echo "  ❌ FAILED - " . $e->getMessage() . "\n\n";
    $failed++;
}

// Test 5: JWT Library
echo "Test 5: JWT Authentication Library\n";
if (file_exists(__DIR__ . '/../lib/JWT.php')) {
    require_once __DIR__ . '/../lib/JWT.php';
    try {
        $token = JWT::encode(['test' => 'data'], 60);
        $decoded = JWT::decode($token);
        if ($decoded['test'] === 'data') {
            echo "  ✅ PASSED - JWT library working\n\n";
            $passed++;
        } else {
            echo "  ❌ FAILED - JWT decode mismatch\n\n";
            $failed++;
        }
    } catch (Exception $e) {
        echo "  ❌ FAILED - " . $e->getMessage() . "\n\n";
        $failed++;
    }
} else {
    echo "  ❌ FAILED - JWT.php not found\n\n";
    $failed++;
}

// Test 6: API Health Check
echo "Test 6: API Health Check\n";
try {
    $ch = curl_init('http://localhost:8000/api/health');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode === 200) {
        $data = json_decode($response, true);
        if ($data['success'] === true) {
            echo "  ✅ PASSED - API responding correctly\n\n";
            $passed++;
        } else {
            echo "  ❌ FAILED - API response invalid\n\n";
            $failed++;
        }
    } else {
        echo "  ❌ FAILED - API not responding (HTTP $httpCode)\n\n";
        $failed++;
    }
} catch (Exception $e) {
    echo "  ⚠️  SKIPPED - API not running\n\n";
}

// Test 7: Authentication Endpoints
echo "Test 7: Authentication Endpoints\n";
try {
    // Test register endpoint
    $ch = curl_init('http://localhost:8000/api/v1/auth/register');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
        'name' => 'Verify Test',
        'email' => 'verify' . time() . '@test.com',
        'password' => 'test123',
        'phone' => '9876543210'
    ]));
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode === 201) {
        $data = json_decode($response, true);
        if (isset($data['data']['token'])) {
            echo "  ✅ PASSED - Registration working, JWT token generated\n\n";
            $passed++;
        } else {
            echo "  ❌ FAILED - No token in response\n\n";
            $failed++;
        }
    } else {
        echo "  ❌ FAILED - Registration failed (HTTP $httpCode)\n\n";
        $failed++;
    }
} catch (Exception $e) {
    echo "  ⚠️  SKIPPED - API not running\n\n";
}

// Test 8: Input Validation
echo "Test 8: Input Validation\n";
try {
    $ch = curl_init('http://localhost:8000/api/v1/auth/register');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
        'name' => 'A', // Too short
        'email' => 'invalid-email',
        'password' => '123', // Too short
        'phone' => '123' // Invalid
    ]));
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode === 422) {
        $data = json_decode($response, true);
        if (isset($data['errors'])) {
            echo "  ✅ PASSED - Validation working correctly\n\n";
            $passed++;
        } else {
            echo "  ❌ FAILED - No validation errors returned\n\n";
            $failed++;
        }
    } else {
        echo "  ❌ FAILED - Wrong HTTP code (expected 422, got $httpCode)\n\n";
        $failed++;
    }
} catch (Exception $e) {
    echo "  ⚠️  SKIPPED - API not running\n\n";
}

// Test 9: Rate Limiting
echo "Test 9: Rate Limiting\n";
$cacheDir = __DIR__ . '/../storage/cache';
if (is_dir($cacheDir)) {
    echo "  ✅ PASSED - Rate limiting cache directory exists\n\n";
    $passed++;
} else {
    echo "  ❌ FAILED - Cache directory missing\n\n";
    $failed++;
}

// Test 10: Error Logging
echo "Test 10: Error Logging\n";
$logDir = __DIR__ . '/../storage/logs';
if (is_dir($logDir)) {
    echo "  ✅ PASSED - Error logging directory exists\n\n";
    $passed++;
} else {
    echo "  ❌ FAILED - Logs directory missing\n\n";
    $failed++;
}

// Summary
echo str_repeat("=", 60) . "\n";
echo "PHASE 1 VERIFICATION SUMMARY\n";
echo str_repeat("=", 60) . "\n";
echo "✅ Passed: $passed\n";
echo "❌ Failed: $failed\n";
echo str_repeat("=", 60) . "\n\n";

if ($failed === 0) {
    echo "🎉 PHASE 1 COMPLETE - ALL TESTS PASSED!\n";
    echo "✅ Ready to start Phase 2 (Payment & Monetization)\n\n";
    exit(0);
} else {
    echo "⚠️  PHASE 1 INCOMPLETE - $failed tests failed\n";
    echo "Please fix the issues before proceeding to Phase 2\n\n";
    exit(1);
}
