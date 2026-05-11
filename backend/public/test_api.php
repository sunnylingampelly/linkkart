<?php
$_SERVER['REQUEST_URI'] = '/api/v1/stores/30/products';
$_SERVER['REQUEST_METHOD'] = 'GET';

ob_start();
require 'api.php';
$output = ob_get_clean();

echo "OUTPUT:\n" . $output;
