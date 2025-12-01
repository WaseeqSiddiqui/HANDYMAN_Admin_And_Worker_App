class WorkerData {
  final String id;
  final String name;
  final String nameArabic;
  final String phone;
  final String email;
  final String nationalId;
  final String stcPayId;
  final String address;
  final String addressArabic;
  final String status;
  final DateTime joinedDate;
  final int completedServices;
  final double creditBalance;

  WorkerData({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.phone,
    required this.email,
    required this.nationalId,
    required this.stcPayId,
    required this.address,
    required this.addressArabic,
    required this.status,
    required this.joinedDate,
    this.completedServices = 0,
    this.creditBalance = 100.0,
  });

  WorkerData copyWith({
    String? id,
    String? name,
    String? nameArabic,
    String? phone,
    String? email,
    String? nationalId,
    String? stcPayId,
    String? address,
    String? addressArabic,
    String? status,
    DateTime? joinedDate,
    int? completedServices,
    double? creditBalance,
  }) {
    return WorkerData(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      nationalId: nationalId ?? this.nationalId,
      stcPayId: stcPayId ?? this.stcPayId,
      address: address ?? this.address,
      addressArabic: addressArabic ?? this.addressArabic,
      status: status ?? this.status,
      joinedDate: joinedDate ?? this.joinedDate,
      completedServices: completedServices ?? this.completedServices,
      creditBalance: creditBalance ?? this.creditBalance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'phone': phone,
      'email': email,
      'nationalId': nationalId,
      'stcPayId': stcPayId,
      'address': address,
      'addressArabic': addressArabic,
      'status': status,
      'joinedDate': joinedDate.toIso8601String(),
      'completedServices': completedServices,
      'creditBalance': creditBalance,
    };
  }

  factory WorkerData.fromMap(Map<String, dynamic> map) {
    return WorkerData(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameArabic: map['nameArabic'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      nationalId: map['nationalId'] ?? '',
      stcPayId: map['stcPayId'] ?? '',
      address: map['address'] ?? '',
      addressArabic: map['addressArabic'] ?? '',
      status: map['status'] ?? 'Active',
      joinedDate: map['joinedDate'] is DateTime
          ? map['joinedDate']
          : DateTime.parse(map['joinedDate'] ?? DateTime.now().toIso8601String()),
      completedServices: map['completedServices'] ?? 0,
      creditBalance: (map['creditBalance'] ?? 100.0).toDouble(),
    );
  }
}