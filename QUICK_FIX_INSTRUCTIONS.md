# Quick Fix for App Crash

## Root Cause Found:
1. **Missing INTERNET permission** in AndroidManifest.xml ✅ FIXED
2. **Old theme.dart file deleted** but screens still reference it ❌ NEEDS FIX
3. **Screens using old AppTheme constants** that don't exist anymore ❌ NEEDS FIX

## The Problem:
- `dashboard_screen.dart`, `create_store_screen.dart`, `add_product_screen.dart`, `product_list_screen.dart` all import `../utils/theme.dart` which we deleted
- They use constants like `AppTheme.successColor`, `AppTheme.spacing16`, etc. which don't exist in the new `app_theme.dart`

## Solution:
We need to either:
1. **Option A**: Recreate the old `theme.dart` with just the constants (QUICK FIX)
2. **Option B**: Update all screens to use new theme system (PROPER FIX - takes longer)

Let me do Option A (quick fix) first so the app works, then we can gradually migrate to the new theme.
