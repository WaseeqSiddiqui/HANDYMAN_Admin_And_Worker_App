// models/financial_transaction_model.dart
// ✅ Complete Financial Transaction Model for completed services

class FinancialTransaction {
  final String id;
  final String serviceId;
  final String serviceName;
  final String workerId;
  final String workerName;
  final String customerName;
  final double basePrice;
  final double extraCharges;
  final double totalAmount;
  final double commission;
  final double vat;
  final double workerDeduction;
  final double workerEarnings;
  final String paymentMethod;
  final DateTime completionDate;
  final String status;
  final String? customerPhone;

  FinancialTransaction({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.workerId,
    required this.workerName,
    required this.customerName,
    required this.basePrice,
    required this.extraCharges,
    required this.totalAmount,
    required this.commission,
    required this.vat,
    required this.workerDeduction,
    required this.workerEarnings,
    required this.paymentMethod,
    required this.completionDate,
    required this.status,
    this.customerPhone,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'serviceId': serviceId,
    'serviceName': serviceName,
    'workerId': workerId,
    'workerName': workerName,
    'customerName': customerName,
    'basePrice': basePrice,
    'extraCharges': extraCharges,
    'totalAmount': totalAmount,
    'commission': commission,
    'vat': vat,
    'workerDeduction': workerDeduction,
    'workerEarnings': workerEarnings,
    'paymentMethod': paymentMethod,
    'completionDate': completionDate.toIso8601String(),
    'status': status,
    'customerPhone': customerPhone,
  };

  factory FinancialTransaction.fromMap(Map<String, dynamic> map) => FinancialTransaction(
    id: map['id'],
    serviceId: map['serviceId'],
    serviceName: map['serviceName'],
    workerId: map['workerId'],
    workerName: map['workerName'],
    customerName: map['customerName'],
    basePrice: map['basePrice'],
    extraCharges: map['extraCharges'],
    totalAmount: map['totalAmount'],
    commission: map['commission'],
    vat: map['vat'],
    workerDeduction: map['workerDeduction'],
    workerEarnings: map['workerEarnings'],
    paymentMethod: map['paymentMethod'],
    completionDate: DateTime.parse(map['completionDate']),
    status: map['status'],
    customerPhone: map['customerPhone'],
  );
}