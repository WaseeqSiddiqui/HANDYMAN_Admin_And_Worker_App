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
import '/services/firestore_service.dart';
import '/services/invoice_service.dart';
import '/models/service_invoice_model.dart';

/// ✅ Financial Service - Centralized service completion handler
/// Admin wallet receives full payment and tracks all deductions
class FinancialService {
  static FinancialService _instance = FinancialService._internal();
  factory FinancialService() => _instance;

  @visibleForTesting
  static void reset() {
    _instance = FinancialService._internal();
  }

  FinancialService._internal() {
    _initializeListeners();
  }

  FirestoreService get _firestoreService => FirestoreService();

  void _initializeListeners() {
    // Admin Wallet Stream
    _firestoreService.getAdminWalletTransactionsStream().listen((transactions) {
      _walletTransactions.clear();
      _walletTransactions.addAll(transactions);

      // Recalculate balance
      _currentBalance = 0.0;
      for (var txn in _walletTransactions) {
        if (txn.type == 'credit') _currentBalance += txn.amount;
        if (txn.type == 'debit') _currentBalance -= txn.amount;
        // Note: WalletTransaction model has balanceAfter, but for aggregation we might need to be careful.
        // Ideally rely on the latest transaction's balanceAfter if ordered?
        // But here we just sum credits/debits if that's how it works.
        // Wait, the previous code computed balance incrementally.
        // Let's trust the balanceAfter from the latest transaction or recompute.
        // For now, let's just use the logic:
      }
      // Actually, standard is to trust the log or recompute.
      // Let's just notify.
      if (_walletTransactions.isNotEmpty) {
        _currentBalance = _walletTransactions
            .first
            .balanceAfter; // First is latest due to descending order
      } else {
        _currentBalance = 0.0;
      }
      _notifyListeners();
    });

    // Commission Stream
    _firestoreService.getCommissionRecordsStream().listen((records) {
      _commissionRecords.clear();
      _commissionRecords.addAll(records);
      _totalCommissionCollected = records.fold(
        0.0,
        (sum, r) => sum + r.commissionAmount,
      );
      _notifyListeners();
    });

    // VAT Stream
    _firestoreService.getVATRecordsStream().listen((records) {
      _vatRecords.clear();
      _vatRecords.addAll(records);
      _totalVATCollected = records.fold(0.0, (sum, r) => sum + r.vatAmount);
      _notifyListeners();
    });

    // Withdrawals Stream
    _firestoreService.getWithdrawalRequestsStream().listen((requests) {
      _withdrawalRequests.clear();
      _withdrawalRequests.addAll(requests);
      _notifyListeners();
    });

    // Also we need _completedServices and _allTransactions.
    // In previous code, _allTransactions was populated.
    // We should probably source this from FirestoreService.getTransactionsStream but filtering for completed?
    // Or maybe we don't strictly need it if we have specific records.
    // Let's look at getReportSummary. It uses _completedServices.
    // We can populate _completedServices by listening to ALL transactions or a specific collection?
    // FirestoreService creates 'transactions' collection which are mostly worker-centric.
    // But FinancialService creates FinancialTransaction struct which is slightly different.
    // Wait, FinancialService.processCompletedService adds to _allTransactions.
    // We didn't create a 'financial_transactions' collection in FirestoreService.
    // We should probably just use the 'transactions' collection or rely on Commission/VAT/AdminWallet to reconstruct reports?
    // OR, better, persist 'financial_transactions' if they store more info.
    // ServiceCompletionResult returns a FinancialTransaction.
    // Let's rely on _completedServices being populated from ServiceRequests that are 'completed'?
    listenToCompletedServices();
  }

