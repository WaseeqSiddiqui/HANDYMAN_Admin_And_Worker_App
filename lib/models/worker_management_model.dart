// lib/models/worker.dart

class Worker {
  final String id;
  final String name;
  final String nameArabic;
  final String nationalId;
  final String email;
  final String phone;
  final String stcPayId;
  final String address;
  final String addressArabic;
  String status; // Active / Blocked
  final DateTime joinedDate;
  int completedServices;
  double creditBalance;

  Worker({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.nationalId,
    required this.email,
    required this.phone,
    required this.stcPayId,
    required this.address,
    required this.addressArabic,
    required this.status,
    required this.joinedDate,
    this.completedServices = 0,
    this.creditBalance = 0.0,
  });

  // Convert from Map/JSON
  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameArabic: map['nameArabic'] ?? '',
      nationalId: map['nationalId'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      stcPayId: map['stcPayId'] ?? '',
      address: map['address'] ?? '',
      addressArabic: map['addressArabic'] ?? '',
      status: map['status'] ?? 'Active',
      joinedDate: map['joinedDate'] is DateTime
          ? map['joinedDate']
          : DateTime.parse(map['joinedDate'] ?? DateTime.now().toIso8601String()),
      completedServices: map['completedServices'] ?? 0,
      creditBalance: map['creditBalance']?.toDouble() ?? 0.0,
    );
  }

  // Convert to Map/JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'nationalId': nationalId,
      'email': email,
      'phone': phone,
      'stcPayId': stcPayId,
      'address': address,
      'addressArabic': addressArabic,
      'status': status,
      'joinedDate': joinedDate.toIso8601String(),
      'completedServices': completedServices,
      'creditBalance': creditBalance,
    };
  }

  // Toggle status
  void toggleStatus() {
    status = status == 'Active' ? 'Blocked' : 'Active';
  }
}
