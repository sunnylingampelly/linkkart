#!/bin/bash

###############################################################################
# Update Mobile App to Production URLs
# This script updates the mobile app configuration to use production URLs
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Update Mobile App to Production URLs                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get production URLs from user
read -p "Enter your production API URL (e.g., https://api.linkkart.shop): " API_URL
read -p "Enter your storefront URL (e.g., https://linkkart.shop): " STOREFRONT_URL

echo ""
echo -e "${YELLOW}Updating mobile app configuration...${NC}"

# Backup original file
cp mobile-app/lib/utils/constants.dart mobile-app/lib/utils/constants.dart.backup
echo -e "${GREEN}✓${NC} Backup created: constants.dart.backup"

# Update constants.dart
cat > mobile-app/lib/utils/constants.dart << 'EOF'
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  // API Configuration - PRODUCTION
  
  static const List<String> baseUrls = [
    'PRODUCTION_API_URL',              // Production API (primary)
    'http://192.168.0.9:8000',        // Local development fallback
    'http://10.0.2.2:8000',           // Android Emulator
    'http://127.0.0.1:8000',          // Localhost
  ];
  
  static String _baseUrl = 'PRODUCTION_API_URL';
  static String get baseUrl => _baseUrl;
  static set baseUrl(String url) {
    _baseUrl = url.replaceAll(RegExp(r'/api/v1.*'), '');
  }

  /// Call on app startup to wipe any previously corrupted saved URL
  static Future<void> cleanupSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHost = prefs.getString('api_ip') ?? '';
    if (savedHost.contains('/') || savedHost.contains('api')) {
      await prefs.remove('api_ip');
      await prefs.remove('api_port');
      debugPrint('🧹 Cleared corrupted saved API host: $savedHost');
    }
  }
  
  static const String storefrontUrl = 'PRODUCTION_STOREFRONT_URL';
  
  /// Attempts to find a reachable API URL from the available options
  static Future<void> discoverBaseUrl() async {
    final client = http.Client();
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // 1. Try the last successfully saved IP first for speed
      final savedHost = prefs.getString('api_ip');
      final savedPort = prefs.getString('api_port');
      
      if (savedHost != null && savedPort != null) {
        final cleanHost = savedHost.replaceAll(RegExp(r'http://|https://|/.*'), '');
        final savedUrl = savedHost.startsWith('http') ? '$savedHost:$savedPort' : 'http://$cleanHost:$savedPort';
        try {
          debugPrint('Probing SAVED API at: $savedUrl/api/health');
          final response = await client.get(
            Uri.parse('$savedUrl/api/health'),
          ).timeout(const Duration(seconds: 4));
          
          if (response.statusCode == 200) {
            baseUrl = savedUrl;
            debugPrint('✅ API Discovery: Using saved backend at $baseUrl');
            return;
          }
        } catch (e) {
          debugPrint('ℹ️ Saved API is unreachable, falling back to discovery list');
        }
      }

      // 2. Fall back to the full list of potential IPs (in parallel for speed)
      debugPrint('🔍 Starting parallel API discovery...');
      
      final futures = baseUrls.map((url) async {
        try {
          final response = await client.get(
            Uri.parse('$url/api/health'),
          ).timeout(const Duration(seconds: 5));
          
          if (response.statusCode == 200) {
            return url;
          }
        } catch (_) {}
        return null;
      }).toList();

      final results = await Future.wait(futures);
      final workingUrl = results.firstWhere((url) => url != null, orElse: () => null);

      if (workingUrl != null) {
        baseUrl = workingUrl;
        debugPrint('✅ API Discovery: Found reachable backend at $baseUrl');
        
        final uri = Uri.parse(workingUrl);
        await prefs.setString('api_ip', uri.host);
        await prefs.setString('api_port', uri.port.toString());
        return;
      }
      
      debugPrint('❌ API Discovery: No reachable backend found in list');
    } finally {
      client.close();
    }
  }
  
  // API Endpoints
  static const String storesEndpoint = '/api/v1/stores';
  static const String sellerStoresEndpoint = '/api/v1/seller/stores';
  static const String productsEndpoint = '/api/v1/seller/products';
  static const String analyticsEndpoint = '/api/v1/analytics';
  
  // Authentication
  static String authToken = '';
  
  // Storage Keys
  static const String storeIdKey = 'store_id';
  static const String storeDataKey = 'store_data';
  static const String userDataKey = 'user_data';
  static const String authTokenKey = 'auth_token';
  static const String subscriptionStoreIdKey = 'subscription_store_id';
  static const String subscriptionPlanNameKey = 'subscription_plan_name';
  static const String subscriptionPlanSlugKey = 'subscription_plan_slug';
  static const String subscriptionPlanPriceKey = 'subscription_plan_price';
  static const String subscriptionStatusKey = 'subscription_status';
  static const String subscriptionUpdatedAtKey = 'subscription_updated_at';
  
  // Validation
  static const int maxImageSize = 2 * 1024 * 1024;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  
  // UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
  
  // Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorImageSize = 'Image size must be less than 2MB';
  static const String successStoreCreated = 'Store created successfully!';
  static const String successProductAdded = 'Product added successfully!';
  static const String successProductUpdated = 'Product updated successfully!';
  static const String successProductDeleted = 'Product deleted successfully!';
  
  /// Constructs a full image URL from a relative path
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    final cleanPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    final effectiveBaseUrl = baseUrl.isNotEmpty ? baseUrl : baseUrls[0];
    
    return '$effectiveBaseUrl$cleanPath';
  }
}
EOF

# Replace placeholders with actual URLs
sed -i "s|PRODUCTION_API_URL|$API_URL|g" mobile-app/lib/utils/constants.dart
sed -i "s|PRODUCTION_STOREFRONT_URL|$STOREFRONT_URL|g" mobile-app/lib/utils/constants.dart

echo -e "${GREEN}✓${NC} Updated constants.dart with production URLs"
echo ""

echo -e "${YELLOW}Testing production API...${NC}"

# Test API health endpoint
if curl -s -f "$API_URL/api/health" > /dev/null; then
    echo -e "${GREEN}✓${NC} Production API is reachable"
else
    echo -e "${RED}✗${NC} Warning: Could not reach production API"
    echo -e "${YELLOW}  Make sure your API is deployed and accessible${NC}"
fi

echo ""
echo -e "${YELLOW}Cleaning and rebuilding mobile app...${NC}"

cd mobile-app

# Clean previous build
flutter clean
echo -e "${GREEN}✓${NC} Cleaned previous build"

# Get dependencies
flutter pub get
echo -e "${GREEN}✓${NC} Dependencies updated"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Configuration Updated Successfully!                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Production URLs:${NC}"
echo -e "  API:        $API_URL"
echo -e "  Storefront: $STOREFRONT_URL"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  1. Build debug APK:    ${GREEN}flutter build apk --debug${NC}"
echo -e "  2. Test on device:     ${GREEN}flutter run${NC}"
echo -e "  3. Build release APK:  ${GREEN}flutter build apk --release${NC}"
echo ""
echo -e "${YELLOW}APK Location:${NC}"
echo -e "  build/app/outputs/flutter-apk/app-release.apk"
echo ""
