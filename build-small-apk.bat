@echo off
echo ========================================
echo   Build Smaller APK (Split by ABI)
echo ========================================
echo.
echo This builds 3 smaller APKs instead of 1 large one:
echo   - arm64-v8a (18MB) - For most modern phones
echo   - armeabi-v7a (15MB) - For older phones
echo   - x86_64 (18MB) - For Intel phones
echo.
echo ========================================
echo.

cd mobile-app

echo Step 1: Cleaning previous build...
call flutter clean
echo.

echo Step 2: Getting dependencies...
call flutter pub get
echo.

echo Step 3: Building split APKs (this takes 3-5 minutes)...
call flutter build apk --split-per-abi --release
echo.

echo ========================================
echo   Build Complete!
echo ========================================
echo.
echo APK Locations:
dir build\app\outputs\flutter-apk\*.apk
echo.
echo For most phones, use: app-arm64-v8a-release.apk
echo.
echo To install:
echo   adb install build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
echo.
echo Or copy the APK to your phone and install manually.
echo.
echo ========================================

pause
