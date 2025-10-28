import 'package:flutter/material.dart';

class CommissionManagementScreen extends StatefulWidget {
  const CommissionManagementScreen({super.key});

  @override
  State<CommissionManagementScreen> createState() =>
      _CommissionManagementScreenState();
}

class _CommissionManagementScreenState
    extends State<CommissionManagementScreen> {
  String _selectedPeriod = 'This Month';
  String _selectedWorker = 'All Workers';

  final List<Map<String, dynamic>> _commissionTransactions = [
    {
      'id': '#COM001',
      'serviceRequest': '#SRV045',
      'worker': 'Ahmed Hassan',
      'customer': 'Ali Raza',
      'service': 'AC Installation',
      'baseAmount': 800.0,
      'commissionRate': 10.0,
      'commissionAmount': 80.0,
      'date': DateTime(2025, 10, 23),
      'status': 'Collected',
    },
    {
      'id': '#COM002',
      'serviceRequest': '#SRV044',
      'worker': 'Mohammed Ali',
      'customer': 'Sara Ahmed',
      'service': 'Washing Machine Repair',
      'baseAmount': 350.0,
      'commissionRate': 10.0,
      'commissionAmount': 35.0,
      'date': DateTime(2025, 10, 22),
      'status': 'Collected',
    },
    {
      'id': '#COM003',
      'serviceRequest': '#SRV043',
      'worker': 'Khalid Ibrahim',
      'customer': 'Mohammed Khan',
      'service': 'Refrigerator Repair',
      'baseAmount': 550.0,
      'commissionRate': 10.0,
      'commissionAmount': 55.0,
      'date': DateTime(2025, 10, 21),
      'status': 'Collected',
    },
    {
      'id': '#COM004',
      'serviceRequest': '#SRV042',
      'worker': 'Ahmed Hassan',
      'customer': 'Fatima Ali',
      'service': 'AC Repair',
      'baseAmount': 450.0,
      'commissionRate': 10.0,
      'commissionAmount': 45.0,
      'date': DateTime(2025, 10, 20),
      'status': 'Collected',
    },
    {
      'id': '#COM005',
      'serviceRequest': '#SRV041',
      'worker': 'Youssef Ahmed',
      'customer': 'Hassan Raza',
      'service': 'Microwave Service',
      'baseAmount': 250.0,
      'commissionRate': 10.0,
      'commissionAmount': 25.0,
      'date': DateTime(2025, 10, 19),
      'status': 'Collected',
    },
  ];

  List<String> get _workers {
    final workers =
        _commissionTransactions.map((t) => t['worker'] as String).toSet().toList();
    workers.insert(0, 'All Workers');
    return workers;
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    final now = DateTime.now();
    return _commissionTransactions.where((transaction) {
      // Period filter
      bool matchesPeriod = true;
      switch (_selectedPeriod) {
        case 'Today':
          matchesPeriod = transaction['date'].day == now.day &&
              transaction['date'].month == now.month;
          break;
        case 'This Week':
          final weekAgo = now.subtract(const Duration(days: 7));
          matchesPeriod = transaction['date'].isAfter(weekAgo);
          break;
        case 'This Month':
          matchesPeriod = transaction['date'].month == now.month;
          break;
      }

      // Worker filter
      bool matchesWorker = _selectedWorker == 'All Workers' ||
          transaction['worker'] == _selectedWorker;

      return matchesPeriod && matchesWorker;
    }).toList();
  }

  double get _totalCommissionCollected {
    return _filteredTransactions.fold(0,
        (sum, transaction) => sum + (transaction['commissionAmount'] as double));
  }

  double get _totalBaseAmount {
    return _filteredTransactions.fold(
        0, (sum, transaction) => sum + (transaction['baseAmount'] as double));
  }

  Map<String, double> get _workerCommissions {
    final Map<String, double> commissions = {};
    for (var transaction in _filteredTransactions) {
      final worker = transaction['worker'] as String;
      commissions[worker] =
          (commissions[worker] ?? 0) + (transaction['commissionAmount'] as double);
    }
    return commissions;
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
        title: const Text('Commission Management'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Commission report downloaded'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildSummaryCards(cardColor, textColor),
          if (_selectedWorker == 'All Workers')
            _buildWorkerBreakdown(cardColor, textColor),
          Expanded(
            child: _filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.money_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No commission transactions found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      return _buildCommissionCard(
                          _filteredTransactions[index], cardColor, textColor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: _workers
                .map((worker) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(worker),
                        selected: _selectedWorker == worker,
                        onSelected: (selected) {
                          setState(() => _selectedWorker = worker);
                        },
                        selectedColor: Colors.green,
                        labelStyle: TextStyle(
                          color: _selectedWorker == worker ? Colors.white : null,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
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
                  colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
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
                      const Icon(Icons.account_balance_wallet,
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
                    'Total Commission',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SAR ${_totalCommissionCollected.toStringAsFixed(2)}',
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
                  Icon(Icons.trending_up,
                      color: const Color(0xFF6B5B9A), size: 28),
                  const SizedBox(height: 12),
                  Text(
                    'Service Value',
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

  Widget _buildWorkerBreakdown(Color cardColor, Color textColor) {
    final sortedWorkers = _workerCommissions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Top Performers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...sortedWorkers.take(3).map((entry) {
            final percentage =
                (entry.value / _totalCommissionCollected * 100).toInt();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'SAR ${entry.value.toStringAsFixed(2)} ($percentage%)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF9C27B0)),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(
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
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.money, color: Colors.purple),
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
              'Worker: ${transaction['worker']}',
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
              'SAR ${transaction['commissionAmount'].toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            Text(
              '${transaction['commissionRate']}%',
              style: TextStyle(
                fontSize: 10,
                color: textColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
        children: [
          const Divider(),
          _buildDetailRow('Service Request', transaction['serviceRequest'], textColor),
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
                _buildCalculationRow('Service Amount',
                    transaction['baseAmount'], textColor),
                _buildCalculationRow(
                    'Commission (${transaction['commissionRate']}%)',
                    transaction['commissionAmount'],
                    textColor,
                    color: Colors.purple),
                const Divider(),
                _buildCalculationRow(
                    'Worker Receives',
                    transaction['baseAmount'] - transaction['commissionAmount'],
                    textColor,
                    isBold: true,
                    color: Colors.green),
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
            width: 120,
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
