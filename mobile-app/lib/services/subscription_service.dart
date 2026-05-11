import 'package:shared_preferences/shared_preferences.dart';
import '../models/plan.dart';
import '../utils/constants.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  Future<void> activateBasicPlan({
    required int storeId,
    bool trial = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.subscriptionStoreIdKey, storeId);
    await prefs.setString(AppConstants.subscriptionPlanNameKey, 'Basic (Free)');
    await prefs.setString(AppConstants.subscriptionPlanSlugKey, 'free');
    await prefs.setDouble(AppConstants.subscriptionPlanPriceKey, 0);
    await prefs.setString(
      AppConstants.subscriptionStatusKey,
      trial ? 'trial' : 'active',
    );
    await prefs.setString(
      AppConstants.subscriptionUpdatedAtKey,
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> activatePlan({
    required int storeId,
    required Plan plan,
    String status = 'active',
  }) async {
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
