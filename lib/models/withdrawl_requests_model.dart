// models/withdrawal_request_model.dart
// ✅ Withdrawal Request Model

class WithdrawalRequest {
  final String id;
  final String workerId;
  final String workerName;
  final double amount;
  final DateTime requestDate;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime? processedDate;
  final String? processedBy;
  final String? adminNotes;

  WithdrawalRequest({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.amount,
    required this.requestDate,
    required this.status,
    this.processedDate,
    this.processedBy,
    this.adminNotes,
  });

  WithdrawalRequest copyWith({
    String? status,
    DateTime? processedDate,
    String? processedBy,
    String? adminNotes,
  }) {
    return WithdrawalRequest(
      id: id,
      workerId: workerId,
      workerName: workerName,
      amount: amount,
      requestDate: requestDate,
      status: status ?? this.status,
      processedDate: processedDate ?? this.processedDate,
      processedBy: processedBy ?? this.processedBy,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'workerId': workerId,
    'workerName': workerName,
    'amount': amount,
    'requestDate': requestDate.toIso8601String(),
    'status': status,
    'processedDate': processedDate?.toIso8601String(),
    'processedBy': processedBy,
    'adminNotes': adminNotes,
  };

  factory WithdrawalRequest.fromMap(Map<String, dynamic> map) => WithdrawalRequest(
    id: map['id'],
    workerId: map['workerId'],
    workerName: map['workerName'],
    amount: map['amount'],
    requestDate: DateTime.parse(map['requestDate']),
    status: map['status'],
    processedDate: map['processedDate'] != null ? DateTime.parse(map['processedDate']) : null,
    processedBy: map['processedBy'],
    adminNotes: map['adminNotes'],
  );

  // Helper getters
  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';
}