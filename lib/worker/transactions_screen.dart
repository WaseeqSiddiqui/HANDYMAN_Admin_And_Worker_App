import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/app_state_provider.dart';
import '/models/transaction_model.dart';

class WorkerTransactionsScreen extends StatelessWidget {
  const WorkerTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          final transactions = appState.transactions; // ✅ Now returns List<Transaction>

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionCard(transaction);
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    IconData icon;
    Color color;
    String title;

    // ✅ Use enum directly
    switch (transaction.type) {
      case TransactionType.creditTopup:
        icon = Icons.arrow_upward;
        color = Colors.green;
        title = 'Credit Top-up';
        break;
      case TransactionType.walletEarning:
        icon = Icons.check_circle;
        color = Colors.blue;
        title = 'Service Completed';
        break;
      case TransactionType.commission:
      case TransactionType.vat:
      case TransactionType.creditDeduction:
        icon = Icons.arrow_downward;
        color = Colors.red;
        title = transaction.typeLabel;
        break;
      case TransactionType.walletWithdrawal:
        icon = Icons.account_balance_wallet;
        color = Colors.orange;
        title = 'Withdrawal';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.description ?? transaction.typeLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(transaction.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.amount >= 0 ? '+' : ''}${transaction.amount.toStringAsFixed(2)} SAR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: transaction.amount >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                if (transaction.reference != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      transaction.reference!,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} minutes ago';
      }
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}