import 'package:flutter/material.dart';
import '../services/financial_service.dart';
import '../models/commission_record_model.dart';
import '../utils/admin_translations.dart';
import '../widgets/bilingual_text.dart';

class CommissionManagementScreen extends StatefulWidget {
  const CommissionManagementScreen({super.key});

  @override
  State<CommissionManagementScreen> createState() =>
      CommissionManagementScreenState();
}

class CommissionManagementScreenState
    extends State<CommissionManagementScreen> {
  final _financialService = FinancialService();
  String _selectedPeriod = 'This Month';

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
    // ✅ Filter records based on selection
    final commissionRecords = _getFilteredRecords();

    // ✅ Calculate total from FILTERED records
    final totalCommission = commissionRecords.fold<double>(
      0.0,
      (sum, record) => sum + record.commissionAmount,
    );

    return Scaffold(
      appBar: AppBar(
        title: BilingualText(
          // ✅ Bilingual app bar title
          english: AdminTranslations.split(
            AdminTranslations.commissionManagement,
          )[0],
          arabic: AdminTranslations.split(
            AdminTranslations.commissionManagement,
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
          _buildCommissionSummaryCard(
            totalCommission,
            commissionRecords.length,
          ),
          _buildPeriodSelector(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BilingualText(
                  english: AdminTranslations.split(
                    AdminTranslations.commissionRecords,
                  )[0],
                  arabic: AdminTranslations.split(
                    AdminTranslations.commissionRecords,
                  )[1],
                  englishStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${commissionRecords.length} ${AdminTranslations.split(AdminTranslations.records)[0]}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: commissionRecords.isEmpty
                ? _buildEmptyState()
                : _buildCommissionList(commissionRecords),
          ),
        ],
      ),
    );
  }

  // ✅ New helper to filter records
  List<CommissionRecord> _getFilteredRecords() {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime.now(); // End is always now

    // Check English string because value is stored in English (from buildPeriodSelector)
    if (_selectedPeriod ==
        AdminTranslations.getEnglish(AdminTranslations.today)) {
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (_selectedPeriod ==
        AdminTranslations.getEnglish(AdminTranslations.thisWeek)) {
      start = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
    } else if (_selectedPeriod ==
        AdminTranslations.getEnglish(AdminTranslations.thisMonth)) {
      start = DateTime(now.year, now.month, 1);
    } else {
      // All Time
      return _financialService.getCommissionRecords();
    }

    return _financialService.getCommissionByDateRange(start, end);
  }

  Widget _buildCommissionSummaryCard(double total, int recordCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BilingualText(
                english:
                    '${AdminTranslations.split(AdminTranslations.totalCommission)[0]} ($_selectedPeriod)',
                arabic: AdminTranslations.split(
                  AdminTranslations.totalCommission,
                )[1],
                englishStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'SAR ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip(
                AdminTranslations.split(AdminTranslations.services)[0],
                AdminTranslations.split(AdminTranslations.services)[1],
                recordCount.toString(),
                Icons.build_circle,
              ),
              _buildInfoChip(
                AdminTranslations.split(AdminTranslations.autoUpdated)[0],
                AdminTranslations.split(AdminTranslations.autoUpdated)[1],
                AdminTranslations.split(AdminTranslations.realTime)[0],
                Icons.sync,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    String labelEn,
    String labelAr,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BilingualText(
                english: labelEn,
                arabic: labelAr,
                englishStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = [
      AdminTranslations.today,
      AdminTranslations.thisWeek,
      AdminTranslations.thisMonth,
      AdminTranslations.allTime,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected =
              _selectedPeriod == AdminTranslations.getEnglish(period);
          final periodText = AdminTranslations.getEnglish(period);

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = periodText),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6B5B9A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  periodText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCommissionList(List<CommissionRecord> records) {
    // Show most recent first
    final sortedRecords = records.reversed.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        return _buildCommissionCard(record);
      },
    );
  }

  Widget _buildCommissionCard(CommissionRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.serviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            record.workerName,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'SAR ${record.commissionAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF9C27B0),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        record.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(
                  AdminTranslations.split(AdminTranslations.serviceAmount)[0],
                  AdminTranslations.split(AdminTranslations.serviceAmount)[1],
                  'SAR ${record.serviceAmount.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
                _buildInfoRow(
                  AdminTranslations.split(AdminTranslations.rateLabel)[0],
                  AdminTranslations.split(AdminTranslations.rateLabel)[1],
                  '${record.commissionRate.toStringAsFixed(0)}%',
                  Icons.percent,
                ),
                _buildInfoRow(
                  AdminTranslations.split(AdminTranslations.date)[0],
                  AdminTranslations.split(AdminTranslations.date)[1],
                  _formatDate(record.date),
                  Icons.calendar_today,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String labelEn,
    String labelAr,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            BilingualText(
              english: labelEn,
              arabic: labelAr,
              englishStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final emptyMessageParts = AdminTranslations.split(
      AdminTranslations.noCommissionRecords,
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.money_off, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          BilingualText(
            english: AdminTranslations.split(
              AdminTranslations.commissionRecords,
            )[0],
            arabic: AdminTranslations.split(
              AdminTranslations.commissionRecords,
            )[1],
            englishStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: BilingualText(
              english: emptyMessageParts[0],
              arabic: emptyMessageParts[1],
              englishStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
