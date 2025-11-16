import 'package:flutter/material.dart';
import '/services/financial_service.dart';
import 'package:flutter/scheduler.dart';
import '/services/worker_auth_service.dart';
import '/services/invoice_service.dart';

class AppStateProvider with ChangeNotifier {
  final _financialService = FinancialService();
  final _workerAuthService = WorkerAuthService();
  final _invoiceService = InvoiceService();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final Map<String, WorkerFinancialData> _workerData = {};
  String? currentWorkerId;
  String? currentWorkerName;
  List<Map<String, dynamic>> _serviceRequests = [];

  // ✅ Getters for worker info (needed for withdrawal requests)
  String get workerId => currentWorkerId ?? 'UNKNOWN';
  String get workerName => currentWorkerName ?? 'Worker';

  @override
  void notifyListeners() {
    if (!_isInitialized) {
      debugPrint('⚠️ Skipping notification - not initialized');
      return;
    }

    final binding = WidgetsBinding.instance;
    if (binding.schedulerPhase != SchedulerPhase.idle &&
        binding.schedulerPhase != SchedulerPhase.postFrameCallbacks) {
      debugPrint('⚠️ Not idle phase, scheduling for next frame');
      binding.addPostFrameCallback((_) {
        if (_isInitialized) {
          try {
            super.notifyListeners();
          } catch (e) {
            debugPrint('❌ Error in delayed notifyListeners: $e');
          }
        }
      });
      return;
    }

    try {
      super.notifyListeners();
    } catch (e) {
      debugPrint('❌ Error in notifyListeners: $e');
    }
  }