  void listenToCompletedServices() {
    _firestoreService.getServiceRequestsStream().listen((services) {
      _completedServices.clear();
      final completed = services
          .where(
            (s) =>
                s.status.toString().contains('completed') ||
                s.status.name == 'completed',
          )
          .toList();

      for (var s in completed) {
        // Map ServiceRequest to FinancialTransaction if possible for reports
        final total = s.totalPrice;
        final commission =
            s.totalCommission; // ✅ FIXED: Use calculated amount, not rate
        final vat = s.totalVAT; // ✅ FIXED: Use calculated amount, not rate
        final workerEarnings = total - commission - vat;

        _completedServices.add(
          FinancialTransaction(
            id: s.id, // Use service ID or derived
            serviceId: s.id,
            serviceName: s.serviceName,
            workerId: s.workerId ?? '',
            workerName: s.workerName ?? '',
            customerName: s.customerName,
            basePrice: s.basePrice,
            extraCharges: s.extraItems.fold(0, (sum, i) => sum + i.price),
            totalAmount: total,
            commission: commission,
            vat: vat,
            workerDeduction: commission + vat,
            workerEarnings: workerEarnings,
            paymentMethod: s.paymentMethod?.name ?? 'Cash', // Enum to string
            completionDate: s.completedDate ?? s.updatedAt,
            status: 'completed',
          ),
        );
      }

      // _allTransactions is basically the same
      _allTransactions.clear();
      _allTransactions.addAll(_completedServices);
      _notifyListeners();
    });
  }

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

      // ✅ FIXED: Update admin wallet based on payment method
      await _updateAdminWallet(transaction, paymentMethod);

      // Update commission records
      await _updateCommissionRecords(transaction);

      // Update VAT records
      await _updateVATRecords(transaction);

      // ✅ FIXED: Generate and Save Invoice
      try {
        final invoice = ServiceInvoice(
          invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
          serviceRequestId: serviceId,
          serviceId: serviceId,
          serviceName: serviceName,
          customerId:
              'N/A', // Customer ID not passed, maybe use customer name or update signature
          customerName: customerName,
          customerAddress: 'N/A', // Address not passed in method signature
          workerName: workerName,
          basePrice: basePrice,
          extraCharges: extraCharges,
          extraItems:
              [], // Extra items details not passed in method signature, might need to fetch or pass them
          totalAmount:
              total, // Total amount (including VAT/Commission? No, Invoice total is usually what customer pays)
          // Wait, totalAmount in FinancialTransaction IS what customer pays.
          // In ServiceInvoice, totalAmount is usually Subtotal + VAT.
          // Here 'total' = base + extras.
          // Is VAT allowed on top?
          // FinancialService implementation says: "Commission and VAT are INCLUDED in total, not added".
          // So Invoice Total = total.
          vat: vat,
          commission: commission,
          completionDate: completionDate,
          paymentMethod: paymentMethod,
          status: 'Paid',
        );

        // Check if invoice already exists to prevent duplicates
        final existingInvoice = InvoiceService().getInvoiceByServiceId(
          serviceId,
        );
        if (existingInvoice != null) {
          debugPrint(
            '⚠️ Invoice already exists for service $serviceId: ${existingInvoice.invoiceNumber}',
          );
        } else {
          // We need InvoiceService instance.
          // Since we cannot easily inject it here without changing constructor steps,
          // and it is a singleton, we can use the factory.
          await InvoiceService().saveInvoice(invoice);
          debugPrint('✅ Invoice generated: ${invoice.invoiceNumber}');
        }
      } catch (e) {
        debugPrint('❌ Error generating invoice: $e');
        // Don't fail the whole transaction if invoice fails, but log it.
      }

      // Notify all listeners
      _notifyListeners();

