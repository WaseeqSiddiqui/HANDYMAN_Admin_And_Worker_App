class Worker {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String stcPayId;
  final List<String> skills;
  final double walletBalance;
  final double creditBalance;
  final bool isActive;
  final bool isBlocked;
  final DateTime joinedDate;
  final String? profileImage;
  final String? address;

  Worker({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.stcPayId,
    required this.skills,
    this.walletBalance = 0.0,
    this.creditBalance = 0.0,
    this.isActive = true,
    this.isBlocked = false,
    required this.joinedDate,
    this.profileImage,
    this.address,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      stcPayId: json['stcPayId'],
      skills: List<String>.from(json['skills'] ?? []),
      walletBalance: json['walletBalance']?.toDouble() ?? 0.0,
      creditBalance: json['creditBalance']?.toDouble() ?? 0.0,
      isActive: json['isActive'] ?? true,
      isBlocked: json['isBlocked'] ?? false,
      joinedDate: DateTime.parse(json['joinedDate']),
      profileImage: json['profileImage'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'stcPayId': stcPayId,
      'skills': skills,
      'walletBalance': walletBalance,
      'creditBalance': creditBalance,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'joinedDate': joinedDate.toIso8601String(),
      'profileImage': profileImage,
      'address': address,
    };
  }

  Worker copyWith({
    String? name,
    String? phoneNumber,
    String? email,
    String? stcPayId,
    List<String>? skills,
    double? walletBalance,
    double? creditBalance,
    bool? isActive,
    bool? isBlocked,
    String? profileImage,
    String? address,
  }) {
    return Worker(
      id: id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      stcPayId: stcPayId ?? this.stcPayId,
      skills: skills ?? this.skills,
      walletBalance: walletBalance ?? this.walletBalance,
      creditBalance: creditBalance ?? this.creditBalance,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      joinedDate: joinedDate,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
    );
  }
}