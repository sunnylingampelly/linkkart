# 🎯 How to Add Pricing Screen to Your App

## Quick Integration Guide

### Option 1: Add "Upgrade" Button in Settings/Profile

If you have a settings or profile screen, add an upgrade button:

```dart
// In your settings/profile screen
import 'package:linkkart/screens/pricing_screen.dart';

// Add this button
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PricingScreen(
          storeId: yourStoreId, // Get from your store data
        ),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF5B6CFF),
  ),
  child: const Text('Upgrade Plan'),
)
```

---

### Option 2: Show When Product Limit Reached

When user tries to add a product but has reached their limit:

```dart
// In your add product screen
import 'package:linkkart/screens/pricing_screen.dart';

Future<void> _addProduct() async {
  // Check if user has reached product limit
  if (currentProductCount >= productLimit) {
    // Show upgrade dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Limit Reached'),
        content: const Text(
          'You\'ve reached your plan limit. Upgrade to add more products!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PricingScreen(storeId: storeId),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B6CFF),
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
    return;
  }
  
  // Continue with adding product...
}
```

---

### Option 3: Show on First Launch

Show pricing screen when user creates their first store:

```dart
// After store creation
import 'package:linkkart/screens/pricing_screen.dart';

Future<void> _createStore() async {
  // Create store...
  final store = await apiService.createStore(name: name, phone: phone);
  
  // Show pricing screen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => PricingScreen(storeId: store.id),
    ),
  );
}
```

---

### Option 4: Add to Navigation Drawer/Menu

If you have a drawer menu:

```dart
// In your drawer
import 'package:linkkart/screens/pricing_screen.dart';

Drawer(
  child: ListView(
    children: [
      // ... other menu items
      
      ListTile(
        leading: const Icon(Icons.workspace_premium, color: Color(0xFF5B6CFF)),
        title: const Text('Upgrade Plan'),
        onTap: () {
          Navigator.pop(context); // Close drawer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PricingScreen(storeId: storeId),
            ),
          );
        },
      ),
    ],
  ),
)
```

---

## Getting Store ID

You need to pass the current store ID to the pricing screen. Here's how to get it:

### From SharedPreferences:
```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

Future<int> _getStoreId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(AppConstants.storeIdKey) ?? 0;
}

// Use it:
final storeId = await _getStoreId();
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PricingScreen(storeId: storeId),
  ),
);
```

### From Provider/State Management:
```dart
// If you're using Provider
final storeId = Provider.of<StoreProvider>(context, listen: false).storeId;

// If you're using GetX
final storeId = Get.find<StoreController>().storeId;
```

---

## Complete Example: Add to Home Screen

Here's a complete example of adding an "Upgrade" card to your home screen:

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/pricing_screen.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Store'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Your existing widgets...
            
            // Add this upgrade card
            _buildUpgradeCard(context),
            
            // More widgets...
          ],
        ),
      ),
    );
  }
  
  Widget _buildUpgradeCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B6CFF), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Upgrade Your Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Get unlimited products and more features',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final storeId = prefs.getInt(AppConstants.storeIdKey) ?? 0;
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PricingScreen(storeId: storeId),
                ),
              );
            },
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Checking Current Plan

To show the current plan in your app:

```dart
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  String _currentPlan = 'Free';
  bool _loading = true;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
  }
  
  Future<void> _loadCurrentPlan() async {
    try {
      // Get store subscription
      final prefs = await SharedPreferences.getInstance();
      final storeId = prefs.getInt(AppConstants.storeIdKey) ?? 0;
      
      // You'll need to add this endpoint to get current subscription
      // For now, you can store it in SharedPreferences after payment
      final planName = prefs.getString('current_plan') ?? 'Free';
      
      setState(() {
        _currentPlan = planName;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: const Text('Current Plan'),
            subtitle: Text(_currentPlan),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final storeId = prefs.getInt(AppConstants.storeIdKey) ?? 0;
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PricingScreen(storeId: storeId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

---

## Storing Plan After Payment

After successful payment, store the plan name:

```dart
// In payment_screen.dart, after successful payment
final prefs = await SharedPreferences.getInstance();
await prefs.setString('current_plan', widget.plan.name);
```

---

## Summary

**Choose the best option for your app:**

1. **Settings/Profile** - Most common, easy to find
2. **Product Limit** - Contextual, when user needs it
3. **First Launch** - Good for onboarding
4. **Navigation Menu** - Always accessible

**Required:**
- Import `pricing_screen.dart`
- Get current `storeId`
- Navigate with `Navigator.push()`

**That's it!** The pricing screen handles everything else.

---

**Next Steps:**
1. Choose where to add the pricing screen
2. Add the navigation code
3. Test the flow
4. Done! ✅
