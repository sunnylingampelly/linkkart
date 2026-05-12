import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/store_provider.dart';
import '../utils/app_colors.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({Key? key}) : super(key: key);

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isDownloading = false;

  Future<void> _downloadQRCode(String storeName) async {
    setState(() => _isDownloading = true);
    
    try {
      // Check permissions
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        // For Android 13+, storage permission might return denied but we might still have access or need photos permission
        // image_gallery_saver usually handles the heavy lifting, but we check just in case.
      }

      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      );

      if (imageBytes != null) {
        final result = await ImageGallerySaverPlus.saveImage(
          imageBytes,
          quality: 100,
          name: "QR_${storeName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}",
        );

        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('QR Code saved to gallery!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          throw Exception(result['errorMessage'] ?? 'Failed to save image');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final store = storeProvider.currentStore;

    if (store == null) {
      return Scaffold(
        appBar: AppBar(title: Text('My QR Code')),
        body: Center(child: Text('No store found')),
      );
    }

    final storeUrl = store.storeUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Beautiful App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.all(Radius.circular(16)),

                ),
                child: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Share Your Store',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 72, bottom: 16),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // QR Code Card wrapped in Screenshot
                  Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      padding: EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white, // Solid white for screenshot
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 30,
                            offset: Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Store Logo/Icon
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            ),
                            child: Icon(
                              Icons.store_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Store Name
                          Text(
                            store.name,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: 8),
                          
                          Text(
                            'Scan to visit store',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          
                          SizedBox(height: 32),
                          
                          // QR Code
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: QrImageView(
                              data: storeUrl,
                              version: QrVersions.auto,
                              size: 220,
                              backgroundColor: Colors.white,
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: AppColors.primary,
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Store URL
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            ),
                            child: Text(
                              storeUrl,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Action Buttons
                  _buildActionButton(
                    icon: Icons.share_rounded,
                    label: 'Share Store Link',
                    gradient: AppColors.primaryGradient,
                    onTap: () {
                      Share.share(
                        'Check out my store: ${store.name}\n\n$storeUrl',
                        subject: store.name,
                      );
                      HapticFeedback.mediumImpact();
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  _buildActionButton(
                    icon: Icons.content_copy_rounded,
                    label: 'Copy Store Link',
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                    ),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: storeUrl));
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                'Link copied to clipboard!',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)),),
                          margin: EdgeInsets.all(16),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  _buildActionButton(
                    icon: _isDownloading ? Icons.hourglass_empty_rounded : Icons.download_rounded,
                    label: _isDownloading ? 'Downloading...' : 'Download QR Code',
                    gradient: LinearGradient(
                      colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
                    ),
                    onTap: _isDownloading ? () {} : () => _downloadQRCode(store.name),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Tips Card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_rounded, color: AppColors.info, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Pro Tips',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildTip('Print the QR code and display it in your shop'),
                        _buildTip('Share the link on WhatsApp status'),
                        _buildTip('Post on Instagram and Facebook'),
                        _buildTip('Add to your business card'),
                      ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
