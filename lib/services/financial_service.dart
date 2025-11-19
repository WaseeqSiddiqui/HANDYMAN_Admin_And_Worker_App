// services/financial_service.dart - FIXED VERSION
// ✅ Admin wallet now receives service payments correctly

import 'package:flutter/foundation.dart';
import '/models/financial_transaction_model.dart';
import '/models/admin_wallet_transaction.dart';
import '/models/commission_record_model.dart';
import '/models/vat_model.dart';
import '/models/financial_report_summary_model.dart';
import '/models/monthly_comparison_model.dart';
import '/models/withdrawl_requests_model.dart';
import '/models/transaction_model.dart';
import '/providers/app_state_provider.dart';

/// ✅ Financial Service - Centralized service completion handler
/// Admin wallet receives full payment and tracks all deductions
class FinancialService {
  static final FinancialService _instance = FinancialService._internal();
  factory FinancialService() => _instance;
  FinancialService._internal();

  // Listeners for real-time updates
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  // ============= DATA STORAGE =============
  final List<FinancialTransaction> _allTransactions = [];
  final List<FinancialTransaction> _completedServices = [];
  final List<WalletTransaction> _walletTransactions = [];
  final List<CommissionRecord> _commissionRecords = [];
  final List<VATRecord> _vatRecords = [];
  final List<WithdrawalRequest> _withdrawalRequests = [];

  double _currentBalance = 0.0;
  double _totalCommissionCollected = 0.0;
  double _totalVATCollected = 0.0;

  // ============= SERVICE COMPLETION =============
  Future<ServiceCompletionResult> processCompletedService({
    required String serviceId,
    required String serviceName,
    required String workerName,
    required String workerId,
    required String customerName,
    required double basePrice,
    required double extraCharges,
    required DateTime completionDate,
    required String paymentMethod,
  }) async {
    try {
      // ✅ FIXED: Calculate correctly
      // Total = base + extras (this is what customer pays)
      final total = basePrice + extraCharges;

      // Commission and VAT are INCLUDED in total, not added
      final commission = total * 0.20; // 20% of total
      final vat = total * 0.15; // 15% of total
      final workerDeduction = commission + vat;
      final workerEarnings = total - workerDeduction;

      // Create transaction record
      final transaction = FinancialTransaction(
        id: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        serviceId: serviceId,
        serviceName: serviceName,
        workerId: workerId,
        workerName: workerName,
        customerName: customerName,
        basePrice: basePrice,
        extraCharges: extraCharges,
        totalAmount: total,
        commission: commission,
        vat: vat,
        workerDeduction: workerDeduction,
        workerEarnings: workerEarnings,
        paymentMethod: paymentMethod,
        completionDate: completionDate,
        status: 'completed',
      );

      // Add to records
      _allTransactions.add(transaction);
      _completedServices.add(transaction);

      // ✅ FIXED: Update admin wallet - receives FULL payment amount
      _updateAdminWallet(transaction);

      // Update commission records
      _updateCommissionRecords(transaction);

      // Update VAT records
      _updateVATRecords(transaction);

      // Notify all listeners
      _notifyListeners();

      debugPrint('✅ Financial Service: Service completed - $serviceId');
      debugPrint('   Total Payment: SAR ${total.toStringAsFixed(2)}');
      debugPrint('   Commission: SAR ${commission.toStringAsFixed(2)}');
      debugPrint('   VAT: SAR ${vat.toStringAsFixed(2)}');
      debugPrint('   Worker Earnings: SAR ${workerEarnings.toStringAsFixed(2)}');
      debugPrint('   Admin Wallet: SAR ${_currentBalance.toStringAsFixed(2)}');

      return ServiceCompletionResult(
        success: true,
        message: 'Service completed successfully',
        transaction: transaction,
      );
    } catch (e) {
      return ServiceCompletionResult(
        success: false,
        message: 'Error: ${e.toString()}',
        transaction: null,
      );
    }
  }

