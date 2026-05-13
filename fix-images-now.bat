@echo off
echo ========================================
echo   LinkKart Image Fix Script
echo ========================================
echo.

echo Step 1: Creating storage symlink...
cd backend\public
if exist storage rmdir storage
mklink /D storage ..\storage\app\public
echo ✅ Symlink created!
echo.

echo Step 2: Verifying image files...
cd ..\storage\app\public\products
dir /b
echo.

echo Step 3: Testing backend...
cd ..\..\..\..\public
echo Starting backend server...
echo.
echo ⚠️  IMPORTANT: Keep this window open!
echo.
echo Backend running at: http://192.168.1.22:8000
echo Test image: http://192.168.1.22:8000/storage/products/69f8cb223f45d.jpg
echo.
echo Press Ctrl+C to stop the server
echo.

php -S 192.168.1.22:8000 api.php
