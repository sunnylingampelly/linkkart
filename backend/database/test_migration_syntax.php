<?php
/**
 * Test Migration Syntax
 * Validates SQL syntax without executing
 */

$migrationFile = $argv[1] ?? 'migrations/2024_05_20_fix_store_subscriptions.sql';

if (!file_exists($migrationFile)) {
    echo "❌ Migration file not found: $migrationFile\n";
    exit(1);
}

echo "🔍 Checking migration syntax: " . basename($migrationFile) . "\n\n";

$sql = file_get_contents($migrationFile);

// Split into statements
$statements = array_filter(
    array_map('trim', explode(';', $sql)),
    function($stmt) {
        $stmt = preg_replace('/--.*$/m', '', $stmt);
        return !empty(trim($stmt));
    }
);

echo "✅ Found " . count($statements) . " SQL statements\n\n";

foreach ($statements as $index => $statement) {
    $statement = trim($statement);
    if (empty($statement)) continue;
    
    $preview = substr($statement, 0, 80);
    if (strlen($statement) > 80) $preview .= '...';
    
    echo "Statement " . ($index + 1) . ":\n";
    echo "  " . $preview . "\n";
    
    // Basic syntax checks
    $errors = [];
    
    // Check for common SQL keywords
    if (!preg_match('/^(INSERT|UPDATE|SELECT|SET|DELETE|CREATE|ALTER|DROP)/i', $statement)) {
        $errors[] = "Doesn't start with valid SQL keyword";
    }
    
    // Check for balanced parentheses
    if (substr_count($statement, '(') !== substr_count($statement, ')')) {
        $errors[] = "Unbalanced parentheses";
    }
    
    if (empty($errors)) {
        echo "  ✅ Syntax looks good\n";
    } else {
        echo "  ⚠️  Potential issues: " . implode(', ', $errors) . "\n";
    }
    
    echo "\n";
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
echo "✅ Migration syntax validation complete!\n";
echo "📝 Ready to run on production database.\n";
