import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/store.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class StoreProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Store? _currentStore;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _statistics;

  Store? get currentStore => _currentStore;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get statistics => _statistics;
  bool get hasStore => _currentStore != null;

  StoreProvider() {
    _loadStoredStore();
  }

  Future<void> _loadStoredStore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storeData = prefs.getString(AppConstants.storeDataKey);
      
      if (storeData != null && storeData.isNotEmpty) {
        try {
          _currentStore = Store.fromJson(json.decode(storeData));
          notifyListeners();
          
          // Automatically load statistics when store is ready
          loadStatistics();
        } catch (e) {
          debugPrint('Error parsing stored store data: $e');
          // Clear corrupted data
          await prefs.remove(AppConstants.storeDataKey);
          await prefs.remove(AppConstants.storeIdKey);
        }
      }
    } catch (e) {
      debugPrint('Error loading stored store: $e');
    }
  }

  Future<void> _saveStore(Store store) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.storeDataKey, json.encode(store.toJson()));
      await prefs.setInt(AppConstants.storeIdKey, store.id);
    } catch (e) {
      debugPrint('Error saving store: $e');
    }
  }

  Future<bool> checkExistingStore(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final store = await _apiService.getStoreByPhone(phone);
      if (store != null) {
        _currentStore = store;
        await _saveStore(store);
        await loadStatistics();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createStore({
    required String name,
    required String phone,
    File? logo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final store = await _apiService.createStore(
        name: name,
        phone: phone,
        logo: logo,
      );

      _currentStore = store;
      await _saveStore(store);
      
      // Load initial statistics for new store
      await loadStatistics();
      
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

  Future<void> refreshStore() async {
    if (_currentStore == null) return;

    try {
      final store = await _apiService.getStore(_currentStore!.id);
      _currentStore = store;
      await _saveStore(store);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing store: $e');
    }
  }

  Future<void> updateStore({
    String? name,
    String? phone,
    File? logo,
  }) async {
    if (_currentStore == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final store = await _apiService.updateStore(
        storeId: _currentStore!.id,
        name: name,
        phone: phone,
        logo: logo,
      );

      _currentStore = store;
      await _saveStore(store);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStatistics() async {
    if (_currentStore == null) return;

    try {
      _statistics = await _apiService.getStoreStatistics(_currentStore!.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.storeDataKey);
    await prefs.remove(AppConstants.storeIdKey);
    _currentStore = null;
    _statistics = null;
    notifyListeners();
  }
}
