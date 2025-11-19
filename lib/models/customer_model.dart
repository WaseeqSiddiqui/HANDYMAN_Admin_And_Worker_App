// models/customer_model.dart
class Customer {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final DateTime registeredAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.registeredAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'registeredAt': registeredAt.toIso8601String(),
  };

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
    id: map['id'],
    name: map['name'],
    phone: map['phone'],
    email: map['email'],
    registeredAt: DateTime.parse(map['registeredAt']),
  );

  // Sample data for testing without Firebase
  static List<Customer> sampleData() {
    return [
      Customer(
        id: 'c1',
        name: 'Ali Khan',
        phone: '03001234567',
        email: 'ali@example.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Customer(
        id: 'c2',
        name: 'Sara Ahmed',
        phone: '03007654321',
        email: null,
        registeredAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
