@echo off
echo ========================================
echo Rebuilding App with Google Sign-In
echo ========================================
echo.

echo [1/4] Cleaning Flutter build...
call flutter clean
echo.

echo [2/4] Getting dependencies...
call flutter pub get
echo.

echo [3/4] Cleaning Android build...
cd android
call gradlew.bat clean
cd ..
echo.

echo [4/4] Building and running app...
call flutter run
echo.

echo ========================================
echo Build Complete!
echo ========================================
echo.
echo Now test Google Sign-In:
echo 1. Click "Sign in with Google" button
echo 2. Select your Google account
echo 3. Grant permissions
echo 4. You should be signed in!
echo.
pause
