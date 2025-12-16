import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/financial_service.dart';
import '../models/withdrawl_requests_model.dart';
import '../utils/worker_translations.dart';

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
        final canWithdraw = appState.canWithdraw();
        final daysRemaining = appState.getDaysUntilWithdrawal();

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.wallet),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.wallet),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(cardColor, textColor, appState),
                const SizedBox(height: 24),

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      WorkerTranslations.getEnglish(WorkerTranslations.withdrawalRestricted),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      WorkerTranslations.getArabic(WorkerTranslations.withdrawalRestricted),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  WorkerTranslations.getBilingual(
                      'You can request withdrawal after $daysRemaining day${daysRemaining > 1 ? 's' : ''} from your last service payment',
                      'يمكنك طلب السحب بعد $daysRemaining ${daysRemaining > 1 ? WorkerTranslations.days : WorkerTranslations.day} ${WorkerTranslations.fromLastServicePayment}'
                  ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    WorkerTranslations.getEnglish(WorkerTranslations.pendingWithdrawalRequests),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    WorkerTranslations.getArabic(WorkerTranslations.pendingWithdrawalRequests),
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ],
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      WorkerTranslations.getEnglish(WorkerTranslations.withdrawalRequest),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      WorkerTranslations.getArabic(WorkerTranslations.withdrawalRequest),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  WorkerTranslations.getBilingual(
                      'Request ID: ${request.id}',
                      'معرف الطلب: ${request.id}'
                  ),
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  WorkerTranslations.getBilingual(
                      'Requested on: ${_formatDate(request.requestDate)}',
                      'تم الطلب في: ${_formatDate(request.requestDate)}'
                  ),
                  style: TextStyle(fontSize: 11, color: Colors.grey),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      WorkerTranslations.getEnglish('PENDING'),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      WorkerTranslations.getArabic('PENDING'),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    'الرصيد الإجمالي', // Fixed Arabic translation
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        WorkerTranslations.getEnglish('Wallet'),
                        style: TextStyle(color: Colors.white, fontSize: 12)
                    ),
                    Text(
                        'المحفظة', // Fixed Arabic translation
                        style: TextStyle(color: Colors.white, fontSize: 10)
                    ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                WorkerTranslations.getEnglish(WorkerTranslations.requestWithdrawal),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                'طلب سحب', // Fixed Arabic translation
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Amount Input Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                WorkerTranslations.getEnglish(WorkerTranslations.amountSAR),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              Text(
                'المبلغ (ريال سعودي)', // Fixed Arabic translation
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _withdrawalController,
            keyboardType: TextInputType.number,
            enabled: canWithdraw,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: InputDecoration(
              hintText: canWithdraw
                  ? WorkerTranslations.getBilingual('Enter amount (min: SAR 50.00)', 'أدخل المبلغ (الحد الأدنى: 50 ريال)')
                  : WorkerTranslations.withdrawalRestricted,
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
          const SizedBox(height: 16),

          // Withdrawal Information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      WorkerTranslations.getEnglish(WorkerTranslations.withdrawalInfo),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'معلومات السحب', // Fixed Arabic translation
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                _buildInfoLine(WorkerTranslations.minWithdrawalAmount),
                _buildInfoLine(WorkerTranslations.processingTime),
                _buildInfoLine(WorkerTranslations.fundsSentToSTC),
                _buildInfoLine(WorkerTranslations.canWithdrawEvery7Days),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Submit Button
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
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    canWithdraw
                        ? WorkerTranslations.getEnglish(WorkerTranslations.submitRequest)
                        : WorkerTranslations.getEnglish('Available in $daysRemaining day${daysRemaining > 1 ? 's' : ''}'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    canWithdraw
                        ? 'إرسال الطلب' // Fixed Arabic translation
                        : 'متاح خلال $daysRemaining ${daysRemaining > 1 ? 'أيام' : 'يوم'}', // Fixed Arabic translation
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
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

  Widget _buildInfoLine(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: Colors.blue),
        textAlign: TextAlign.start,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                WorkerTranslations.getEnglish(WorkerTranslations.earningsBreakdown),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                'تفصيل الأرباح', // Fixed Arabic translation
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEarningRow(
            WorkerTranslations.totalServices,
            '${appState.totalServicesCompleted}',
            Icons.build,
            Colors.blue,
          ),
          _buildEarningRow(
            WorkerTranslations.totalEarnings,
            'SAR ${appState.totalEarnings.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green,
          ),
          _buildEarningRow(
            WorkerTranslations.avgEarningPerService,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WorkerTranslations.getEnglish(label),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  _getArabicTranslationForLabel(label), // Fixed Arabic translation
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Helper method to get Arabic translations for labels
  String _getArabicTranslationForLabel(String label) {
    switch (label) {
      case WorkerTranslations.totalServices:
        return 'إجمالي الخدمات';
      case WorkerTranslations.totalEarnings:
        return 'إجمالي الأرباح';
      case WorkerTranslations.avgEarningPerService:
        return 'متوسط الربح لكل خدمة';
      default:
        return label;
    }
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                WorkerTranslations.getEnglish(WorkerTranslations.withdrawalHistory),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                'سجل السحب', // Fixed Arabic translation
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
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
                    Column(
                      children: [
                        Text(
                          WorkerTranslations.getEnglish(WorkerTranslations.noWithdrawalsYet),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          'لا توجد عمليات سحب حتى الآن', // Fixed Arabic translation
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        Text(
                          WorkerTranslations.getEnglish(WorkerTranslations.firstWithdrawalAppear),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                        Text(
                          'سيظهر أول سحب لك هنا', // Fixed Arabic translation
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                        ),
                      ],
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      WorkerTranslations.getEnglish('Withdrawal Approved'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'تمت الموافقة على السحب', // Fixed Arabic translation
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  WorkerTranslations.getBilingual(
                      'Processed: ${_formatDate(withdrawal.processedDate ?? withdrawal.requestDate)}',
                      'تم المعالجة: ${_formatDate(withdrawal.processedDate ?? withdrawal.requestDate)}'
                  ),
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  WorkerTranslations.getBilingual(
                      'ID: ${withdrawal.id}',
                      'المعرف: ${withdrawal.id}'
                  ),
                  style: TextStyle(fontSize: 10, color: Colors.grey),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      WorkerTranslations.getEnglish('COMPLETED'),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'مكتمل', // Fixed Arabic translation
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
      if (diff.inHours == 0) return WorkerTranslations.justNow;
      return WorkerTranslations.getBilingual(
          '${diff.inHours}h ago',
          '${diff.inHours}س مضت'
      );
    } else if (diff.inDays == 1) {
      return WorkerTranslations.yesterday;
    } else if (diff.inDays < 7) {
      return WorkerTranslations.getBilingual(
          '${diff.inDays} days ago',
          '${diff.inDays} منذ أيام'
      );
    } else {
      return WorkerTranslations.getBilingual(
          '${date.day}/${date.month}/${date.year}',
          '${date.day}/${date.month}/${date.year}'
      );
    }
  }

  void _createWithdrawalRequest(AppStateProvider appState) async {
    final amount = double.tryParse(_withdrawalController.text) ?? 0;

    if (amount < 50) {
      _showError(WorkerTranslations.minWithdrawalIs);
      return;
    }

    if (amount > appState.walletBalance) {
      _showError(WorkerTranslations.cannotExceedBalance);
      return;
    }

    if (!appState.canWithdraw()) {
      final days = appState.getDaysUntilWithdrawal();
      _showError(
          WorkerTranslations.getBilingual(
              'You can withdraw in $days day${days > 1 ? 's' : ''}',
              'يمكنك السحب خلال $days ${days > 1 ? 'أيام' : 'يوم'}'
          )
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
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
          WorkerTranslations.getBilingual(
              '✅ Withdrawal request submitted!\n'
                  'Request ID: $requestId\n'
                  'Admin will process within 1-3 business days',
              '✅ تم إرسال طلب السحب بنجاح!\n'
                  'معرف الطلب: $requestId\n'
                  'سيقوم المشرف بمعالجة الطلب خلال 1-3 أيام عمل'
          )
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(
          WorkerTranslations.getBilingual(
              'Failed to create withdrawal request: $e',
              'فشل إنشاء طلب السحب: $e'
          )
      );
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