import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  String? _verificationId;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Send OTP to phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      // Check if Firebase is initialized
      try {
        firebase_auth.FirebaseAuth.instance;
      } catch (e) {
        onError('Firebase not initialized. Please check configuration.');
        return;
      }

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _signInWithCredential(credential);
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
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

      firebase_auth.PhoneAuthCredential credential = 
          firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      return await _signInWithCredential(credential);
    } catch (e) {
      throw Exception('Invalid OTP: ${e.toString()}');
    }
  }

  // Sign in with credential
  Future<User?> _signInWithCredential(firebase_auth.PhoneAuthCredential credential) async {
    try {
      firebase_auth.UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        _currentUser = User(
          id: userCredential.user!.uid,
          phoneNumber: userCredential.user!.phoneNumber ?? '',
          createdAt: userCredential.user!.metadata.creationTime ?? DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        // Save to local storage
        await _saveUserToLocal(_currentUser!);
        return _currentUser;
      }
      return null;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
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
    await _firebaseAuth.signOut();
    _currentUser = null;
    _verificationId = null;

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
