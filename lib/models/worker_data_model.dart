// lib/models/worker_data.dart
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
    this.creditBalance = 100.0, // default initial credit
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
}
