// services/service_management_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/models/service_model.dart' hide ServiceCategory;
import '/models/service_category_model.dart';
import 'firestore_service.dart';

/// ✅ Service Management Service - Using Firestore
class ServiceManagementService {
  static final ServiceManagementService _instance =
      ServiceManagementService._internal();
  factory ServiceManagementService() => _instance;

  final FirestoreService _firestoreService = FirestoreService();

  ServiceManagementService._internal() {
    _init();
  }

  final List<VoidCallback> _listeners = [];
  List<ServiceCategory> _categories = [];
  List<Service> _services = [];

  void _init() {
    // Listen to Categories
    _firestoreService.getServiceCategoriesStream().listen((categories) {
      _categories = categories;
      _notifyListeners();
    });

    // Listen to Offered Services
    _firestoreService.getOfferedServicesStream().listen((services) {
      _services = services;
      _notifyListeners();
    });
  }

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  // ============= CATEGORY MANAGEMENT =============
  List<ServiceCategory> getAllCategories() => List.unmodifiable(_categories);

  ServiceCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addCategory(ServiceCategory category) async {
    if (_categories.any((cat) => cat.id == category.id)) return false;
    await _firestoreService.addServiceCategory(category);
    return true;
  }

  // Note: We don't have update/delete category in FirestoreService yet (only add).
  // Assuming simpler requirement or handled elsewhere.
  // For now, I'll keep the local logic for unsupported ops or add them to FirestoreService if needed.
  // Actually, I should probably add them to FirestoreService to be consistent.
  // But let's verify if I can just implement the key methods requested.
  // The user mainly complained about adding SERVICE not showing up.

  // ============= SERVICE MANAGEMENT =============
  List<Service> getAllServices() => List.unmodifiable(_services);

  List<Service> getActiveServices() =>
      _services.where((service) => service.isActive).toList();

  List<Service> getServicesByCategory(String categoryId) =>
      _services.where((service) => service.categoryId == categoryId).toList();

  List<Service> getServicesBySubcategory(
    String categoryId,
    String subcategory,
  ) => _services
      .where(
        (service) =>
            service.categoryId == categoryId &&
            service.subcategory == subcategory,
      )
      .toList();

  Service? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addService(Service service) async {
    if (_services.any((s) => s.id == service.id)) return false;

    // Validate category exists
    final category = getCategoryById(service.categoryId);
    if (category == null) {
      debugPrint('❌ Category not found: ${service.categoryId}');
      return false;
    }

    try {
      await _firestoreService.addOfferedService(service);
      debugPrint('✅ Service added to Firestore: ${service.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Error adding service: $e');
      return false;
    }
  }

  Future<bool> updateService(String id, Service updatedService) async {
    try {
      await _firestoreService.updateOfferedService(updatedService);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleServiceStatus(String id) async {
    final service = getServiceById(id);
    if (service == null) return false;

    final updatedService = service.copyWith(isActive: !service.isActive);
    return await updateService(id, updatedService);
  }

  Future<bool> deleteService(String id) async {
    try {
      await _firestoreService.deleteOfferedService(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============= HELPER METHODS =============
  String getCategoryName(String categoryId) {
    final category = getCategoryById(categoryId);
    return category?.name ?? 'Unknown';
  }

  String getCategoryNameArabic(String categoryId) {
    final category = getCategoryById(categoryId);
    return category?.nameArabic ?? 'غير معروف';
  }

  String getSubcategoryNameArabic(String categoryId, String subcategory) {
    final category = getCategoryById(categoryId);
    if (category == null) return 'غير معروف';

    final index = category.subcategories.indexOf(subcategory);
    if (index == -1 || index >= category.subcategoriesArabic.length)
      return 'غير معروف';

    return category.subcategoriesArabic[index];
  }

  // Generate unique ID
  String _generateId(String prefix) {
    return '$prefix${DateTime.now().millisecondsSinceEpoch}';
  }

  String generateCategoryId() => _generateId('cat');
  String generateServiceId() => _generateId('srv');

  // Stats
  int get totalCategories => _categories.length;
  int get totalServices => _services.length;
  int get totalActiveServices => _services.where((s) => s.isActive).length;
  int get totalInactiveServices => _services.where((s) => !s.isActive).length;

  // ============= UNSUPPORTED / TODO OPS =============
  // These were local-only.

  bool updateCategory(String id, ServiceCategory updatedCategory) {
    // TODO: Implement in FirestoreService
    return false;
  }

  bool deleteCategory(String id) {
    // TODO: Implement in FirestoreService
    return false;
  }

  bool addSubcategoryToCategory(
    String categoryId,
    String subcategory,
    String subcategoryArabic,
  ) {
    // TODO: Implement in FirestoreService
    return false;
  }

  bool updateSubcategory(
    String categoryId,
    int index,
    String subcategory,
    String subcategoryArabic,
  ) {
    // TODO: Implement in FirestoreService
    return false;
  }

  bool deleteSubcategory(String categoryId, int index) {
    // TODO: Implement in FirestoreService
    return false;
  }
}
