enum TransactionType {
  creditTopup,
  creditDeduction,
  walletEarning,
  walletWithdrawal,
  commission,
  vat
}

class Transaction {
  final String id;
  final String workerId;
  final String workerName;
  final TransactionType type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? serviceRequestId;
  final String? reference;
  final String? description;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.serviceRequestId,
    this.reference,
    this.description,
    required this.createdAt,
  });

  String get typeLabel {
    switch (type) {
      case TransactionType.creditTopup:
        return 'Credit Top-up';
      case TransactionType.creditDeduction:
        return 'Credit Deduction';
      case TransactionType.walletEarning:
        return 'Wallet Earning';
      case TransactionType.walletWithdrawal:
        return 'Wallet Withdrawal';
      case TransactionType.commission:
        return 'Commission';
      case TransactionType.vat:
        return 'VAT';
    }
  }

  bool get isCredit =>
      type == TransactionType.creditTopup || type == TransactionType.creditDeduction;

  bool get isWallet =>
      type == TransactionType.walletEarning ||
          type == TransactionType.walletWithdrawal;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      workerId: json['workerId'],
      workerName: json['workerName'],
      type: TransactionType.values.firstWhere(
            (e) => e.toString() == 'TransactionType.${json['type']}',
      ),
      amount: json['amount'].toDouble(),
      balanceBefore: json['balanceBefore'].toDouble(),
      balanceAfter: json['balanceAfter'].toDouble(),
      serviceRequestId: json['serviceRequestId'],
      reference: json['reference'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workerId': workerId,
      'workerName': workerName,
      'type': type.toString().split('.').last,
      'amount': amount,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'serviceRequestId': serviceRequestId,
      'reference': reference,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// ✅ REMOVED: Invoice, ExtraItem, and PaymentMethod classes
// These should ONLY exist in service_request_model.dart to avoid duplication