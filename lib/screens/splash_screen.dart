import 'package:flutter/material.dart';
import '/services/auth_persistence_service.dart';
import '/services/notification_service.dart';
import '/screens/auth/role_selection.dart';
import 'package:provider/provider.dart';
import '/providers/app_state_provider.dart';
import '/screens/dashboard/worker_dashboard.dart';
import '/screens/dashboard/complete_admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final _authService = AuthPersistenceService();

  @override
  void initState() {
    super.initState();

    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Check login state and navigate
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final loginState = await _authService.getLoginState();
    final isLoggedIn = loginState['isLoggedIn'] as bool;
    final role = loginState['role'] as String?;

    if (!mounted) return;

    if (isLoggedIn && role != null) {
      if (role == 'admin') {
        // ✅ Update Admin FCM Token
        await NotificationService().updateUserToken('admin', 'admin');

        // Navigate to Admin Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const AdminDashboard(phoneNumber: 'admin@handyman.com'),
          ),
        );
      } else if (role == 'worker') {
        // ✅ Persistent Login for Worker
        final workerId = loginState['workerId'] as String?;
        final phone = loginState['phone'] as String? ?? '';
        final name = loginState['name'] as String?;

        if (workerId != null) {
          // Initialize AppStateProvider with current worker
          Provider.of<AppStateProvider>(
            context,
            listen: false,
          ).setCurrentWorker(workerId);

          // ✅ Update Worker FCM Token
          await NotificationService().updateUserToken(workerId, 'worker');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WorkerDashboardScreen(phoneNumber: phone, workerName: name),
            ),
          );
        } else {
          _navigateToRoleSelection();
        }
      } else {
        _navigateToRoleSelection();
      }
    } else {
      // Not logged in, go to role selection
      _navigateToRoleSelection();
    }
  }

  void _navigateToRoleSelection() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B82F6), // Electric Blue
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo (same as role selection)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logoFinal.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if image not found
                        return const Icon(
                          Icons.handyman,
                          size: 60,
                          color: Color(0xFF3B82F6),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // App Name
                const Text(
                  'HANDYMAN',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Admin & Worker Panel',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 50),
                // Loading indicator
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
