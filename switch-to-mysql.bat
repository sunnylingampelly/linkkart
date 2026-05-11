@echo off
echo ========================================
echo LinkKart - Switch to MySQL Backend
echo ========================================
echo.

cd backend\public

echo Backing up demo version...
if exist index.php (
    copy /Y index.php index-demo.php
    echo Demo version backed up to index-demo.php
)

echo.
echo Activating MySQL version...
if exist index-mysql.php (
    copy /Y index-mysql.php index.php
    echo MySQL version activated!
) else (
    echo ERROR: index-mysql.php not found!
    pause
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS! MySQL backend is now active
echo ========================================
echo.
echo Next steps:
echo 1. Make sure XAMPP MySQL is running
echo 2. Create database 'linkkart' in phpMyAdmin
echo 3. Import database_setup.sql
echo 4. Restart PHP server: php -S localhost:8000 -t public
echo.
pause
