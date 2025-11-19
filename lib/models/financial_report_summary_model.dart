// models/financial_report_summary_model.dart
import 'financial_transaction_model.dart';

class FinancialReportSummary {
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double workersShare;
  final int totalServices;
  final double averageServiceValue;
  final double totalVAT;
  final double totalCommission;
  final List<FinancialTransaction> transactions;

  FinancialReportSummary({
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.workersShare,
    required this.totalServices,
    required this.averageServiceValue,
    required this.totalVAT,
    required this.totalCommission,
    required this.transactions,
  });

  Map<String, dynamic> toMap() => {
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'totalRevenue': totalRevenue,
    'workersShare': workersShare,
    'totalServices': totalServices,
    'averageServiceValue': averageServiceValue,
    'totalVAT': totalVAT,
    'totalCommission': totalCommission,
    'transactions': transactions.map((t) => t.toMap()).toList(),
  };

  factory FinancialReportSummary.fromMap(Map<String, dynamic> map) => FinancialReportSummary(
    startDate: DateTime.parse(map['startDate']),
    endDate: DateTime.parse(map['endDate']),
    totalRevenue: map['totalRevenue'],
    workersShare: map['workersShare'],
    totalServices: map['totalServices'],
    averageServiceValue: map['averageServiceValue'],
    totalVAT: map['totalVAT'],
    totalCommission: map['totalCommission'],
    transactions: (map['transactions'] as List)
        .map((t) => FinancialTransaction.fromMap(t))
        .toList(),
  );
}