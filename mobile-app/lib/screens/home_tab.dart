import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/store_provider.dart';
import 'notifications_screen.dart';
import '../providers/product_provider.dart';
import '../services/subscription_service.dart';
import 'add_product_screen_premium.dart';
import 'pricing_screen.dart';
import 'qr_code_screen.dart';

class HomeTab extends StatefulWidget {
  final Function(int)? onTabChange;
  
  const HomeTab({Key? key, this.onTabChange}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _planName = 'Basic';
  String _planStatus = 'trial';

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (storeProvider.currentStore != null) {
      await storeProvider.loadStatistics();
    }
    await _loadPlanData();
  }

  Future<void> _loadPlanData() async {
    final planData = await SubscriptionService().getCurrentPlan();
    if (!mounted) return;
    setState(() {
      _planName = planData['name'] as String? ?? 'Basic';
      _planStatus = planData['status'] as String? ?? 'trial';
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final store = storeProvider.currentStore;
    final stats = storeProvider.statistics;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStoreData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Luxury Header
                _buildHeader(store?.name ?? 'My Luxury Store', stats),
                
                // Revenue Card (The "Black Card")
                _buildRevenueCard(stats?['total_revenue']?.toString() ?? '0.00'),
                
                SizedBox(height: 24),
                
                // Quick Actions (Horizontal Pill Menu)
                _buildQuickActions(),

                SizedBox(height: 32),

                // Metrics Carousel
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Business Overview',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                _buildMetricsGrid(stats),

                SizedBox(height: 32),
                
                // Plan Info
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _buildPlanCard(store?.id),
                ),
                
                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String storeName, Map<String, dynamic>? stats) {
    final int pendingOrders = stats?['pending_orders'] ?? 0;
    
    return Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  storeName,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationsScreen()),
              );
            },
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.all(Radius.circular(16)),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  if (pendingOrders > 0)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(String revenue) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F0F0F), Color(0xFF222222)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Revenue',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFD4AF37).withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Color(0xFFD4AF37), size: 14),
                    SizedBox(width: 4),
                    Text(
                      '+12.5%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 16),
          Text(
            '₹${double.tryParse(revenue)?.toStringAsFixed(2) ?? revenue}',
            style: GoogleFonts.playfairDisplay(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          Text(
            '**** **** **** 8821', // Just a mock card number aesthetic
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 3,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildActionPill(
            icon: Icons.add_rounded,
            label: 'Add Product',
            color: Color(0xFFD4AF37), // Gold
            onTap: () async {
              HapticFeedback.mediumImpact();
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductScreenPremium()),
              );
              if (result == true) {
                _loadStoreData();
                final storeProvider = Provider.of<StoreProvider>(context, listen: false);
                if (storeProvider.currentStore != null) {
                  Provider.of<ProductProvider>(context, listen: false)
                      .loadProducts(storeProvider.currentStore!.id);
                }
              }
            },
          ),
          SizedBox(width: 12),
          _buildActionPill(
            icon: Icons.receipt_long_rounded,
            label: 'View Orders',
            color: AppColors.primary,
            onTap: () {
              HapticFeedback.mediumImpact();
              if (widget.onTabChange != null) widget.onTabChange!(2); // Go to orders tab
            },
          ),
          SizedBox(width: 12),
          _buildActionPill(
            icon: Icons.qr_code_rounded,
            label: 'Share Store',
            color: AppColors.secondary,
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRCodeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionPill({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic>? stats) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildMetricCard('Orders', stats?['total_orders']?.toString() ?? '0', '+4.2%', true)),
              SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Products', stats?['total_products']?.toString() ?? '0', '0.0%', true)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Store Views', stats?['total_views']?.toString() ?? '0', '+22.4%', true)),
              SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Link Clicks', stats?['total_clicks']?.toString() ?? '0', '-1.2%', false)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String trend, bool isPositive) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: isPositive ? AppColors.success : AppColors.error,
              ),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  trend,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? AppColors.success : AppColors.error,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                ' /wk',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPlanCard(int? storeId) {
    final isTrial = _planStatus == 'trial';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF9F7F1), // Very light gold/warm white
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: Color(0xFFE5D5A4)), // Gold border
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFD4AF37).withOpacity(0.2),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFD4AF37),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan: $_planName',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isTrial ? 'Free trial active. Upgrade for more.' : 'Your luxury plan is active.',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (storeId != null)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PricingScreen(storeId: storeId)),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFD4AF37),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)),),
              ),
              child: Text(
                'Upgrade',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
