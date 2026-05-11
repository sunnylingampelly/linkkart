@echo off
echo ========================================
echo   Getting SHA-1 Fingerprint
echo ========================================
echo.
echo This will get your SHA-1 fingerprint needed for Firebase Phone Auth
echo.
cd mobile-app\android
echo Running gradlew signingReport...
echo.
call gradlew signingReport
echo.
echo ========================================
echo   INSTRUCTIONS
echo ========================================
echo.
echo 1. Look for "SHA1:" in the output above
echo 2. Copy the value (looks like: A1:B2:C3:D4:...)
echo 3. Go to Firebase Console
echo 4. Project Settings -^> Your apps -^> Add fingerprint
echo 5. Paste the SHA1 value
echo 6. Download new google-services.json
echo 7. Replace file at: mobile-app\android\app\google-services.json
echo 8. Run: flutter clean ^&^& flutter build apk --debug
echo.
echo See FIREBASE_OTP_COMPLETE_FIX.md for detailed instructions
echo.
pause
