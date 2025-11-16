import 'package:flutter/foundation.dart';
import '/providers/app_state_provider.dart';

/// Financial Service - Centralized service completion handler
/// Jab worker service complete karta hai, automatically:
/// - Admin wallet update
/// - Commission record
/// - VAT record
/// - Financial reports update
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

  /// Process completed service and update all financial records
  /// Ye method call hoga jab worker "Complete Service" button press karega
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
      // Calculate all amounts
      final total = basePrice + extraCharges;
      final commission = total * 0.20; // 20% commission
      final vat = total * 0.15; // 15% VAT
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

      // Update wallet
      _updateWallet(transaction);

      // Update commission records
      _updateCommissionRecords(transaction);

      // Update VAT records
      _updateVATRecords(transaction);

      // Update financial reports
      _updateFinancialReports(transaction);

      // Notify all listeners
      _notifyListeners();

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

  // ============= WALLET MANAGEMENT =============
  final List<WalletTransaction> _walletTransactions = [];
  double _currentBalance = 0.0;

  void _updateWallet(FinancialTransaction transaction) {
    // Add earnings to wallet
    final walletTxn = WalletTransaction(
      id: 'WLT_${DateTime.now().millisecondsSinceEpoch}',
      type: 'credit',
      amount: transaction.totalAmount,
      description: 'Payment from ${transaction.serviceName} - ${transaction.customerName}',
      serviceId: transaction.serviceId,
      date: transaction.completionDate,
      balanceAfter: _currentBalance + transaction.totalAmount,
    );

    _walletTransactions.add(walletTxn);
    _currentBalance += transaction.totalAmount;

    // Deduct commission
    final commissionTxn = WalletTransaction(
      id: 'WLT_${DateTime.now().millisecondsSinceEpoch + 1}',
      type: 'debit',
      amount: transaction.commission,
      description: 'Commission (20%) - ${transaction.serviceName}',
      serviceId: transaction.serviceId,
      date: transaction.completionDate,
      balanceAfter: _currentBalance - transaction.commission,
    );

    _walletTransactions.add(commissionTxn);
    _currentBalance -= transaction.commission;

    // Deduct VAT
    final vatTxn = WalletTransaction(
      id: 'WLT_${DateTime.now().millisecondsSinceEpoch + 2}',
      type: 'debit',
      amount: transaction.vat,
      description: 'VAT (15%) - ${transaction.serviceName}',
      serviceId: transaction.serviceId,
      date: transaction.completionDate,
      balanceAfter: _currentBalance - transaction.vat,
    );

    _walletTransactions.add(vatTxn);
    _currentBalance -= transaction.vat;
  }

  List<WalletTransaction> getWalletTransactions() => List.unmodifiable(_walletTransactions);
  double getCurrentBalance() => _currentBalance;

  // ============= COMMISSION MANAGEMENT =============
  final List<CommissionRecord> _commissionRecords = [];
  double _totalCommissionCollected = 0.0;

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

  // Get commission by worker
  double getWorkerCommission(String workerId) {
    return _commissionRecords
        .where((record) => record.workerId == workerId)
        .fold(0.0, (sum, record) => sum + record.commissionAmount);
  }

  // Get commission by date range
  List<CommissionRecord> getCommissionByDateRange(DateTime start, DateTime end) {
    return _commissionRecords
        .where((record) =>
    record.date.isAfter(start) && record.date.isBefore(end))
        .toList();
  }

  // ============= VAT MANAGEMENT =============
  final List<VATRecord> _vatRecords = [];
  double _totalVATCollected = 0.0;

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

  // Get VAT by date range
  List<VATRecord> getVATByDateRange(DateTime start, DateTime end) {
    return _vatRecords
        .where((record) => record.date.isAfter(start) && record.date.isBefore(end))
        .toList();
  }

  // ============= FINANCIAL REPORTS =============
  final List<FinancialTransaction> _allTransactions = [];
  final List<FinancialTransaction> _completedServices = [];

  void _updateFinancialReports(FinancialTransaction transaction) {
    // Already added to _completedServices in processCompletedService
    // Just update summary stats
  }

  // Get report summary
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

  // Get all completed services
  List<FinancialTransaction> getCompletedServices() => List.unmodifiable(_completedServices);

  // Get services by worker
  List<FinancialTransaction> getWorkerServices(String workerId) {
    return _completedServices
        .where((service) => service.workerId == workerId)
        .toList();
  }

  // ============= ANALYTICS =============

  // Monthly comparison
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

  // ============= WITHDRAWAL REQUESTS MANAGEMENT =============
  final List<WithdrawalRequest> _withdrawalRequests = [];

  // ✅ Create withdrawal request (called from worker app)
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

  // ✅ Get withdrawal requests
  List<WithdrawalRequest> getWithdrawalRequests({String? status}) {
    if (status != null) {
      return _withdrawalRequests
          .where((req) => req.status == status)
          .toList();
    }
    return List.unmodifiable(_withdrawalRequests);
  }

  // ✅ Get withdrawal request by ID
  WithdrawalRequest? getWithdrawalRequestById(String requestId) {
    try {
      return _withdrawalRequests.firstWhere((req) => req.id == requestId);
    } catch (e) {
      return null;
    }
  }

  // ✅ Process withdrawal request (called from admin app)
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
        // Check if worker has sufficient balance
        if (appState.walletBalance < request.amount) {
          return WithdrawalResult(
              success: false,
              message: 'Worker has insufficient wallet balance'
          );
        }

        // ✅ Deduct from worker's wallet
        appState.updateWalletBalance(-request.amount);

        // ✅ Add worker transaction
        appState.addTransaction({
          'type': 'withdrawal',
          'amount': -request.amount,
          'date': DateTime.now(),
          'description': 'Withdrawal to STC Pay - Request ${request.id}',
          'txnId': 'WD${DateTime.now().millisecondsSinceEpoch}',
          'status': 'approved',
        });

        // ✅ Deduct from admin revenue
        _currentBalance -= request.amount;

        // ✅ Create admin wallet transaction
        final walletTxn = WalletTransaction(
          id: 'WD_${DateTime.now().millisecondsSinceEpoch}',
          type: 'debit',
          amount: request.amount,
          description: 'Withdrawal approved - ${request.workerName}',
          serviceId: request.id,
          date: DateTime.now(),
          balanceAfter: _currentBalance,
        );

        _walletTransactions.add(walletTxn);

        // ✅ Update request status
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
        // ✅ Reject request
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

  // ✅ Get withdrawal statistics
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

  // Clear all data (for testing)
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

