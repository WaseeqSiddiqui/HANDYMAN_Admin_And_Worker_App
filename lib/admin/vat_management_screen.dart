import 'package:flutter/material.dart';
import '../services/financial_service.dart';
import '../models/vat_model.dart';
import '../utils/admin_translations.dart';
import '../widgets/bilingual_text.dart';

class VATManagementScreen extends StatefulWidget {
  const VATManagementScreen({super.key});

  @override
  State<VATManagementScreen> createState() =>
      VATManagementScreenState();
}

class VATManagementScreenState
    extends State<VATManagementScreen> {
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
    final totalVAT = _financialService.getTotalVATCollected();
    final vatRecords = _financialService.getVATRecords();

    return Scaffold(
      appBar: AppBar(
        title: BilingualText( // ✅ Bilingual app bar title
          english: AdminTranslations.split(AdminTranslations.vatManagement)[0],
          arabic: AdminTranslations.split(AdminTranslations.vatManagement)[1],
          englishStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          arabicStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF005DFF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportVATReport(),
            tooltip: AdminTranslations.split(AdminTranslations.exportVatReport)[0],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildVATSummaryCard(totalVAT, vatRecords.length),
          _buildPeriodSelector(),
          const SizedBox(height: 16),
          _buildVATRecordsSection(vatRecords),
        ],
      ),
    );
  }

  Widget _buildVATSummaryCard(double total, int recordCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800), // ✅ Orange color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          BilingualText(
            english: AdminTranslations.split(AdminTranslations.totalVatCollected)[0],
            arabic: AdminTranslations.split(AdminTranslations.totalVatCollected)[1],
            englishStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white, // ✅ White text on orange
            ),
          ),
          const SizedBox(height: 8),

          // Amount
          Text(
            'SAR ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white, // ✅ White text on orange
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.3), // ✅ White divider
          ),
          const SizedBox(height: 16),

          // Services Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceInfo(
                AdminTranslations.split(AdminTranslations.services)[0],
                AdminTranslations.split(AdminTranslations.services)[1],
                recordCount.toString(),
              ),
              _buildServiceInfo(
                AdminTranslations.split(AdminTranslations.autoUpdated)[0],
                AdminTranslations.split(AdminTranslations.autoUpdated)[1],
                AdminTranslations.split(AdminTranslations.realTime)[0],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfo(String labelEn, String labelAr, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BilingualText(
          english: labelEn,
          arabic: labelAr,
          englishStyle: const TextStyle(
            fontSize: 12,
            color: Colors.white70, // ✅ Light white text
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // ✅ White text
          ),
        ),
      ],
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
          final isSelected = _selectedPeriod == AdminTranslations.getEnglish(period);
          final periodText = AdminTranslations.getEnglish(period);

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = periodText),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6B5B9A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  periodText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildVATRecordsSection(List<VATRecord> vatRecords) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BilingualText(
                  english: AdminTranslations.split(AdminTranslations.vatRecords)[0],
                  arabic: AdminTranslations.split(AdminTranslations.vatRecords)[1],
                  englishStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${vatRecords.length} ${AdminTranslations.split(AdminTranslations.records)[0]}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Records List or Empty State
          Expanded(
            child: vatRecords.isEmpty
                ? _buildEmptyState()
                : _buildVATList(vatRecords),
          ),
        ],
      ),
    );
  }

  Widget _buildVATList(List<VATRecord> records) {
    final sortedRecords = records.reversed.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        return _buildVATRecordCard(record);
      },
    );
  }

  Widget _buildVATRecordCard(VATRecord record) {
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
                      Text(
                        '${AdminTranslations.split(AdminTranslations.serviceId)[0]}: ${record.serviceId}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'SAR ${record.vatAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFFF9800), // ✅ Orange color for VAT amount
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRecordInfo(
                  AdminTranslations.split(AdminTranslations.serviceAmount)[0],
                  'SAR ${record.serviceAmount.toStringAsFixed(2)}',
                ),
                _buildRecordInfo(
                  AdminTranslations.split(AdminTranslations.vatRate)[0],
                  '${record.vatRate.toStringAsFixed(0)}%',
                ),
                _buildRecordInfo(
                  AdminTranslations.split(AdminTranslations.date)[0],
                  _formatDate(record.date),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
            child: Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          BilingualText(
            english: AdminTranslations.split(AdminTranslations.noVatRecordsTitle)[0],
            arabic: AdminTranslations.split(AdminTranslations.noVatRecordsTitle)[1],
            englishStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: BilingualText(
              english: AdminTranslations.split(AdminTranslations.noVatRecords)[0],
              arabic: AdminTranslations.split(AdminTranslations.noVatRecords)[1],
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

  void _exportVATReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AdminTranslations.split(AdminTranslations.vatReportExported)[0]),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}