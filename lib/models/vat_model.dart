// models/vat_record_model.dart
// ✅ VAT Record Model

class VATRecord {
  final String id;
  final String serviceId;
  final String serviceName;
  final double serviceAmount;
  final double vatRate;
  final double vatAmount;
  final DateTime date;
  final String status; // 'collected', 'pending'

  VATRecord({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.serviceAmount,
    required this.vatRate,
    required this.vatAmount,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'serviceId': serviceId,
    'serviceName': serviceName,
    'serviceAmount': serviceAmount,
    'vatRate': vatRate,
    'vatAmount': vatAmount,
    'date': date.toIso8601String(),
    'status': status,
  };

  factory VATRecord.fromMap(Map<String, dynamic> map) => VATRecord(
    id: map['id'],
    serviceId: map['serviceId'],
    serviceName: map['serviceName'],
    serviceAmount: map['serviceAmount'],
    vatRate: map['vatRate'],
    vatAmount: map['vatAmount'],
    date: DateTime.parse(map['date']),
    status: map['status'],
  );
}