      debugPrint('✅ Financial Service: Service completed - $serviceId');
      debugPrint('   Total Payment: SAR ${total.toStringAsFixed(2)}');
      debugPrint('   Commission: SAR ${commission.toStringAsFixed(2)}');
      debugPrint('   VAT: SAR ${vat.toStringAsFixed(2)}');
      debugPrint(
        '   Worker Earnings: SAR ${workerEarnings.toStringAsFixed(2)}',
      );
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
  // ✅ FIXED: Admin wallet based on payment method
  // ONLINE: Receives full payment, then pays worker
  // CASH: Receives only VAT + Commission (worker already got cash)
  Future<void> _updateAdminWallet(
    FinancialTransaction transaction,
    String paymentMethod,
  ) async {
    if (paymentMethod == 'Cash') {
      // CASH: Admin receives only VAT + Commission
      final deductionAmount = transaction.commission + transaction.vat;

      final deductionTxn = WalletTransaction(
        id: 'WLT_${DateTime.now().millisecondsSinceEpoch}',
        type: 'credit',
        amount: deductionAmount,
        description:
            'VAT+Commission received (CASH) - ${transaction.serviceName} (${transaction.customerName})',
        serviceId: transaction.serviceId,
        date: transaction.completionDate,
        balanceAfter: _currentBalance + deductionAmount,
      );

      await _firestoreService.addAdminWalletTransaction(deductionTxn);
      _currentBalance += deductionAmount; // Optimistic update

      debugPrint(
        '✅ Admin Wallet (CASH): +SAR ${deductionAmount.toStringAsFixed(2)} (VAT+Commission only)',
      );
    } else {
      // ONLINE: Admin receives FULL payment from customer
      final paymentTxn = WalletTransaction(
        id: 'WLT_${DateTime.now().millisecondsSinceEpoch}',
        type: 'credit',
        amount: transaction.totalAmount,
        description:
            'Payment received (ONLINE) - ${transaction.serviceName} (${transaction.customerName})',
        serviceId: transaction.serviceId,
        date: transaction.completionDate,
        balanceAfter: _currentBalance + transaction.totalAmount,
      );

      await _firestoreService.addAdminWalletTransaction(paymentTxn);
      _currentBalance += transaction.totalAmount; // Optimistic update

      debugPrint(
        '✅ Admin Wallet (ONLINE): +SAR ${transaction.totalAmount.toStringAsFixed(2)} (Full payment received)',
      );
    }

    // ✅ REMOVED: These were creating duplicate wallet entries and inflating balance
    // Commission and VAT are already tracked in their own collections
    // The wallet should only show actual money received, not breakdowns

    debugPrint(
      '✅ Admin Wallet Balance: SAR ${_currentBalance.toStringAsFixed(2)}',
    );
    debugPrint(
      '   Commission: SAR ${transaction.commission.toStringAsFixed(2)}',
    );
    debugPrint('   VAT: SAR ${transaction.vat.toStringAsFixed(2)}');
  }

  List<WalletTransaction> getWalletTransactions() =>
      List.unmodifiable(_walletTransactions);
  double getCurrentBalance() => _currentBalance;

  // ============= COMMISSION MANAGEMENT =============
  Future<void> _updateCommissionRecords(
    FinancialTransaction transaction,
  ) async {
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

    await _firestoreService.addCommissionRecord(record);
    // Local list update handled by stream
  }

  List<CommissionRecord> getCommissionRecords() =>
      List.unmodifiable(_commissionRecords);
  double getTotalCommissionCollected() => _totalCommissionCollected;

  double getWorkerCommission(String workerId) {
    return _commissionRecords
        .where((record) => record.workerId == workerId)
        .fold(0.0, (sum, record) => sum + record.commissionAmount);
  }

