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
