# Build Error Fixed - PricingScreen storeId Parameter

## Error
```
lib/screens/add_product_screen_premium.dart:429:76: Error: 
Required named parameter 'storeId' must be provided.
MaterialPageRoute(builder: (context) => const PricingScreen()),
```

## Root Cause
`PricingScreen` requires a `storeId` parameter, but it wasn't being passed when navigating from the "Upgrade Plan" dialog in `add_product_screen_premium.dart`.

## Fix Applied

**File:** `mobile-app/lib/screens/add_product_screen_premium.dart`

**Before:**
```dart
onPressed: () {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const PricingScreen()),
  );
},
```

**After:**
```dart
onPressed: () {
  final storeProvider = Provider.of<StoreProvider>(context, listen: false);
  final storeId = storeProvider.currentStore?.id ?? 0;
  
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PricingScreen(storeId: storeId),
    ),
  );
},
```

## What Changed
- ✅ Get `storeId` from `StoreProvider` before navigation
- ✅ Pass `storeId` to `PricingScreen` constructor
- ✅ Use null-safe operator (`?.`) with fallback to 0

## Testing
```bash
cd mobile-app
flutter clean
flutter build apk --debug
```

Should build successfully now!

## Files Modified
- ✅ `mobile-app/lib/screens/add_product_screen_premium.dart`

## Build Command
```bash
cd mobile-app
flutter clean
flutter build apk --release
```

Build should complete without errors! ✅
