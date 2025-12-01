import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Send OTP to phone number
  Future<Map<String, dynamic>> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function(PhoneAuthCredential) onAutoVerify,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        // Verification completed automatically (Android only)
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (kDebugMode) {
            print('✅ Auto verification completed');
          }
          onAutoVerify(credential);
        },

        // Verification failed
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('❌ Verification failed: ${e.message}');
          }

          String errorMessage;
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number format';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later';
          } else if (e.code == 'quota-exceeded') {
            errorMessage = 'SMS quota exceeded. Please try again later';
          } else {
            errorMessage = e.message ?? 'Verification failed';
          }

          onError(errorMessage);
        },

        // Code sent successfully
        codeSent: (String verificationId, int? resendToken) {
          if (kDebugMode) {
            print('✅ Code sent successfully');
          }
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },

        // Code auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) {
            print('⏱️ Auto retrieval timeout');
          }
          _verificationId = verificationId;
        },

        // Use forceResendingToken for resend
        forceResendingToken: _resendToken,
      );

      return {
        'success': true,
        'message': 'OTP sent successfully',
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending OTP: $e');
      }
      return {
        'success': false,
        'message': 'Failed to send OTP: ${e.toString()}',
      };
    }
  }

  // Verify OTP code
  Future<Map<String, dynamic>> verifyOTP({
    required String otp,
    String? verificationId,
  }) async {
    try {
      final String verId = verificationId ?? _verificationId ?? '';

      if (verId.isEmpty) {
        return {
          'success': false,
          'message': 'Verification ID not found. Please resend OTP',
        };
      }

      // Create credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: otp,
      );

      // Sign in with credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (kDebugMode) {
        print('✅ User signed in: ${userCredential.user?.uid}');
      }

      return {
        'success': true,
        'message': 'OTP verified successfully',
        'user': userCredential.user,
        'phoneNumber': userCredential.user?.phoneNumber,
        'uid': userCredential.user?.uid,
      };
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ OTP verification failed: ${e.message}');
      }

      String errorMessage;
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'Invalid OTP code. Please try again';
      } else if (e.code == 'session-expired') {
        errorMessage = 'OTP expired. Please request a new one';
      } else {
        errorMessage = e.message ?? 'Verification failed';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verifying OTP: $e');
      }
      return {
        'success': false,
        'message': 'Failed to verify OTP: ${e.toString()}',
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _verificationId = null;
      _resendToken = null;
      if (kDebugMode) {
        print('✅ User signed out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error signing out: $e');
      }
    }
  }

  // Check if user is signed in
  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }

  // Get user phone number
  String? getUserPhoneNumber() {
    return _auth.currentUser?.phoneNumber;
  }

  // Get user UID
  String? getUserUID() {
    return _auth.currentUser?.uid;
  }

  // Reset verification ID (for resend)
  void resetVerification() {
    _verificationId = null;
  }
}