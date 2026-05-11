import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../providers/store_provider.dart';
import '../utils/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({Key? key}) : super(key: key);

  @override
  _OrdersTabState createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<OrderModel> _orders = [];
  String _selectedStatus = 'all'; // all, pending, completed, cancelled

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final storeId = Provider.of<StoreProvider>(context, listen: false).currentStore?.id;
      if (storeId != null) {
        final orders = await _apiService.getOrders(storeId);
        setState(() => _orders = orders);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    try {
      await _apiService.updateOrderStatus(orderId, newStatus);
      _fetchOrders(); // Refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  void _openWhatsApp(String phone, String name, String productName) async {
    final message = 'Hi $name, regarding your order for $productName...';
    final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _selectedStatus == 'all'
        ? _orders
        : _orders.where((o) => o.status == _selectedStatus).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Orders',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSegmentedControl(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchOrders,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(filteredOrders[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusChip('All', 'all'),
            SizedBox(width: 8),
            _buildStatusChip('Pending', 'pending'),
            SizedBox(width: 8),
            _buildStatusChip('Completed', 'completed'),
            SizedBox(width: 8),
            _buildStatusChip('Cancelled', 'cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedStatus = value),
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary.withOpacity(0.1),
      labelStyle: GoogleFonts.inter(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, size: 72, color: AppColors.textTertiary),
            SizedBox(height: 14),
            Text(
              'No Orders Found',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8),
            Text(
              'When customers place orders, they will appear here.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    Color statusColor;
    switch (order.status) {
      case 'completed': statusColor = AppColors.success; break;
      case 'cancelled': statusColor = AppColors.error; break;
      default: statusColor = AppColors.warning;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
,
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          
          // Customer Info
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    order.customerName.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.customerName, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      Text(order.customerPhone, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.success),
                  onPressed: () => _openWhatsApp(order.customerPhone, order.customerName, order.productName),
                  tooltip: 'Chat on WhatsApp',
                )
              ],
            ),
          ),
          
          // Product Info
          Container(
            color: AppColors.background,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
,
                    border: Border.all(color: AppColors.border),
                    image: order.productImage != null && order.productImage!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(
                              order.productImage!.startsWith('http') 
                                ? order.productImage! 
                                : '${AppConstants.baseUrl.replaceAll('/api/v1', '')}${order.productImage}'
                            ), 
                            fit: BoxFit.cover
                          )
                        : null,
                  ),
                  child: order.productImage == null || order.productImage!.isEmpty
                      ? Icon(Icons.inventory_2_outlined, color: AppColors.textTertiary)
                      : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.productName, style: GoogleFonts.inter(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4),
                      Text('Qty: ${order.quantity}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Text(
                  '₹${order.totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                ),
              ],
            ),
          ),
          
          // Actions
          if (order.status == 'pending')
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(order.id, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(order.id, 'completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Mark Complete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