  // ============= ADMIN WALLET MANAGEMENT =============
  // ✅ FIXED: Admin wallet receives full payment, tracks deductions with actual amounts
  void _updateAdminWallet(FinancialTransaction transaction) {
    // Step 1: Admin receives FULL payment from customer
    final paymentTxn = WalletTransaction(
      id: 'WLT_${DateTime.now().millisecondsSinceEpoch}',
      type: 'credit',
      amount: transaction.totalAmount,
      description: 'Payment received - ${transaction.serviceName} (${transaction.customerName})',
      serviceId: transaction.serviceId,
      date: transaction.completionDate,
      balanceAfter: _currentBalance + transaction.totalAmount,
    );

    _walletTransactions.add(paymentTxn);
    _currentBalance += transaction.totalAmount;

    debugPrint('✅ Admin Wallet: +SAR ${transaction.totalAmount.toStringAsFixed(2)} (Payment received)');

    // Step 2: Track commission (kept by admin) - SHOW ACTUAL AMOUNT
    final commissionTxn = WalletTransaction(
      id: 'WLT_${DateTime.now().millisecondsSinceEpoch + 1}',
      type: 'credit', // Commission is income for admin
      amount: transaction.commission, // ✅ FIXED: Show actual commission amount
      description: 'Commission earned (20%) - ${transaction.serviceName}',
      serviceId: transaction.serviceId,
      date: transaction.completionDate,
      balanceAfter: _currentBalance,
    );

    _walletTransactions.add(commissionTxn);

    // Step 3: Track VAT (kept by admin) - SHOW ACTUAL AMOUNT
    final vatTxn = WalletTransaction(
      id: 'WLT_${DateTime.now().millisecondsSinceEpoch + 2}',
      type: 'credit', // VAT is income for admin
      amount: transaction.vat, // ✅ FIXED: Show actual VAT amount
      description: 'VAT collected (15%) - ${transaction.serviceName}',
      serviceId: transaction.serviceId,
      date: transaction.completionDate,
      balanceAfter: _currentBalance,
    );

    _walletTransactions.add(vatTxn);

    debugPrint('✅ Admin Wallet Balance: SAR ${_currentBalance.toStringAsFixed(2)}');
    debugPrint('   Commission: SAR ${transaction.commission.toStringAsFixed(2)}');
    debugPrint('   VAT: SAR ${transaction.vat.toStringAsFixed(2)}');
  }

  List<WalletTransaction> getWalletTransactions() => List.unmodifiable(_walletTransactions);
  double getCurrentBalance() => _currentBalance;

  // ============= COMMISSION MANAGEMENT =============
  void _updateCommissionRecords(FinancialTransaction transaction) {
    final record = CommissionRecord(
      id: 'COM_${DateTime.now().millisecondsSinceEpoch}',
      serviceId: transaction.serviceId,
      serviceName: transaction.serviceName,
      workerId: transaction.workerId,
      workerName: transaction.workerName,
      serviceAmount: transaction.totalAmount,
      commissionRate: 20.0,
      commissionAmount: transaction.commission,
      date: transaction.completionDate,
      status: 'collected',
    );

    _commissionRecords.add(record);
    _totalCommissionCollected += transaction.commission;
  }

  List<CommissionRecord> getCommissionRecords() => List.unmodifiable(_commissionRecords);
  double getTotalCommissionCollected() => _totalCommissionCollected;

  double getWorkerCommission(String workerId) {
    return _commissionRecords
        .where((record) => record.workerId == workerId)
        .fold(0.0, (sum, record) => sum + record.commissionAmount);
  }

  List<CommissionRecord> getCommissionByDateRange(DateTime start, DateTime end) {
    return _commissionRecords
        .where((record) =>
    record.date.isAfter(start) && record.date.isBefore(end))
        .toList();
  }

  // ============= VAT MANAGEMENT =============
  void _updateVATRecords(FinancialTransaction transaction) {
    final record = VATRecord(
      id: 'VAT_${DateTime.now().millisecondsSinceEpoch}',
      serviceId: transaction.serviceId,
      serviceName: transaction.serviceName,
      serviceAmount: transaction.totalAmount,
      vatRate: 15.0,
      vatAmount: transaction.vat,
      date: transaction.completionDate,
      status: 'collected',
    );

    _vatRecords.add(record);
    _totalVATCollected += transaction.vat;
  }

