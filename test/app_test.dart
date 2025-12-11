import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:admin_x_technician_panel/services/firestore_service.dart';
import 'package:admin_x_technician_panel/services/service_management_service.dart';
import 'package:admin_x_technician_panel/models/service_category_model.dart';
import 'package:admin_x_technician_panel/admin/service_management_screen.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();

    // Seed initial data
    await fakeFirestore
        .collection('service_categories')
        .doc('cat1')
        .set(
          ServiceCategory(
            id: 'cat1',
            nameEnglish: 'Test Category',
            nameArabic: 'تجربة',
            descriptionEnglish: 'Desc',
            descriptionArabic: 'وصف',
            basePrice: 100,
            subcategories: ['Sub1'],
            subcategoriesArabic: ['SubAr1'],
          ).toMap(),
        );

    // Inject fake instance
    FirestoreService.setInstance(FirestoreService.withFirestore(fakeFirestore));

    // Reset ServiceManager to pick up the new Firestore instance
    ServiceManagementService.reset();
  });

  testWidgets('Service Management Screen loads categories', (
    WidgetTester tester,
  ) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(home: const ServiceManagementScreen()),
      );

      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      // Wait for data to load using runAsync to allow stream to fire
      await tester.runAsync(() async {
        // Wait up to 2 seconds for data
        for (int i = 0; i < 20; i++) {
          final manager = ServiceManagementService();
          if (manager.getAllCategories().isNotEmpty) return;
          await Future.delayed(const Duration(milliseconds: 100));
        }
      });

      await tester.pumpAndSettle();

      // Verify Categories are loaded
      expect(find.textContaining('Test Category'), findsOneWidget);
    });
  });
}
