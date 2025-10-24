import 'package:flutter/material.dart';

class CreditWalletLogsScreen extends StatefulWidget {
  const CreditWalletLogsScreen({super.key});

  @override
  State<CreditWalletLogsScreen> createState() => _CreditWalletLogsScreenState();
}

class _CreditWalletLogsScreenState extends State<CreditWalletLogsScreen> {
  String _selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit/Wallet Logs'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildTypeFilter(),
          Expanded(child: _buildTransactionsList()),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: ['All', 'Credit', 'Wallet', 'Top-up', 'Deduction', 'Withdrawal']
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
            ),
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (context, index) {
        final isCredit = index % 2 == 0;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCredit ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              child: Icon(
                isCredit ? Icons.add : Icons.remove,
                color: isCredit ? Colors.green : Colors.red,
              ),
            ),
            title: Text('Worker: Ahmed Hassan'),
            subtitle: Text('${isCredit ? 'Top-up' : 'Deduction'} • Oct 23, 2025'),
            trailing: Text(
              '${isCredit ? '+' : '-'}SAR 250',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCredit ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }
}