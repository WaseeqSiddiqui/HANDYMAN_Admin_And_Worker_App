// models/service_category_model.dart
class ServiceCategory {
  final String id;
  final String nameEnglish;
  final String nameArabic;
  final String descriptionEnglish;
  final String descriptionArabic;
  final double basePrice;

  final String? icon; // Only String supported for Firestore for now
  final List<String> subcategories;
  final List<String> subcategoriesArabic;

  ServiceCategory({
    required this.id,
    required this.nameEnglish,
    required this.nameArabic,
    required this.descriptionEnglish,
    required this.descriptionArabic,
    required this.basePrice,
    this.icon,
    this.subcategories = const [],
    this.subcategoriesArabic = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameEnglish': nameEnglish,
      'nameArabic': nameArabic,
      'descriptionEnglish': descriptionEnglish,
      'descriptionArabic': descriptionArabic,
      'basePrice': basePrice,
      'icon': icon,
      'subcategories': subcategories,
      'subcategoriesArabic': subcategoriesArabic,
    };
  }

  factory ServiceCategory.fromMap(Map<String, dynamic> map) {
    return ServiceCategory(
      id: map['id'] ?? '',
      nameEnglish: map['nameEnglish'] ?? '',
      nameArabic: map['nameArabic'] ?? '',
      descriptionEnglish: map['descriptionEnglish'] ?? '',
      descriptionArabic: map['descriptionArabic'] ?? '',
      basePrice: (map['basePrice'] ?? 0.0).toDouble(),
      icon: map['icon'],
      subcategories: List<String>.from(map['subcategories'] ?? []),
      subcategoriesArabic: List<String>.from(map['subcategoriesArabic'] ?? []),
    );
  }

  // Helper to get bilingual name
  String get name => '$nameEnglish • $nameArabic';

  // Legacy helpers for compatibility
  ServiceCategory copyWith({
    String? id,
    String? nameEnglish,
    String? nameArabic,
    String? descriptionEnglish,
    String? descriptionArabic,
    double? basePrice,
    String? icon,
    List<String>? subcategories,
    List<String>? subcategoriesArabic,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      nameArabic: nameArabic ?? this.nameArabic,
      descriptionEnglish: descriptionEnglish ?? this.descriptionEnglish,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      basePrice: basePrice ?? this.basePrice,
      icon: icon ?? this.icon,
      subcategories: subcategories ?? this.subcategories,
      subcategoriesArabic: subcategoriesArabic ?? this.subcategoriesArabic,
    );
  }

  ServiceCategory addSubcategory(String subcat, String subcatArabic) {
    return copyWith(
      subcategories: [...subcategories, subcat],
      subcategoriesArabic: [...subcategoriesArabic, subcatArabic],
    );
  }

  ServiceCategory updateSubcategory(
    int index,
    String subcat,
    String subcatArabic,
  ) {
    var newSubs = List<String>.from(subcategories);
    var newSubsAr = List<String>.from(subcategoriesArabic);
    if (index >= 0 && index < newSubs.length) {
      newSubs[index] = subcat;
      newSubsAr[index] = subcatArabic;
    }
    return copyWith(subcategories: newSubs, subcategoriesArabic: newSubsAr);
  }

  ServiceCategory removeSubcategory(int index) {
    var newSubs = List<String>.from(subcategories);
    var newSubsAr = List<String>.from(subcategoriesArabic);
    if (index >= 0 && index < newSubs.length) {
      newSubs.removeAt(index);
      newSubsAr.removeAt(index);
    }
    return copyWith(subcategories: newSubs, subcategoriesArabic: newSubsAr);
  }
}
