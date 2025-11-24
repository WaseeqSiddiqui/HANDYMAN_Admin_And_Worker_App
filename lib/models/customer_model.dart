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

  // ✅ UPDATED: Hardcoded customers - single language data
  static List<Customer> sampleData() {
    return [
      // English-speaking customers - فقط English میں
      Customer(
        id: 'C001',
        name: 'Ali Khan',
        phone: '+966501234567',
        email: 'ali.khan@email.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 15)),
        languagePreference: 'english',
      ),
      Customer(
        id: 'C002',
        name: 'Sarah Johnson',
        phone: '+966502345678',
        email: 'sarah.j@email.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 8)),
        languagePreference: 'english',
      ),
      Customer(
        id: 'C003',
        name: 'Robert Smith',
        phone: '+966503456789',
        email: 'robert.smith@email.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 25)),
        languagePreference: 'english',
      ),

      // Arabic-speaking customers - فقط Arabic میں
      Customer(
        id: 'C004',
        name: 'فاطمة حسن',
        phone: '+966504567890',
        email: null,
        registeredAt: DateTime.now().subtract(const Duration(days: 12)),
        languagePreference: 'arabic',
      ),
      Customer(
        id: 'C005',
        name: 'محمد أحمد',
        phone: '+966505678901',
        email: 'm.ahmed@email.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 30)),
        languagePreference: 'arabic',
      ),
      Customer(
        id: 'C006',
        name: 'نورة عبدالله',
        phone: '+966506789012',
        email: 'noura.a@email.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 5)),
        languagePreference: 'arabic',
      ),
    ];
  }
}