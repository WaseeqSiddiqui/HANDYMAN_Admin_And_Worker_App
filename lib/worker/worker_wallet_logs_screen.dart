import 'package:flutter/material.dart';
import '/utils/worker_translations.dart';

class WorkerWalletLogsScreen extends StatefulWidget {
  const WorkerWalletLogsScreen({super.key});

  @override
  State<WorkerWalletLogsScreen> createState() => _WorkerWalletLogsScreenState();
}

class _WorkerWalletLogsScreenState extends State<WorkerWalletLogsScreen> {
  String _selectedType = WorkerTranslations.getEnglish(WorkerTranslations.all);
  String _selectedPeriod = WorkerTranslations.getEnglish('All Time • كل الوقت');

  final List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactions.addAll([
      {
        'id': 'LOG001',
        'type': 'credit_deduction',
        'category': WorkerTranslations.getEnglish('Service Acceptance • قبول الخدمة'),
        'description': WorkerTranslations.getEnglish('Credit deducted for accepting service SRV001 • تم خصم الرصيد لقبول الخدمة SRV001'),
        'serviceId': 'SRV001',
        'serviceName': 'AC Repair',
        'amount': -112.50,
        'vat': 67.50,
        'commission': 45.00,
        'balanceBefore': 850.00,
        'balanceAfter': 737.50,
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'status': WorkerTranslations.getEnglish(WorkerTranslations.completed),
      },
      {
        'id': 'LOG002',
        'type': 'wallet_credit',
        'category': WorkerTranslations.getEnglish('Service Completion • إتمام الخدمة'),
        'description': WorkerTranslations.getEnglish('Payment received for completed service SRV002 • تم استلام الدفع للخدمة المكتملة SRV002'),
        'serviceId': 'SRV002',
        'serviceName': 'Refrigerator Repair',
        'amount': 650.00,
        'balanceBefore': 2100.00,
        'balanceAfter': 2750.00,
        'date': DateTime.now().subtract(const Duration(hours: 5)),
        'status': WorkerTranslations.getEnglish(WorkerTranslations.completed),
      },
      {
        'id': 'LOG003',
        'type': 'credit_topup',
        'category': WorkerTranslations.getEnglish('Top-up from Wallet • شحن من المحفظة'),
        'description': WorkerTranslations.getEnglish('Credit topped up from wallet balance • تم شحن الرصيد من رصيد المحفظة'),
        'amount': 500.00,
        'balanceBefore': 737.50,
        'balanceAfter': 1237.50,
        'paymentMethod': 'wallet',
        'date': DateTime.now().subtract(const Duration(hours: 8)),
        'status': WorkerTranslations.getEnglish(WorkerTranslations.completed),
      },
      {
        'id': 'LOG004',
        'type': 'credit_deduction',
        'category': WorkerTranslations.getEnglish('Extra Charges • رسوم إضافية'),
        'description': WorkerTranslations.getEnglish('Additional credit deducted for extra service charges • تم خصم رصيد إضافي للرسوم الإضافية للخدمة'),
        'serviceId': 'SRV001',
        'serviceName': 'AC Repair',
        'amount': -45.00,
        'vat': 27.00,
        'commission': 18.00,
        'balanceBefore': 1237.50,
        'balanceAfter': 1192.50,
        'date': DateTime.now().subtract(const Duration(hours: 10)),
        'status': WorkerTranslations.getEnglish(WorkerTranslations.completed),
      },
      {
        'id': 'LOG005',
        'type': 'wallet_debit',
        'category': WorkerTranslations.getEnglish('Withdrawal • سحب'),
        'description': WorkerTranslations.getEnglish('Withdrawal to STC Bank • سحب إلى STC Bank'),
        'amount': -2500.00,
        'balanceBefore': 2750.00,
        'balanceAfter': 250.00,
        'paymentMethod': 'stc_bank',
        'bankAccount': '+966501234567',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'status': WorkerTranslations.getEnglish(WorkerTranslations.completed),
      },
      {
        'id': 'LOG006',
        'type': 'credit_topup',
        'category': WorkerTranslations.getEnglish('Top-up from STC Bank • شحن من STC Bank'),
        'description': WorkerTranslations.getEnglish('Credit topped up from STC Bank • تم شحن الرصيد من STC Bank'),
        'amount': 1000.00,
        'balanceBefore': 450.00,
        'balanceAfter': 1450.00,
        'paymentMethod': 'stc_bank',
        'bankAccount': '+966501234567',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'status': WorkerTranslations.getEnglish(WorkerTranslations.completed),
      },
      {
        'id': 'LOG007',
        'type': 'credit_adjustment',
        'category': WorkerTranslations.getEnglish('Admin Adjustment • تعديل إداري'),
        'description': WorkerTranslations.getEnglish('Credit adjusted by admin - Bonus for excellent service • تم تعديل الرصيد من قبل المشرف - مكافأة للخدمة الممتازة'),
        'amount': 200.00,
        'balanceBefore': 1192.50,
        'balanceAfter': 1392.50,
        'adjustedBy': WorkerTranslations.getEnglish(WorkerTranslations.admin),
        'reason': WorkerTranslations.getEnglish('Performance bonus • مكافأة الأداء'),
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'status': WorkerTranslations.getEnglish(WorkerTranslations.completed),
      },
      {
        'id': 'LOG008',
        'type': 'credit_deduction',
        'category': WorkerTranslations.getEnglish('Complaint Penalty • غرامة شكوى'),
        'description': WorkerTranslations.getEnglish('Credit deducted due to customer complaint • تم خصم الرصيد بسبب شكوى العميل'),
        'complaintId': 'CMP001',
        'amount': -150.00,
        'balanceBefore': 1392.50,
        'balanceAfter': 1242.50,
        'adjustedBy': WorkerTranslations.getEnglish(WorkerTranslations.admin),
        'reason': WorkerTranslations.getEnglish('Service quality issue • مشكلة في جودة الخدمة'),
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'status': WorkerTranslations.getEnglish(WorkerTranslations.completed),
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _getFilteredTransactions();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(WorkerTranslations.walletLogs),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          _buildTypeFilter(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: filteredTransactions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  return _buildTransactionCard(filteredTransactions[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Summary Cards
  Widget _buildSummaryCards() {
    final totalCredit = _transactions
        .where((t) => t['type'] == 'credit_topup' || t['type'] == 'credit_adjustment' && t['amount'] > 0)
        .fold<double>(0, (sum, t) => sum + t['amount']);

    final totalDebit = _transactions
        .where((t) => t['type'] == 'credit_deduction' || (t['type'] == 'credit_adjustment' && t['amount'] < 0))
        .fold<double>(0, (sum, t) => sum + t['amount'].abs());

    final totalWalletCredit = _transactions
        .where((t) => t['type'] == 'wallet_credit')
        .fold<double>(0, (sum, t) => sum + t['amount']);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              WorkerTranslations.getEnglish('Total Credits • إجمالي الرصيد'),
              totalCredit,
              Icons.add_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              WorkerTranslations.getEnglish('Total Debits • إجمالي الخصومات'),
              totalDebit,
              Icons.remove_circle,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              WorkerTranslations.getEnglish('Earnings • الأرباح'),
              totalWalletCredit,
              Icons.attach_money,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '${WorkerTranslations.sar.split(' • ')[0]} ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Type Filter
  Widget _buildTypeFilter() {
    final filterTypes = [
      WorkerTranslations.all,
      'Credit Top-up • شحن الرصيد',
      'Credit Deduction • خصم الرصيد',
      'Wallet Credit • رصيد المحفظة',
      'Wallet Debit • خصم المحفظة',
      'Adjustments • تعديلات'
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filterTypes.map((type) {
          final isSelected = _selectedType == WorkerTranslations.getEnglish(type);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(WorkerTranslations.getEnglish(type)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedType = WorkerTranslations.getEnglish(type));
              },
              selectedColor: const Color(0xFF6B5B9A),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Transaction Card
  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    IconData icon;
    Color iconColor;
    Color amountColor;

    switch (transaction['type']) {
      case 'credit_topup':
      case 'wallet_credit':
        icon = Icons.add_circle;
        iconColor = Colors.green;
        amountColor = Colors.green;
        break;
      case 'credit_deduction':
      case 'wallet_debit':
        icon = Icons.remove_circle;
        iconColor = Colors.red;
        amountColor = Colors.red;
        break;
      case 'credit_adjustment':
        icon = transaction['amount'] > 0 ? Icons.add_circle : Icons.remove_circle;
        iconColor = transaction['amount'] > 0 ? Colors.green : Colors.red;
        amountColor = transaction['amount'] > 0 ? Colors.green : Colors.red;
        break;
      default:
        icon = Icons.swap_horiz;
        iconColor = Colors.blue;
        amountColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          WorkerTranslations.getEnglish(transaction['category']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          WorkerTranslations.getEnglish(transaction['description']),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${transaction['amount'] > 0 ? '+' : ''}${WorkerTranslations.sar.split(' • ')[0]} ${transaction['amount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: amountColor,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          WorkerTranslations.getEnglish(transaction['status']),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(transaction['date']),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  if (transaction['serviceId'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction['serviceId'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (transaction['vat'] != null || transaction['commission'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (transaction['vat'] != null)
                          Text(
                            '${WorkerTranslations.getEnglish(WorkerTranslations.vat)}: ${WorkerTranslations.sar.split(' • ')[0]} ${transaction['vat'].toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        if (transaction['commission'] != null)
                          Text(
                            '${WorkerTranslations.getEnglish(WorkerTranslations.commission)}: ${WorkerTranslations.sar.split(' • ')[0]} ${transaction['commission'].toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            WorkerTranslations.getEnglish(WorkerTranslations.noWalletLogs),
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            WorkerTranslations.getEnglish(WorkerTranslations.firstTransactionAppear),
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // Filter Dialog
  void _showFilterDialog() {
    final periodOptions = [
      'All Time • كل الوقت',
      'Today • اليوم',
      'This Week • هذا الأسبوع',
      'This Month • هذا الشهر',
      'Last Month • الشهر الماضي'
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              WorkerTranslations.getBilingual('Filter Transactions', 'تصفية المعاملات'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(WorkerTranslations.getBilingual('Period', 'الفترة'), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: periodOptions
                  .map((period) => ChoiceChip(
                label: Text(WorkerTranslations.getEnglish(period)),
                selected: _selectedPeriod == WorkerTranslations.getEnglish(period),
                onSelected: (selected) {
                  setState(() => _selectedPeriod = WorkerTranslations.getEnglish(period));
                  Navigator.pop(context);
                },
              ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedType = WorkerTranslations.getEnglish(WorkerTranslations.all);
                    _selectedPeriod = WorkerTranslations.getEnglish('All Time • كل الوقت');
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                ),
                child: Text(WorkerTranslations.getBilingual('Reset Filters', 'إعادة تعيين الفلاتر')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Transaction Details
  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  WorkerTranslations.getBilingual('Transaction Details', 'تفاصيل المعاملة'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildDetailRow(WorkerTranslations.getBilingual('Transaction ID', 'معرف المعاملة'), transaction['id']),
                _buildDetailRow(WorkerTranslations.getBilingual('Type', 'النوع'), transaction['type']),
                _buildDetailRow(WorkerTranslations.getBilingual('Category', 'الفئة'), WorkerTranslations.getEnglish(transaction['category'])),
                const Divider(height: 24),
                _buildDetailRow(WorkerTranslations.getBilingual('Description', 'الوصف'), WorkerTranslations.getEnglish(transaction['description'])),
                if (transaction['serviceId'] != null) ...[
                  _buildDetailRow(WorkerTranslations.getBilingual('Service ID', 'معرف الخدمة'), transaction['serviceId']),
                  _buildDetailRow(WorkerTranslations.getBilingual('Service', 'الخدمة'), transaction['serviceName']),
                ],
                if (transaction['complaintId'] != null)
                  _buildDetailRow(WorkerTranslations.getBilingual('Complaint ID', 'معرف الشكوى'), transaction['complaintId']),
                const Divider(height: 24),
                _buildDetailRow(
                  WorkerTranslations.getBilingual('Amount', 'المبلغ'),
                  '${transaction['amount'] > 0 ? '+' : ''}${WorkerTranslations.sar.split(' • ')[0]} ${transaction['amount'].toStringAsFixed(2)}',
                  isBold: true,
                ),
                if (transaction['vat'] != null)
                  _buildDetailRow(WorkerTranslations.getBilingual('VAT', 'ضريبة القيمة المضافة'), '${WorkerTranslations.sar.split(' • ')[0]} ${transaction['vat'].toStringAsFixed(2)}'),
                if (transaction['commission'] != null)
                  _buildDetailRow(WorkerTranslations.getBilingual('Commission', 'العمولة'), '${WorkerTranslations.sar.split(' • ')[0]} ${transaction['commission'].toStringAsFixed(2)}'),
                const Divider(height: 24),
                _buildDetailRow(WorkerTranslations.getBilingual('Balance Before', 'الرصيد قبل'), '${WorkerTranslations.sar.split(' • ')[0]} ${transaction['balanceBefore'].toStringAsFixed(2)}'),
                _buildDetailRow(WorkerTranslations.getBilingual('Balance After', 'الرصيد بعد'), '${WorkerTranslations.sar.split(' • ')[0]} ${transaction['balanceAfter'].toStringAsFixed(2)}'),
                const Divider(height: 24),
                if (transaction['paymentMethod'] != null)
                  _buildDetailRow(WorkerTranslations.getBilingual('Payment Method', 'طريقة الدفع'), transaction['paymentMethod']),
                if (transaction['bankAccount'] != null)
                  _buildDetailRow(WorkerTranslations.getBilingual('Bank Account', 'الحساب البنكي'), transaction['bankAccount']),
                if (transaction['adjustedBy'] != null) ...[
                  _buildDetailRow(WorkerTranslations.getBilingual('Adjusted By', 'تم التعديل بواسطة'), WorkerTranslations.getEnglish(transaction['adjustedBy'])),
                  _buildDetailRow(WorkerTranslations.getBilingual('Reason', 'السبب'), WorkerTranslations.getEnglish(transaction['reason'])),
                ],
                _buildDetailRow(WorkerTranslations.getBilingual('Date', 'التاريخ'), _formatDateTime(transaction['date'])),
                _buildDetailRow(WorkerTranslations.getBilingual('Status', 'الحالة'), WorkerTranslations.getEnglish(transaction['status'])),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            WorkerTranslations.getEnglish(label),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  List<Map<String, dynamic>> _getFilteredTransactions() {
    return _transactions.where((transaction) {
      if (_selectedType == WorkerTranslations.getEnglish(WorkerTranslations.all)) return true;

      switch (_selectedType) {
        case 'Credit Top-up':
          return transaction['type'] == 'credit_topup';
        case 'Credit Deduction':
          return transaction['type'] == 'credit_deduction';
        case 'Wallet Credit':
          return transaction['type'] == 'wallet_credit';
        case 'Wallet Debit':
          return transaction['type'] == 'wallet_debit';
        case 'Adjustments':
          return transaction['type'] == 'credit_adjustment';
        default:
          return true;
      }
    }).toList();
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${WorkerTranslations.getEnglish(WorkerTranslations.minAgo)}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${WorkerTranslations.getEnglish(WorkerTranslations.hAgo)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${WorkerTranslations.getEnglish(WorkerTranslations.daysAgo)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Refresh data
    });
  }
}