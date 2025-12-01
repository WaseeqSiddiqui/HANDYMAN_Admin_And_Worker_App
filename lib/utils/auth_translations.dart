/// Comprehensive Arabic translations for all authentication screens
class AuthTranslations {
  // Role Selection Screen
  static const String companyName = 'HANDYMAN\nعامل الماهر';
  static const String systemName = 'Service Management System\nنظام إدارة الخدمات';
  static const String continueAs = 'Continue as\nالمتابعة كـ';
  static const String admin = 'Admin\nمشرف';
  static const String adminDescription = 'Manage services, workers, and financials\nإدارة الخدمات والعاملين والشؤون المالية';
  static const String worker = 'Worker\nعامل';
  static const String workerDescription = 'Manage assigned services and earnings\nإدارة الخدمات المعينة والأرباح';

  // Phone Login Screen
  static const String welcome = 'Welcome\nمرحباً';
  static const String loginAs = 'Login as\nتسجيل الدخول كـ';
  static const String enterPhone = 'Enter your phone number to receive verification code\nأدخل رقم هاتفك لاستلام رمز التحقق';
  static const String enterPhoneToContinue = 'Enter your phone number to continue\nأدخل رقم هاتفك للمتابعة';
  static const String phoneNumber = 'Phone Number\nرقم الهاتف';
  static const String saudiArabia = 'Saudi Arabia\nالسعودية';
  static const String phoneHint = '5XXXXXXXX';
  static const String phoneRequired = 'Phone number is required\nرقم الهاتف مطلوب';
  static const String sendOtp = 'Send OTP\nإرسال الرمز';
  static const String workersMustBeRegistered = 'Workers must be registered by admin before login\nيجب تسجيل العمال من قبل المشرف قبل تسجيل الدخول';
  static const String otpInfo = 'We will send you a one-time password to verify your account\nسنرسل لك كلمة مرور لمرة واحدة للتحقق من حسابك';
  static const String validPhoneError = 'Please enter a valid 10-digit phone number\nيرجى إدخال رقم هاتف صالح مكون من 10 أرقام';
  static const String workerNotRegistered = 'Worker not registered!\nالعامل غير مسجل!';
  static const String contactAdmin = 'Please contact admin to register your account\nيرجى الاتصال بالمشرف لتسجيل حسابك';
  static const String accountBlocked = 'Account Blocked!\nالحساب محظور!';
  static const String accountBlockedMessage = 'Your account has been blocked. Contact admin.\nتم حظر حسابك. يرجى الاتصال بالمشرف.';

  // OTP Verification Screen
  static const String verifyOtp = 'Verify OTP\nالتحقق من الرمز';
  static const String enterCodeSentTo = 'Enter the code sent to\nأدخل الرمز المرسل إلى';
  static const String verifyContinue = 'Verify & Continue\nالتحقق والمتابعة';
  static const String resendOtp = 'Resend OTP\nإعادة إرسال الرمز';
  static const String resendOtpIn = 'Resend OTP in\nإعادة إرسال الرمز خلال';
  static const String seconds = 'seconds\nثواني';
  static const String completeOtpError = 'Please enter complete OTP\nيرجى إدخال الرمز بالكامل';
  static const String otpSentSuccess = 'OTP sent successfully\nتم إرسال الرمز بنجاح';

  // General
  static const String back = 'Back\nرجوع';
  static const String loading = 'Loading\nجاري التحميل';
  static const String error = 'Error\nخطأ';
  static const String success = 'Success\nنجاح';
  static const String cancel = 'Cancel\nإلغاء';
  static const String confirm = 'Confirm\nتأكيد';

  // Helper Methods
  static String getBilingual(String english, String arabic) {
    return '$english\n$arabic';
  }

  static List<String> split(String bilingualText) {
    final parts = bilingualText.split('\n');
    return parts.length == 2 ? parts : [bilingualText, bilingualText];
  }

  /// Get English only (first part)
  static String getEnglish(String bilingualText) {
    return split(bilingualText)[0];
  }

  /// Get Arabic only (second part)
  static String getArabic(String bilingualText) {
    return split(bilingualText)[1];
  }
}