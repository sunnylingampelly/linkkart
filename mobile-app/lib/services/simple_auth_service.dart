import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'dart:math';

class SimpleAuthService {
  static final SimpleAuthService _instance = SimpleAuthService._internal();
  factory SimpleAuthService() => _instance;
  SimpleAuthService._internal();

  String? _verificationId;
  String? _sentOTP;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Send OTP to phone number (simulated for now)
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      // Generate random 6-digit OTP
      final random = Random();
      _sentOTP = (100000 + random.nextInt(900000)).toString();
      _verificationId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // In production, this would send SMS via Firebase
      // For now, we'll just print it (you can see it in logs)
      print('📱 OTP for $phoneNumber: $_sentOTP');
      
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));
      
      onCodeSent(_verificationId!);
    } catch (e) {
      onError(e.toString());
    }
  }

  // Verify OTP and sign in
  Future<User?> verifyOTP(String otp) async {
    try {
      if (_verificationId == null) {
        throw Exception('Verification ID not found');
      }

      // For testing: accept any 6-digit code OR the generated OTP
      if (otp.length != 6) {
        throw Exception('Invalid OTP format');
      }

      // In production, Firebase would verify this
      // For now, accept the generated OTP or "123456" for testing
      if (otp != _sentOTP && otp != '123456') {
        throw Exception('Invalid OTP code');
      }

      // Create user
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        phoneNumber: 'user_phone', // Would come from phone input
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Save to local storage
      await _saveUserToLocal(_currentUser!);
      return _currentUser;
    } catch (e) {
      throw Exception('Invalid OTP: ${e.toString()}');
    }
  }

  // Load user from local storage
  Future<User?> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final phoneNumber = prefs.getString('user_phone');
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');
      final createdAtStr = prefs.getString('user_created_at');

      if (userId != null && phoneNumber != null) {
        _currentUser = User(
          id: userId,
          phoneNumber: phoneNumber,
          name: name,
          email: email,
          createdAt: createdAtStr != null 
              ? DateTime.parse(createdAtStr) 
              : DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        return _currentUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Save user to local storage
  Future<void> _saveUserToLocal(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_phone', user.phoneNumber);
    if (user.name != null) await prefs.setString('user_name', user.name!);
    if (user.email != null) await prefs.setString('user_email', user.email!);
    await prefs.setString('user_created_at', user.createdAt.toIso8601String());
  }

  // Update user profile
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      email: email ?? _currentUser!.email,
    );

    await _saveUserToLocal(_currentUser!);
  }

  // Sign out
  Future<void> signOut() async {
    _currentUser = null;
    _verificationId = null;
    _sentOTP = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_phone');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_created_at');
  }

  // Check if user has store
  Future<bool> hasStore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('store_id');
  }
}
