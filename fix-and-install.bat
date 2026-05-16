@echo off
echo ========================================
echo   Fix and Install LinkKart App
echo ========================================
echo.
echo This will:
echo   1. Uninstall old version
echo   2. Clean build
echo   3. Rebuild APK
echo   4. Install on phone
echo.
echo Make sure:
echo   - Phone is connected via USB
echo   - USB Debugging is enabled
echo.
pause
echo.

cd mobile-app

echo Step 1: Uninstalling old version...
adb uninstall com.linkkart.app
echo.

echo Step 2: Cleaning previous build...
call flutter clean
echo.

echo Step 3: Getting dependencies...
call flutter pub get
echo.

echo Step 4: Building fresh APK...
call flutter build apk --debug
echo.

echo Step 5: Installing on phone...
adb install build\app\outputs\flutter-apk\app-debug.apk
echo.

echo ========================================
echo   Done!
echo ========================================
echo.
echo If installation failed, try:
echo   1. Enable "Install from Unknown Sources"
echo   2. Manually uninstall old app from phone
echo   3. Run: flutter run --release
echo.
pause