  List<VATRecord> getVATRecords() => List.unmodifiable(_vatRecords);
  double getTotalVATCollected() => _totalVATCollected;

  List<VATRecord> getVATByDateRange(DateTime start, DateTime end) {
    return _vatRecords
        .where((record) => record.date.isAfter(start) && record.date.isBefore(end))
        .toList();
  }

  // ============= FINANCIAL REPORTS =============
  FinancialReportSummary getReportSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();
    final start = startDate ?? DateTime(now.year, now.month, 1);
    final end = endDate ?? DateTime(now.year, now.month + 1, 0);

    final filteredTransactions = _completedServices
        .where((txn) => txn.completionDate.isAfter(start) && txn.completionDate.isBefore(end))
        .toList();

    final totalRevenue = filteredTransactions.fold(0.0, (sum, txn) => sum + txn.totalAmount);
    final totalCommission = filteredTransactions.fold(0.0, (sum, txn) => sum + txn.commission);
    final totalVAT = filteredTransactions.fold(0.0, (sum, txn) => sum + txn.vat);
    final workersShare = totalRevenue - totalCommission - totalVAT;

    return FinancialReportSummary(
      startDate: start,
      endDate: end,
      totalRevenue: totalRevenue,
      totalCommission: totalCommission,
      totalVAT: totalVAT,
      workersShare: workersShare,
      totalServices: filteredTransactions.length,
      averageServiceValue: filteredTransactions.isEmpty
          ? 0.0
          : totalRevenue / filteredTransactions.length,
      transactions: filteredTransactions,
    );
  }

  List<FinancialTransaction> getCompletedServices() => List.unmodifiable(_completedServices);

  List<FinancialTransaction> getWorkerServices(String workerId) {
    return _completedServices
        .where((service) => service.workerId == workerId)
        .toList();
  }

  // ============= ANALYTICS =============
  MonthlyComparison getMonthlyComparison() {
    final now = DateTime.now();
    final currentMonth = getReportSummary(
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
    );

    final previousMonth = getReportSummary(
      startDate: DateTime(now.year, now.month - 1, 1),
      endDate: DateTime(now.year, now.month, 0),
    );

    return MonthlyComparison(
      currentMonth: currentMonth,
      previousMonth: previousMonth,
      revenueGrowth: _calculateGrowth(previousMonth.totalRevenue, currentMonth.totalRevenue),
      workersShareGrowth: _calculateGrowth(previousMonth.workersShare, currentMonth.workersShare),
      servicesGrowth: _calculateGrowth(
          previousMonth.totalServices.toDouble(),
          currentMonth.totalServices.toDouble()
      ),
    );
  }

  double _calculateGrowth(double previous, double current) {
    if (previous == 0) return 0.0;
    return ((current - previous) / previous) * 100;
  }

  // ============= WITHDRAWAL REQUESTS =============
  String createWithdrawalRequest({
    required String workerId,
    required String workerName,
    required double amount,
  }) {
    final requestId = 'WR${DateTime.now().millisecondsSinceEpoch}';

    final request = WithdrawalRequest(
      id: requestId,
      workerId: workerId,
      workerName: workerName,
      amount: amount,
      requestDate: DateTime.now(),
      status: 'Pending',
    );

    _withdrawalRequests.add(request);
    _notifyListeners();

    debugPrint('✅ Withdrawal request created: $requestId for SAR ${amount.toStringAsFixed(2)}');
    return requestId;
  }

  List<WithdrawalRequest> getWithdrawalRequests({String? status}) {
    if (status != null) {
      return _withdrawalRequests
          .where((req) => req.status == status)
          .toList();
    }
    return List.unmodifiable(_withdrawalRequests);
  }

  WithdrawalRequest? getWithdrawalRequestById(String requestId) {
    try {
      return _withdrawalRequests.firstWhere((req) => req.id == requestId);
    } catch (e) {
      return null;
    }
  }

  Future<WithdrawalResult> processWithdrawalRequest({
    required WithdrawalRequest request,
    required AppStateProvider appState,
    required bool approve,
    String? adminNotes,
  }) async {
    try {
      final index = _withdrawalRequests.indexWhere((r) => r.id == request.id);

      if (index == -1) {
        return WithdrawalResult(success: false, message: 'Request not found');
      }

      if (approve) {
        if (appState.walletBalance < request.amount) {
          return WithdrawalResult(
              success: false,
              message: 'Worker has insufficient wallet balance'
          );
        }

        appState.updateWalletBalance(-request.amount);

        appState.addTransaction(Transaction(
          id: 'WD${DateTime.now().millisecondsSinceEpoch}',
          workerId: appState.workerId,
          workerName: appState.workerName,
          type: TransactionType.walletWithdrawal,
          amount: -request.amount,
          balanceBefore: appState.walletBalance + request.amount,
          balanceAfter: appState.walletBalance,
          reference: request.id,
          description: 'Withdrawal to STC Pay - Request ${request.id}',
          createdAt: DateTime.now(),
        ));

        // ✅ Admin wallet pays out withdrawal
        _currentBalance -= request.amount;

        final walletTxn = WalletTransaction(
          id: 'WD_${DateTime.now().millisecondsSinceEpoch}',
          type: 'debit',
          amount: request.amount,
          description: 'Withdrawal paid - ${request.workerName}',
          serviceId: request.id,
          date: DateTime.now(),
          balanceAfter: _currentBalance,
        );

        _walletTransactions.add(walletTxn);

        _withdrawalRequests[index] = request.copyWith(
          status: 'Approved',
          processedDate: DateTime.now(),
          processedBy: 'Admin',
        );

        _notifyListeners();

        debugPrint('✅ Withdrawal approved: ${request.id} - SAR ${request.amount.toStringAsFixed(2)}');

        return WithdrawalResult(
          success: true,
          message: 'Withdrawal approved successfully',
        );
      } else {
        _withdrawalRequests[index] = request.copyWith(
          status: 'Rejected',
          processedDate: DateTime.now(),
          processedBy: 'Admin',
          adminNotes: adminNotes,
        );

        _notifyListeners();

        debugPrint('⚠️ Withdrawal rejected: ${request.id} - Reason: $adminNotes');

        return WithdrawalResult(
          success: true,
          message: 'Withdrawal rejected',
        );
      }
    } catch (e) {
      return WithdrawalResult(
        success: false,
        message: 'Error processing withdrawal: $e',
      );
    }
  }

  Map<String, dynamic> getWithdrawalStats() {
    final pending = _withdrawalRequests.where((r) => r.status == 'Pending').toList();
    final approved = _withdrawalRequests.where((r) => r.status == 'Approved').toList();
    final rejected = _withdrawalRequests.where((r) => r.status == 'Rejected').toList();

    return {
      'pendingCount': pending.length,
      'pendingAmount': pending.fold<double>(0.0, (sum, req) => sum + req.amount),
      'approvedCount': approved.length,
      'approvedAmount': approved.fold<double>(0.0, (sum, req) => sum + req.amount),
      'rejectedCount': rejected.length,
      'rejectedAmount': rejected.fold<double>(0.0, (sum, req) => sum + req.amount),
    };
  }

  void clearAllData() {
    _allTransactions.clear();
    _completedServices.clear();
    _walletTransactions.clear();
    _commissionRecords.clear();
    _vatRecords.clear();
    _withdrawalRequests.clear();
    _currentBalance = 0.0;
    _totalCommissionCollected = 0.0;
    _totalVATCollected = 0.0;
    _notifyListeners();
  }
}

// ============= RESULT CLASSES =============
class ServiceCompletionResult {
  final bool success;
  final String message;
  final FinancialTransaction? transaction;

  ServiceCompletionResult({
    required this.success,
    required this.message,
    this.transaction,
  });
}

class WithdrawalResult {
  final bool success;
  final String message;

  WithdrawalResult({required this.success, required this.message});
}