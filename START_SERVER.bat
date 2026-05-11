@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   LinkKart Backend Server Starter
echo ========================================
echo.

:: Check if PHP is installed
php -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] PHP is not installed or not in PATH.
    echo Please install PHP to run the backend.
    pause
    exit /b 1
)

:: Find current local IP
for /f "tokens=4 delims= " %%i in ('route print ^| findstr 0.0.0.0 ^| findstr 192.168') do set LOCAL_IP=%%i

if "%LOCAL_IP%"=="" (
    for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr IPv4') do (
        set val=%%a
        set LOCAL_IP=!val:~1!
        goto :found_ip
    )
)

:found_ip
:: Remove leading space if any
set LOCAL_IP=%LOCAL_IP: =%

echo [SUCCESS] Your machine IP is: %LOCAL_IP%
echo [INFO] Backend will be available at: http://%LOCAL_IP%:8000
echo.
echo [CHECK] Testing if port 8000 is free...
netstat -ano | findstr :8000 >nul
if %errorlevel% equ 0 (
    echo [WARNING] Port 8000 is already in use. 
    echo Please close any other running servers.
) else (
    echo [OK] Port 8000 is free.
)
echo.
echo [IMPORTANT] FIREWALL SETUP:
echo If your phone cannot connect, run this command in ADMINISTRATOR CMD:
echo netsh advfirewall firewall add rule name="LinkKart" dir=in action=allow protocol=TCP localport=8000
echo.
echo [IMPORTANT] Same WiFi: Ensure your phone is on the SAME WiFi network.
echo.
echo ========================================
echo Starting PHP Server...
echo ========================================
echo.

:: Open browser to verify server is running
start http://127.0.0.1:8000/api/health

:: Run PHP server with explicit document root
php -S 0.0.0.0:8000 -t backend/public backend/public/api.php

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Server failed to start!
    echo Possible causes:
    echo 1. Port 8000 is occupied by another app.
    echo 2. You don't have permission to bind to 0.0.0.0.
    echo.
    echo Trying alternative port 8080...
    start http://127.0.0.1:8080/api/health
    php -S 0.0.0.0:8080 -t backend/public backend/public/api.php
)

pause
