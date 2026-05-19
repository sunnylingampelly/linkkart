import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  // API Configuration
  // Multiple endpoints for fallback (tries in order)
  
  static const List<String> baseUrls = [
    'https://api.linkkart.shop',     // Production API (primary)
    // 'http://192.168.0.9:8000',       // Local development fallback
    // 'http://10.0.2.2:8000',          // Android Emulator
    // 'http://127.0.0.1:8000',         // Localhost
    // 'http://localhost:8000',
  ];
  
  static String _baseUrl = 'https://api.linkkart.shop';
  static String get baseUrl => _baseUrl;
  static set baseUrl(String url) {
    // Strip any accidental /api/v1 path that may have been stored
    _baseUrl = url.replaceAll(RegExp(r'/api/v1.*$'), '');
  }

  /// Call on app startup to wipe any previously corrupted saved URL
  static Future<void> cleanupSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHost = prefs.getString('api_ip') ?? '';
    // If saved host contains a path (e.g. was saved as full URL), clear it
    if (savedHost.contains('/') || savedHost.contains('api')) {
      await prefs.remove('api_ip');
      await prefs.remove('api_port');
      debugPrint('🧹 Cleared corrupted saved API host: $savedHost');
    }
  }
  
  static const String storefrontUrl = 'https://linkkart.shop';
  
  /// Attempts to find a reachable API URL from the available options
  static Future<void> discoverBaseUrl() async {
    final client = http.Client();
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // 1. Try the last successfully saved IP first for speed
      final savedHost = prefs.getString('api_ip');
      final savedPort = prefs.getString('api_port');
      
      if (savedHost != null && savedPort != null) {
        // Guard: only use saved host if it's a raw IP/hostname, not a full URL
        final cleanHost = savedHost.replaceAll(RegExp(r'http://|https://|/.*'), '');
        final savedUrl = 'http://$cleanHost:$savedPort';
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
        
        // Save only host and port — never the full path
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
  static String authToken = ''; // Will be set after login
  
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
  static const int maxImageSize = 2 * 1024 * 1024; // 2MB
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
  
  // Helper Methods
  
  /// Constructs a full image URL from a relative path
  /// If the path is already a full URL (starts with http), returns it as-is
  /// Otherwise, prepends the base URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    
    // If already a full URL, return as-is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Ensure path starts with /
    final cleanPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    
    // Use current baseUrl or fallback to first option if empty
    final effectiveBaseUrl = baseUrl.isNotEmpty ? baseUrl : baseUrls[0];
    
    // Construct full URL
    return '$effectiveBaseUrl$cleanPath';
  }
}
