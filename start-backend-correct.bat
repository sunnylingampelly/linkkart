@echo off
echo ========================================
echo Starting LinkKart Backend Server
echo ========================================
echo.
echo Configuration:
echo - IP Address: 192.168.1.25
echo - Port: 8000
echo - Router: api.php (with /api/v1 endpoints)
echo.
echo Backend will be available at:
echo http://192.168.1.25:8000
echo.
echo API Endpoints:
echo - GET  /api/v1/stores
echo - POST /api/v1/stores
echo - GET  /api/v1/stores/{id}
echo - POST /api/v1/products
echo - POST /api/v1/analytics/track
echo.
echo ========================================
echo.

cd backend/public
php -S 192.168.1.25:8000 api.php

pause
