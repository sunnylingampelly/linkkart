import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/constants.dart';
import 'api_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _apiService = ApiService();
  String? _verificationId;
  int? _resendToken;

  /// Send OTP to phone number
  Future<bool> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function(PhoneAuthCredential) onAutoVerify,
  }) async {
    try {
      // Format phone number (add +91 if not present)
      String formattedPhone = phoneNumber;
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+91$phoneNumber';
      }

      debugPrint('Sending OTP to: $formattedPhone');

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        
        // Auto-verification (instant verification on some devices)
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('Auto verification completed');
          onAutoVerify(credential);
        },
        
        // Verification failed
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Verification failed: ${e.code} - ${e.message}');
          if (e.code == 'invalid-phone-number') {
            onError('Wrong phone number. Please check and try again.');
          } else if (e.code == 'too-many-requests') {
            onError('Too many tries. Please wait for some time.');
          } else if (e.code == 'network-request-failed') {
            onError('No internet. Please check your connection.');
          } else if (e.code == 'app-not-authorized') {
            onError('App not setup properly. Please contact support.');
          } else {
            onError(e.message ?? 'Cannot send code. Try again.');
          }
        },
        
        // Code sent successfully
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('Code sent successfully');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        
        // Code auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('Auto retrieval timeout');
          _verificationId = verificationId;
        },
        
        forceResendingToken: _resendToken,
      );

      return true;
    } catch (e) {
      debugPrint('Send OTP error: $e');
      onError(e.toString());
      return false;
    }
  }

  /// Verify OTP code
  Future<User?> verifyOTP({
    required String otp,
    String? verificationId,
  }) async {
    try {
      final String vid = verificationId ?? _verificationId ?? '';
      
      if (vid.isEmpty) {
        throw Exception('Verification ID not found. Please resend OTP');
      }

      debugPrint('Verifying OTP: $otp');

      // Create credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: vid,
        smsCode: otp,
      );

      // Sign in with credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      debugPrint('OTP verified successfully');
      
      // Save user data
      await _saveUser(userCredential.user);
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('OTP verification error: ${e.message}');
      if (e.code == 'invalid-verification-code') {
        throw Exception('Invalid OTP code');
      } else if (e.code == 'session-expired') {
        throw Exception('OTP expired. Please resend');
      } else {
        throw Exception(e.message ?? 'Verification failed');
      }
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      throw Exception(e.toString());
    }
  }

  /// Sign in with credential (for auto-verification)
  Future<User?> signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      await _saveUser(userCredential.user);
      return userCredential.user;
    } catch (e) {
      debugPrint('Sign in with credential error: $e');
      return null;
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  /// Save user data to SharedPreferences
  Future<void> _saveUser(User? user) async {
    if (user == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userDataKey, json.encode({
        'uid': user.uid,
        'phone': user.phoneNumber,
        'created_at': DateTime.now().toIso8601String(),
      }));
      debugPrint('User data saved');
    } catch (e) {
      debugPrint('Save user error: $e');
    }
  }

  /// Load user data from SharedPreferences
  Future<Map<String, dynamic>?> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(AppConstants.userDataKey);
      
      if (userData != null) {
        return json.decode(userData);
      }
    } catch (e) {
      debugPrint('Load user error: $e');
    }
    return null;
  }

  /// Check if user has a store
  Future<bool> hasStore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storeId = prefs.getInt(AppConstants.storeIdKey);
      return storeId != null && storeId > 0;
    } catch (e) {
      debugPrint('Has store check error: $e');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userDataKey);
      await prefs.remove(AppConstants.storeIdKey);
      await prefs.remove(AppConstants.storeDataKey);
      debugPrint('User signed out');
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  /// Resend OTP
  Future<bool> resendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    return await sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerify: (credential) async {
        await signInWithCredential(credential);
      },
    );
  }

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;
      
      if (user != null) {
        // Synchronize with backend and check for existing store
        try {
          final result = await _apiService.googleAuth(
            email: user.email ?? '',
            name: user.displayName ?? 'User',
            phone: user.phoneNumber,
          );
          
          if (result['success'] == true) {
            final prefs = await SharedPreferences.getInstance();
            
            // Save token
            if (result['data']['token'] != null) {
              await prefs.setString(AppConstants.authTokenKey, result['data']['token']);
              AppConstants.authToken = result['data']['token'];
            }
            
            // Save store data if exists
            if (result['data']['store'] != null) {
              final storeData = result['data']['store'];
              await prefs.setInt(AppConstants.storeIdKey, storeData['id']);
              await prefs.setString(AppConstants.storeDataKey, json.encode(storeData));
              debugPrint('Existing store found and saved for Google user: ${storeData['name']}');
            }
          }
        } catch (e) {
          debugPrint('Backend sync error during Google sign in: $e');
          // We still continue as firebase login was successful
        }
        
        // Save user data locally
        await _saveUser(user);
      }
      
      return user;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return null;
    }
  }
}
