import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/api_service.dart';
import '../services/subscription_service.dart';
import '../models/plan.dart';
import '../utils/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
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
                borderRadius: BorderRadius.circular(16),
,
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
                          borderRadius: BorderRadius.circular(16),
,
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
                borderRadius: BorderRadius.circular(16),
,
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

            // Trial Info
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
,
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
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
,
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
