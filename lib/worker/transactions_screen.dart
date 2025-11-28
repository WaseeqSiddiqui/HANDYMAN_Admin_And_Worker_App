import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/app_state_provider.dart';
import '/models/transaction_model.dart';
import '/utils/worker_translations.dart';

class WorkerTransactionsScreen extends StatelessWidget {
  const WorkerTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              WorkerTranslations.getEnglish(WorkerTranslations.transactionHistory),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              WorkerTranslations.getArabic(WorkerTranslations.transactionHistory),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          final transactions = appState.transactions;

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    WorkerTranslations.noTransactions,
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
    String subtitle;

    switch (transaction.type) {
      case TransactionType.creditTopup:
        icon = Icons.arrow_upward;
        color = Colors.green;
        title = 'Credit Top-up • شحن رصيد';
        subtitle = 'Credit top-up via STC Pay • شحن رصيد عبر STC Pay';
        break;
      case TransactionType.walletEarning:
        icon = Icons.check_circle;
        color = Colors.blue;
        title = 'Service Completed • خدمة مكتملة';
        subtitle = 'Service payment received • تم استلام دفعة الخدمة';
        break;
      case TransactionType.commission:
        icon = Icons.arrow_downward;
        color = Colors.red;
        title = 'Commission • عمولة';
        subtitle = 'Platform commission • عمولة المنصة';
        break;
      case TransactionType.vat:
        icon = Icons.arrow_downward;
        color = Colors.red;
        title = 'VAT • ضريبة القيمة المضافة';
        subtitle = 'Value Added Tax • ضريبة القيمة المضافة';
        break;
      case TransactionType.creditDeduction:
        icon = Icons.arrow_downward;
        color = Colors.red;
        title = 'Credit Deduction • خصم رصيد';
        subtitle = 'Credit deduction for service • خصم رصيد للخدمة';
        break;
      case TransactionType.walletWithdrawal:
        icon = Icons.account_balance_wallet;
        color = Colors.orange;
        title = 'Withdrawal • سحب';
        subtitle = 'Wallet withdrawal request • طلب سحب من المحفظة';
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
                  // Bilingual Title - Fixed: Single text widget
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Bilingual Subtitle - Fixed: Single text widget
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Date
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
                // Amount in SAR only (once)
                Text(
                  '${transaction.amount >= 0 ? '+' : ''}${transaction.amount.toStringAsFixed(2)} SAR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: transaction.amount >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),

                // Reference if available
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
        if (diff.inMinutes == 0) {
          return WorkerTranslations.justNow;
        }
        return WorkerTranslations.getBilingual(
            '${diff.inMinutes} min ago',
            '${diff.inMinutes} دقيقة مضت'
        );
      }
      return WorkerTranslations.getBilingual(
          '${diff.inHours} h ago',
          '${diff.inHours} ساعة مضت'
      );
    } else if (diff.inDays == 1) {
      return WorkerTranslations.yesterday;
    } else if (diff.inDays < 7) {
      return WorkerTranslations.getBilingual(
          '${diff.inDays} days ago',
          '${diff.inDays} أيام مضت'
      );
    } else {
      return WorkerTranslations.getBilingual(
          '${date.day}/${date.month}/${date.year}',
          '${date.day}/${date.month}/${date.year}'
      );
    }
  }
}