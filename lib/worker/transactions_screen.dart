import 'package:flutter/material.dart';

class WorkerTransactionsScreen extends StatefulWidget {
  const WorkerTransactionsScreen({super.key});

  @override
  State<WorkerTransactionsScreen> createState() => _WorkerTransactionsScreenState();
}

class _WorkerTransactionsScreenState extends State<WorkerTransactionsScreen> {
  String _selectedType = 'All';

  // Mock transactions data
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN001',
      'type': 'Service Payment',
      'category': 'Wallet',
      'amount': 420.0,
      'isCredit': true,
      'serviceId': '#SRV047',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'Completed',
      'icon': Icons.build_circle,
      'color': Colors.green,
    },
    {
      'id': 'TXN002',
      'type': 'Credit Top-up',
      'category': 'Credit',
      'amount': 100.0,
      'isCredit': true,
      'paymentMethod': 'Wallet Transfer',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'Completed',
      'icon': Icons.credit_card,
      'color': Colors.blue,
    },
    {
      'id': 'TXN003',
      'type': 'VAT Deduction',
      'category': 'Credit',
      'amount': 22.5,
      'isCredit': false,
      'serviceId': '#SRV046',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Completed',
      'icon': Icons.remove_circle,
      'color': Colors.red,
    },
    {
      'id': 'TXN004',
      'type': 'Commission Deduction',
      'category': 'Credit',
      'amount': 45.0,
      'isCredit': false,
      'serviceId': '#SRV046',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Completed',
      'icon': Icons.remove_circle,
      'color': Colors.red,
    },
    {
      'id': 'TXN005',
      'type': 'Wallet Withdrawal',
      'category': 'Wallet',
      'amount': 2000.0,
      'isCredit': false,
      'paymentMethod': 'STC Pay',
      'txnId': 'WD123456',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'Completed',
      'icon': Icons.account_balance,
      'color': Colors.orange,
    },
    {
      'id': 'TXN006',
      'type': 'Service Payment',
      'category': 'Wallet',
      'amount': 350.0,
      'isCredit': true,
      'serviceId': '#SRV045',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'status': 'Completed',
      'icon': Icons.build_circle,
      'color': Colors.green,
    },
    {
      'id': 'TXN007',
      'type': 'Credit Top-up',
      'category': 'Credit',
      'amount': 150.0,
      'isCredit': true,
      'paymentMethod': 'STC Pay',
      'txnId': 'STC789012',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'Completed',
      'icon': Icons.payment,
      'color': Colors.blue,
    },
    {
      'id': 'TXN008',
      'type': 'VAT Deduction',
      'category': 'Credit',
      'amount': 17.5,
      'isCredit': false,
      'serviceId': '#SRV044',
      'date': DateTime.now().subtract(const Duration(days: 8)),
      'status': 'Completed',
      'icon': Icons.remove_circle,
      'color': Colors.red,
    },
    {
      'id': 'TXN009',
      'type': 'Service Payment',
      'category': 'Wallet',
      'amount': 500.0,
      'isCredit': true,
      'serviceId': '#SRV043',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'status': 'Completed',
      'icon': Icons.build_circle,
      'color': Colors.green,
    },
    {
      'id': 'TXN010',
      'type': 'Wallet Withdrawal',
      'category': 'Wallet',
      'amount': 1500.0,
      'isCredit': false,
      'paymentMethod': 'STC Pay',
      'txnId': 'WD123455',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'status': 'Completed',
      'icon': Icons.account_balance,
      'color': Colors.orange,
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedType == 'All') {
      return _transactions;
    } else if (_selectedType == 'Credit') {
      return _transactions.where((t) => t['category'] == 'Credit').toList();
    } else if (_selectedType == 'Wallet') {
      return _transactions.where((t) => t['category'] == 'Wallet').toList();
    } else if (_selectedType == 'Income') {
      return _transactions.where((t) => t['isCredit'] == true).toList();
    } else if (_selectedType == 'Expense') {
      return _transactions.where((t) => t['isCredit'] == false).toList();
    }
    return _transactions;
  }

  double get _totalIncome {
    return _transactions
        .where((t) => t['isCredit'] == true)
        .fold(0.0, (sum, t) => sum + t['amount']);
  }

  double get _totalExpense {
    return _transactions
        .where((t) => t['isCredit'] == false)
        .fold(0.0, (sum, t) => sum + t['amount']);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Add date filter or export functionality
              _showFilterOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCards(cardColor, textColor),
          _buildTypeFilter(),
          Expanded(
            child: _filteredTransactions.isEmpty
                ? _buildEmptyState(textColor)
                : _buildTransactionsList(cardColor, textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Total Income',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SAR ${_totalIncome.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF44336), Color(0xFFE53935)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_downward, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Total Expense',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SAR ${_totalExpense.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ['All', 'Credit', 'Wallet', 'Income', 'Expense']
            .map((type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      setState(() => _selectedType = type);
                    },
                    selectedColor: const Color(0xFF6B5B9A),
                    labelStyle: TextStyle(
                      color: _selectedType == type ? Colors.white : null,
                      fontWeight:
                          _selectedType == type ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTransactionsList(Color cardColor, Color textColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        return _buildTransactionCard(transaction, cardColor, textColor);
      },
    );
  }

  Widget _buildTransactionCard(
    Map<String, dynamic> transaction,
    Color cardColor,
    Color textColor,
  ) {
    final bool isCredit = transaction['isCredit'];

    return GestureDetector(
      onTap: () => _showTransactionDetails(transaction),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: transaction['color'].withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: transaction['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                transaction['icon'],
                color: transaction['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['type'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(transaction['date']),
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                  if (transaction['serviceId'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Service: ${transaction['serviceId']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                  if (transaction['txnId'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'TXN: ${transaction['txnId']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}SAR ${transaction['amount'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: transaction['category'] == 'Wallet'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction['category'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: transaction['category'] == 'Wallet'
                          ? Colors.green
                          : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transactions will appear here',
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: transaction['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    transaction['icon'],
                    color: transaction['color'],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction['type'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        transaction['id'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow('Amount', 
                '${transaction['isCredit'] ? '+' : '-'}SAR ${transaction['amount'].toStringAsFixed(2)}',
                color: transaction['isCredit'] ? Colors.green : Colors.red),
            _buildDetailRow('Category', transaction['category']),
            _buildDetailRow('Date', _formatDate(transaction['date'])),
            _buildDetailRow('Status', transaction['status']),
            if (transaction['serviceId'] != null)
              _buildDetailRow('Service ID', transaction['serviceId']!),
            if (transaction['paymentMethod'] != null)
              _buildDetailRow('Payment Method', transaction['paymentMethod']!),
            if (transaction['txnId'] != null)
              _buildDetailRow('Transaction ID', transaction['txnId']!),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B5B9A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date Range'),
              onTap: () {
                Navigator.pop(context);
                // Implement date range picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export to PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting transactions...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export to Excel'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting transactions...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
