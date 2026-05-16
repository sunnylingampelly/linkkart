@echo off
echo ========================================
echo   Build LinkKart Production APK
echo ========================================
echo.
echo Your Production URLs:
echo   API:        https://api.linkkart.shop
echo   Storefront: https://linkkart.shop
echo   Admin:      https://admin.linkkart.shop
echo.
echo ========================================
echo.

cd mobile-app

echo Step 1/3: Cleaning previous build...
call flutter clean
echo.

echo Step 2/3: Getting dependencies...
call flutter pub get
echo.

echo Step 3/3: Building debug APK...
call flutter build apk --debug
echo.

echo ========================================
echo   Build Complete!
echo ========================================
echo.
echo APK Location:
echo   build\app\outputs\flutter-apk\app-debug.apk
echo.
echo Next Steps:
echo   1. Copy APK to your phone
echo   2. Install and test
echo   3. If working, build release: flutter build apk --release
echo.
echo ========================================

pause
