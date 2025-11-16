import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/financial_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _withdrawalController = TextEditingController();
  final _financialService = FinancialService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        // ✅ Check if 7 days have passed since last service
        final canWithdraw = appState.canWithdraw();
        final daysRemaining = appState.getDaysUntilWithdrawal();

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: const Text('Wallet'),
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(cardColor, textColor, appState),
                const SizedBox(height: 24),

                // ✅ Show 7-day restriction banner
                if (!canWithdraw)
                  _buildWithdrawalRestrictionBanner(daysRemaining),
                if (!canWithdraw) const SizedBox(height: 16),

                _buildWithdrawalSection(
                    cardColor,
                    textColor,
                    appState,
                    canWithdraw,
                    daysRemaining
                ),
                const SizedBox(height: 24),

                // ✅ Show pending withdrawal requests
                _buildPendingRequests(cardColor, textColor, appState),
                const SizedBox(height: 24),

                _buildEarningsBreakdown(cardColor, textColor, appState),
                const SizedBox(height: 24),
                _buildWithdrawalHistory(cardColor, textColor, appState),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ 7-Day Restriction Banner
  Widget _buildWithdrawalRestrictionBanner(int daysRemaining) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.schedule, color: Colors.orange, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Withdrawal Restricted',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You can request withdrawal after $daysRemaining day${daysRemaining > 1 ? 's' : ''} from your last service payment',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Show Pending Withdrawal Requests
  Widget _buildPendingRequests(Color cardColor, Color textColor, AppStateProvider appState) {
    final pendingRequests = _financialService.getWithdrawalRequests(status: 'Pending')
        .where((req) => req.workerId == appState.workerId)
        .toList();

    if (pendingRequests.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pending_actions, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                'Pending Withdrawal Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...pendingRequests.map((req) => _buildPendingRequestTile(req)),
        ],
      ),
    );
  }

  Widget _buildPendingRequestTile(WithdrawalRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.schedule, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Withdrawal Request',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Request ID: ${request.id}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  _formatDate(request.requestDate),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SAR ${request.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.orange,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(Color cardColor, Color textColor, AppStateProvider appState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Wallet', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'SAR ${appState.walletBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalSection(
      Color cardColor,
      Color textColor,
      AppStateProvider appState,
      bool canWithdraw,
      int daysRemaining,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Withdrawal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _withdrawalController,
            keyboardType: TextInputType.number,
            enabled: canWithdraw,
            decoration: InputDecoration(
              labelText: 'Amount (SAR)',
              hintText: canWithdraw ? 'Min. 100 SAR' : 'Withdrawal restricted',
              prefixIcon: Icon(
                Icons.money,
                color: canWithdraw ? Colors.green : Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.withOpacity(0.3), width: 2),
              ),
              filled: true,
              fillColor: canWithdraw
                  ? Colors.grey.shade50
                  : Colors.red.withOpacity(0.05),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Withdrawal Policy',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• Minimum withdrawal: 100 SAR',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
                Text(
                  '• Request after 7 days from last service',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
                Text(
                  '• Admin will process within 24-48 hours',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isLoading || !canWithdraw)
                  ? null
                  : () => _createWithdrawalRequest(appState),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                canWithdraw
                    ? 'Send Withdrawal Request'
                    : 'Available in $daysRemaining day${daysRemaining > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdown(Color cardColor, Color textColor, AppStateProvider appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildEarningRow(
            'Total Services',
            '${appState.totalServicesCompleted}',
            Icons.build,
            Colors.blue,
          ),
          _buildEarningRow(
            'Total Earnings',
            'SAR ${appState.totalEarnings.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green,
          ),
          _buildEarningRow(
            'Avg per Service',
            'SAR ${appState.averagePerService.toStringAsFixed(2)}',
            Icons.trending_up,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningRow(String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalHistory(Color cardColor, Color textColor, AppStateProvider appState) {
    final withdrawals = _financialService.getWithdrawalRequests()
        .where((req) => req.workerId == appState.workerId && req.status == 'Approved')
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Approved Withdrawals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          if (withdrawals.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text(
                      'No approved withdrawals yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            ...withdrawals.take(5).map((w) => _buildWithdrawalTile(w)),
        ],
      ),
    );
  }

  Widget _buildWithdrawalTile(WithdrawalRequest withdrawal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Withdrawal Approved',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatDate(withdrawal.processedDate ?? withdrawal.requestDate),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'ID: ${withdrawal.id}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SAR ${withdrawal.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'COMPLETED',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) return 'Just now';
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // ✅ Create Withdrawal Request (sends to admin)
  void _createWithdrawalRequest(AppStateProvider appState) async {
    final amount = double.tryParse(_withdrawalController.text) ?? 0;

    // Validate minimum amount
    if (amount < 100) {
      _showError('Minimum withdrawal amount is 100 SAR');
      return;
    }

    // Validate sufficient balance
    if (amount > appState.walletBalance) {
      _showError('Insufficient balance');
      return;
    }

    // Check 7-day restriction
    if (!appState.canWithdraw()) {
      final days = appState.getDaysUntilWithdrawal();
      _showError('You can withdraw in $days day${days > 1 ? 's' : ''}');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Create withdrawal request (goes to admin)
      final requestId = _financialService.createWithdrawalRequest(
        workerId: appState.workerId,
        workerName: appState.workerName,
        amount: amount,
      );

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
        _withdrawalController.clear();
      });

      _showSuccess(
          'Withdrawal request submitted!\n'
              'Request ID: $requestId\n'
              'Admin will process within 24-48 hours'
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to create withdrawal request: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _withdrawalController.dispose();
    super.dispose();
  }
}