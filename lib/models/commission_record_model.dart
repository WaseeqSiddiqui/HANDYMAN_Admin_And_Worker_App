// models/commission_record_model.dart
// ✅ Commission Record Model

class CommissionRecord {
  final String id;
  final String serviceId;
  final String serviceName;
  final String workerId;
  final String workerName;
  final double commissionAmount;
  final double serviceAmount;
  final double commissionRate;
  final String status; // 'paid', 'pending', 'collected'
  final DateTime date;

  CommissionRecord({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.workerId,
    required this.workerName,
    required this.commissionAmount,
    required this.serviceAmount,
    required this.commissionRate,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'serviceId': serviceId,
    'serviceName': serviceName,
    'workerId': workerId,
    'workerName': workerName,
    'commissionAmount': commissionAmount,
    'serviceAmount': serviceAmount,
    'commissionRate': commissionRate,
    'status': status,
    'date': date.toIso8601String(),
  };

  factory CommissionRecord.fromMap(Map<String, dynamic> map) => CommissionRecord(
    id: map['id'],
    serviceId: map['serviceId'],
    serviceName: map['serviceName'],
    workerId: map['workerId'],
    workerName: map['workerName'],
    commissionAmount: map['commissionAmount'],
    serviceAmount: map['serviceAmount'],
    commissionRate: map['commissionRate'],
    status: map['status'],
    date: DateTime.parse(map['date']),
  );
}