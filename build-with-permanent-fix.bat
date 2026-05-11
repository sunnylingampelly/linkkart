@echo off
echo ========================================
echo   Building App with Permanent Solution
echo ========================================
echo.
echo New Features:
echo - API Settings Screen (change IP anytime)
echo - Auto-Detect Backend Server
echo - Connection Testing
echo - Multiple Fallback URLs
echo - Settings Button on Create Store screen
echo.
echo Starting build...
echo.
cd mobile-app
echo [1/3] Cleaning...
call flutter clean
echo.
echo [2/3] Getting dependencies...
call flutter pub get
echo.
echo [3/3] Building APK...
call flutter build apk --debug
echo.
echo ========================================
echo   BUILD COMPLETE!
echo ========================================
echo.
echo APK Location:
echo mobile-app\build\app\outputs\flutter-apk\app-debug.apk
echo.
echo How to Use:
echo 1. Install the new APK
echo 2. Open app and tap Settings icon (top right)
echo 3. Click "Auto-Detect Server" or enter IP manually
echo 4. Test connection
echo 5. Create your store!
echo.
echo See PERMANENT_SOLUTION_GUIDE.md for full details
echo.
pause
