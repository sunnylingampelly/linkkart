@echo off
echo ========================================
echo   Fixing Firebase and Rebuilding App
echo ========================================
echo.
echo This will:
echo 1. Update Firebase dependencies
echo 2. Clean build cache
echo 3. Rebuild the app
echo.
cd mobile-app
echo Step 1: Cleaning...
call flutter clean
echo.
echo Step 2: Getting updated dependencies...
call flutter pub get
echo.
echo Step 3: Building APK...
call flutter build apk --debug
echo.
echo ========================================
echo   Build Complete!
echo ========================================
echo.
echo APK location: mobile-app\build\app\outputs\flutter-apk\app-debug.apk
echo.
echo Install the new APK and test OTP!
echo Test with: Phone 8639424962, OTP 123456
echo.
pause
