// models/admin_wallet_transaction.dart
// ✅ Wallet Transaction Model for Admin Wallet

class WalletTransaction {
  final String id;
  final String description;
  final String type; // 'credit' or 'debit'
  final double amount;
  final double balanceAfter;
  final DateTime date;
  final String? serviceId; // Optional reference to service

  WalletTransaction({
    required this.id,
    required this.description,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.date,
    this.serviceId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'description': description,
    'type': type,
    'amount': amount,
    'balanceAfter': balanceAfter,
    'date': date.toIso8601String(),
    'serviceId': serviceId,
  };

  factory WalletTransaction.fromMap(Map<String, dynamic> map) => WalletTransaction(
    id: map['id'],
    description: map['description'],
    type: map['type'],
    amount: map['amount'],
    balanceAfter: map['balanceAfter'],
    date: DateTime.parse(map['date']),
    serviceId: map['serviceId'],
  );

  // Helper getters
  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';
}