  List<CommissionRecord> getCommissionByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _commissionRecords
        .where(
          (record) => record.date.isAfter(start) && record.date.isBefore(end),
        )
        .toList();
  }

  // ============= VAT MANAGEMENT =============
  Future<void> _updateVATRecords(FinancialTransaction transaction) async {
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

    await _firestoreService.addVATRecord(record);
    // Local list update handled by stream
  }

  List<VATRecord> getVATRecords() => List.unmodifiable(_vatRecords);
  double getTotalVATCollected() => _totalVATCollected;

  List<VATRecord> getVATByDateRange(DateTime start, DateTime end) {
    return _vatRecords
        .where(
          (record) => record.date.isAfter(start) && record.date.isBefore(end),
        )
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
        .where(
          (txn) =>
              txn.completionDate.isAfter(start) &&
              txn.completionDate.isBefore(end),
        )
        .toList();

    final totalRevenue = filteredTransactions.fold(
      0.0,
      (sum, txn) => sum + txn.totalAmount,
    );
    final totalCommission = filteredTransactions.fold(
      0.0,
      (sum, txn) => sum + txn.commission,
    );
    final totalVAT = filteredTransactions.fold(
      0.0,
      (sum, txn) => sum + txn.vat,
    );
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

  List<FinancialTransaction> getCompletedServices() =>
      List.unmodifiable(_completedServices);

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
      revenueGrowth: _calculateGrowth(
        previousMonth.totalRevenue,
        currentMonth.totalRevenue,
      ),
      workersShareGrowth: _calculateGrowth(
        previousMonth.workersShare,
        currentMonth.workersShare,
      ),
      servicesGrowth: _calculateGrowth(
        previousMonth.totalServices.toDouble(),
        currentMonth.totalServices.toDouble(),
      ),
    );
  }

  double _calculateGrowth(double previous, double current) {
    if (previous == 0) return 0.0;
    return ((current - previous) / previous) * 100;
  }

  // ============= WITHDRAWAL REQUESTS =============
  Future<String> createWithdrawalRequest({
    required String workerId,
    required String workerName,
    required double amount,
  }) async {
    final requestId = 'WR${DateTime.now().millisecondsSinceEpoch}';

    final request = WithdrawalRequest(
      id: requestId,
      workerId: workerId,
      workerName: workerName,
      amount: amount,
      requestDate: DateTime.now(),
      status: 'Pending',
    );

    await _firestoreService.addWithdrawalRequest(request);

    debugPrint(
      '✅ Withdrawal request created: $requestId for SAR ${amount.toStringAsFixed(2)}',
    );
    return requestId;
  }

  List<WithdrawalRequest> getWithdrawalRequests({String? status}) {
    if (status != null) {
      return _withdrawalRequests.where((req) => req.status == status).toList();
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
            message: 'Worker has insufficient wallet balance',
          );
        }

        appState.updateWalletBalance(-request.amount);

        appState.addTransaction(
          Transaction(
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
          ),
        );

        // ✅ Admin wallet pays out withdrawal
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

        await _firestoreService.addAdminWalletTransaction(walletTxn);

        // Update withdrawal status in Firestore
        final updatedRequest = request.copyWith(
          status: 'Approved',
          processedDate: DateTime.now(),
          processedBy: 'Admin',
        );
        await _firestoreService.updateWithdrawalRequest(updatedRequest);

        debugPrint(
          '✅ Withdrawal approved: ${request.id} - SAR ${request.amount.toStringAsFixed(2)}',
        );

        return WithdrawalResult(
          success: true,
          message: 'Withdrawal approved successfully',
        );
      } else {
        final updatedRequest = request.copyWith(
          status: 'Rejected',
          processedDate: DateTime.now(),
          processedBy: 'Admin',
          adminNotes: adminNotes,
        );
        await _firestoreService.updateWithdrawalRequest(updatedRequest);

        debugPrint(
          '⚠️ Withdrawal rejected: ${request.id} - Reason: $adminNotes',
        );

        return WithdrawalResult(success: true, message: 'Withdrawal rejected');
      }
    } catch (e) {
      return WithdrawalResult(
        success: false,
        message: 'Error processing withdrawal: $e',
      );
    }
  }

  Map<String, dynamic> getWithdrawalStats() {
    final pending = _withdrawalRequests
        .where((r) => r.status == 'Pending')
        .toList();
    final approved = _withdrawalRequests
        .where((r) => r.status == 'Approved')
        .toList();
    final rejected = _withdrawalRequests
        .where((r) => r.status == 'Rejected')
        .toList();

    return {
      'pendingCount': pending.length,
      'pendingAmount': pending.fold<double>(
        0.0,
        (sum, req) => sum + req.amount,
      ),
      'approvedCount': approved.length,
      'approvedAmount': approved.fold<double>(
        0.0,
        (sum, req) => sum + req.amount,
      ),
      'rejectedCount': rejected.length,
      'rejectedAmount': rejected.fold<double>(
        0.0,
        (sum, req) => sum + req.amount,
      ),
    };
  }

  void clearAllData() {
    // TODO: Implement clear for Firestore if needed, for now just clear local RAM
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
