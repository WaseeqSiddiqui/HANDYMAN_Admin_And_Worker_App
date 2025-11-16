import 'package:flutter/material.dart';

class WorkerWalletLogsScreen extends StatefulWidget {
  const WorkerWalletLogsScreen({super.key});

  @override
  State<WorkerWalletLogsScreen> createState() => _WorkerWalletLogsScreenState();
}

class _WorkerWalletLogsScreenState extends State<WorkerWalletLogsScreen> {
  String _selectedType = 'All';
  String _selectedPeriod = 'All Time';

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
        'category': 'Service Acceptance',
        'description': 'Credit deducted for accepting service SRV001',
        'serviceId': 'SRV001',
        'serviceName': 'AC Repair',
        'amount': -112.50,
        'vat': 67.50,
        'commission': 45.00,
        'balanceBefore': 850.00,
        'balanceAfter': 737.50,
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'status': 'completed',
      },
      {
        'id': 'LOG002',
        'type': 'wallet_credit',
        'category': 'Service Completion',
        'description': 'Payment received for completed service SRV002',
        'serviceId': 'SRV002',
        'serviceName': 'Refrigerator Repair',
        'amount': 650.00,
        'balanceBefore': 2100.00,
        'balanceAfter': 2750.00,
        'date': DateTime.now().subtract(const Duration(hours: 5)),
        'status': 'completed',
      },
      {
        'id': 'LOG003',
        'type': 'credit_topup',
        'category': 'Top-up from Wallet',
        'description': 'Credit topped up from wallet balance',
        'amount': 500.00,
        'balanceBefore': 737.50,
        'balanceAfter': 1237.50,
        'paymentMethod': 'wallet',
        'date': DateTime.now().subtract(const Duration(hours: 8)),
        'status': 'completed',
      },
      {
        'id': 'LOG004',
        'type': 'credit_deduction',
        'category': 'Extra Charges',
        'description': 'Additional credit deducted for extra service charges',
        'serviceId': 'SRV001',
        'serviceName': 'AC Repair',
        'amount': -45.00,
        'vat': 27.00,
        'commission': 18.00,
        'balanceBefore': 1237.50,
        'balanceAfter': 1192.50,
        'date': DateTime.now().subtract(const Duration(hours: 10)),
        'status': 'completed',
      },
      {
        'id': 'LOG005',
        'type': 'wallet_debit',
        'category': 'Withdrawal',
        'description': 'Withdrawal to STC Bank',
        'amount': -2500.00,
        'balanceBefore': 2750.00,
        'balanceAfter': 250.00,
        'paymentMethod': 'stc_bank',
        'bankAccount': '+966501234567',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'status': 'completed',
      },
      {
        'id': 'LOG006',
        'type': 'credit_topup',
        'category': 'Top-up from STC Bank',
        'description': 'Credit topped up from STC Bank',
        'amount': 1000.00,
        'balanceBefore': 450.00,
        'balanceAfter': 1450.00,
        'paymentMethod': 'stc_bank',
        'bankAccount': '+966501234567',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'status': 'completed',
      },
      {
        'id': 'LOG007',
        'type': 'credit_adjustment',
        'category': 'Admin Adjustment',
        'description': 'Credit adjusted by admin - Bonus for excellent service',
        'amount': 200.00,
        'balanceBefore': 1192.50,
        'balanceAfter': 1392.50,
        'adjustedBy': 'Admin',
        'reason': 'Performance bonus',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'status': 'completed',
      },
      {
        'id': 'LOG008',
        'type': 'credit_deduction',
        'category': 'Complaint Penalty',
        'description': 'Credit deducted due to customer complaint',
        'complaintId': 'CMP001',
        'amount': -150.00,
        'balanceBefore': 1392.50,
        'balanceAfter': 1242.50,
        'adjustedBy': 'Admin',
        'reason': 'Service quality issue',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'status': 'completed',
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _getFilteredTransactions();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Wallet & Credit Logs'),
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
              'Total Credits',
              totalCredit,
              Icons.add_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Total Debits',
              totalDebit,
              Icons.remove_circle,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Earnings',
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
            'SAR ${amount.toStringAsFixed(2)}',
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          'All',
          'Credit Top-up',
          'Credit Deduction',
          'Wallet Credit',
          'Wallet Debit',
          'Adjustments'
        ].map((type) {
          final isSelected = _selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedType = type);
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
                          transaction['category'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transaction['description'],
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
                        '${transaction['amount'] > 0 ? '+' : ''}SAR ${transaction['amount'].toStringAsFixed(2)}',
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
                          transaction['status'],
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
                            'VAT: SAR ${transaction['vat'].toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        if (transaction['commission'] != null)
                          Text(
                            'Commission: SAR ${transaction['commission'].toStringAsFixed(2)}',
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
            'No transactions found',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // Filter Dialog
  void _showFilterDialog() {
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
            const Text(
              'Filter Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Period', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['All Time', 'Today', 'This Week', 'This Month', 'Last Month']
                  .map((period) => ChoiceChip(
                label: Text(period),
                selected: _selectedPeriod == period,
                onSelected: (selected) {
                  setState(() => _selectedPeriod = period);
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
                    _selectedType = 'All';
                    _selectedPeriod = 'All Time';
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Reset Filters'),
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
                const Text(
                  'Transaction Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Transaction ID', transaction['id']),
                _buildDetailRow('Type', transaction['type']),
                _buildDetailRow('Category', transaction['category']),
                const Divider(height: 24),
                _buildDetailRow('Description', transaction['description']),
                if (transaction['serviceId'] != null) ...[
                  _buildDetailRow('Service ID', transaction['serviceId']),
                  _buildDetailRow('Service', transaction['serviceName']),
                ],
                if (transaction['complaintId'] != null)
                  _buildDetailRow('Complaint ID', transaction['complaintId']),
                const Divider(height: 24),
                _buildDetailRow(
                  'Amount',
                  '${transaction['amount'] > 0 ? '+' : ''}SAR ${transaction['amount'].toStringAsFixed(2)}',
                  isBold: true,
                ),
                if (transaction['vat'] != null)
                  _buildDetailRow('VAT', 'SAR ${transaction['vat'].toStringAsFixed(2)}'),
                if (transaction['commission'] != null)
                  _buildDetailRow('Commission', 'SAR ${transaction['commission'].toStringAsFixed(2)}'),
                const Divider(height: 24),
                _buildDetailRow('Balance Before', 'SAR ${transaction['balanceBefore'].toStringAsFixed(2)}'),
                _buildDetailRow('Balance After', 'SAR ${transaction['balanceAfter'].toStringAsFixed(2)}'),
                const Divider(height: 24),
                if (transaction['paymentMethod'] != null)
                  _buildDetailRow('Payment Method', transaction['paymentMethod']),
                if (transaction['bankAccount'] != null)
                  _buildDetailRow('Bank Account', transaction['bankAccount']),
                if (transaction['adjustedBy'] != null) ...[
                  _buildDetailRow('Adjusted By', transaction['adjustedBy']),
                  _buildDetailRow('Reason', transaction['reason']),
                ],
                _buildDetailRow('Date', _formatDateTime(transaction['date'])),
                _buildDetailRow('Status', transaction['status']),
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
            label,
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
      if (_selectedType == 'All') return true;

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
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
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