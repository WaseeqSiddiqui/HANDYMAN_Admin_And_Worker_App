// models/monthly_comparison_model.dart
import 'financial_report_summary_model.dart';

class MonthlyComparison {
  final FinancialReportSummary currentMonth;
  final FinancialReportSummary previousMonth;
  final double revenueGrowth; // in percent
  final double workersShareGrowth; // in percent
  final double servicesGrowth; // in percent

  MonthlyComparison({
    required this.currentMonth,
    required this.previousMonth,
    required this.revenueGrowth,
    required this.workersShareGrowth,
    required this.servicesGrowth,
  });

  Map<String, dynamic> toMap() => {
    'currentMonth': currentMonth.toMap(),
    'previousMonth': previousMonth.toMap(),
    'revenueGrowth': revenueGrowth,
    'workersShareGrowth': workersShareGrowth,
    'servicesGrowth': servicesGrowth,
  };

  factory MonthlyComparison.fromMap(Map<String, dynamic> map) => MonthlyComparison(
    currentMonth: FinancialReportSummary.fromMap(map['currentMonth']),
    previousMonth: FinancialReportSummary.fromMap(map['previousMonth']),
    revenueGrowth: map['revenueGrowth'],
    workersShareGrowth: map['workersShareGrowth'],
    servicesGrowth: map['servicesGrowth'],
  );

  // Helper getters
  bool get isRevenueUp => revenueGrowth > 0;
  bool get isWorkersShareUp => workersShareGrowth > 0;
  bool get isServicesUp => servicesGrowth > 0;
}