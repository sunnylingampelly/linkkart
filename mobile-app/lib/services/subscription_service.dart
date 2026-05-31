import 'package:shared_preferences/shared_preferences.dart';
import '../models/plan.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final ApiService _apiService = ApiService();

  Future<void> activateBasicPlan({
    required int storeId,
    bool trial = true,
  }) async {
    try {
      // Fetch plans to find the free one
      final plans = await _apiService.getPlans();
      final freePlan = plans.firstWhere((p) => p.slug == 'free');
      
      // Create subscription on backend
      final subData = await _apiService.createSubscription(storeId, freePlan.id);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.subscriptionStoreIdKey, storeId);
      await prefs.setString(AppConstants.subscriptionPlanNameKey, freePlan.name);
      await prefs.setString(AppConstants.subscriptionPlanSlugKey, freePlan.slug);
      await prefs.setDouble(AppConstants.subscriptionPlanPriceKey, freePlan.price);
      await prefs.setString(AppConstants.subscriptionStatusKey, 'active');
      await prefs.setString(
        AppConstants.subscriptionUpdatedAtKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error activating basic plan: $e');
    }
  }

  Future<void> activatePlan({
    required int storeId,
    required Plan plan,
    String status = 'active',
  }) async {
    try {
      // NOTE: Do NOT call createSubscription here — the subscription was already
      // created before Razorpay was opened. This method only persists the
      // activated plan locally so the UI reflects the new status immediately.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.subscriptionStoreIdKey, storeId);
      await prefs.setString(AppConstants.subscriptionPlanNameKey, plan.name);
      await prefs.setString(AppConstants.subscriptionPlanSlugKey, plan.slug);
      await prefs.setDouble(AppConstants.subscriptionPlanPriceKey, plan.price);
      await prefs.setString(AppConstants.subscriptionStatusKey, status);
      await prefs.setString(
        AppConstants.subscriptionUpdatedAtKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error activating plan locally: $e');
    }
  }

  Future<Map<String, dynamic>> syncSubscription(int storeId, {bool force = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Prevent frequent database sync calls unless forced (cache for 1 minute)
      if (!force) {
        final lastUpdateStr = prefs.getString(AppConstants.subscriptionUpdatedAtKey);
        if (lastUpdateStr != null && lastUpdateStr.isNotEmpty) {
          final lastUpdate = DateTime.tryParse(lastUpdateStr);
          if (lastUpdate != null && DateTime.now().difference(lastUpdate).inMinutes < 1) {
            return getCurrentPlan();
          }
        }
      }
      
      final response = await _apiService.getStoreSubscription(storeId);
      if (response['success'] == true) {
        final subData = response['data'];
        final plans = await _apiService.getPlans();
        
        final planId = int.tryParse(subData['plan_id'].toString()) ?? 1;
        final plan = plans.firstWhere(
          (p) => p.id == planId,
          orElse: () => Plan(
            id: planId,
            name: subData['plan_name'] ?? 'Basic',
            slug: subData['plan_slug'] ?? 'free',
            price: double.tryParse(subData['price'].toString()) ?? 0.0,
            billingCycle: 'monthly',
            productLimit: 100,
            orderLimit: 100,
            features: [],
            isActive: true,
            sortOrder: 1,
          ),
        );

        await prefs.setInt(AppConstants.subscriptionStoreIdKey, storeId);
        await prefs.setString(AppConstants.subscriptionPlanNameKey, plan.name);
        await prefs.setString(AppConstants.subscriptionPlanSlugKey, plan.slug);
        await prefs.setDouble(AppConstants.subscriptionPlanPriceKey, plan.price);
        await prefs.setString(AppConstants.subscriptionStatusKey, subData['status'] ?? 'trial');
        await prefs.setString(
          AppConstants.subscriptionUpdatedAtKey,
          DateTime.now().toIso8601String(),
        );
      }
      return getCurrentPlan();
    } catch (e) {
      print('Error syncing subscription: $e');
      return getCurrentPlan();
    }
  }

  Future<Map<String, dynamic>> getCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'store_id': prefs.getInt(AppConstants.subscriptionStoreIdKey),
      'name': prefs.getString(AppConstants.subscriptionPlanNameKey) ?? 'Basic (Free)',
      'slug': prefs.getString(AppConstants.subscriptionPlanSlugKey) ?? 'free',
      'price': prefs.getDouble(AppConstants.subscriptionPlanPriceKey) ?? 0.0,
      'status': prefs.getString(AppConstants.subscriptionStatusKey) ?? 'trial',
      'updated_at':
          prefs.getString(AppConstants.subscriptionUpdatedAtKey) ?? '',
    };
  }
}
