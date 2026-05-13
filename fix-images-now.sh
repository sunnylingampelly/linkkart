#!/bin/bash

echo "========================================"
echo "  LinkKart Image Fix Script"
echo "========================================"
echo ""

echo "Step 1: Creating storage symlink..."
cd backend/public
rm -f storage
ln -s ../storage/app/public storage
echo "✅ Symlink created!"
echo ""

echo "Step 2: Setting permissions..."
cd ..
chmod -R 775 storage
chmod -R 775 public/storage
echo "✅ Permissions set!"
echo ""

echo "Step 3: Verifying image files..."
ls -la storage/app/public/products/
echo ""

echo "Step 4: Starting backend server..."
cd public
echo ""
echo "⚠️  IMPORTANT: Keep this terminal open!"
echo ""
echo "Backend running at: http://192.168.1.22:8000"
echo "Test image: http://192.168.1.22:8000/storage/products/69f8cb223f45d.jpg"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

php -S 192.168.1.22:8000 api.php
