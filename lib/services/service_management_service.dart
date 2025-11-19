// services/service_management_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/models/service_model.dart';

/// ✅ Service Management Service - Using proper bilingual models
class ServiceManagementService {
  static final ServiceManagementService _instance = ServiceManagementService._internal();
  factory ServiceManagementService() => _instance;
  ServiceManagementService._internal() {
    _initializeSampleData();
  }

  final List<VoidCallback> _listeners = [];
  final List<ServiceCategory> _categories = [];
  final List<Service> _services = [];

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  // ============= INITIALIZATION =============
  void _initializeSampleData() {
    // Sample Categories with bilingual support
    _categories.addAll([
      ServiceCategory(
        id: 'cat1',
        name: 'AC Services',
        nameArabic: 'خدمات التكييف',
        icon: Icons.ac_unit,
        subcategories: ['Repair', 'Installation', 'Maintenance'],
        subcategoriesArabic: ['إصلاح', 'تركيب', 'صيانة'],
      ),
      ServiceCategory(
        id: 'cat2',
        name: 'Appliances',
        nameArabic: 'الأجهزة المنزلية',
        icon: Icons.kitchen,
        subcategories: ['Washing Machine', 'Refrigerator', 'Microwave'],
        subcategoriesArabic: ['غسالة', 'ثلاجة', 'ميكروويف'],
      ),
      ServiceCategory(
        id: 'cat3',
        name: 'Plumbing',
        nameArabic: 'السباكة',
        icon: Icons.plumbing,
        subcategories: ['Leak Repair', 'Installation', 'Drain Cleaning'],
        subcategoriesArabic: ['إصلاح التسريبات', 'تركيب', 'تنظيف المصارف'],
      ),
    ]);

    // Sample Services with bilingual support
    _services.addAll([
      Service(
        id: 'srv1',
        name: 'AC Repair',
        nameArabic: 'إصلاح التكييف',
        categoryId: 'cat1',
        category: 'AC Services',
        categoryArabic: 'خدمات التكييف',
        subcategoryId: 'cat1_0',
        subcategory: 'Repair',
        subcategoryArabic: 'إصلاح',
        basePrice: 450.0,
        commission: 10.0,
        vat: 5.0,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      Service(
        id: 'srv2',
        name: 'Washing Machine Service',
        nameArabic: 'صيانة الغسالة',
        categoryId: 'cat2',
        category: 'Appliances',
        categoryArabic: 'الأجهزة المنزلية',
        subcategoryId: 'cat2_0',
        subcategory: 'Washing Machine',
        subcategoryArabic: 'غسالة',
        basePrice: 300.0,
        commission: 10.0,
        vat: 5.0,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      Service(
        id: 'srv3',
        name: 'Refrigerator Repair',
        nameArabic: 'إصلاح الثلاجة',
        categoryId: 'cat2',
        category: 'Appliances',
        categoryArabic: 'الأجهزة المنزلية',
        subcategoryId: 'cat2_1',
        subcategory: 'Refrigerator',
        subcategoryArabic: 'ثلاجة',
        basePrice: 550.0,
        commission: 10.0,
        vat: 5.0,
        isActive: false,
        createdAt: DateTime.now(),
      ),
    ]);

    debugPrint('✅ ServiceManagementService initialized with ${_categories.length} categories and ${_services.length} services');
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

  bool addCategory(ServiceCategory category) {
    if (_categories.any((cat) => cat.id == category.id)) return false;
    _categories.add(category);
    _notifyListeners();
    debugPrint('✅ Category added: ${category.name}');
    return true;
  }

  bool updateCategory(String id, ServiceCategory updatedCategory) {
    final index = _categories.indexWhere((cat) => cat.id == id);
    if (index == -1) return false;

    // Update all services that use this category
    for (int i = 0; i < _services.length; i++) {
      if (_services[i].categoryId == id) {
        _services[i] = _services[i].copyWith(
          category: updatedCategory.name,
          categoryArabic: updatedCategory.nameArabic,
        );
      }
    }

    _categories[index] = updatedCategory;
    _notifyListeners();
    debugPrint('✅ Category updated: ${updatedCategory.name}');
    return true;
  }

  bool deleteCategory(String id) {
    // Check if any services use this category
    if (_services.any((service) => service.categoryId == id)) {
      debugPrint('❌ Cannot delete category: Services are using it');
      return false;
    }

    // Find and remove the category
    final index = _categories.indexWhere((cat) => cat.id == id);
    if (index == -1) return false;

    _categories.removeAt(index);
    _notifyListeners();
    debugPrint('✅ Category deleted');
    return true;
  }

  // ============= SUBCATEGORY MANAGEMENT =============
  bool addSubcategoryToCategory(String categoryId, String subcategory, String subcategoryArabic) {
    final category = getCategoryById(categoryId);
    if (category == null) return false;

    final updatedCategory = category.addSubcategory(subcategory, subcategoryArabic);
    return updateCategory(categoryId, updatedCategory);
  }

  bool updateSubcategory(String categoryId, int index, String subcategory, String subcategoryArabic) {
    final category = getCategoryById(categoryId);
    if (category == null) return false;

    if (index < 0 || index >= category.subcategories.length) return false;

    final oldSubcategory = category.subcategories[index];
    final updatedCategory = category.updateSubcategory(index, subcategory, subcategoryArabic);

    // Update all services that use this subcategory
    for (int i = 0; i < _services.length; i++) {
      if (_services[i].categoryId == categoryId && _services[i].subcategory == oldSubcategory) {
        _services[i] = _services[i].copyWith(
          subcategory: subcategory,
          subcategoryArabic: subcategoryArabic,
        );
      }
    }

    return updateCategory(categoryId, updatedCategory);
  }

  bool deleteSubcategory(String categoryId, int index) {
    final category = getCategoryById(categoryId);
    if (category == null) return false;

    if (index < 0 || index >= category.subcategories.length) return false;

    final subcategoryToDelete = category.subcategories[index];

    // Check if any services use this subcategory
    if (_services.any((service) =>
    service.categoryId == categoryId && service.subcategory == subcategoryToDelete)) {
      debugPrint('❌ Cannot delete subcategory: Services are using it');
      return false;
    }

    final updatedCategory = category.removeSubcategory(index);
    return updateCategory(categoryId, updatedCategory);
  }

  // ============= SERVICE MANAGEMENT =============
  List<Service> getAllServices() => List.unmodifiable(_services);

  List<Service> getActiveServices() =>
      _services.where((service) => service.isActive).toList();

  List<Service> getServicesByCategory(String categoryId) =>
      _services.where((service) => service.categoryId == categoryId).toList();

  List<Service> getServicesBySubcategory(String categoryId, String subcategory) =>
      _services.where((service) =>
      service.categoryId == categoryId && service.subcategory == subcategory).toList();

  Service? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }

  bool addService(Service service) {
    if (_services.any((s) => s.id == service.id)) return false;

    // Validate category exists
    final category = getCategoryById(service.categoryId);
    if (category == null) {
      debugPrint('❌ Category not found: ${service.categoryId}');
      return false;
    }

    // Validate subcategory exists
    if (!category.subcategories.contains(service.subcategory)) {
      debugPrint('❌ Subcategory not found: ${service.subcategory}');
      return false;
    }

    _services.add(service);
    _notifyListeners();
    debugPrint('✅ Service added: ${service.name}');
    return true;
  }

  bool updateService(String id, Service updatedService) {
    final index = _services.indexWhere((service) => service.id == id);
    if (index == -1) return false;
    _services[index] = updatedService;
    _notifyListeners();
    debugPrint('✅ Service updated: ${updatedService.name}');
    return true;
  }

  bool toggleServiceStatus(String id) {
    final index = _services.indexWhere((service) => service.id == id);
    if (index == -1) return false;

    _services[index] = _services[index].copyWith(
      isActive: !_services[index].isActive,
    );

    _notifyListeners();
    debugPrint('✅ Service status toggled: ${_services[index].name} -> ${_services[index].isActive}');
    return true;
  }

  bool deleteService(String id) {
    final index = _services.indexWhere((service) => service.id == id);
    if (index == -1) return false;

    _services.removeAt(index);
    _notifyListeners();
    debugPrint('✅ Service deleted');
    return true;
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
    if (index == -1 || index >= category.subcategoriesArabic.length) return 'غير معروف';

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
}