import 'package:shared_preferences/shared_preferences.dart';

class AuthPersistenceService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserRole = 'user_role'; // 'admin' or 'worker'
  static const String _keyWorkerId = 'worker_id';
  static const String _keyWorkerPhone = 'worker_phone';
  static const String _keyWorkerName = 'worker_name';

  // Save admin login
  Future<void> saveAdminLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, 'admin');
  }

  // Save worker login
  Future<void> saveWorkerLogin({
    required String workerId,
    required String phone,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, 'worker');
    await prefs.setString(_keyWorkerId, workerId);
    await prefs.setString(_keyWorkerPhone, phone);
    await prefs.setString(_keyWorkerName, name);
  }

  // Get login state
  Future<Map<String, dynamic>> getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    final role = prefs.getString(_keyUserRole);
    final workerId = prefs.getString(_keyWorkerId);
    final phone = prefs.getString(_keyWorkerPhone);
    final name = prefs.getString(_keyWorkerName);

    return {
      'isLoggedIn': isLoggedIn,
      'role': role,
      'workerId': workerId,
      'phone': phone,
      'name': name,
    };
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Clear login (logout)
  Future<void> clearLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
