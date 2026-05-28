import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkkart/utils/app_colors.dart';
import 'package:linkkart/services/api_service.dart';
import 'package:linkkart/services/subscription_service.dart';
import 'package:linkkart/utils/constants.dart';
import 'package:linkkart/models/plan.dart';
import 'package:linkkart/screens/payment_screen.dart';

class PricingScreen extends StatefulWidget {
  final int storeId;

  const PricingScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final ApiService _apiService = ApiService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Plan> _plans = [];
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _currentPlan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadPlans(),
      _loadCurrentPlan(),
    ]);
  }

  Future<void> _loadCurrentPlan() async {
    try {
      final plan = await _subscriptionService.getCurrentPlan();
      if (!mounted) return;
      setState(() {
        _currentPlan = plan;
      });
    } catch (e) {
      print('Error loading current plan: $e');
    }
  }

  Future<void> _loadPlans() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final plans = await _apiService.getPlans();
      if (!mounted) return;

      setState(() {
        _plans = plans.isEmpty ? _fallbackPlans() : plans;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _plans = _fallbackPlans();
        _error = null;
        _loading = false;
      });
    }
  }

  List<Plan> _fallbackPlans() {
    return [
      Plan(
        id: 1,
        name: 'Free Trial',
        slug: 'free',
        price: 0,
        billingCycle: 'lifetime',
        productLimit: 5,
        orderLimit: 999999,
        features: const [
          '5 Products',
          'Unlimited Orders',
          'WhatsApp Integration',
          'QR Code Store',
          'Analytics Dashboard',
          'Size Variants',
          'Multiple Images',
          'Custom Branding',
        ],
        isActive: true,
        sortOrder: 1,
      ),
      Plan(
        id: 2,
        name: 'Starter',
        slug: 'starter',
        price: 399,
        billingCycle: 'monthly',
        productLimit: 10,
        orderLimit: 999999,
        features: const [
          '10 Products',
          'Unlimited Orders',
          'WhatsApp Integration',
          'QR Code Store',
          'Analytics Dashboard',
          'Size Variants',
          'Multiple Images',
          'Custom Branding',
          'Priority Support',
        ],
        isActive: true,
        sortOrder: 2,
      ),
      Plan(
        id: 3,
        name: 'Business',
        slug: 'business',
        price: 599,
        billingCycle: 'monthly',
        productLimit: 999999,
        orderLimit: 999999,
        features: const [
          'Unlimited Products',
          'Unlimited Orders',
          'WhatsApp Integration',
          'QR Code Store',
          'Analytics Dashboard',
          'Size Variants',
          'Multiple Images',
          'Custom Branding',
          'Priority Support',
          '24/7 Support',
        ],
        isActive: true,
        sortOrder: 3,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PREMIUM PLANS',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading plans',
                        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadPlans,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ELEVATE YOUR\nBUSINESS',
                        style: GoogleFonts.playfairDisplay(
                          color: AppColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select a plan that matches your ambition. All plans include our 14-day luxury trial.',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ..._plans.map((plan) => _buildPlanCard(plan)).toList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPlanCard(Plan plan) {
    final isPopular = plan.slug == 'starter';
    final isFree = plan.price == 0;
    final isCurrentPlan = _currentPlan != null && 
        (_currentPlan!['slug'] == plan.slug || 
         (_currentPlan!['slug'] == 'free' && plan.slug == 'free'));
    
    // Determine button text and action
    String buttonText;
    Color buttonColor;
    Color textColor;
    bool hasAction = true;
    
    if (isCurrentPlan) {
      buttonText = 'CURRENT PLAN';
      buttonColor = Colors.transparent;
      textColor = AppColors.secondary;
      hasAction = false;
    } else if (_currentPlan != null) {
      final currentPrice = _currentPlan!['price'] ?? 0.0;
      if (plan.price > currentPrice) {
        buttonText = 'UPGRADE NOW';
        buttonColor = AppColors.primary;
        textColor = Colors.white;
      } else if (plan.price < currentPrice) {
        buttonText = 'SWITCH PLAN';
        buttonColor = Colors.transparent;
        textColor = AppColors.primary;
      } else {
        buttonText = 'SELECT PLAN';
        buttonColor = AppColors.primary;
        textColor = Colors.white;
      }
    } else {
      buttonText = isFree ? 'START FREE' : 'SELECT PLAN';
      buttonColor = isFree ? Colors.transparent : AppColors.primary;
      textColor = isFree ? AppColors.primary : Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          color: isCurrentPlan 
              ? AppColors.secondary 
              : (isPopular ? AppColors.secondary : AppColors.border),
          width: isCurrentPlan || isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCurrentPlan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
              ),
              child: Text(
                'YOUR CURRENT PLAN',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            )
          else if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
              ),
              child: Text(
                'EXCEPTIONAL VALUE',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan name
                Text(
                  plan.name.toUpperCase(),
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹',
                      style: GoogleFonts.inter(
                        color: AppColors.secondary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      plan.price.toStringAsFixed(0),
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.textPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '/mo',
                        style: GoogleFonts.inter(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Features
                ...plan.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            color: AppColors.secondary,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature.toUpperCase(),
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 32),

                // CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: hasAction ? () => _selectPlan(plan) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: textColor,
                      side: buttonColor == Colors.transparent 
                          ? BorderSide(color: textColor, width: 2) 
                          : null,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.transparent,
                      disabledForegroundColor: AppColors.secondary,
                    ),
                    child: Text(
                      buttonText,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectPlan(Plan plan) {
    if (widget.storeId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create/select a store first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Check if this is current plan
    if (_currentPlan != null && _currentPlan!['slug'] == plan.slug) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is already your current plan.'),
          backgroundColor: AppColors.secondary,
        ),
      );
      return;
    }
    
    if (plan.price == 0) {
      // Free plan - create subscription directly
      _createFreeSubscription(plan);
    } else {
      // Paid plan - show confirmation for upgrade/downgrade
      final currentPrice = _currentPlan?['price'] ?? 0.0;
      final isUpgrade = plan.price > currentPrice;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            isUpgrade ? 'Upgrade Plan?' : 'Change Plan?',
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            isUpgrade
                ? 'Upgrade to ${plan.name} plan for ₹${plan.price.toStringAsFixed(0)}/month?'
                : 'Switch to ${plan.name} plan for ₹${plan.price.toStringAsFixed(0)}/month?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      storeId: widget.storeId,
                      plan: plan,
                    ),
                  ),
                ).then((_) => _loadCurrentPlan()); // Reload after payment
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                'CONTINUE',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _createFreeSubscription(Plan plan) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );

      if (AppConstants.authToken.isNotEmpty) {
        await _apiService.createSubscription(widget.storeId, plan.id);
      }
      await SubscriptionService().activatePlan(
        storeId: widget.storeId,
        plan: plan,
        status: 'trial',
      );

      // Reload current plan
      await _loadCurrentPlan();

      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Go back

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Free trial activated! 14 days free.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
