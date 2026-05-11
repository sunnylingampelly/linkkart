import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import '../models/customer_model.dart';
import '../services/api_service.dart';
import '../providers/store_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomersTab extends StatefulWidget {
  const CustomersTab({Key? key}) : super(key: key);

  @override
  _CustomersTabState createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<CustomerModel> _customers = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() => _isLoading = true);
    try {
      final storeId = Provider.of<StoreProvider>(context, listen: false).currentStore?.id;
      if (storeId != null) {
        final customers = await _apiService.getCustomers(storeId);
        setState(() => _customers = customers);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load customers: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openWhatsApp(String phone, String name) async {
    final message = 'Hi $name, from our store...';
    final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _callPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Customers',
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
            onPressed: _fetchCustomers,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _customers.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchCustomers,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _customers.length,
                    itemBuilder: (context, index) {
                      return _buildCustomerCard(_customers[index]);
                    },
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
            Icon(Icons.people_outline_rounded, size: 72, color: AppColors.textTertiary),
            SizedBox(height: 14),
            Text(
              'No Customers Yet',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8),
            Text(
              'Customer details will appear after orders start coming in.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
,
              ),
              child: Center(
                child: Text(
                  customer.name.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${customer.totalOrders} Orders • ₹${customer.totalSpent.toStringAsFixed(2)} Spent',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  if (customer.address != null && customer.address!.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      customer.address!,
                      style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.phone_outlined, color: AppColors.primary),
                  onPressed: () => _callPhone(customer.phone),
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.all(8),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.success, size: 20),
                  onPressed: () => _openWhatsApp(customer.phone, customer.name),
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.all(8),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
