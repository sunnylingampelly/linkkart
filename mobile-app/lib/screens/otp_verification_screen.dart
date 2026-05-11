import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/firebase_auth_service.dart';
import '../providers/store_provider.dart';
import 'create_store_screen.dart';
import 'main_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OTPVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  final _authService = FirebaseAuthService();
  bool _isLoading = false;
  String _currentOTP = '';
  String? _verificationId;
  int _secondsRemaining = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsRemaining = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String _formatTimer(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _verifyOTP() async {
    if (_currentOTP.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter complete OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.verifyOTP(
        otp: _currentOTP,
        verificationId: _verificationId,
      );
      
      if (user != null) {
        final storeProvider = Provider.of<StoreProvider>(context, listen: false);
        
        // Show a message that we're checking for existing store
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Done! Checking for your store...'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        final hasStore = await storeProvider.checkExistingStore(widget.phoneNumber);
        
        if (!mounted) return;
        
        if (hasStore) {
          // Found an existing store, bypass creation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back! Found store: ${storeProvider.currentStore?.name}'),
              backgroundColor: AppColors.success,
            ),
          );
          
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        } else {
          // No store found, go to creation
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CreateStoreScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              
              // Title
              Text(
                'CONFIRM',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 4,
                ),
              ),
              
              SizedBox(height: 10),
              
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(text: 'Code sent to '),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code we sent',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 40),
              
              // OTP Input - Full Width Boxes
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                backgroundColor: Colors.transparent,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 48,
                  activeFillColor: Colors.transparent,
                  inactiveFillColor: Colors.transparent,
                  selectedFillColor: Colors.transparent,
                  activeColor: AppColors.primary,
                  inactiveColor: Colors.black.withOpacity(0.2),
                  selectedColor: AppColors.primary,
                  borderWidth: 2.0,
                ),
                cursorColor: AppColors.secondary,
                enableActiveFill: false,
                textStyle: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                onChanged: (value) {
                  setState(() => _currentOTP = value);
                },
                onCompleted: (value) {
                  _verifyOTP();
                },
              ),
              
              SizedBox(height: 32),
              
              // Resend Code
              Center(
                child: Column(
                  children: [
                    Text(
                      _secondsRemaining > 0
                          ? 'Resend in ${_formatTimer(_secondsRemaining)}'
                          : 'Didn\'t receive code?',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: (_isLoading || _secondsRemaining > 0)
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              final ok = await _authService.resendOTP(
                                phoneNumber: widget.phoneNumber,
                                onCodeSent: (verificationId) {
                                  _verificationId = verificationId;
                                },
                                onError: (error) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                },
                              );
                              if (!mounted) return;
                              setState(() => _isLoading = false);
                              if (ok) {
                                _startResendTimer();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('OTP resent successfully'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                      child: Text(
                        'Resend OTP',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _secondsRemaining > 0
                              ? AppColors.textTertiary
                              : AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 48),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Verify & Continue',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
