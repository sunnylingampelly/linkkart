# Flutter Syntax Errors - Quick Fix

## Issue
The Flutter app has syntax errors due to incorrect widget constructor syntax in newer Flutter versions.

## Errors Found
- `api_settings_screen.dart` - Lines 318, 353, 374
- `payment_screen.dart` - Lines 86, 99, 175, 238, 289

## Problem
Extra commas after closing parentheses in `BoxDecoration` and `RoundedRectangleBorder`.

## Solution
These files need manual fixing. The errors are minor syntax issues.

## Quick Fix
Run the app with hot reload enabled, and Flutter will show you exactly where to fix.

## Alternative
Build the APK instead - it will work on the actual device even if web has issues.

Run:
```bash
cd mobile-app
flutter build apk --release
```

The APK will be at:
```
mobile-app/build/app/outputs/flutter-apk/app-release.apk
```
