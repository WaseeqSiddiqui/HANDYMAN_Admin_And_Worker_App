import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminWalletScreen extends StatefulWidget {
  const AdminWalletScreen({super.key});

  @override
  State<AdminWalletScreen> createState() => _AdminWalletScreenState();
}

class _AdminWalletScreenState extends State<AdminWalletScreen> {
  String _selectedTab = 'All Workers';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _workers = [
    {
      'id': 'w001',
      'name': 'Ahmed Hassan',
      'phone': '+966501234567',
      'walletBalance': 5420.0,
      'pendingWithdrawal': 0.0,
      'totalEarned': 45600.0,
      'totalWithdrawn': 40180.0,
      'isActive': true,
    },
    {
      'id': 'w002',
      'name': 'Mohammed Ali',
      'phone': '+966507654321',
      'walletBalance': 3200.0,
      'pendingWithdrawal': 1000.0,
      'totalEarned': 67800.0,
      'totalWithdrawn': 64600.0,
      'isActive': true,
    },
    {
      'id': 'w003',
      'name': 'Khalid Ibrahim',
      'phone': '+966509876543',
      'walletBalance': 1800.0,
      'pendingWithdrawal': 500.0,
      'totalEarned': 23400.0,
      'totalWithdrawn': 21600.0,
      'isActive': false,
    },
    {
      'id': 'w004',
      'name': 'Youssef Ahmed',
      'phone': '+966502223333',
      'walletBalance': 6750.0,
      'pendingWithdrawal': 2000.0,
      'totalEarned': 89200.0,
      'totalWithdrawn': 82450.0,
      'isActive': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredWorkers {
    var filtered = _workers.where((worker) {
      final matchesSearch = worker['name']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          worker['phone'].contains(_searchQuery);

      switch (_selectedTab) {
        case 'Active':
          return matchesSearch && worker['isActive'];
        case 'Pending Withdrawal':
          return matchesSearch && worker['pendingWithdrawal'] > 0;
        default:
          return matchesSearch;
      }
    }).toList();

    filtered.sort((a, b) => (b['walletBalance'] as double)
        .compareTo(a['walletBalance'] as double));
    return filtered;
  }

  double get _totalWalletBalance {
    return _filteredWorkers.fold(
        0, (sum, worker) => sum + (worker['walletBalance'] as double));
  }

  double get _totalPendingWithdrawals {
    return _filteredWorkers.fold(
        0, (sum, worker) => sum + (worker['pendingWithdrawal'] as double));
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
        title: const Text('Worker Wallets'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filter dialog
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(cardColor, textColor),
          _buildTabFilter(),
          _buildSummaryCards(cardColor, textColor),
          Expanded(
            child: _filteredWorkers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No workers found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredWorkers.length,
                    itemBuilder: (context, index) {
                      return _buildWorkerWalletCard(
                          _filteredWorkers[index], cardColor, textColor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color cardColor, Color textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      color: cardColor,
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by name or phone...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: ['All Workers', 'Active', 'Pending Withdrawal']
            .map((tab) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tab),
                    selected: _selectedTab == tab,
                    onSelected: (selected) {
                      setState(() => _selectedTab = tab);
                    },
                    selectedColor: const Color(0xFF6B5B9A),
                    labelStyle: TextStyle(
                      color: _selectedTab == tab ? Colors.white : null,
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SAR ${_totalWalletBalance.toStringAsFixed(2)}',
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
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SAR ${_totalPendingWithdrawals.toStringAsFixed(2)}',
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

  Widget _buildWorkerWalletCard(
      Map<String, dynamic> worker, Color cardColor, Color textColor) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF6B5B9A),
          child: Text(
            worker['name'].substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                worker['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ),
            if (worker['pendingWithdrawal'] > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
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
              worker['phone'],
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
              'SAR ${worker['walletBalance'].toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            if (worker['pendingWithdrawal'] > 0)
              Text(
                '-${worker['pendingWithdrawal'].toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange,
                ),
              ),
          ],
        ),
        children: [
          const Divider(),
          _buildStatRow(
              'Total Earned', worker['totalEarned'], Colors.blue, textColor),
          _buildStatRow('Total Withdrawn', worker['totalWithdrawn'],
              Colors.purple, textColor),
          if (worker['pendingWithdrawal'] > 0)
            _buildStatRow('Pending Withdrawal', worker['pendingWithdrawal'],
                Colors.orange, textColor),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAddFundsDialog(worker),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Funds'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: worker['pendingWithdrawal'] > 0
                      ? () => _showApproveWithdrawalDialog(worker)
                      : null,
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Approve'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B5B9A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showTransactionHistoryDialog(worker),
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('History'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      String label, double value, Color color, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
          Text(
            'SAR ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFundsDialog(Map<String, dynamic> worker) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Funds to ${worker['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Amount (SAR)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                setState(() {
                  worker['walletBalance'] += double.parse(amountController.text);
                  worker['totalEarned'] += double.parse(amountController.text);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funds added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Funds'),
          ),
        ],
      ),
    );
  }

  void _showApproveWithdrawalDialog(Map<String, dynamic> worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Withdrawal'),
        content: Text(
          'Approve withdrawal of SAR ${worker['pendingWithdrawal'].toStringAsFixed(2)} for ${worker['name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                worker['walletBalance'] -= worker['pendingWithdrawal'];
                worker['totalWithdrawn'] += worker['pendingWithdrawal'];
                worker['pendingWithdrawal'] = 0.0;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Withdrawal approved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5B9A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showTransactionHistoryDialog(Map<String, dynamic> worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${worker['name']} - Transaction History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (context, index) {
              final isCredit = index % 2 == 0;
              return ListTile(
                leading: Icon(
                  isCredit ? Icons.add_circle : Icons.remove_circle,
                  color: isCredit ? Colors.green : Colors.red,
                ),
                title: Text(isCredit ? 'Service Payment' : 'Withdrawal'),
                subtitle: Text('Oct ${25 - index}, 2025'),
                trailing: Text(
                  '${isCredit ? '+' : '-'}SAR ${(200 + index * 50)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
