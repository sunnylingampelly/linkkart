import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get productCount => _products.length;

  Future<void> loadProducts(int storeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _apiService.getProducts(storeId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct({
    required int storeId,
    required String name,
    required double price,
    String? description,
    int? stockQuantity,
    File? image,
    bool hasSizes = false,
    Map<String, int>? sizes,
    File? sizeChartImage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final product = await _apiService.createProduct(
        storeId: storeId,
        name: name,
        price: price,
        description: description,
        stockQuantity: stockQuantity,
        image: image,
        hasSizes: hasSizes,
        sizes: sizes,
        sizeChartImage: sizeChartImage,
      );

      _products.insert(0, product);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      // Check if it's a limit reached error
      if (_error!.contains('limit reached') || _error!.contains('upgrade')) {
        _error = 'LIMIT_REACHED: $_error';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct({
    required int productId,
    String? name,
    double? price,
    String? description,
    File? image,
    bool? hasSizes,
    Map<String, int>? sizes,
    File? sizeChartImage,
    int? stockQuantity,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final product = await _apiService.updateProduct(
        productId: productId,
        name: name,
        price: price,
        description: description,
        image: image,
        hasSizes: hasSizes,
        sizes: sizes,
        sizeChartImage: sizeChartImage,
        stockQuantity: stockQuantity,
      );

      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = product;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Alias for loadProducts to match common naming convention
  Future<void> fetchProducts([int? storeId]) async {
    if (storeId != null) {
      await loadProducts(storeId);
    }
  }

  void clear() {
    _products = [];
    _error = null;
    notifyListeners();
  }
}
