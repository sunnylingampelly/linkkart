import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/subscription_service.dart';
import '../services/iap_service.dart';
import '../models/plan.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class PaymentScreen extends StatefulWidget {
  final int storeId;
  final Plan plan;

  const PaymentScreen({
    Key? key,
    required this.storeId,
    required this.plan,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _apiService = ApiService();
  late Razorpay _razorpay;
  bool _processing = false;
  int? _subscriptionId;
  String _selectedMethod = 'google_play'; // Default to Google Play to follow app store policy

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final iapService = Provider.of<IapService>(context, listen: false);
        iapService.addListener(_onIapChanged);
        
        final productId = 'linkkart_${widget.plan.slug}_monthly';
        iapService.loadProducts([productId]);
      } catch (e) {
        debugPrint('Error initializing Google Play Billing: $e');
      }
    });
  }

  void _onIapChanged() async {
    if (!mounted) return;
    final iapService = Provider.of<IapService>(context, listen: false);
    
    if (iapService.error != null) {
      setState(() => _processing = false);
      _showError(iapService.error!);
      iapService.clearError();
    }
    
    // Check if the plan is now active locally
    final currentPlan = await SubscriptionService().getCurrentPlan();
    if (currentPlan['slug'] == widget.plan.slug && currentPlan['status'] == 'active') {
      if (mounted) {
        setState(() => _processing = false);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription activated successfully via Google Play!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    try {
      final iapService = Provider.of<IapService>(context, listen: false);
      iapService.removeListener(_onIapChanged);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'CHECKOUT',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Summary Section
            Text(
              'ORDER SUMMARY',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.all(Radius.circular(16)),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          color: AppColors.secondary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.plan.name.toUpperCase(),
                              style: GoogleFonts.playfairDisplay(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              'MONTHLY SUBSCRIPTION',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: AppColors.border, thickness: 1),
                  const SizedBox(height: 32),

                  // Features
                  ...widget.plan.features.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(
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
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Price Breakdown
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.all(Radius.circular(16)),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SUBTOTAL',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        '₹${widget.plan.price.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '₹${widget.plan.price.toStringAsFixed(0)}',
                        style: GoogleFonts.playfairDisplay(
                          color: AppColors.secondary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Payment Method Section
            Text(
              'PAYMENT METHOD',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            
            // Google Play Option
            GestureDetector(
              onTap: () => setState(() => _selectedMethod = 'google_play'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  border: Border.all(
                    color: _selectedMethod == 'google_play' ? AppColors.secondary : AppColors.border,
                    width: _selectedMethod == 'google_play' ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedMethod == 'google_play' ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: _selectedMethod == 'google_play' ? AppColors.secondary : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Play Billing',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'One-tap secure purchase via Google Account',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Razorpay Option
            GestureDetector(
              onTap: () => setState(() => _selectedMethod = 'razorpay'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  border: Border.all(
                    color: _selectedMethod == 'razorpay' ? AppColors.secondary : AppColors.border,
                    width: _selectedMethod == 'razorpay' ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedMethod == 'razorpay' ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: _selectedMethod == 'razorpay' ? AppColors.secondary : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.payment_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Razorpay',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'UPI, Cards, Netbanking & Wallets',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Trial Info
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '14 DAYS LUXURY TRIAL',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Experience full premium features. You won\'t be charged during the trial period.',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _processing ? null : _startPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  elevation: 0,
                ),
                child: _processing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'START FREE TRIAL',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Terms
            Text(
              'BY CONTINUING, YOU AGREE TO OUR TERMS OF SERVICE AND PRIVACY POLICY. CANCEL ANYTIME DURING TRIAL.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startPayment() async {
    if (widget.storeId <= 0) {
      _showError('Invalid store selected.');
      return;
    }
    if (widget.plan.price <= 0) {
      _showError('Please choose a paid plan for payment.');
      return;
    }

    if (_selectedMethod == 'google_play') {
      await _startGooglePlayPayment();
    } else {
      await _startRazorpayPayment();
    }
  }

  Future<void> _startGooglePlayPayment() async {
    setState(() => _processing = true);
    try {
      final iapService = Provider.of<IapService>(context, listen: false);
      if (!iapService.isAvailable) {
        throw Exception('Google Play Billing is not available on this device');
      }

      final productId = 'linkkart_${widget.plan.slug}_monthly';
      
      // Look for Google Play product
      final product = iapService.products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product details for ${widget.plan.name} plan could not be loaded from Google Play Store.'),
      );

      // Save the store ID locally before purchase so the verification callback has access to it
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.subscriptionStoreIdKey, widget.storeId);

      await iapService.buySubscription(product);
    } catch (e) {
      setState(() => _processing = false);
      _showError(e.toString());
    }
  }

  Future<void> _startRazorpayPayment() async {
    try {
      setState(() => _processing = true);

      // Step 1: Create subscription
      final subscription =
          await _apiService.createSubscription(widget.storeId, widget.plan.id);
      _subscriptionId = int.tryParse('${subscription['subscription_id']}');
      if (_subscriptionId == null) {
        throw Exception('Invalid subscription response');
      }

      // Step 2: Create payment order
      final totalAmount = widget.plan.price.toDouble(); // NO GST
      final orderData = await _apiService.createPaymentOrder(
        _subscriptionId!,
        totalAmount,
      );

      // Step 3: Open Razorpay
      var options = {
        'key': orderData['key_id'],
        'amount': (totalAmount * 100).toInt(), // Amount in paise
        'currency': 'INR',
        'name': 'LinkKart',
        'description': '${widget.plan.name} Plan Subscription',
        'order_id': orderData['razorpay_order_id'],
        'prefill': {
          'contact': '', // Add user phone if available
          'email': '', // Add user email if available
        },
        'theme': {
          'color': '#000000',
        },
      };

      _razorpay.open(options);
    } catch (e) {
      setState(() => _processing = false);
      _showError('Failed to start payment: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      if (response.orderId == null ||
          response.paymentId == null ||
          response.signature == null) {
        throw Exception('Payment response is incomplete');
      }

      // Verify payment with backend
      await _apiService.verifyPayment(
        response.orderId!,
        response.paymentId!,
        response.signature!,
      );

      await SubscriptionService().activatePlan(
        storeId: widget.storeId,
        plan: widget.plan,
        status: 'active',
      );
      if (!mounted) return;
      setState(() => _processing = false);

      // Show success and go back
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Subscription activated.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      _showError('Payment verification failed: $e');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _processing = false);
    _showError('Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    setState(() => _processing = false);
    _showError('External wallet selected: ${response.walletName}');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
