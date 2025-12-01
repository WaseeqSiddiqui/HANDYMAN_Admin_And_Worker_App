import 'package:flutter/material.dart';
import '../services/financial_service.dart';
import '../models/admin_wallet_transaction.dart';
import '../models/financial_report_summary_model.dart';
import '../widgets/bilingual_text.dart';
import '/utils/admin_translations.dart';

class AdminWalletScreen extends StatefulWidget {
  const AdminWalletScreen({super.key});

  @override
  State<AdminWalletScreen> createState() => _AdminWalletScreenState();
}

class _AdminWalletScreenState extends State<AdminWalletScreen> {
  final _financialService = FinancialService();
  String _currentFilter = 'all';
  List<WalletTransaction> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _financialService.addListener(_onFinancialUpdate);
    _updateFilteredTransactions();
  }

  @override
  void dispose() {
    _financialService.removeListener(_onFinancialUpdate);
    super.dispose();
  }

  void _onFinancialUpdate() {
    if (mounted) {
      setState(() {
        _updateFilteredTransactions();
      });
    }
  }

  void _updateFilteredTransactions() {
    final transactions = _financialService.getWalletTransactions();

    switch (_currentFilter) {
      case 'income':
        _filteredTransactions = transactions.where((t) => t.type == 'credit').toList();
        break;
      case 'expenses':
        _filteredTransactions = transactions.where((t) => t.type == 'debit').toList();
        break;
      default:
        _filteredTransactions = transactions;
    }
  }

  Future<void> _refreshData() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const BilingualText(
            english: 'Failed to refresh data',
            arabic: 'فشل في تحديث البيانات',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const BilingualText(
          english: 'Filter Transactions',
          arabic: 'تصفية المعاملات',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.all_inclusive,
                color: _currentFilter == 'all' ? const Color(0xFF6B5B9A) : Colors.grey,
              ),
              title: const BilingualText(
                english: 'All Transactions',
                arabic: 'جميع المعاملات',
              ),
              onTap: () {
                setState(() {
                  _currentFilter = 'all';
                  _updateFilteredTransactions();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.arrow_downward,
                color: _currentFilter == 'income' ? Colors.green : Colors.grey,
              ),
              title: const BilingualText(
                english: 'Income Only',
                arabic: 'الدخل فقط',
              ),
              onTap: () {
                setState(() {
                  _currentFilter = 'income';
                  _updateFilteredTransactions();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.arrow_upward,
                color: _currentFilter == 'expenses' ? Colors.red : Colors.grey,
              ),
              title: const BilingualText(
                english: 'Expenses Only',
                arabic: 'المصروفات فقط',
              ),
              onTap: () {
                setState(() {
                  _currentFilter = 'expenses';
                  _updateFilteredTransactions();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _financialService.getCurrentBalance();
    final transactions = _financialService.getWalletTransactions();

    return Scaffold(
      appBar: AppBar(
        title: const BilingualText(
          english: 'Wallet',
          arabic: 'المحفظة',
          englishStyle: TextStyle(color: Colors.white, fontSize: 16),
          arabicStyle:  TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildBalanceCard(balance),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BilingualText(
                  english: 'Transactions',
                  arabic: 'المعاملات',
                  englishStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list),
                  label: const BilingualText(
                    english: 'Filter',
                    arabic: 'تصفية',
                    englishStyle: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          if (_currentFilter != 'all') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      _currentFilter == 'income' ? 'Income Only' : 'Expenses Only',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _currentFilter == 'income'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _currentFilter = 'all';
                        _updateFilteredTransactions();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: _filteredTransactions.isEmpty
                  ? _buildEmptyState()
                  : _buildTransactionsList(_filteredTransactions),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF4A3B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    'الرصيد الإجمالي',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      AdminTranslations.active,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "SAR ${balance.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWalletInfo('Auto Updated • محدث تلقائياً', Icons.sync),
              Container(
                height: 40,
                width: 1,
                color: Colors.white24,
              ),
              _buildWalletInfo('Real Time • حقيقي', Icons.flash_on),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletInfo(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }


  Widget _buildTransactionsList(List<WalletTransaction> transactions) {
    final sortedTransactions = transactions.reversed.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = sortedTransactions[index];
        final isCredit = transaction.type == 'credit';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCredit
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? Colors.green : Colors.red,
                size: 24,
              ),
            ),
            title: Text(
              transaction.description,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.date),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Balance • الرصيد: SAR ${transaction.balanceAfter.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'} SAR ${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isCredit ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCredit
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCredit ? AdminTranslations.credit : AdminTranslations.debit,
                    style: TextStyle(
                      color: isCredit ? Colors.green : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          const BilingualText(
            english: 'No Transactions Available',
            arabic: 'لا توجد معاملات متاحة',
            englishStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const BilingualText(
            english: 'You don\'t have any wallet transactions yet',
            arabic: 'ليس لديك معاملات محفظة حتى الآن',
            textAlign: TextAlign.center,
            englishStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return '${AdminTranslations.today} at ${_formatTime(date)}';
    } else if (dateToCheck == yesterday) {
      return '${AdminTranslations.yesterday} at ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}