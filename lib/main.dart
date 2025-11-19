import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/auth/role_selection.dart';
import 'l10n/app_localizations.dart';

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
        title: 'Aidea Admin & Worker Panel',
        debugShowCheckedModeBanner: false,

        // ✅ Add localization support
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,

        // Optional: Set default locale (remove if you want system default)
        // locale: const Locale('en'),

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6B5B9A),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6B5B9A),
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