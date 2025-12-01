import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'otp_verification.dart';
import '/services/firebase_auth_service.dart';
import '/utils/auth_translations.dart';

class PhoneLoginScreen extends StatefulWidget {
  final String role;

  const PhoneLoginScreen({super.key, required this.role});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  String _formatPhoneNumber(String phone) {
    // Remove any spaces or special characters
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // If phone starts with 05, convert to +9665
    if (phone.startsWith('05')) {
      phone = '+966${phone.substring(1)}';
    }
    // If phone starts with 5 (without 0), add +966
    else if (phone.startsWith('5') && !phone.startsWith('+')) {
      phone = '+966$phone';
    }
    // If phone doesn't have country code, assume Saudi Arabia
    else if (!phone.startsWith('+')) {
      phone = '+966$phone';
    }

    return phone;
  }

  bool _isValidSaudiPhone(String phone) {
    // Remove country code for validation
    String digits = phone.replaceAll('+966', '').replaceAll(RegExp(r'\s+'), '');

    // Saudi mobile numbers: 5XXXXXXXX (9 digits starting with 5)
    return digits.length == 9 && digits.startsWith('5');
  }

  void _sendOTP() async {
    String phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showError(
        AuthTranslations.getEnglish(AuthTranslations.phoneRequired),
        AuthTranslations.getArabic(AuthTranslations.phoneRequired),
      );
      return;
    }

    // Format phone number
    String formattedPhone = _formatPhoneNumber(phone);

    // Validate phone number
    if (!_isValidSaudiPhone(formattedPhone)) {
      _showError(
        'Please enter a valid Saudi phone number (e.g., 0512345678)',
        'يرجى إدخال رقم هاتف سعودي صحيح (مثال: 0512345678)',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.sendOTP(
        phoneNumber: formattedPhone,
        onCodeSent: (verificationId) {
          setState(() => _isLoading = false);

          // Show success message
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

          // Navigate to OTP verification screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                phoneNumber: formattedPhone,
                role: widget.role,
                verificationId: verificationId,
              ),
            ),
          );
        },
        onError: (error) {
          setState(() => _isLoading = false);
          _showError(
            'Error: $error',
            'خطأ: $error',
          );
        },
        onAutoVerify: (credential) async {
          // Auto verification happened (Android only)
          setState(() => _isLoading = false);

          // Show success and navigate
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone verified automatically!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to appropriate dashboard
          _navigateToDashboard(formattedPhone);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(
        'Failed to send OTP: ${e.toString()}',
        'فشل في إرسال رمز التحقق: ${e.toString()}',
      );
    }
  }

  void _navigateToDashboard(String phoneNumber) {
    if (widget.role == 'Worker') {
      // Navigate to worker dashboard
      // Import your worker dashboard and navigate
    } else {
      // Navigate to admin dashboard
      // Import your admin dashboard and navigate
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
                      'assets/images/logoFinal.png',
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

              // Login As - Column Format
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AuthTranslations.getEnglish(AuthTranslations.loginAs)} ${widget.role}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '${AuthTranslations.getArabic(AuthTranslations.loginAs)} ${AuthTranslations.getArabic(widget.role == 'Admin' ? AuthTranslations.admin : AuthTranslations.worker)}',
                    style: TextStyle(
                      fontSize: 20,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Enter Phone - Column Format
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AuthTranslations.getEnglish(AuthTranslations.enterPhone),
                    style: TextStyle(
                      fontSize: 16,
                      color: subtitleColor,
                    ),
                  ),
                  Text(
                    AuthTranslations.getArabic(AuthTranslations.enterPhone),
                    style: TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Phone Number - Column Format
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AuthTranslations.getEnglish(AuthTranslations.phoneNumber),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    AuthTranslations.getArabic(AuthTranslations.phoneNumber),
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
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
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                    LengthLimitingTextInputFormatter(13), // +966XXXXXXXXX
                  ],
                  decoration: InputDecoration(
                    hintText: '05XXXXXXXX',
                    hintStyle: TextStyle(color: subtitleColor),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🇸🇦',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+966',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 24,
                            color: subtitleColor.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
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
                        AuthTranslations.getEnglish(AuthTranslations.sendOtp),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AuthTranslations.getArabic(AuthTranslations.sendOtp),
                        style: const TextStyle(
                          color: Colors.white,
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
    _phoneController.dispose();
    super.dispose();
  }
}