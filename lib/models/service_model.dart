class Service {
  final String id;
  final String categoryId;
  final String subcategoryId;
  final String name;
  final String description;
  final double basePrice;
  final double commission;
  final double vat;
  final bool isActive;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.categoryId,
    required this.subcategoryId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.commission,
    required this.vat,
    this.isActive = true,
    required this.createdAt,
  });

  double get totalPrice => basePrice + vat;
  double get commissionAmount => basePrice * (commission / 100);
  double get vatAmount => basePrice * (vat / 100);

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      categoryId: json['categoryId'],
      subcategoryId: json['subcategoryId'],
      name: json['name'],
      description: json['description'],
      basePrice: json['basePrice'].toDouble(),
      commission: json['commission'].toDouble(),
      vat: json['vat'].toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'commission': commission,
      'vat': vat,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final List<ServiceSubcategory> subcategories;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.subcategories,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      subcategories: (json['subcategories'] as List)
          .map((e) => ServiceSubcategory.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'subcategories': subcategories.map((e) => e.toJson()).toList(),
    };
  }
}

class ServiceSubcategory {
  final String id;
  final String categoryId;
  final String name;

  ServiceSubcategory({
    required this.id,
    required this.categoryId,
    required this.name,
  });

  factory ServiceSubcategory.fromJson(Map<String, dynamic> json) {
    return ServiceSubcategory(
      id: json['id'],
      categoryId: json['categoryId'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
    };
  }
}