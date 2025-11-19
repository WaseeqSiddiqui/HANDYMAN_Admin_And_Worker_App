// models/service.dart

class Service {
  final String id;
  final String name;
  final String nameArabic;
  final String categoryId;
  final String category;
  final String categoryArabic;
  final String subcategoryId;
  final String subcategory;
  final String subcategoryArabic;
  final double basePrice;
  final double commission;
  final double vat;
  final bool isActive;
  final DateTime? createdAt;

  Service({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.categoryId,
    required this.category,
    required this.categoryArabic,
    required this.subcategoryId,
    required this.subcategory,
    required this.subcategoryArabic,
    required this.basePrice,
    required this.commission,
    required this.vat,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculated properties
  double get commissionAmount => basePrice * (commission / 100);
  double get vatAmount => basePrice * (vat / 100);
  double get totalPrice => basePrice + vatAmount;
  double get finalPrice => totalPrice + commissionAmount;

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'categoryId': categoryId,
      'category': category,
      'categoryArabic': categoryArabic,
      'subcategoryId': subcategoryId,
      'subcategory': subcategory,
      'subcategoryArabic': subcategoryArabic,
      'basePrice': basePrice,
      'commission': commission,
      'vat': vat,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Create from Map
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as String,
      name: map['name'] as String,
      nameArabic: map['nameArabic'] as String,
      categoryId: map['categoryId'] as String,
      category: map['category'] as String,
      categoryArabic: map['categoryArabic'] as String,
      subcategoryId: map['subcategoryId'] as String,
      subcategory: map['subcategory'] as String,
      subcategoryArabic: map['subcategoryArabic'] as String,
      basePrice: (map['basePrice'] as num).toDouble(),
      commission: (map['commission'] as num).toDouble(),
      vat: (map['vat'] as num).toDouble(),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }

  // Copy with method for updates
  Service copyWith({
    String? id,
    String? name,
    String? nameArabic,
    String? categoryId,
    String? category,
    String? categoryArabic,
    String? subcategoryId,
    String? subcategory,
    String? subcategoryArabic,
    double? basePrice,
    double? commission,
    double? vat,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      categoryArabic: categoryArabic ?? this.categoryArabic,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategory: subcategory ?? this.subcategory,
      subcategoryArabic: subcategoryArabic ?? this.subcategoryArabic,
      basePrice: basePrice ?? this.basePrice,
      commission: commission ?? this.commission,
      vat: vat ?? this.vat,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ServiceCategory {
  final String id;
  final String name;
  final String nameArabic;
  final dynamic icon; // Can be IconData or String
  final List<String> subcategories;
  final List<String> subcategoriesArabic;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.icon,
    required this.subcategories,
    required this.subcategoriesArabic,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'icon': icon is String ? icon : icon.toString(),
      'subcategories': subcategories,
      'subcategoriesArabic': subcategoriesArabic,
    };
  }

  // Create from Map
  factory ServiceCategory.fromMap(Map<String, dynamic> map) {
    return ServiceCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      nameArabic: map['nameArabic'] as String,
      icon: map['icon'], // Can handle both String and IconData
      subcategories: List<String>.from(map['subcategories'] as List? ?? []),
      subcategoriesArabic: List<String>.from(map['subcategoriesArabic'] as List? ?? []),
    );
  }

  // Copy with method
  ServiceCategory copyWith({
    String? id,
    String? name,
    String? nameArabic,
    dynamic icon,
    List<String>? subcategories,
    List<String>? subcategoriesArabic,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      icon: icon ?? this.icon,
      subcategories: subcategories ?? this.subcategories,
      subcategoriesArabic: subcategoriesArabic ?? this.subcategoriesArabic,
    );
  }

  // Add subcategory
  ServiceCategory addSubcategory(String subcat, String subcatArabic) {
    return copyWith(
      subcategories: [...subcategories, subcat],
      subcategoriesArabic: [...subcategoriesArabic, subcatArabic],
    );
  }

  // Remove subcategory
  ServiceCategory removeSubcategory(int index) {
    final newSubcats = List<String>.from(subcategories);
    final newSubcatsArabic = List<String>.from(subcategoriesArabic);

    if (index >= 0 && index < newSubcats.length) {
      newSubcats.removeAt(index);
      newSubcatsArabic.removeAt(index);
    }

    return copyWith(
      subcategories: newSubcats,
      subcategoriesArabic: newSubcatsArabic,
    );
  }

  // Update subcategory
  ServiceCategory updateSubcategory(int index, String subcat, String subcatArabic) {
    final newSubcats = List<String>.from(subcategories);
    final newSubcatsArabic = List<String>.from(subcategoriesArabic);

    if (index >= 0 && index < newSubcats.length) {
      newSubcats[index] = subcat;
      newSubcatsArabic[index] = subcatArabic;
    }

    return copyWith(
      subcategories: newSubcats,
      subcategoriesArabic: newSubcatsArabic,
    );
  }
}

class ServiceSubcategory {
  final String id;
  final String categoryId;
  final String name;
  final String nameArabic;

  ServiceSubcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.nameArabic,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'nameArabic': nameArabic,
    };
  }

  factory ServiceSubcategory.fromMap(Map<String, dynamic> map) {
    return ServiceSubcategory(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      name: map['name'] as String,
      nameArabic: map['nameArabic'] as String,
    );
  }

  ServiceSubcategory copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? nameArabic,
  }) {
    return ServiceSubcategory(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
    );
  }
}