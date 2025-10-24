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

class Invoice {
  final String id;
  final String serviceRequestId;
  final String workerId;
  final String workerName;
  final String customerId;
  final String customerName;
  final double servicePrice;
  final double extraCharges;
  final double subtotal;
  final double vatAmount;
  final double totalAmount;
  final double commissionAmount;
  final List<ExtraItem> extraItems;
  final PaymentMethod paymentMethod;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? paidAt;

  Invoice({
    required this.id,
    required this.serviceRequestId,
    required this.workerId,
    required this.workerName,
    required this.customerId,
    required this.customerName,
    required this.servicePrice,
    required this.extraCharges,
    required this.subtotal,
    required this.vatAmount,
    required this.totalAmount,
    required this.commissionAmount,
    required this.extraItems,
    required this.paymentMethod,
    this.isPaid = false,
    required this.createdAt,
    this.paidAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      serviceRequestId: json['serviceRequestId'],
      workerId: json['workerId'],
      workerName: json['workerName'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      servicePrice: json['servicePrice'].toDouble(),
      extraCharges: json['extraCharges'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
      vatAmount: json['vatAmount'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      commissionAmount: json['commissionAmount'].toDouble(),
      extraItems: (json['extraItems'] as List)
          .map((e) => ExtraItem.fromJson(e))
          .toList(),
      paymentMethod: PaymentMethod.values.firstWhere(
            (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
      ),
      isPaid: json['isPaid'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceRequestId': serviceRequestId,
      'workerId': workerId,
      'workerName': workerName,
      'customerId': customerId,
      'customerName': customerName,
      'servicePrice': servicePrice,
      'extraCharges': extraCharges,
      'subtotal': subtotal,
      'vatAmount': vatAmount,
      'totalAmount': totalAmount,
      'commissionAmount': commissionAmount,
      'extraItems': extraItems.map((e) => e.toJson()).toList(),
      'paymentMethod': paymentMethod.toString().split('.').last,
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
    };
  }
}

class ExtraItem {
  final String name;
  final String type;
  final double price;
  final String? description;

  ExtraItem({
    required this.name,
    required this.type,
    required this.price,
    this.description,
  });

  factory ExtraItem.fromJson(Map<String, dynamic> json) {
    return ExtraItem(
      name: json['name'],
      type: json['type'],
      price: json['price'].toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'price': price,
      'description': description,
    };
  }
}

enum PaymentMethod { cash, online }