  AppStateProvider() {
    debugPrint('🔧 AppStateProvider created');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  void _initialize() {
    debugPrint('🚀 Initializing AppStateProvider...');

    _serviceRequests = [
      {
        'id': 'SR001',
        'serviceType': 'AC Repair',
        'service': 'AC Repair',
        'customer': 'Ahmed Al-Mansour',
        'customerPhone': '+966501234567',
        'location': 'Riyadh',
        'address': 'Al Malqa, Riyadh 13521',
        'date': DateTime.now().add(const Duration(days: 2)),
        'requestDate': DateTime.now(),
        'price': 250.0,
        'extraCharges': 0.0,
        'extraItems': [],
        'description': 'Air conditioning not cooling properly',
        'priority': 'high',
        'status': 'Requested',
        'assignedWorkerId': null,
        'assignedWorkerName': null,
      },
      {
        'id': 'SR002',
        'serviceType': 'Plumbing',
        'service': 'Plumbing',
        'customer': 'Fatima Hassan',
        'customerPhone': '+966507654321',
        'location': 'Jeddah',
        'address': 'Al Hamra, Jeddah 23323',
        'date': DateTime.now().add(const Duration(days: 1)),
        'requestDate': DateTime.now(),
        'price': 180.0,
        'extraCharges': 0.0,
        'extraItems': [],
        'description': 'Leaking kitchen sink',
        'priority': 'medium',
        'status': 'Requested',
        'assignedWorkerId': null,
        'assignedWorkerName': null,
      },
    ];

    _isInitialized = true;
    debugPrint('✅ AppStateProvider initialized with ${_serviceRequests.length} services');
    notifyListeners();
  }

  void loadMockData() {
    if (_isInitialized) {
      notifyListeners();
    }
  }

  WorkerFinancialData get _currentWorkerData {
    if (currentWorkerId == null || !_workerData.containsKey(currentWorkerId)) {
      return WorkerFinancialData(
        workerId: 'unknown',
        creditBalance: 0.0,
        walletBalance: 0.0,
      );
    }
    return _workerData[currentWorkerId]!;
  }

  // ✅ ALL GETTERS - COMPLETE WITH RECALCULATION
  double get creditBalance => _currentWorkerData.creditBalance;
  double get walletBalance => _currentWorkerData.walletBalance;

  // ✅ FIXED: Always recalculate pending amount when accessed
  double get pendingAmount {
    _currentWorkerData.calculatePendingAmount(_serviceRequests.where((s) =>
    s['assignedWorkerId'] == currentWorkerId && s['status'] == 'In Progress'
    ).toList());
    return _currentWorkerData.pendingAmount;
  }

  // ✅ Wallet breakdown getters
  double get availableForWithdrawal => _currentWorkerData.availableForWithdrawal;
  double get pendingClearance => _currentWorkerData.pendingClearance;

  // ✅ Earnings breakdown getters
  int get totalServicesCompleted => _currentWorkerData.totalServicesCompleted;
  double get totalEarnings => _currentWorkerData.totalEarnings;
  double get averagePerService => _currentWorkerData.averagePerService;

  // ✅ NEW: Check if worker can withdraw (7 days after last service)
  bool canWithdraw() {
    if (currentWorkerId == null) return false;

    final lastCreditDate = _currentWorkerData.lastWalletCreditDate;
    if (lastCreditDate == null) return true; // No service completed yet, can withdraw

    final daysSinceLastCredit = DateTime.now().difference(lastCreditDate).inDays;
    return daysSinceLastCredit >= 7;
  }

  // ✅ NEW: Get days remaining until withdrawal allowed
  int getDaysUntilWithdrawal() {
    if (currentWorkerId == null) return 0;

    final lastCreditDate = _currentWorkerData.lastWalletCreditDate;
    if (lastCreditDate == null) return 0; // No restriction

    final daysSinceLastCredit = DateTime.now().difference(lastCreditDate).inDays;
    final remaining = 7 - daysSinceLastCredit;
    return remaining > 0 ? remaining : 0;
  }

  List<Map<String, dynamic>> get availableServices =>
      currentWorkerId == null
          ? []
          : _serviceRequests
          .where((s) =>
      s['assignedWorkerId'] == currentWorkerId &&
          s['status'] == 'Assigned')
          .toList();

  List<Map<String, dynamic>> get activeServices =>
      currentWorkerId == null
          ? []
          : _serviceRequests
          .where((s) =>
      s['assignedWorkerId'] == currentWorkerId &&
          s['status'] == 'In Progress')
          .toList();

  List<Map<String, dynamic>> get completedServices =>
      currentWorkerId == null ? [] : _currentWorkerData.completedServices;

  List<Map<String, dynamic>> get postponedServices =>
      currentWorkerId == null
          ? []
          : _serviceRequests
          .where((s) =>
      s['assignedWorkerId'] == currentWorkerId &&
          s['status'] == 'Postponed')
          .toList();

  List<Map<String, dynamic>> get transactions =>
      currentWorkerId == null ? [] : _currentWorkerData.transactions;

  List<Map<String, dynamic>> get adminRequestedServices {
    return _serviceRequests
        .where((s) => s['status'] == 'Requested' || s['status'] == 'Assigned')
        .toList();
  }

  List<Map<String, dynamic>> get adminAssignedServices {
    return _serviceRequests.where((s) => s['status'] == 'Assigned').toList();
  }

  List<Map<String, dynamic>> get adminInProgressServices {
    return _serviceRequests.where((s) => s['status'] == 'In Progress').toList();
  }

  List<Map<String, dynamic>> get adminPostponedServices {
    return _serviceRequests.where((s) => s['status'] == 'Postponed').toList();
  }

  List<Map<String, dynamic>> get adminAllActiveServices {
    return _serviceRequests;
  }

  List<Map<String, dynamic>> get adminCompletedServices {
    return _financialService.getCompletedServices().map((txn) {
      return {
        'id': txn.serviceId,
        'serviceType': txn.serviceName,
        'service': txn.serviceName,
        'customer': txn.customerName,
        'customerPhone': '+966501234567',
        'location': 'Riyadh',
        'address': 'Service Location',
        'requestDate': txn.completionDate.subtract(const Duration(days: 1)),
        'scheduledDate': txn.completionDate.subtract(const Duration(hours: 2)),
        'completedDate': txn.completionDate,
        'date': txn.completionDate,
        'baseAmount': txn.basePrice,
        'price': txn.basePrice,
        'extraCharges': txn.extraCharges,
        'totalAmount': txn.totalAmount,
        'vat': txn.vat,
        'commission': txn.commission,
        'description': '${txn.serviceName} completed',
        'priority': 'medium',
        'status': 'Completed',
        'assignedWorker': txn.workerName,
        'assignedWorkerId': txn.workerId,
        'worker': txn.workerName,
        'workerId': txn.workerId,
        'workerRating': 4.5,
        'customerFeedback': 'Service completed successfully',
        'completionNotes': 'Payment via ${txn.paymentMethod}',
      };
    }).toList();
  }

  void setCurrentWorker(String workerId) {
    currentWorkerId = workerId;

    final workers = _workerAuthService.getAllWorkers();
    final workerData = workers.firstWhere(
          (w) => w.id == workerId,
      orElse: () => WorkerData(
        id: workerId,
        name: 'Worker',
        nameArabic: '',
        phone: '',
        email: '',
        nationalId: '',
        stcPayId: '',
        address: '',
        addressArabic: '',
        status: 'Active',
        joinedDate: DateTime.now(),
        creditBalance: 100.0,
        completedServices: 0,
      ),
    );

    // ✅ Store worker name for withdrawal requests
    currentWorkerName = workerData.name;

    if (!_workerData.containsKey(workerId)) {
      _workerData[workerId] = WorkerFinancialData(
        workerId: workerId,
        creditBalance: workerData.creditBalance,
        walletBalance: 0.0,
      );
    } else {
      _workerData[workerId]!.creditBalance = workerData.creditBalance;
    }

    debugPrint('✅ Worker $workerId ($currentWorkerName) logged in');
    notifyListeners();
  }

  void assignServiceToWorker(
      String serviceId, String workerId, String workerName) {
    final serviceIndex =
    _serviceRequests.indexWhere((s) => s['id'] == serviceId);

    if (serviceIndex != -1) {
      final workerData = _workerAuthService.getAllWorkers().firstWhere(
            (w) => w.id == workerId,
        orElse: () => WorkerData(
          id: workerId,
          name: workerName,
          nameArabic: '',
          phone: '',
          email: '',
          nationalId: '',
          stcPayId: '',
          address: '',
          addressArabic: '',
          status: 'Active',
          joinedDate: DateTime.now(),
        ),
      );

      _serviceRequests[serviceIndex] = {
        ..._serviceRequests[serviceIndex],
        'status': 'Assigned',
        'assignedWorkerId': workerId,
        'assignedWorkerName': workerName,
        'assignedWorkerPhone': workerData.phone,
        'assignedAt': DateTime.now(),
      };

      debugPrint('✅ Service $serviceId assigned to $workerName');
      notifyListeners();
    }
  }

  void acceptService(dynamic serviceOrId) {
    if (currentWorkerId == null) return;

    String serviceId;
    if (serviceOrId is Map<String, dynamic>) {
      serviceId = serviceOrId['id'] as String;
    } else {
      serviceId = serviceOrId as String;
    }

    final serviceIndex =
    _serviceRequests.indexWhere((s) => s['id'] == serviceId);
    if (serviceIndex != -1) {
      final currentStatus = _serviceRequests[serviceIndex]['status'];

      _serviceRequests[serviceIndex] = {
        ..._serviceRequests[serviceIndex],
        'status': 'In Progress',
        'startedAt': DateTime.now(),
        'worker':
        _serviceRequests[serviceIndex]['assignedWorkerName'] ?? 'Worker',
        'workerId': currentWorkerId,
      };

      if (currentStatus == 'Postponed') {
        _serviceRequests[serviceIndex].remove('postponeReason');
        _serviceRequests[serviceIndex].remove('postponedAt');
        _serviceRequests[serviceIndex].remove('postponedBy');
        _serviceRequests[serviceIndex].remove('postponedByWorkerName');
        _serviceRequests[serviceIndex].remove('originalScheduledDate');
        _serviceRequests[serviceIndex].remove('newScheduledDate');
      }

      _currentWorkerData.calculatePendingAmount(activeServices);
      debugPrint('✅ Service $serviceId accepted');
      notifyListeners();
    }
  }

  void resumeService(Map<String, dynamic> service) {
    acceptService(service);
  }

  void postponeAvailableService(dynamic serviceOrId, [String? reason]) {
    if (currentWorkerId == null) return;

    String serviceId;
    if (serviceOrId is Map<String, dynamic>) {
      serviceId = serviceOrId['id'] as String;
    } else {
      serviceId = serviceOrId as String;
    }

    final serviceIndex =
    _serviceRequests.indexWhere((s) => s['id'] == serviceId);
    if (serviceIndex != -1) {
      _serviceRequests[serviceIndex] = {
        ..._serviceRequests[serviceIndex],
        'status': 'Postponed',
        'postponeReason': reason ?? 'Worker postponed before accepting',
        'postponedAt': DateTime.now(),
        'postponedBy': 'Worker',
        'postponedByWorkerName':
        _serviceRequests[serviceIndex]['assignedWorkerName'],
        'originalScheduledDate': _serviceRequests[serviceIndex]['date'],
        'newScheduledDate': DateTime.now().add(const Duration(days: 2)),
      };

      debugPrint('✅ Service $serviceId postponed before acceptance');
      notifyListeners();
    }
  }

  Future<void> completeService(dynamic serviceOrId) async {
    if (currentWorkerId == null) return;

    String serviceId;
    if (serviceOrId is Map<String, dynamic>) {
      serviceId = serviceOrId['id'] as String;
    } else {
      serviceId = serviceOrId as String;
    }

    final serviceIndex =
    _serviceRequests.indexWhere((s) => s['id'] == serviceId);
    if (serviceIndex == -1) return;

    final service = _serviceRequests[serviceIndex];
    final totalPrice = (service['price'] as num).toDouble() +
        ((service['extraCharges'] ?? 0.0) as num).toDouble();

    final commission = totalPrice * 0.20;
    final vat = totalPrice * 0.15;
    final requiredCredit = commission + vat;

    _currentWorkerData.walletBalance += totalPrice;
    _currentWorkerData.creditBalance -= requiredCredit;

    service['status'] = 'Completed';
    service['commission'] = commission;
    service['vat'] = vat;
    service['completedAt'] = DateTime.now();

    _currentWorkerData.completedServices.insert(0, Map.from(service));
    _serviceRequests.removeAt(serviceIndex);

    _currentWorkerData.transactions.insert(0, {
      'type': 'service_completed',
      'amount': totalPrice,
      'date': DateTime.now(),
      'walletCreditDate': DateTime.now(),
      'description': '${service['service']} - ${service['customer']}',
      'txnId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
      'serviceId': service['id'],
    });

    _currentWorkerData.transactions.insert(0, {
      'type': 'platform_fee',
      'amount': -requiredCredit,
      'date': DateTime.now(),
      'description': 'Commission & VAT deducted',
      'txnId': 'TXN${DateTime.now().millisecondsSinceEpoch + 1}',
      'serviceId': service['id'],
    });

    // ✅ CRITICAL: Update last wallet credit date (for 7-day withdrawal restriction)
    _currentWorkerData.lastWalletCreditDate = DateTime.now();

    await _financialService.processCompletedService(
      serviceId: service['id'],
      serviceName: service['service'],
      workerName: service['worker'] ?? 'Worker',
      workerId: currentWorkerId!,
      customerName: service['customer'],
      basePrice: service['price'],
      extraCharges: service['extraCharges'] ?? 0.0,
      completionDate: DateTime.now(),
      paymentMethod: 'Cash',
    );

    final extraItems =
        (service['extraItems'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            [];

    await _invoiceService.generateInvoiceForCompletedService(
      serviceId: service['id'],
      serviceName: service['service'],
      customerName: service['customer'],
      customerAddress: service['address'] ?? 'N/A',
      workerName: service['worker'] ?? 'Worker',
      basePrice: (service['price'] as num).toDouble(),
      extraCharges: ((service['extraCharges'] ?? 0.0) as num).toDouble(),
      extraItems: extraItems,
      completionDate: DateTime.now(),
      paymentMethod: 'Cash',
    );

    final workerData = _workerAuthService.getWorkerByPhone(
      service['assignedWorkerPhone'] ?? service['workerPhone'] ?? '',
    );
    if (workerData != null) {
      _workerAuthService.updateWorkerCredit(
        workerData.phone,
        _currentWorkerData.creditBalance,
      );
      _workerAuthService.updateWorkerServices(
        workerData.phone,
        _currentWorkerData.completedServices.length,
      );
    }

    _currentWorkerData.calculatePendingAmount(activeServices);
    debugPrint('✅ Service $serviceId completed (7-day withdrawal restriction started)');
    notifyListeners();
  }

  void postponeService(dynamic serviceOrId, [String? reason]) {
    if (currentWorkerId == null) return;

    String serviceId;
    if (serviceOrId is Map<String, dynamic>) {
      serviceId = serviceOrId['id'] as String;
    } else {
      serviceId = serviceOrId as String;
    }

    final serviceIndex =
    _serviceRequests.indexWhere((s) => s['id'] == serviceId);
    if (serviceIndex != -1) {
      _serviceRequests[serviceIndex] = {
        ..._serviceRequests[serviceIndex],
        'status': 'Postponed',
        'postponeReason': reason ?? 'Worker postponed the service',
        'postponedAt': DateTime.now(),
        'postponedBy': 'Worker',
        'postponedByWorkerName':
        _serviceRequests[serviceIndex]['assignedWorkerName'],
        'originalScheduledDate': _serviceRequests[serviceIndex]['date'],
        'newScheduledDate': DateTime.now().add(const Duration(days: 2)),
      };

      _currentWorkerData.calculatePendingAmount(activeServices);
      debugPrint('✅ Service $serviceId postponed');
      notifyListeners();
    }
  }

  void reschedulePostponedService({
    required String serviceId,
    required String newWorkerId,
    required String newWorkerName,
    required DateTime newScheduledDate,
  }) {
    final serviceIndex =
    _serviceRequests.indexWhere((s) => s['id'] == serviceId);

    if (serviceIndex != -1) {
      _serviceRequests[serviceIndex] = {
        ..._serviceRequests[serviceIndex],
        'assignedWorkerId': newWorkerId,
        'assignedWorkerName': newWorkerName,
        'status': 'Assigned',
        'date': newScheduledDate,
        'rescheduleDate': DateTime.now(),
        'postponeReason': null,
        'postponedAt': null,
        'postponedBy': null,
        'postponedByWorkerName': null,
        'originalScheduledDate': null,
        'newScheduledDate': null,
      };

      debugPrint('✅ Service $serviceId rescheduled');
      notifyListeners();
    }
  }

  void addServiceRequest(Map<String, dynamic> serviceData) {
    final newService = {
      'id': 'SR${DateTime.now().millisecondsSinceEpoch}',
      ...serviceData,
      'status': 'Requested',
      'requestDate': DateTime.now(),
      'assignedWorkerId': null,
      'assignedWorkerName': null,
      'extraCharges': 0.0,
      'extraItems': [],
    };

    _serviceRequests.insert(0, newService);
    debugPrint('✅ New service request added');
    notifyListeners();
  }

  Map<String, dynamic>? getServiceById(String serviceId) {
    try {
      return _serviceRequests.firstWhere((s) => s['id'] == serviceId);
    } catch (e) {
      try {
        return _currentWorkerData.completedServices
            .firstWhere((s) => s['id'] == serviceId);
      } catch (e) {
        return null;
      }
    }
  }

  double getRequiredCredit(Map<String, dynamic> service) {
    final totalPrice = (service['price'] as num).toDouble() +
        ((service['extraCharges'] ?? 0.0) as num).toDouble();
    return totalPrice * 0.35;
  }

  bool hasEnoughCredit(Map<String, dynamic> service) {
    return creditBalance >= getRequiredCredit(service);
  }

  void addExtraCharges(String serviceId, double extraCharges) {
    final serviceIndex =
    _serviceRequests.indexWhere((s) => s['id'] == serviceId);
    if (serviceIndex != -1) {
      _serviceRequests[serviceIndex]['extraCharges'] =
          ((_serviceRequests[serviceIndex]['extraCharges'] ?? 0.0) as num)
              .toDouble() +
              extraCharges;

      if (_serviceRequests[serviceIndex]['status'] == 'In Progress') {
        _currentWorkerData.calculatePendingAmount(activeServices);
      }
      notifyListeners();
    }
  }

  void addExtraItems(String serviceId, List<Map<String, dynamic>> items) {
    final serviceIndex =
    _serviceRequests.indexWhere((s) => s['id'] == serviceId);
    if (serviceIndex != -1) {
      final existingItems =
          (_serviceRequests[serviceIndex]['extraItems'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
              [];
      _serviceRequests[serviceIndex]['extraItems'] = [
        ...existingItems,
        ...items
      ];

      double totalExtra = 0.0;
      for (var item in _serviceRequests[serviceIndex]['extraItems'] as List) {
        totalExtra += (item['price'] as num).toDouble();
      }
      _serviceRequests[serviceIndex]['extraCharges'] = totalExtra;

      if (_serviceRequests[serviceIndex]['status'] == 'In Progress') {
        _currentWorkerData.calculatePendingAmount(activeServices);
      }
      notifyListeners();
    }
  }

  void topUpCreditSTC(double amount, String stcNumber) {
    if (currentWorkerId == null) return;

    _currentWorkerData.creditBalance += amount;
    _currentWorkerData.transactions.insert(0, {
      'type': 'topup_stc',
      'amount': amount,
      'date': DateTime.now(),
      'description': 'Credit top-up via STC Pay ($stcNumber)',
      'txnId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
    });
    notifyListeners();
  }

  void topUpCreditWallet(double amount, String method) {
    if (currentWorkerId == null) return;

    _currentWorkerData.creditBalance += amount;
    _currentWorkerData.transactions.insert(0, {
      'type': 'credit_topup',
      'amount': amount,
      'date': DateTime.now(),
      'description': 'Credit top-up via $method',
      'txnId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
    });
    notifyListeners();
  }

  void transferWalletToCredit(double amount) {
    if (currentWorkerId == null) return;

    if (_currentWorkerData.walletBalance >= amount) {
      _currentWorkerData.walletBalance -= amount;
      _currentWorkerData.creditBalance += amount;
      _currentWorkerData.transactions.insert(0, {
        'type': 'transfer_wallet_to_credit',
        'amount': amount,
        'date': DateTime.now(),
        'description': 'Transferred from Wallet to Credit',
        'txnId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
      });
      notifyListeners();
    }
  }

  void updateCreditBalance(double amount) {
    if (currentWorkerId == null) return;

    _currentWorkerData.creditBalance += amount;
    _currentWorkerData.transactions.insert(0, {
      'type': 'topup_stc',
      'amount': amount,
      'date': DateTime.now(),
      'description': 'Credit top-up via STC Pay',
      'txnId': 'STC${DateTime.now().millisecondsSinceEpoch}',
    });
    notifyListeners();
  }

  void updateWalletBalance(double amount) {
    if (currentWorkerId == null) return;

    _currentWorkerData.walletBalance += amount;
    notifyListeners();
  }

  void addTransaction(Map<String, dynamic> transaction) {
    if (currentWorkerId == null) return;

    _currentWorkerData.transactions.insert(0, transaction);
    notifyListeners();
  }
}

class WorkerFinancialData {
  final String workerId;
  double creditBalance;
  double walletBalance;
  double pendingAmount = 0.0;
  double availableForWithdrawal = 0.0;
  double pendingClearance = 0.0;
  DateTime? lastWalletCreditDate;

  int totalServicesCompleted = 0;
  double totalEarnings = 0.0;
  double averagePerService = 0.0;

  List<Map<String, dynamic>> completedServices = [];
  List<Map<String, dynamic>> transactions = [];

  WorkerFinancialData({
    required this.workerId,
    required this.creditBalance,
    required this.walletBalance,
    this.lastWalletCreditDate,
  }) {
    transactions = [
      {
        'type': 'topup_stc',
        'amount': 100.0,
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'description': 'Initial credit top-up via STC Pay',
        'txnId': 'TXN1001',
      },
    ];
    _calculateBalances();
  }

  void _calculateBalances() {
    final now = DateTime.now();
    pendingClearance = 0.0;

    for (var txn in transactions) {
      if (txn['type'] == 'service_completed' && txn['walletCreditDate'] != null) {
        final creditDate = txn['walletCreditDate'] as DateTime;
        final daysSince = now.difference(creditDate).inDays;

        if (daysSince < 7) {
          pendingClearance += (txn['amount'] as num).toDouble();
        }
      }
    }

    availableForWithdrawal = walletBalance - pendingClearance;
    if (availableForWithdrawal < 0) availableForWithdrawal = 0;
  }

  void _calculateEarnings() {
    totalServicesCompleted = completedServices.length;

    totalEarnings = 0.0;
    for (var service in completedServices) {
      final price = (service['price'] as num?)?.toDouble() ?? 0.0;
      final extra = (service['extraCharges'] as num?)?.toDouble() ?? 0.0;
      totalEarnings += (price + extra);
    }

    averagePerService = totalServicesCompleted > 0
        ? totalEarnings / totalServicesCompleted
        : 0.0;
  }

  void calculatePendingAmount(List<Map<String, dynamic>> activeServices) {
    pendingAmount = 0.0;

    for (var service in activeServices) {
      final price = (service['price'] as num?)?.toDouble() ?? 0.0;
      final extra = (service['extraCharges'] as num?)?.toDouble() ?? 0.0;
      final total = price + extra;
      final commission = total * 0.20;
      final vat = total * 0.15;
      pendingAmount += (commission + vat);
    }

    _calculateBalances();
    _calculateEarnings();
  }
}