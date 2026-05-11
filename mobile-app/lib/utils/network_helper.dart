import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/material.dart';
import 'constants.dart';

class NetworkHelper {
  static String? _workingBaseUrl;
  static DateTime? _lastCheck;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Find the first working API endpoint from the list
  static Future<String> getWorkingBaseUrl() async {
    // Return cached URL if still valid
    if (_workingBaseUrl != null && _lastCheck != null) {
      if (DateTime.now().difference(_lastCheck!) < _cacheDuration) {
        return _workingBaseUrl!;
      }
    }

    // Try each URL in order
    for (String url in AppConstants.baseUrls) {
      if (await _testConnection(url)) {
        _workingBaseUrl = url;
        _lastCheck = DateTime.now();
        debugPrint('✅ Found working API: $url');
        return url;
      }
    }

    // If none work, return the first one (will show error to user)
    debugPrint('⚠️ No working API found, using default');
    return AppConstants.baseUrls[0];
  }

  /// Test if a URL is reachable
  static Future<bool> _testConnection(String baseUrl) async {
    try {
      // Extract base URL without /api/v1
      final uri = Uri.parse(baseUrl.replaceAll('/api/v1', ''));
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 3),
        onTimeout: () => http.Response('Timeout', 408),
      );

      return response.statusCode < 500; // Accept any non-server-error response
    } catch (e) {
      debugPrint('Connection test failed for $baseUrl: $e');
      return false;
    }
  }

  /// Update the base URL in AppConstants
  static Future<void> updateBaseUrl() async {
    final workingUrl = await getWorkingBaseUrl();
    AppConstants.baseUrl = workingUrl;
  }

  /// Force refresh the working URL
  static void clearCache() {
    _workingBaseUrl = null;
    _lastCheck = null;
  }

  /// Check if backend is reachable
  static Future<bool> isBackendReachable() async {
    try {
      final url = await getWorkingBaseUrl();
      return await _testConnection(url);
    } catch (e) {
      return false;
    }
  }

  /// Get connection status message
  static Future<String> getConnectionStatus() async {
    final isReachable = await isBackendReachable();
    if (isReachable) {
      return '✅ Connected to backend';
    } else {
      return '❌ Cannot reach backend. Check your network connection.';
    }
  }
}
