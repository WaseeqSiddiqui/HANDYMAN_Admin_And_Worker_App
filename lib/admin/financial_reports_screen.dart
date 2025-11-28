import 'package:flutter/material.dart';
import '../services/financial_service.dart';
import 'vat_management_screen.dart';
import 'commission_management_screen.dart';
import '../models/financial_report_summary_model.dart';
import '../models/monthly_comparison_model.dart';
import '../utils/admin_translations.dart';
import '../widgets/bilingual_text.dart';

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() =>
      FinancialReportsScreenState();
}

class FinancialReportsScreenState
    extends State<FinancialReportsScreen> {
  final _financialService = FinancialService();
  String _selectedPeriod = 'Monthly';

  @override
  void initState() {
    super.initState();
    _financialService.addListener(_onFinancialUpdate);
  }

  @override
  void dispose() {
    _financialService.removeListener(_onFinancialUpdate);
    super.dispose();
  }

  void _onFinancialUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
    isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final report = _financialService.getReportSummary();
    final comparison = _financialService.getMonthlyComparison();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: BilingualText( // ✅ Bilingual app bar title
          english: AdminTranslations.split(AdminTranslations.financialReports)[0],
          arabic: AdminTranslations.split(AdminTranslations.financialReports)[1],
          englishStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          arabicStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: AdminTranslations.split(AdminTranslations.refreshBtn)[0],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOverviewCards(
                      report, comparison, cardColor, textColor),
                  const SizedBox(height: 16),
                  _buildQuickAccessCards(report, cardColor, textColor),
                  const SizedBox(height: 16),
                  _buildReportsList(report, cardColor, textColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<String>(
        segments: [
          ButtonSegment(
            value: 'Weekly',
            label: Text(AdminTranslations.split(AdminTranslations.weekly)[0]),
          ),
          ButtonSegment(
            value: 'Monthly',
            label: Text(AdminTranslations.split(AdminTranslations.monthly)[0]),
          ),
          ButtonSegment(
            value: 'Yearly',
            label: Text(AdminTranslations.split(AdminTranslations.yearly)[0]),
          ),
        ],
        selected: {_selectedPeriod},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() => _selectedPeriod = newSelection.first);
        },
      ),
    );
  }

  Widget _buildOverviewCards(FinancialReportSummary report,
      MonthlyComparison comparison, Color cardColor, Color textColor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.trending_up,
                        color: Colors.white, size: 28),
                    const SizedBox(height: 12),
                    BilingualText(
                      english: AdminTranslations.split(AdminTranslations.totalRevenue)[0],
                      arabic: AdminTranslations.split(AdminTranslations.totalRevenue)[1],
                      englishStyle: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SAR ${report.totalRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            comparison.revenueGrowth >= 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comparison.revenueGrowth.abs().toStringAsFixed(1)}% ${AdminTranslations.split(AdminTranslations.fromLastMonth)[0]}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.account_balance_wallet,
                        color: Colors.white, size: 28),
                    const SizedBox(height: 12),
                    BilingualText(
                      english: AdminTranslations.split(AdminTranslations.workersShare)[0],
                      arabic: AdminTranslations.split(AdminTranslations.workersShare)[1],
                      englishStyle: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SAR ${report.workersShare.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            comparison.workersShareGrowth >= 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comparison.workersShareGrowth.abs().toStringAsFixed(1)}% ${AdminTranslations.split(AdminTranslations.fromLastMonth)[0]}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9800).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.white, size: 28),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BilingualText(
                        english: AdminTranslations.split(AdminTranslations.avgServiceValue)[0],
                        arabic: AdminTranslations.split(AdminTranslations.avgServiceValue)[1],
                        englishStyle: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SAR ${report.averageServiceValue.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${report.totalServices} ${AdminTranslations.split(AdminTranslations.services)[0]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCards(
      FinancialReportSummary report, Color cardColor, Color textColor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                AdminTranslations.split(AdminTranslations.vat)[0],
                AdminTranslations.split(AdminTranslations.vat)[1],
                'SAR ${report.totalVAT.toStringAsFixed(0)}',
                Icons.receipt,
                Colors.orange,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const VATManagementScreen(),
                    ),
                  );
                },
                cardColor,
                textColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                AdminTranslations.split(AdminTranslations.commission)[0],
                AdminTranslations.split(AdminTranslations.commission)[1],
                'SAR ${report.totalCommission.toStringAsFixed(0)}',
                Icons.money,
                Colors.purple,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const CommissionManagementScreen(),
                    ),
                  );
                },
                cardColor,
                textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
      String titleEn,
      String titleAr,
      String amount,
      IconData icon,
      Color color,
      VoidCallback onTap,
      Color cardColor,
      Color textColor,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: textColor.withOpacity(0.5)),
              ],
            ),
            const SizedBox(height: 12),
            BilingualText(
              english: titleEn,
              arabic: titleAr,
              englishStyle: TextStyle(
                fontSize: 13,
                color: textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList(
      FinancialReportSummary report, Color cardColor, Color textColor) {
    final transactions = report.transactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BilingualText(
            english: AdminTranslations.split(AdminTranslations.recentServices)[0],
            arabic: AdminTranslations.split(AdminTranslations.recentServices)[1],
            englishStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        transactions.isEmpty
            ? _buildEmptyServicesState()
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length > 5 ? 5 : transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions.reversed.toList()[index];
            return Card(
              color: cardColor,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B5B9A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Color(0xFF6B5B9A)),
                ),
                title: Text(
                  transaction.serviceName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AdminTranslations.split(AdminTranslations.worker)[0]}: ${transaction.workerName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '${AdminTranslations.split(AdminTranslations.customer)[0]}: ${transaction.customerName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'SAR ${transaction.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      _formatDate(transaction.completionDate),
                      style: TextStyle(
                        fontSize: 10,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyServicesState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.analytics_outlined,
                size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            BilingualText(
              english: AdminTranslations.split(AdminTranslations.noServicesYet)[0],
              arabic: AdminTranslations.split(AdminTranslations.noServicesYet)[1],
              englishStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return AdminTranslations.split(AdminTranslations.today)[0];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}