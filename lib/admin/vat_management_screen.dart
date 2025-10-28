import 'package:flutter/material.dart';

class VATManagementScreen extends StatefulWidget {
  const VATManagementScreen({super.key});

  @override
  State<VATManagementScreen> createState() => _VATManagementScreenState();
}

class _VATManagementScreenState extends State<VATManagementScreen> {
  String _selectedPeriod = 'This Month';

  final List<Map<String, dynamic>> _vatTransactions = [
    {
      'id': '#VAT001',
      'serviceRequest': '#SRV045',
      'worker': 'Ahmed Hassan',
      'customer': 'Ali Raza',
      'service': 'AC Installation',
      'baseAmount': 800.0,
      'vatRate': 5.0,
      'vatAmount': 40.0,
      'date': DateTime(2025, 10, 23),
      'status': 'Collected',
    },
    {
      'id': '#VAT002',
      'serviceRequest': '#SRV044',
      'worker': 'Mohammed Ali',
      'customer': 'Sara Ahmed',
      'service': 'Washing Machine Repair',
      'baseAmount': 350.0,
      'vatRate': 5.0,
      'vatAmount': 17.5,
      'date': DateTime(2025, 10, 22),
      'status': 'Collected',
    },
    {
      'id': '#VAT003',
      'serviceRequest': '#SRV043',
      'worker': 'Khalid Ibrahim',
      'customer': 'Mohammed Khan',
      'service': 'Refrigerator Repair',
      'baseAmount': 550.0,
      'vatRate': 5.0,
      'vatAmount': 27.5,
      'date': DateTime(2025, 10, 21),
      'status': 'Collected',
    },
    {
      'id': '#VAT004',
      'serviceRequest': '#SRV042',
      'worker': 'Ahmed Hassan',
      'customer': 'Fatima Ali',
      'service': 'AC Repair',
      'baseAmount': 450.0,
      'vatRate': 5.0,
      'vatAmount': 22.5,
      'date': DateTime(2025, 10, 20),
      'status': 'Collected',
    },
    {
      'id': '#VAT005',
      'serviceRequest': '#SRV041',
      'worker': 'Youssef Ahmed',
      'customer': 'Hassan Raza',
      'service': 'Microwave Service',
      'baseAmount': 250.0,
      'vatRate': 5.0,
      'vatAmount': 12.5,
      'date': DateTime(2025, 10, 19),
      'status': 'Collected',
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    final now = DateTime.now();
    return _vatTransactions.where((transaction) {
      switch (_selectedPeriod) {
        case 'Today':
          return transaction['date'].day == now.day &&
              transaction['date'].month == now.month;
        case 'This Week':
          final weekAgo = now.subtract(const Duration(days: 7));
          return transaction['date'].isAfter(weekAgo);
        case 'This Month':
          return transaction['date'].month == now.month;
        default:
          return true;
      }
    }).toList();
  }

  double get _totalVATCollected {
    return _filteredTransactions.fold(
        0, (sum, transaction) => sum + (transaction['vatAmount'] as double));
  }

  double get _totalBaseAmount {
    return _filteredTransactions.fold(
        0, (sum, transaction) => sum + (transaction['baseAmount'] as double));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('VAT Management'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('VAT report downloaded'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodFilter(),
          _buildSummaryCards(cardColor, textColor),
          _buildVATInfo(cardColor, textColor),
          Expanded(
            child: _filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No VAT transactions found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      return _buildVATCard(
                          _filteredTransactions[index], cardColor, textColor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: ['Today', 'This Week', 'This Month', 'All Time']
            .map((period) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(period),
                    selected: _selectedPeriod == period,
                    onSelected: (selected) {
                      setState(() => _selectedPeriod = period);
                    },
                    selectedColor: const Color(0xFF6B5B9A),
                    labelStyle: TextStyle(
                      color: _selectedPeriod == period ? Colors.white : null,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSummaryCards(Color cardColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.account_balance,
                          color: Colors.white, size: 28),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_filteredTransactions.length} TXN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Total VAT Collected',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SAR ${_totalVATCollected.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
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
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6B5B9A).withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.attach_money,
                      color: const Color(0xFF6B5B9A), size: 28),
                  const SizedBox(height: 12),
                  Text(
                    'Base Amount',
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SAR ${_totalBaseAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
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

  Widget _buildVATInfo(Color cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6B5B9A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6B5B9A).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFF6B5B9A),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Current VAT Rate: 5% | All transactions are automatically calculated',
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVATCard(
      Map<String, dynamic> transaction, Color cardColor, Color textColor) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_long, color: Colors.orange),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                transaction['id'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                transaction['status'],
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              transaction['service'],
              style: TextStyle(
                fontSize: 13,
                color: textColor.withOpacity(0.8),
              ),
            ),
            Text(
              'Service Request: ${transaction['serviceRequest']}',
              style: TextStyle(
                fontSize: 11,
                color: textColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'SAR ${transaction['vatAmount'].toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text(
              '${transaction['vatRate']}% VAT',
              style: TextStyle(
                fontSize: 10,
                color: textColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
        children: [
          const Divider(),
          _buildDetailRow('Worker', transaction['worker'], textColor),
          _buildDetailRow('Customer', transaction['customer'], textColor),
          _buildDetailRow(
              'Date',
              '${transaction['date'].day}/${transaction['date'].month}/${transaction['date'].year}',
              textColor),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildCalculationRow('Base Amount',
                    transaction['baseAmount'], textColor),
                _buildCalculationRow(
                    'VAT (${transaction['vatRate']}%)',
                    transaction['vatAmount'],
                    textColor,
                    color: Colors.orange),
                const Divider(),
                _buildCalculationRow(
                    'Total',
                    transaction['baseAmount'] + transaction['vatAmount'],
                    textColor,
                    isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(String label, double amount, Color textColor,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? textColor.withOpacity(0.8),
            ),
          ),
          Text(
            'SAR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? textColor,
            ),
          ),
        ],
      ),
    );
  }
}
