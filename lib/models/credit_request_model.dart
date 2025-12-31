class CreditRequest {
  final String id;
  final String workerId;
  final String workerName;
  final double amount;
  final String referenceNumber;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime requestDate;
  final DateTime? processedDate;
  final String? adminNotes;

  CreditRequest({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.amount,
    required this.referenceNumber,
    required this.status,
    required this.requestDate,
    this.processedDate,
    this.adminNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workerId': workerId,
      'workerName': workerName,
      'amount': amount,
      'referenceNumber': referenceNumber,
      'status': status,
      'requestDate': requestDate.toIso8601String(),
      'processedDate': processedDate?.toIso8601String(),
      'adminNotes': adminNotes,
    };
  }

  factory CreditRequest.fromJson(Map<String, dynamic> json) {
    return CreditRequest(
      id: json['id'],
      workerId: json['workerId'],
      workerName: json['workerName'],
      amount: json['amount'].toDouble(),
      referenceNumber: json['referenceNumber'],
      status: json['status'],
      requestDate: DateTime.parse(json['requestDate']),
      processedDate: json['processedDate'] != null
          ? DateTime.parse(json['processedDate'])
          : null,
      adminNotes: json['adminNotes'],
    );
  }
}
