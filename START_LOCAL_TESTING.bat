@echo off
echo ========================================
echo   LINKKART LOCAL TESTING
echo ========================================
echo.

echo Step 1: Checking database...
php check_current_stores.php
echo.

echo Step 2: Starting Backend API on http://localhost:8000
echo.
start "LinkKart Backend API" cmd /k "cd /d %~dp0backend\public && php -S localhost:8000"
timeout /t 3 /nobreak >nul

echo Step 3: Starting Storefront on http://localhost:3000
echo.
start "LinkKart Storefront" cmd /k "cd /d %~dp0storefront && npm start"
timeout /t 3 /nobreak >nul

echo.
echo ========================================
echo   ALL SERVICES STARTING...
echo ========================================
echo.
echo Backend API:  http://localhost:8000
echo Storefront:   http://localhost:3000
echo.
echo Press any key to open browser...
pause >nul

start http://localhost:3000

echo.
echo ========================================
echo   TESTING IN PROGRESS
echo ========================================
echo.
echo Check the browser for:
echo  - Homepage loads
echo  - Store images display
echo  - No console errors
echo.
echo Press any key to exit...
pause >nul
