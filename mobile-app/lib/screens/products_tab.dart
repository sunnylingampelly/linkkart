import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../providers/store_provider.dart';
import '../providers/product_provider.dart';
import 'add_product_screen_premium.dart';
import 'edit_product_screen.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({Key? key}) : super(key: key);

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  String _resolveImageUrl(String imagePath) {
    return AppConstants.getImageUrl(imagePath);
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (storeProvider.currentStore != null) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      await productProvider.loadProducts(storeProvider.currentStore!.id);
    }
  }

  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreenPremium()),
    );
    
    if (result == true) {
      // Refresh products list
      _loadProducts();
      // Refresh store stats
      if (mounted) {
        Provider.of<StoreProvider>(context, listen: false).loadStatistics();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Products',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (productProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: AppColors.error),
                  SizedBox(height: 16),
                  Text(
                    'Error loading products',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    productProvider.error!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadProducts,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (productProvider.products.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadProducts,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_rounded,
                        size: 80,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No Products Yet',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add your first product to get started',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _navigateToAddProduct,
                        icon: Icon(Icons.add_rounded),
                        label: Text('Add Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadProducts,
            color: AppColors.primary,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              itemCount: productProvider.products.length,
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      // Product Image
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
,
                        ),
                        child: product.image != null && product.image!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
,
                                child: Image.network(
                                  product.image!.startsWith('http')
                                      ? product.image!
                                      : _resolveImageUrl(product.image!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_rounded,
                                      color: AppColors.primary,
                                      size: 32,
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.image_rounded,
                                color: AppColors.primary,
                                size: 32,
                              ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '₹${product.price.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            if (product.description != null) ...[
                              SizedBox(height: 4),
                              Text(
                                product.description!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: product.stockQuantity > 0 
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inventory_rounded,
                                    size: 14,
                                    color: product.stockQuantity > 0 
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Stock: ${product.stockQuantity}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: product.stockQuantity > 0 
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_rounded, color: AppColors.primary),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProductScreen(product: product),
                            ),
                          );
                          
                          if (result == true) {
                            _loadProducts();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_rounded, color: AppColors.error),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
),
                              title: Row(
                                children: [
                                  Icon(Icons.warning_rounded, color: AppColors.error),
                                  SizedBox(width: 12),
                                  Text('Delete Product'),
                                ],
                              ),
                              content: Text(
                                'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                  ),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            // Show loading
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Deleting product...'),
                                    ],
                                  ),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: AppColors.textSecondary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }

                            await productProvider.deleteProduct(product.id);
                            
                            if (context.mounted) {
                              if (productProvider.error == null) {
                                // Refresh store stats after deletion
                                Provider.of<StoreProvider>(context, listen: false).loadStatistics();
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.white),
                                        SizedBox(width: 12),
                                        Text('Product deleted successfully'),
                                      ],
                                    ),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.error, color: Colors.white),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Failed to delete: ${productProvider.error}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 4),
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
),
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add_rounded),
        label: Text('Add Product'),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
),
      ),
    );
  }
}

