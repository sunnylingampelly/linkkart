@echo off
echo ========================================
echo   Rebuilding LinkKart App
echo ========================================
echo.
echo Fixes applied:
echo 1. Updated Firebase dependencies (fixes OTP error)
echo 2. Fixed API URL to 192.168.1.38:8000
echo.
echo Starting rebuild...
echo.
cd mobile-app
echo [1/3] Cleaning build cache...
call flutter clean
echo.
echo [2/3] Getting dependencies...
call flutter pub get
echo.
echo [3/3] Building APK (this takes 2-3 minutes)...
call flutter build apk --debug
echo.
echo ========================================
echo   BUILD COMPLETE!
echo ========================================
echo.
echo APK Location:
echo mobile-app\build\app\outputs\flutter-apk\app-debug.apk
echo.
echo Next Steps:
echo 1. Install the new APK on your phone
echo 2. Test OTP with: Phone 8639424962, OTP 123456
echo 3. Create store and add products
echo.
echo Backend is running on: http://192.168.1.38:8000
echo.
pause
