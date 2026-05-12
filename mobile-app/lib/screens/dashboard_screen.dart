import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../providers/store_provider.dart';
import '../providers/product_provider.dart';
import '../utils/theme.dart';
import 'add_product_screen.dart';
import 'product_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto-refresh every 10 seconds for dashboard stats
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    await storeProvider.refreshStore();
    if (storeProvider.currentStore != null) {
      await productProvider.loadProducts(storeProvider.currentStore!.id);
      await storeProvider.loadStatistics();
    }
  }

  void _copyStoreLink(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Store link copied to clipboard!'),
        backgroundColor: AppTheme.successColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareStore(String url, String storeName) {
    Share.share(
      'Check out my store "$storeName" on LinkKart!\n\n$url',
      subject: 'Visit my store on LinkKart',
    );
  }

  Future<void> _openStoreLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: const [
                  Icon(Icons.autorenew, size: 16, color: AppTheme.successColor),
                  SizedBox(width: 4),
                  Text(
                    'Auto',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer2<StoreProvider, ProductProvider>(
        builder: (context, storeProvider, productProvider, child) {
          final store = storeProvider.currentStore;
          
          if (store == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Store Info Card
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: AppTheme.elevatedShadow,
                    ),
                    child: Column(
                      children: [
                        if (store.logo != null)
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                              image: DecorationImage(
                                image: NetworkImage(store.logo!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            ),
                            child: const Icon(
                              Icons.store_rounded,
                              size: 40,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        const SizedBox(height: AppTheme.spacing16),
                        Text(
                          store.name,
                          style: AppTheme.heading2.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          store.phone,
                          style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Products',
                          '${productProvider.productCount}',
                          Icons.inventory_2_rounded,
                          AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing16),
                      Expanded(
                        child: _buildStatCard(
                          'Views',
                          '${store.viewCount}',
                          Icons.visibility_rounded,
                          AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: AppTheme.heading3,
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  _buildActionButton(
                    'Add Product',
                    Icons.add_shopping_cart_rounded,
                    AppTheme.primaryColor,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddProductScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing12),

                  _buildActionButton(
                    'View Products',
                    Icons.list_rounded,
                    AppTheme.secondaryColor,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductListScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing12),

                  _buildActionButton(
                    'View Store',
                    Icons.open_in_new_rounded,
                    AppTheme.successColor,
                    () => _openStoreLink(store.storeUrl),
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Share Section
                  const Text(
                    'Share Your Store',
                    style: AppTheme.heading3,
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                store.storeUrl,
                                style: AppTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded),
                              onPressed: () => _copyStoreLink(store.storeUrl),
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing12),
                        ElevatedButton.icon(
                          onPressed: () => _shareStore(store.storeUrl, store.name),
                          icon: const Icon(Icons.share_rounded),
                          label: const Text('Share on WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: AppTheme.heading2.copyWith(color: color),
          ),
          Text(
            label,
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Text(
                label,
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.lightText),
          ],
        ),
      ),
    );
  }
}
