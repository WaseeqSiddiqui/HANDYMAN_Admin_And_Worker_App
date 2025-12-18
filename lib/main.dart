import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/app_state_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const AdminWorkerApp());
}

class AdminWorkerApp extends StatelessWidget {
  const AdminWorkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppStateProvider(),
      child: MaterialApp(
        title: 'Handyman Admin & Worker Panel',
        debugShowCheckedModeBanner: false,

        // ✅ Localization removed - simple and clean
        // No localizationsDelegates
        // No supportedLocales
        // No locale settings
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3B82F6),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        ),
        themeMode: ThemeMode.light,
        home: const SplashScreen(), // ✅ Changed to SplashScreen
      ),
    );
  }
}
