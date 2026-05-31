import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plan.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'subscription_service.dart';

class IapService extends ChangeNotifier {
  static final IapService _instance = IapService._internal();
  factory IapService() => _instance;
  IapService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final ApiService _apiService = ApiService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isLoading = false;
  String? _error;

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize stream listener
  void initialize() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () => _subscription?.cancel(),
      onError: (err) {
        _error = err.toString();
        notifyListeners();
      },
    );
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    _isAvailable = await _iap.isAvailable();
    notifyListeners();
  }

  // Load subscriptions products from Play Store
  Future<void> loadProducts(List<String> productIds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_isAvailable) {
        await _checkAvailability();
      }

      if (!_isAvailable) {
        throw Exception('In-App Billing is not available on this device');
      }

      final ProductDetailsResponse response =
          await _iap.queryProductDetails(productIds.toSet());

      if (response.error != null) {
        throw Exception(response.error!.message);
      }

      _products = response.productDetails;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start checkout flow for a subscription
  Future<void> buySubscription(ProductDetails productDetails) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Process purchases stream updates
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _isLoading = true;
        notifyListeners();
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _error = purchaseDetails.error?.message ?? 'Purchase failed';
        _isLoading = false;
        _iap.completePurchase(purchaseDetails);
        notifyListeners();
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        
        final localStoreId = await _getLocalStoreId();
        if (localStoreId != null) {
          final success = await _verifyPurchaseOnBackend(
            storeId: localStoreId,
            productId: purchaseDetails.productID,
            token: purchaseDetails.verificationData.serverVerificationData,
          );

          if (success) {
            _iap.completePurchase(purchaseDetails);
          }
        }
      }
    }
  }

  // Verify Play Store Purchase Token via Standalone PHP Router
  Future<bool> _verifyPurchaseOnBackend({
    required int storeId,
    required String productId,
    required String token,
  }) async {
    try {
      final response = await _apiService.verifyGooglePlayPurchase(
        storeId: storeId,
        productId: productId,
        purchaseToken: token,
      );

      if (response['success'] == true) {
        // Map play store product ID to the plan model to persist locally
        final endsAtStr = response['data']?['ends_at'] ?? '';
        final endsAt = DateTime.tryParse(endsAtStr);
        final slug = productId.replaceAll('linkkart_', '');

        // Fetch local plans to get plan details
        final plans = await _apiService.getPlans();
        final plan = plans.firstWhere(
          (p) => p.slug == slug,
          orElse: () => Plan(
            id: 2,
            name: slug.toUpperCase(),
            slug: slug,
            price: 299.0,
            billingCycle: 'monthly',
            productLimit: 100,
            orderLimit: 100,
            features: [],
            isActive: true,
            sortOrder: 2,
          ),
        );

        // Update local SharedPreferences
        await _subscriptionService.activatePlan(
          storeId: storeId,
          plan: plan,
          status: 'active',
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = response['message'] ?? 'Purchase token verification failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Verification error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<int?> _getLocalStoreId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? storeId = prefs.getInt(AppConstants.subscriptionStoreIdKey);
      if (storeId == null) {
        storeId = prefs.getInt(AppConstants.storeIdKey);
      }
      return storeId;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
