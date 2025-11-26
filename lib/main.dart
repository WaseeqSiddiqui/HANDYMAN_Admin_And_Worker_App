import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/auth/role_selection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
            seedColor: const Color(0xFF005DFF),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Updated to match customer app
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF005DFF),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
        ),
        themeMode: ThemeMode.system,
        home: const RoleSelectionScreen(),
      ),
    );
  }
}