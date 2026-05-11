import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/store_provider.dart';
import '../services/api_service.dart';
import '../models/order_model.dart';
import 'orders_tab.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<OrderModel> _pendingOrders = [];
  List<OrderModel> _recentOrders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      final storeId = storeProvider.currentStore?.id;
      if (storeId == null) throw Exception('No store found');

      final apiService = ApiService();
      final orders = await apiService.getOrders(storeId);

      // Sort by most recent first
      orders.sort((a, b) => b.id.compareTo(a.id));

      setState(() {
        _pendingOrders = orders.where((o) => o.status == 'pending').toList();
        _recentOrders = orders.where((o) => o.status != 'pending').take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadNotifications,
          ),
          SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? _buildSkeleton()
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: AppColors.primary,
                  child: _buildContent(),
                ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: 4,
      itemBuilder: (_, __) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
,
      ),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(16),
)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 160, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
                SizedBox(height: 8),
                Container(height: 12, width: 100, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 60),
          SizedBox(height: 16),
          Text('Could not load notifications', style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary)),
          SizedBox(height: 16),
          ElevatedButton(onPressed: _loadNotifications, child: Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_pendingOrders.isEmpty && _recentOrders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        if (_pendingOrders.isNotEmpty) ...[
          _buildSectionHeader(
            'New Orders',
            '${_pendingOrders.length} requiring attention',
            AppColors.error,
          ),
          SizedBox(height: 12),
          ..._pendingOrders.map((order) => _buildNotificationCard(order, isPending: true)),
          SizedBox(height: 24),
        ],
        if (_recentOrders.isNotEmpty) ...[
          _buildSectionHeader(
            'Recent Activity',
            'Last updated orders',
            AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          ..._recentOrders.map((order) => _buildNotificationCard(order, isPending: false)),
        ],
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
,
                ),
                child: Icon(Icons.notifications_none_rounded, size: 52, color: AppColors.primary),
              ),
              SizedBox(height: 24),
              Text(
                'All Caught Up!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'You have no pending orders.\nNew notifications will appear here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationCard(OrderModel order, {required bool isPending}) {
    final Color accentColor = isPending ? AppColors.warning : AppColors.success;
    final IconData icon = isPending ? Icons.shopping_bag_rounded : Icons.check_circle_rounded;
    final String timeAgo = _formatTimeAgo(order.id);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        // Navigate back to orders tab
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OrdersTab()),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
,
          border: Border.all(
            color: isPending ? AppColors.warning.withOpacity(0.3) : AppColors.border,
            width: isPending ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
,
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isPending ? '🛒 New Order #${order.id}' : '✅ Order #${order.id} ${order.status}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPending) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
,
                          ),
                          child: Text(
                            'NEW',
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${order.customerName}  •  ${order.productName}',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${order.totalPrice.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isPending ? AppColors.warning : AppColors.success,
                        ),
                      ),
                      Text(
                        isPending ? 'Tap to manage' : 'Qty: ${order.quantity}',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(int orderId) {
    // Simple relative time based on order id
    return 'Order #$orderId';
  }
}
