// models/customer_service_model.dart
class CustomerService {
  final String id;
  final String service;
  final String status;
  final double price;

  CustomerService({
    required this.id,
    required this.service,
    required this.status,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'service': service,
    'status': status,
    'price': price,
  };

  factory CustomerService.fromMap(Map<String, dynamic> map) => CustomerService(
    id: map['id'],
    service: map['service'],
    status: map['status'],
    price: (map['price'] as num).toDouble(),
  );

  // Sample data
  static List<CustomerService> sampleData() {
    return [
      CustomerService(
        id: 's1',
        service: 'Home Cleaning',
        status: 'Completed',
        price: 150.0,
      ),
      CustomerService(
        id: 's2',
        service: 'Plumbing',
        status: 'In Progress',
        price: 200.0,
      ),
    ];
  }
}
