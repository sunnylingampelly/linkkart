@echo off
echo ========================================
echo Building LinkKart APK with Fixed Network Configuration
echo ========================================
echo.
echo Configuration:
echo - Backend IP: 192.168.1.25:8000
echo - API Base: /api/v1
echo - Endpoints: /stores, /products, /analytics
echo.
echo ========================================
echo.

cd mobile-app

echo Cleaning previous build...
call flutter clean

echo.
echo Getting dependencies...
call flutter pub get

echo.
echo Building APK (this may take 5-10 minutes)...
call flutter build apk --release

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo APK Location: mobile-app\build\app\outputs\flutter-apk\app-release.apk
echo.
echo Next Steps:
echo 1. Transfer the APK to your phone
echo 2. Install the APK
echo 3. Make sure backend is running: php -S 192.168.1.25:8000 -t backend/public
echo 4. Test store creation in the app
echo.
pause
