import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../utils/network_helper.dart';

class ConnectionCheckScreen extends StatefulWidget {
  final VoidCallback onConnected;

  const ConnectionCheckScreen({
    Key? key,
    required this.onConnected,
  }) : super(key: key);

  @override
  State<ConnectionCheckScreen> createState() => _ConnectionCheckScreenState();
}

class _ConnectionCheckScreenState extends State<ConnectionCheckScreen> {
  bool _isChecking = true;
  String _status = 'Checking connection...';
  String? _workingUrl;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
      _status = 'Finding backend server...';
    });

    try {
      // Find working URL
      final workingUrl = await NetworkHelper.getWorkingBaseUrl();
      final isReachable = await NetworkHelper.isBackendReachable();

      if (isReachable) {
        setState(() {
          _workingUrl = workingUrl;
          _status = '✅ Connected successfully!';
          _isChecking = false;
        });

        // Wait a moment then proceed
        await Future.delayed(const Duration(seconds: 1));
        widget.onConnected();
      } else {
        setState(() {
          _status = '❌ Cannot reach backend server';
          _isChecking = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Connection error: $e';
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _isChecking
                      ? AppColors.primary.withOpacity(0.1)
                      : _workingUrl != null
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isChecking
                      ? Icons.wifi_find
                      : _workingUrl != null
                          ? Icons.check_circle
                          : Icons.error,
                  size: 60,
                  color: _isChecking
                      ? AppColors.primary
                      : _workingUrl != null
                          ? AppColors.success
                          : AppColors.error,
                ),
              ),

              const SizedBox(height: 32),

              // Status
              Text(
                _status,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              if (_workingUrl != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Connected to:',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _workingUrl!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              if (_isChecking) ...[
                const SizedBox(height: 32),
                const CircularProgressIndicator(),
              ],

              if (!_isChecking && _workingUrl == null) ...[
                const SizedBox(height: 32),
                
                // Troubleshooting info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Troubleshooting',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Make sure backend is running\n'
                        '2. Check if phone and computer are on same WiFi\n'
                        '3. Try restarting the backend server\n'
                        '4. Check firewall settings',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Retry button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _checkConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Retry Connection',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Skip button (for testing)
                TextButton(
                  onPressed: widget.onConnected,
                  child: Text(
                    'Skip (Continue Anyway)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
