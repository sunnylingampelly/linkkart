@echo off
echo ========================================
echo   LinkKart Backend Server
echo ========================================
echo.
echo Starting backend on http://localhost:8000
echo Press Ctrl+C to stop
echo.

cd backend\public
php -S 0.0.0.0:8000 index.php
