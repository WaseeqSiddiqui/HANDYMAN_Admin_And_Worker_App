// models/customer_model.dart
class Customer {
  final String id;
  final String name; // ✅ صرف ایک language میں name
  final String phone;
  final String? email;
  final DateTime registeredAt;
  final String languagePreference; // 'english' or 'arabic'

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.registeredAt,
    required this.languagePreference, // ✅ Required field
  });

  // Check if customer prefers Arabic
  bool get prefersArabic => languagePreference == 'arabic';

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'registeredAt': registeredAt.toIso8601String(),
    'languagePreference': languagePreference,
  };

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
    id: map['id'],
    name: map['name'],
    phone: map['phone'],
    email: map['email'],
    registeredAt: DateTime.parse(map['registeredAt']),
    languagePreference: map['languagePreference'] ?? 'english',
  );
}
