import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

// Services
import 'package:admin_x_technician_panel/services/firestore_service.dart';
import 'package:admin_x_technician_panel/services/service_management_service.dart';
import 'package:admin_x_technician_panel/services/financial_service.dart';
import 'package:admin_x_technician_panel/services/worker_auth_service.dart';
import 'package:admin_x_technician_panel/services/invoice_service.dart';

// Providers
import 'package:admin_x_technician_panel/providers/app_state_provider.dart';

// Models
import 'package:admin_x_technician_panel/models/service_category_model.dart';
import 'package:admin_x_technician_panel/models/worker_data_model.dart';
import 'package:admin_x_technician_panel/models/service_model.dart';

// Screens
import 'package:admin_x_technician_panel/screens/auth/role_selection.dart';
import 'package:admin_x_technician_panel/admin/service_management_screen.dart';
import 'package:admin_x_technician_panel/admin/worker_management_screen.dart';
import 'package:admin_x_technician_panel/admin/financial_reports_screen.dart';
import 'package:admin_x_technician_panel/admin/commission_management_screen.dart';
import 'package:admin_x_technician_panel/screens/dashboard/complete_admin_dashboard.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();

    // Inject fake instance
    FirestoreService.setInstance(FirestoreService.withFirestore(fakeFirestore));

    // Reset all singleton services to pick up the new Firestore instance
    ServiceManagementService.reset();
    FinancialService.reset();
    WorkerAuthService.reset();
    InvoiceService.reset();

    // Seed Data
    await _seedData(fakeFirestore);
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppStateProvider())],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(size: const Size(1080, 1920)),
              child: child,
            );
          },
        ),
      ),
    );
  }

  group('Full App Screen Tests', () {
    testWidgets('RoleSelectionScreen renders correctly', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(const MaterialApp(home: RoleSelectionScreen()));
        await tester.pumpAndSettle();
        expect(find.textContaining('Handyman Admin Panel'), findsOneWidget);
        expect(find.textContaining('Login as Admin'), findsOneWidget);
      });
    });

    testWidgets('ServiceManagementScreen renders with data', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(const ServiceManagementScreen()),
        );

        // Wait for data
        await tester.runAsync(() async {
          for (int i = 0; i < 20; i++) {
            if (ServiceManagementService().getAllCategories().isNotEmpty) break;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        });
        await tester.pumpAndSettle();

        expect(find.text('Cleaning'), findsOneWidget);
      });
    });

    testWidgets('WorkerManagementScreen renders with workers', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(const WorkerManagementScreen()),
        );

        // Wait for workers logic could be added here if needed, but stream should fire
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          for (int i = 0; i < 20; i++) {
            if (WorkerAuthService().getAllWorkers().isNotEmpty) break;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        });
        await tester.pumpAndSettle();

        // Check for worker name
        expect(find.text('Ahmed Ali'), findsOneWidget);
      });
    });

    testWidgets('AdminDashboard launches', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(const AdminDashboard(phoneNumber: '123')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Financial Overview'), findsOneWidget);
        expect(find.text('Active Services'), findsOneWidget);
      });
    });

    testWidgets('FinancialReportsScreen renders', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(const FinancialReportsScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Financial Reports'), findsOneWidget);
        expect(find.text('Total Revenue'), findsOneWidget);
      });
    });

    testWidgets('CommissionManagementScreen renders', (
      WidgetTester tester,
    ) async {
      // Set screen size
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(const CommissionManagementScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Commission Management'), findsOneWidget);
      });
    });
  });
}

Future<void> _seedData(FakeFirebaseFirestore firestore) async {
  // 1. Categories
  await firestore
      .collection('service_categories')
      .doc('cleaning')
      .set(
        ServiceCategory(
          id: 'cleaning',
          nameEnglish: 'Cleaning',
          nameArabic: 'تنظيف',
          descriptionEnglish: 'Cleaning Services',
          descriptionArabic: 'خدمات تنظيف',
          basePrice: 50,
          subcategories: ['Home Cleaning'],
          subcategoriesArabic: ['تنظيف المنزل'],
        ).toMap(),
      );

  // 2. Workers
  await firestore
      .collection('workers')
      .doc('w1')
      .set(
        WorkerData(
          id: 'w1',
          name: 'Ahmed Ali',
          nameArabic: 'أحمد علي',
          phone: '+966500000001',
          email: 'ahmed@example.com',
          nationalId: '1000000001',
          stcPayId: 'STC001',
          address: 'Riyadh',
          addressArabic: 'الرياض',
          status: 'Active',
          joinedDate: DateTime.now(),
          creditBalance: 100.0,
        ).toMap(),
      );

  // 3. Admin Wallet (for Financial Reports)
  // ... (add if needed for financial tests)
}
