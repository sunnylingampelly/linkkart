import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../models/plan.dart';
import '../models/order_model.dart';
import '../models/customer_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Get base URL dynamically
  String get baseUrl => AppConstants.baseUrl;

  Future<String> _getAuthToken() async {
    if (AppConstants.authToken.isNotEmpty) return AppConstants.authToken;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.authTokenKey) ?? '';
    AppConstants.authToken = token;
    return token;
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method to handle API responses
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  // Wrapper for HTTP calls with auto-discovery retry
  Future<http.Response> _safeRequest(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeoutDuration);
    } catch (e) {
      if (e is SocketException || e is http.ClientException || e is TimeoutException) {
        debugPrint('⚠️ Network/Timeout error detected, attempting API discovery...');
        await AppConstants.discoverBaseUrl();
        // Retry once with new base URL
        try {
          return await request().timeout(_timeoutDuration);
        } catch (retryError) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  // Common timeout duration
  static const Duration _timeoutDuration = Duration(seconds: 30);

  // Store APIs
  Future<Store> createStore({
    required String name,
    required String phone,
    File? logo,
  }) async {
    var response = await _safeRequest(() async {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl${AppConstants.sellerStoresEndpoint}'),
      );

      request.fields['name'] = name;
      request.fields['phone'] = phone;

      if (logo != null) {
        request.files.add(
          await http.MultipartFile.fromPath('logo', logo.path),
        );
      }

      var streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    });

    var data = _handleResponse(response);
    return Store.fromJson(data['data']);
  }

  Future<Store> getStore(int storeId) async {
    final response = await _safeRequest(() => http.get(
      Uri.parse('$baseUrl${AppConstants.storesEndpoint}/$storeId'),
    ));

    var data = _handleResponse(response);
    return Store.fromJson(data['data']);
  }

  Future<Store?> getStoreByPhone(String phone) async {
    try {
      final encodedPhone = Uri.encodeComponent(phone);
      final response = await _safeRequest(() => http.get(
        Uri.parse('$baseUrl${AppConstants.storesEndpoint}/search-by-phone?phone=$encodedPhone'),
      ));

      if (response.statusCode == 404) return null;
      
      var data = _handleResponse(response);
      return Store.fromJson(data['data']);
    } catch (e) {
      debugPrint('Error fetching store by phone: $e');
      return null;
    }
  }

  Future<Store> updateStore({
    required int storeId,
    String? name,
    String? phone,
    File? logo,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl${AppConstants.sellerStoresEndpoint}/$storeId/update'),
    );

    if (name != null) request.fields['name'] = name;
    if (phone != null) request.fields['phone'] = phone;

    if (logo != null) {
      request.files.add(
        await http.MultipartFile.fromPath('logo', logo.path),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    var data = _handleResponse(response);

    return Store.fromJson(data['data']);
  }

  Future<Map<String, dynamic>> getStoreStatistics(int storeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${AppConstants.storesEndpoint}/$storeId/statistics'),
    ).timeout(_timeoutDuration);

    var data = _handleResponse(response);
    return data['data'];
  }

  // Product APIs
  Future<Product> createProduct({
    required int storeId,
    required String name,
    required double price,
    String? description,
    int? stockQuantity,
    File? image,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl${AppConstants.productsEndpoint}'),
    );

    request.fields['store_id'] = storeId.toString();
    request.fields['name'] = name;
    request.fields['price'] = price.toString();
    if (description != null) request.fields['description'] = description;
    if (stockQuantity != null) request.fields['stock_quantity'] = stockQuantity.toString();

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    var data = _handleResponse(response);

    return Product.fromJson(data['data']);
  }

  Future<List<Product>> getProducts(int storeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.storesEndpoint}/$storeId/products'),
      ).timeout(_timeoutDuration);

      var data = _handleResponse(response);
      
      // Handle different response structures
      List<dynamic> productsJson;
      if (data['data'] is Map && data['data']['products'] != null) {
        // Direct list from byStore: {success: true, data: {store: ..., products: [...]}}
        productsJson = data['data']['products'];
      } else if (data['data'] is Map && data['data']['data'] != null) {
        // Paginated response: {success: true, data: {data: [...], current_page: 1, ...}}
        productsJson = data['data']['data'];
      } else if (data['data'] is List) {
        // Direct array response: {success: true, data: [...]}
        productsJson = data['data'];
      } else {
        // Fallback
        productsJson = [];
      }
      
      return productsJson.map((json) {
        try {
          return Product.fromJson(json);
        } catch (e) {
          print('Error parsing product: $e');
          print('Product JSON: $json');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  Future<Product> updateProduct({
    required int productId,
    String? name,
    double? price,
    String? description,
    File? image,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl${AppConstants.productsEndpoint}/$productId/update'),
    );

    if (name != null) request.fields['name'] = name;
    if (price != null) request.fields['price'] = price.toString();
    if (description != null) request.fields['description'] = description;

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    var data = _handleResponse(response);

    return Product.fromJson(data['data']);
  }

  Future<void> deleteProduct(int productId) async {
    try {
      print('Deleting product with ID: $productId');
      print('URL: $baseUrl${AppConstants.productsEndpoint}/$productId');
      
      final response = await http.delete(
        Uri.parse('$baseUrl${AppConstants.productsEndpoint}/$productId'),
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      _handleResponse(response);
    } catch (e) {
      print('Delete error: $e');
      rethrow;
    }
  }

  // Analytics API
  Future<void> trackEvent({
    required int storeId,
    int? productId,
    required String eventType,
    Map<String, dynamic>? metadata,
  }) async {
    await http.post(
      Uri.parse('$baseUrl${AppConstants.analyticsEndpoint}/track'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'store_id': storeId,
        'product_id': productId,
        'event_type': eventType,
        'metadata': metadata,
      }),
    );
  }

  // Orders API
  Future<List<OrderModel>> getOrders(int storeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${AppConstants.storesEndpoint}/$storeId/orders'),
      headers: await _authHeaders(),
    );
    var data = _handleResponse(response);
    List<dynamic> ordersJson = data['data'];
    return ordersJson.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/orders/$orderId/status'),
      headers: await _authHeaders(),
      body: json.encode({'status': status}),
    );
    _handleResponse(response);
  }

  // Customers API
  Future<List<CustomerModel>> getCustomers(int storeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${AppConstants.storesEndpoint}/$storeId/customers'),
      headers: await _authHeaders(),
    );
    var data = _handleResponse(response);
    List<dynamic> customersJson = data['data'];
    return customersJson.map((json) => CustomerModel.fromJson(json)).toList();
  }

  // Payment & Subscription APIs
  Future<List<Plan>> getPlans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/plans'),
    );

    var data = _handleResponse(response);
    List<dynamic> plansJson = data['data'];
    return plansJson.map((json) => Plan.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> createSubscription(
    int storeId,
    int planId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subscriptions'),
      headers: await _authHeaders(),
      body: json.encode({
        'store_id': storeId,
        'plan_id': planId,
      }),
    );

    var data = _handleResponse(response);
    return data['data'];
  }

  Future<Map<String, dynamic>> getSubscription(int subscriptionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/subscriptions/$subscriptionId'),
      headers: await _authHeaders(),
    );

    var data = _handleResponse(response);
    return data['data'];
  }

  Future<Map<String, dynamic>> createPaymentOrder(
    int subscriptionId,
    double amount,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/create-order'),
      headers: await _authHeaders(),
      body: json.encode({
        'subscription_id': subscriptionId,
        'amount': amount,
      }),
    );

    var data = _handleResponse(response);
    return data['data'];
  }

  Future<Map<String, dynamic>> verifyPayment(
    String orderId,
    String paymentId,
    String signature,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/verify'),
      headers: await _authHeaders(),
      body: json.encode({
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      }),
    );

    var data = _handleResponse(response);
    return data['data'];
  }

  Future<List<dynamic>> getPaymentHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/history'),
      headers: await _authHeaders(),
    );

    var data = _handleResponse(response);
    return data['data'];
  }
}
