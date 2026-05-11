@echo off
echo ========================================
echo   Rebuilding LinkKart App
echo ========================================
echo.
echo This will rebuild the app with new Firebase configuration
echo.
cd mobile-app
echo Step 1: Cleaning...
call flutter clean
echo.
echo Step 2: Getting dependencies...
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
echo.
pause
