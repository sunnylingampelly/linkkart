import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/store_provider.dart';
import '../services/api_service.dart';
import '../models/order_model.dart';
import '../models/product.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;
  List<OrderModel> _orders = [];
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    
    try {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      final storeId = storeProvider.currentStore?.id;
      if (storeId == null) throw Exception('No store found. Please log in again.');

      final apiService = ApiService();
      
      // Load stats first as it's the most important
      try {
        _stats = await apiService.getStoreStatistics(storeId);
      } catch (e) {
        debugPrint('Analytics stats error: $e');
      }
      
      // Load orders
      try {
        _orders = await apiService.getOrders(storeId);
      } catch (e) {
        debugPrint('Analytics orders error: $e');
      }
      
      // Load products
      try {
        _products = await apiService.getProducts(storeId);
      } catch (e) {
        debugPrint('Analytics products error: $e');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          // Only show error if we have NO data at all
          if (_stats == null && _orders.isEmpty && _products.isEmpty) {
            _error = "Could not retrieve analytics data. Please check your connection.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { 
          _error = e.toString().replaceAll('Exception: ', ''); 
          _isLoading = false; 
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analytics',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.secondary),
            onPressed: _load,
          ),
          SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, color: AppColors.error, size: 60),
                      SizedBox(height: 16),
                      Text('Could not load analytics', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                      SizedBox(height: 16),
                      ElevatedButton(onPressed: _load, child: Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: _buildContent(),
                ),
    );
  }

  Widget _buildContent() {
    final totalRevenue = (_stats?['total_revenue'] ?? 0.0).toDouble();
    final totalOrders = (_stats?['total_orders'] ?? 0) as int;
    final pendingOrders = (_stats?['pending_orders'] ?? 0) as int;
    final totalViews = (_stats?['total_views'] ?? 0) as int;
    final totalProducts = (_stats?['total_products'] ?? 0) as int;
    final totalClicks = (_stats?['total_clicks'] ?? 0) as int;

    final completedOrders = _orders.where((o) => o.status == 'completed').length;
    final cancelledOrders = _orders.where((o) => o.status == 'cancelled').length;

    // Top products by click
    final sortedProducts = List<Product>.from(_products)
      ..sort((a, b) => b.clickCount.compareTo(a.clickCount));
    final topProducts = sortedProducts.take(5).toList();

    // Conversion: clicks → orders
    final conversionRate = totalClicks > 0 ? (totalOrders / totalClicks * 100) : 0.0;

    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        // Revenue header card
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Revenue', style: GoogleFonts.inter(fontSize: 13, color: Colors.white54, letterSpacing: 1)),
              SizedBox(height: 8),
              Text(
                '₹${totalRevenue.toStringAsFixed(2)}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.secondary,
                ),
              ),
              SizedBox(height: 16),
              Divider(color: Colors.white24),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat('Completed', '$completedOrders', Color(0xFF10B981)),
                  _buildMiniStat('Pending', '$pendingOrders', Color(0xFFF59E0B)),
                  _buildMiniStat('Cancelled', '$cancelledOrders', Color(0xFFEF4444)),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Stats grid
        _buildSectionLabel('Store Overview'),
        SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1, // Increased height to prevent bottom overflow (was 1.5)
          children: [
            _buildStatCard('👁️ Total Views', '$totalViews', AppColors.secondary, '+Store visits'),
            _buildStatCard('🛒 Total Orders', '$totalOrders', AppColors.secondary, 'All time'),
            _buildStatCard('🔗 Link Clicks', '$totalClicks', AppColors.secondary, 'Product taps'),
            _buildStatCard(
              '📊 Conversion',
              '${conversionRate.toStringAsFixed(1)}%',
              AppColors.accent,
              'Clicks → Orders',
            ),
          ],
        ),

        SizedBox(height: 28),

        // Order status breakdown
        _buildSectionLabel('Order Breakdown'),
        SizedBox(height: 12),
        _buildOrderBreakdown(completedOrders, pendingOrders, cancelledOrders, totalOrders),

        SizedBox(height: 28),

        // Top products
        if (topProducts.isNotEmpty) ...[
          _buildSectionLabel('Top Products by Clicks'),
          SizedBox(height: 12),
          ...topProducts.asMap().entries.map((entry) {
            final idx = entry.key;
            final product = entry.value;
            final clicks = product.clickCount;
            final maxClicks = topProducts.first.clickCount == 0 ? 1 : topProducts.first.clickCount;
            final ratio = maxClicks > 0 ? clicks / maxClicks : 0.0;

            return _buildProductRankCard(idx + 1, product, clicks, ratio);
          }).toList(),
        ],

        SizedBox(height: 28),

        // Products summary
        _buildSectionLabel('Products Summary'),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(child: _buildMiniStatLight('Total Products', '$totalProducts', AppColors.secondary)),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(child: _buildMiniStatLight('Total Clicks', '$totalClicks', AppColors.secondary)),
            ],
          ),
        ),

        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
      ],
    );
  }

  Widget _buildMiniStatLight(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, String subtitle) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(title, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          ),
          SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ),
          SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBreakdown(int completed, int pending, int cancelled, int total) {
    if (total == 0) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text('No orders yet', style: GoogleFonts.inter(color: AppColors.textTertiary)),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildBreakdownRow('Completed', completed, total, AppColors.success),
          SizedBox(height: 12),
          _buildBreakdownRow('Pending', pending, total, AppColors.warning),
          SizedBox(height: 12),
          _buildBreakdownRow('Cancelled', cancelled, total, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int count, int total, Color color) {
    final ratio = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        SizedBox(width: 12),
        SizedBox(
          width: 36,
          child: Text(
            '$count',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildProductRankCard(int rank, Product product, int clicks, double ratio) {
    final medals = ['🥇', '🥈', '🥉'];
    final medal = rank <= 3 ? medals[rank - 1] : '$rank.';

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
,
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Text(medal, style: TextStyle(fontSize: 20)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
,
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: AppColors.secondary.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Column(
            children: [
              Text(
                '$clicks',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondary),
              ),
              Text('clicks', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }
}