// ============= DATA MODELS =============

class FinancialTransaction {
  final String id;
  final String serviceId;
  final String serviceName;
  final String workerId;
  final String workerName;
  final String customerName;
  final double basePrice;
  final double extraCharges;
  final double totalAmount;
  final double commission;
  final double vat;
  final double workerDeduction;
  final double workerEarnings;
  final String paymentMethod;
  final DateTime completionDate;
  final String status;

  FinancialTransaction({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.workerId,
    required this.workerName,
    required this.customerName,
    required this.basePrice,
    required this.extraCharges,
    required this.totalAmount,
    required this.commission,
    required this.vat,
    required this.workerDeduction,
    required this.workerEarnings,
    required this.paymentMethod,
    required this.completionDate,
    required this.status,
  });
}

class WalletTransaction {
  final String id;
  final String type; // 'credit' or 'debit'
  final double amount;
  final String description;
  final String serviceId;
  final DateTime date;
  final double balanceAfter;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.serviceId,
    required this.date,
    required this.balanceAfter,
  });
}

class CommissionRecord {
  final String id;
  final String serviceId;
  final String serviceName;
  final String workerId;
  final String workerName;
  final double serviceAmount;
  final double commissionRate;
  final double commissionAmount;
  final DateTime date;
  final String status;

  CommissionRecord({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.workerId,
    required this.workerName,
    required this.serviceAmount,
    required this.commissionRate,
    required this.commissionAmount,
    required this.date,
    required this.status,
  });
}

class VATRecord {
  final String id;
  final String serviceId;
  final String serviceName;
  final double serviceAmount;
  final double vatRate;
  final double vatAmount;
  final DateTime date;
  final String status;

  VATRecord({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.serviceAmount,
    required this.vatRate,
    required this.vatAmount,
    required this.date,
    required this.status,
  });
}

class FinancialReportSummary {
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double totalCommission;
  final double totalVAT;
  final double workersShare;
  final int totalServices;
  final double averageServiceValue;
  final List<FinancialTransaction> transactions;

  FinancialReportSummary({
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalCommission,
    required this.totalVAT,
    required this.workersShare,
    required this.totalServices,
    required this.averageServiceValue,
    required this.transactions,
  });
}

class MonthlyComparison {
  final FinancialReportSummary currentMonth;
  final FinancialReportSummary previousMonth;
  final double revenueGrowth;
  final double workersShareGrowth;
  final double servicesGrowth;

  MonthlyComparison({
    required this.currentMonth,
    required this.previousMonth,
    required this.revenueGrowth,
    required this.workersShareGrowth,
    required this.servicesGrowth,
  });
}

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

// ============= WITHDRAWAL REQUEST MODELS =============

class WithdrawalRequest {
  final String id;
  final String workerId;
  final String workerName;
  final double amount;
  final DateTime requestDate;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime? processedDate;
  final String? processedBy;
  final String? adminNotes;

  WithdrawalRequest({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.amount,
    required this.requestDate,
    required this.status,
    this.processedDate,
    this.processedBy,
    this.adminNotes,
  });

  WithdrawalRequest copyWith({
    String? status,
    DateTime? processedDate,
    String? processedBy,
    String? adminNotes,
  }) {
    return WithdrawalRequest(
      id: id,
      workerId: workerId,
      workerName: workerName,
      amount: amount,
      requestDate: requestDate,
      status: status ?? this.status,
      processedDate: processedDate ?? this.processedDate,
      processedBy: processedBy ?? this.processedBy,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}

class WithdrawalResult {
  final bool success;
  final String message;

  WithdrawalResult({required this.success, required this.message});
}