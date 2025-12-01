import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dashboard/complete_admin_dashboard.dart';
import '../dashboard/worker_dashboard.dart';
import '/services/worker_auth_service.dart';
import '/services/firebase_auth_service.dart';
import '/utils/auth_translations.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String role;
  final String verificationId;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.role,
    required this.verificationId,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool _isLoading = false;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        _startResendTimer();
      } else if (mounted) {
        setState(() => _canResend = true);
      }
    });
  }

  void _verifyOTP() async {
    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AuthTranslations.getEnglish(AuthTranslations.completeOtpError)),
              Text(AuthTranslations.getArabic(AuthTranslations.completeOtpError)),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Verify OTP with Firebase
      final result = await _authService.verifyOTP(
        otp: otp,
        verificationId: widget.verificationId,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success']) {
          // OTP verified successfully
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Phone verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to appropriate dashboard
          if (widget.role == 'Worker') {
            final authService = WorkerAuthService();
            final worker = authService.getWorkerByPhone(widget.phoneNumber);

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => WorkerDashboardScreen(
                  phoneNumber: widget.phoneNumber,
                  workerName: worker!.name,
                ),
              ),
                  (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => AdminDashboard(phoneNumber: widget.phoneNumber),
              ),
                  (route) => false,
            );
          }
        } else {
          // Verification failed
          _showError(
            result['message'] ?? 'Verification failed',
            'فشل التحقق: ${result['message'] ?? 'فشل التحقق'}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(
          'Error verifying OTP: ${e.toString()}',
          'خطأ في التحقق من الرمز: ${e.toString()}',
        );
      }
    }
  }

  void _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 60;
      _isLoading = true;
    });
    _startResendTimer();

    try {
      // Reset verification and send new OTP
      _authService.resetVerification();

      await _authService.sendOTP(
        phoneNumber: widget.phoneNumber,
        onCodeSent: (verificationId) {
          setState(() => _isLoading = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AuthTranslations.getEnglish(AuthTranslations.otpSentSuccess)),
                  Text(AuthTranslations.getArabic(AuthTranslations.otpSentSuccess)),
                ],
              ),
              backgroundColor: const Color(0xFF005DFF),
            ),
          );

          // Update verification ID
          // Note: You might want to update the parent widget's verificationId here
        },
        onError: (error) {
          setState(() => _isLoading = false);
          _showError(
            'Failed to resend OTP: $error',
            'فشل في إعادة إرسال الرمز: $error',
          );
        },
        onAutoVerify: (credential) {
          setState(() => _isLoading = false);
          // Auto-verified
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(
        'Error resending OTP: ${e.toString()}',
        'خطأ في إعادة إرسال الرمز: ${e.toString()}',
      );
    }
  }

  void _showError(String englishMessage, String arabicMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(englishMessage),
            Text(arabicMessage),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: textColor),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AuthTranslations.getEnglish(AuthTranslations.back),
              style: TextStyle(fontSize: 16, color: textColor),
            ),
            Text(
              AuthTranslations.getArabic(AuthTranslations.back),
              style: TextStyle(fontSize: 12, color: subtitleColor),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF005DFF).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/Aidea_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.business,
                          color: Color(0xFF005DFF),
                          size: 50,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Verify OTP - Column Format
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AuthTranslations.getEnglish(AuthTranslations.verifyOtp),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    AuthTranslations.getArabic(AuthTranslations.verifyOtp),
                    style: TextStyle(
                      fontSize: 20,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Enter Code - Column Format
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AuthTranslations.getEnglish(AuthTranslations.enterCodeSentTo)} ${widget.phoneNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      color: subtitleColor,
                    ),
                  ),
                  Text(
                    '${AuthTranslations.getArabic(AuthTranslations.enterCodeSentTo)} ${widget.phoneNumber}',
                    style: TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _otpControllers[index].text.isNotEmpty
                              ? const Color(0xFF6B5B9A)
                              : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005DFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AuthTranslations.getEnglish(AuthTranslations.verifyContinue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AuthTranslations.getArabic(AuthTranslations.verifyContinue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: TextButton(
                  onPressed: _canResend ? _resendOTP : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _canResend
                            ? AuthTranslations.getEnglish(AuthTranslations.resendOtp)
                            : '${AuthTranslations.getEnglish(AuthTranslations.resendOtpIn)} $_resendTimer ${AuthTranslations.getEnglish(AuthTranslations.seconds)}',
                        style: TextStyle(
                          color: _canResend ? const Color(0xFF005DFF) : subtitleColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _canResend
                            ? AuthTranslations.getArabic(AuthTranslations.resendOtp)
                            : '${AuthTranslations.getArabic(AuthTranslations.resendOtpIn)} $_resendTimer ${AuthTranslations.getArabic(AuthTranslations.seconds)}',
                        style: TextStyle(
                          color: _canResend ? const Color(0xFF005DFF) : subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}