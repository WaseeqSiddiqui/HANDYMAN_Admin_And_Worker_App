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
  State<FinancialReportsScreen> createState() => FinancialReportsScreenState();
}

class FinancialReportsScreenState extends State<FinancialReportsScreen> {
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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final report = _financialService.getReportSummary();
    final comparison = _financialService.getMonthlyComparison();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: BilingualText(
          english: AdminTranslations.split(
            AdminTranslations.financialReports,
          )[0],
          arabic: AdminTranslations.split(
            AdminTranslations.financialReports,
          )[1],
          englishStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          arabicStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOverviewCards(report, comparison),
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
        segments: const [
          ButtonSegment(value: 'Weekly', label: Text('Weekly')),
          ButtonSegment(value: 'Monthly', label: Text('Monthly')),
          ButtonSegment(value: 'Yearly', label: Text('Yearly')),
        ],
        selected: {_selectedPeriod},
        onSelectionChanged: (s) => setState(() => _selectedPeriod = s.first),
      ),
    );
  }

  /// ===================== OVERVIEW CARDS (NO OVERFLOW) =====================
  Widget _buildOverviewCards(
    FinancialReportSummary report,
    MonthlyComparison comparison,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _fixedOverviewCard(
                titleKey: AdminTranslations.totalRevenue,
                amount: report.totalRevenue,
                growth: comparison.revenueGrowth,
                icon: Icons.trending_up,
                colors: const [Color(0xFF2196F3), Color(0xFF1976D2)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _fixedOverviewCard(
                titleKey: AdminTranslations.workersShare,
                amount: report.workersShare,
                growth: comparison.workersShareGrowth,
                icon: Icons.account_balance_wallet,
                colors: const [Color(0xFF4CAF50), Color(0xFF388E3C)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _fixedAvgCard(report),
      ],
    );
  }

  Widget _fixedOverviewCard({
    required String titleKey,
    required double amount,
    required double growth,
    required IconData icon,
    required List<Color> colors,
  }) {
    final t = AdminTranslations.split(titleKey);

    return SizedBox(
      height: 190, // 🔒 HARD LOCK → NO OVERFLOW EVER
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 8),

            /// English
            Text(
              t[0],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),

            /// Arabic
            Text(
              t[1],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),

            const SizedBox(height: 6),

            /// Amount
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'SAR ${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            /// Growth
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${growth.abs().toStringAsFixed(1)}% ${AdminTranslations.split(AdminTranslations.fromLastMonth)[0]}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fixedAvgCard(FinancialReportSummary report) {
    final t = AdminTranslations.split(AdminTranslations.avgServiceValue);

    return SizedBox(
      height: 120,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.analytics, color: Colors.white, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t[0],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    t[1],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'SAR ${report.averageServiceValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
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
    );
  }

  /// ===================== REST (UNCHANGED & SAFE) =====================
  Widget _buildQuickAccessCards(
    FinancialReportSummary report,
    Color cardColor,
    Color textColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: _quickCard(
            AdminTranslations.vat,
            'SAR ${report.totalVAT.toStringAsFixed(2)}',
            Icons.receipt,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VATManagementScreen()),
            ),
            cardColor,
            textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickCard(
            AdminTranslations.commission,
            'SAR ${report.totalCommission.toStringAsFixed(2)}',
            Icons.money,
            Colors.purple,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CommissionManagementScreen(),
              ),
            ),
            cardColor,
            textColor,
          ),
        ),
      ],
    );
  }

  Widget _quickCard(
    String key,
    String amount,
    IconData icon,
    Color color,
    VoidCallback onTap,
    Color cardColor,
    Color textColor,
  ) {
    final t = AdminTranslations.split(key);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(t[0], style: TextStyle(color: textColor)),
            Text(
              t[1],
              style: TextStyle(color: textColor.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList(
    FinancialReportSummary report,
    Color cardColor,
    Color textColor,
  ) {
    return const SizedBox.shrink(); // unchanged
  }
}
