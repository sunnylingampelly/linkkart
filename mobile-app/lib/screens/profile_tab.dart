import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/app_colors.dart';
import '../providers/store_provider.dart';
import '../services/firebase_auth_service.dart';
import '../services/subscription_service.dart';
import 'pricing_screen.dart';
import 'qr_code_screen.dart';
import 'welcome_screen.dart';
import 'store_settings_screen.dart';
import 'analytics_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final store = storeProvider.currentStore;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        border: Border.all(color: AppColors.secondary, width: 2),
                      ),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16)),

                        ),
                        child: Icon(
                          Icons.store_rounded,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      store?.name ?? 'My Store',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      store?.phone ?? '+91 9876543210',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Menu Items
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context: context,
                      icon: Icons.store_rounded,
                      title: 'Store Settings',
                      subtitle: 'Edit store details',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => StoreSettingsScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.qr_code_rounded,
                      title: 'My QR Code',
                      subtitle: 'Share your store',
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QRCodeScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.analytics_rounded,
                      title: 'Analytics',
                      subtitle: 'View detailed reports',
                      color: AppColors.accent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AnalyticsScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.payment_rounded,
                      title: 'Plans & Billing',
                      subtitle: 'Current plan and upgrade options',
                      color: AppColors.accentOrange,
                      onTap: () {
                        if (store != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PricingScreen(storeId: store.id),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Create your store first.'),
                            ),
                          );
                        }
                      },
                    ),
                    FutureBuilder<Map<String, dynamic>>(
                      future: SubscriptionService().getCurrentPlan(),
                      builder: (context, snapshot) {
                        final planName = snapshot.data?['name'] ?? 'Basic';
                        final status = snapshot.data?['status'] ?? 'trial';
                        return _buildPlanInfoCard(planName, status);
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.help_rounded,
                      title: 'Help & Support',
                      subtitle: 'Get help via WhatsApp',
                      color: AppColors.info,
                      onTap: () => _showHelpSupport(context),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      color: AppColors.error,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanInfoCard(String planName, String status) {
    final isTrial = status == 'trial';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Plan: $planName (${isTrial ? 'Trial' : 'Active'})',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.all(Radius.circular(16)),

          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.textTertiary,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  // Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),

          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(16)),

                ),
                child: Icon(Icons.logout_rounded, color: AppColors.error),
              ),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from your account?',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),

                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Perform logout
  Future<void> _performLogout(BuildContext context) async {
    // Get navigator before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16)),

              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Logging out...',
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Logout from auth service
      final authService = FirebaseAuthService();
      await authService.signOut();

      // Logout from store provider
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      await storeProvider.logout();

      // Close loading dialog
      navigator.pop();

      // Navigate to welcome screen and clear stack
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
        (route) => false,
      );

      // Show success message
      Future.delayed(Duration(milliseconds: 500), () {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)),),
          ),
        );
      });
    } catch (e) {
      // Close loading dialog if open
      try {
        navigator.pop();
      } catch (_) {}

      // Show error
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)),),
        ),
      );
    }
  }

  // Show help & support options
  void _showHelpSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),

      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.all(Radius.circular(16)),

                ),
              ),
              SizedBox(height: 24),

              // Title
              Text(
                'Help & Support',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Choose how you want to get help',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24),

              // WhatsApp Support
              _buildSupportOption(
                context: context,
                icon: FontAwesomeIcons.whatsapp,
                title: 'WhatsApp Support',
                subtitle: 'Chat with our support team',
                color: AppColors.success,
                onTap: () async {
                  Navigator.pop(context);
                  final url = Uri.parse('https://wa.me/918639424962?text=Hi, I need help with LinkKart');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),

              SizedBox(height: 12),

              // Email Support
              _buildSupportOption(
                context: context,
                icon: Icons.email_rounded,
                title: 'Email Support',
                subtitle: 'vashynovatechnologies@gmail.com',
                color: AppColors.primary,
                onTap: () async {
                  Navigator.pop(context);
                  final url = Uri.parse('mailto:vashynovatechnologies@gmail.com?subject=LinkKart Support Request');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),

              SizedBox(height: 12),

              // FAQ
              _buildSupportOption(
                context: context,
                icon: Icons.help_outline_rounded,
                title: 'FAQ',
                subtitle: 'Find answers to common questions',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pop(context);
                  _showFAQ(context);
                },
              ),

                SizedBox(height: 8), // Replaced 24 with 8 to let SafeArea handle the bottom spacing
              ],
            ),
          ),
        ));
      },
    );
  }

  Widget _buildSupportOption({
    required BuildContext context,
    required dynamic icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: icon is IconData
                  ? Icon(icon, color: color, size: 20)
                  : FaIcon(icon, color: color, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  // Show FAQ
  void _showFAQ(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),

      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.all(Radius.circular(16)),

                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Title
                  Text(
                    'Frequently Asked Questions',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find answers to common questions',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24),

                  // FAQ List
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildFAQItem(
                          question: 'How do I add products to my store?',
                          answer: 'Tap the "Add Product" button on the home screen or products tab. Fill in the product details, upload up to 5 images, and tap "Add Product" to save.',
                        ),
                        _buildFAQItem(
                          question: 'How do customers order from my store?',
                          answer: 'Share your store QR code or link with customers. When they tap on a product, they can order via WhatsApp directly.',
                        ),
                        _buildFAQItem(
                          question: 'Can I edit product details after adding?',
                          answer: 'Yes! Go to the Products tab, tap the edit icon on any product to update its details, price, or images.',
                        ),
                        _buildFAQItem(
                          question: 'How do I share my store with customers?',
                          answer: 'Go to "My QR Code" from the home screen or profile. You can share the QR code or copy the store link to share on WhatsApp, Instagram, or Facebook.',
                        ),
                        _buildFAQItem(
                          question: 'Is there a limit on products I can add?',
                          answer: 'No! You can add unlimited products to your store. Each product can have up to 5 images.',
                        ),
                        _buildFAQItem(
                          question: 'How do I track my store performance?',
                          answer: 'Check the Analytics section to see total views, clicks, orders, and revenue. You can also see which products are most popular.',
                        ),
                        _buildFAQItem(
                          question: 'Can I customize my store appearance?',
                          answer: 'Your store automatically gets a beautiful, professional design. You can add your store logo and customize product images.',
                        ),
                        _buildFAQItem(
                          question: 'How do I manage stock quantity?',
                          answer: 'When adding or editing a product, enter the stock quantity. The app will show if a product is in stock or out of stock.',
                        ),
                        _buildFAQItem(
                          question: 'What if I need help?',
                          answer: 'Contact us via WhatsApp at +91 8639424962 or email us at vashynovatechnologies@gmail.com. We\'re here to help!',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(16)),

                ),
                child: Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.only(left: 38),
            child: Text(
              answer,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
