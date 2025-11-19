import 'package:flutter/material.dart';
import '/services/financial_service.dart';
import 'package:flutter/scheduler.dart';
import '/services/worker_auth_service.dart';
import '/models/worker_data_model.dart';
import '/services/invoice_service.dart';
import '/models/customer_model.dart';
import '/models/customer_service_model.dart';
import '/models/service_request_model.dart';
import '/models/service_invoice_model.dart';
import '/models/transaction_model.dart';

class AppStateProvider with ChangeNotifier {
  final _financialService = FinancialService();
  final _workerAuthService = WorkerAuthService();
  final _invoiceService = InvoiceService();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final Map<String, WorkerFinancialData> _workerData = {};
  String? currentWorkerId;
  String? currentWorkerName;
  List<ServiceRequest> _serviceRequests = [];

  // ✅ Getters for worker info
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
      ServiceRequest(
        id: 'SR001',
        customerId: 'C001',
        customerName: 'Ahmed Al-Mansour',
        serviceId: 'SV001',
        serviceName: 'AC Repair',
        requestedDate: DateTime.now().add(const Duration(days: 2)),
        requestedTime: '10:00 AM',
        address: 'Al Malqa, Riyadh 13521',
        customerNotes: 'Air conditioning not cooling properly',
        status: ServiceRequestStatus.pending,
        basePrice: 250.0,
        commission: 20.0,
        vat: 15.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceRequest(
        id: 'SR002',
        customerId: 'C002',
        customerName: 'Fatima Hassan',
        serviceId: 'SV002',
        serviceName: 'Plumbing',
        requestedDate: DateTime.now().add(const Duration(days: 1)),
        requestedTime: '02:00 PM',
        address: 'Al Hamra, Jeddah 23323',
        customerNotes: 'Leaking kitchen sink',
        status: ServiceRequestStatus.pending,
        basePrice: 180.0,
        commission: 20.0,
        vat: 15.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
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

  // ✅ ALL GETTERS
  double get creditBalance => _currentWorkerData.creditBalance;
  double get walletBalance => _currentWorkerData.walletBalance;

  double get pendingAmount {
    _currentWorkerData.calculatePendingAmount(
      _serviceRequests
          .where((s) => s.workerId == currentWorkerId && s.status == ServiceRequestStatus.inProgress)
          .toList(),
    );
    return _currentWorkerData.pendingAmount;
  }

  double get availableForWithdrawal => _currentWorkerData.availableForWithdrawal;
  double get pendingClearance => _currentWorkerData.pendingClearance;

  int get totalServicesCompleted => _currentWorkerData.totalServicesCompleted;
  double get totalEarnings => _currentWorkerData.totalEarnings;
  double get averagePerService => _currentWorkerData.averagePerService;

  bool canWithdraw() {
    if (currentWorkerId == null) return false;

    final lastCreditDate = _currentWorkerData.lastWalletCreditDate;
    if (lastCreditDate == null) return true;

    final daysSinceLastCredit = DateTime.now().difference(lastCreditDate).inDays;
    return daysSinceLastCredit >= 7;
  }

  int getDaysUntilWithdrawal() {
    if (currentWorkerId == null) return 0;

    final lastCreditDate = _currentWorkerData.lastWalletCreditDate;
    if (lastCreditDate == null) return 0;

    final daysSinceLastCredit = DateTime.now().difference(lastCreditDate).inDays;
    final remaining = 7 - daysSinceLastCredit;
    return remaining > 0 ? remaining : 0;
  }

  // ✅ Return ServiceRequest objects (not Maps)
  List<ServiceRequest> get availableServices => currentWorkerId == null
      ? []
      : _serviceRequests
      .where((s) => s.workerId == currentWorkerId && s.status == ServiceRequestStatus.assigned)
      .toList();

  List<ServiceRequest> get activeServices => currentWorkerId == null
      ? []
      : _serviceRequests
      .where((s) => s.workerId == currentWorkerId && s.status == ServiceRequestStatus.inProgress)
      .toList();

  List<ServiceRequest> get completedServices => currentWorkerId == null
      ? []
      : _currentWorkerData.completedServices;

  List<ServiceRequest> get postponedServices => currentWorkerId == null
      ? []
      : _serviceRequests
      .where((s) => s.workerId == currentWorkerId && s.status == ServiceRequestStatus.postponed)
      .toList();

  // ✅ Return Transaction objects (not Maps)
  List<Transaction> get transactions {
    if (currentWorkerId == null) return [];
    return _currentWorkerData.transactions;
  }

  List<ServiceRequest> get adminRequestedServices {
    return _serviceRequests
        .where((s) => s.status == ServiceRequestStatus.pending || s.status == ServiceRequestStatus.assigned)
        .toList();
  }

  List<ServiceRequest> get adminAssignedServices {
    return _serviceRequests.where((s) => s.status == ServiceRequestStatus.assigned).toList();
  }

  List<ServiceRequest> get adminInProgressServices {
    return _serviceRequests.where((s) => s.status == ServiceRequestStatus.inProgress).toList();
  }

  List<ServiceRequest> get adminPostponedServices {
    return _serviceRequests.where((s) => s.status == ServiceRequestStatus.postponed).toList();
  }

  List<ServiceRequest> get adminAllActiveServices {
    return _serviceRequests;
  }

  List<ServiceRequest> get adminCompletedServices {
    return _currentWorkerData.completedServices;
  }

  // ✅ CUSTOMER MANAGEMENT
  List<Customer> get registeredCustomers {
    final Map<String, Customer> customersMap = {};

    // ✅ Use customer ID as key, name from service
    for (var service in _serviceRequests) {
      final customerId = service.customerId;

      if (!customersMap.containsKey(customerId)) {
        customersMap[customerId] = Customer(
          id: customerId,
          name: service.customerName,
          phone: '+966501234567',
          email: null,
          registeredAt: service.createdAt,
        );
      }
    }

    for (var worker in _workerData.values) {
      for (var service in worker.completedServices) {
        final customerId = service.customerId;

        if (!customersMap.containsKey(customerId)) {
          customersMap[customerId] = Customer(
            id: customerId,
            name: service.customerName,
            phone: '+966501234567',
            email: null,
            registeredAt: service.createdAt,
          );
        }
      }
    }

    return customersMap.values.toList();
  }

  List<CustomerService> getCustomerServices(String customerId) {
    final services = <CustomerService>[];

    for (var service in _serviceRequests) {
      if (service.customerId == customerId) {
        services.add(CustomerService(
          id: service.id,
          service: service.serviceName,
          status: service.status.toString().split('.').last,
          price: service.totalPrice,
        ));
      }
    }

    for (var worker in _workerData.values) {
      for (var service in worker.completedServices) {
        if (service.customerId == customerId) {
          services.add(CustomerService(
            id: service.id,
            service: service.serviceName,
            status: 'Completed',
            price: service.totalPrice,
          ));
        }
      }
    }

    return services;
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

  void assignServiceToWorker(String serviceId, String workerId, String workerName) {
    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);

    if (serviceIndex != -1) {
      final service = _serviceRequests[serviceIndex];

      _serviceRequests[serviceIndex] = ServiceRequest(
        id: service.id,
        customerId: service.customerId,
        customerName: service.customerName,
        serviceId: service.serviceId,
        serviceName: service.serviceName,
        workerId: workerId,
        workerName: workerName,
        requestedDate: service.requestedDate,
        requestedTime: service.requestedTime,
        address: service.address,
        customerNotes: service.customerNotes,
        status: ServiceRequestStatus.assigned,
        basePrice: service.basePrice,
        commission: service.commission,
        vat: service.vat,
        extraItems: service.extraItems,
        createdAt: service.createdAt,
        updatedAt: DateTime.now(),
      );

      debugPrint('✅ Service $serviceId assigned to $workerName');
      notifyListeners();
    }
  }

  void acceptService(String serviceId) {
    if (currentWorkerId == null) return;

    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex != -1) {
      final service = _serviceRequests[serviceIndex];

      _serviceRequests[serviceIndex] = ServiceRequest(
        id: service.id,
        customerId: service.customerId,
        customerName: service.customerName,
        serviceId: service.serviceId,
        serviceName: service.serviceName,
        workerId: service.workerId,
        workerName: service.workerName,
        requestedDate: service.requestedDate,
        requestedTime: service.requestedTime,
        address: service.address,
        customerNotes: service.customerNotes,
        status: ServiceRequestStatus.inProgress,
        basePrice: service.basePrice,
        commission: service.commission,
        vat: service.vat,
        extraItems: service.extraItems,
        postponeReason: null,
        createdAt: service.createdAt,
        updatedAt: DateTime.now(),
      );

      _currentWorkerData.calculatePendingAmount(activeServices);
      debugPrint('✅ Service $serviceId accepted');
      notifyListeners();
    }
  }

  void resumeService(String serviceId) {
    acceptService(serviceId);
  }

  void postponeAvailableService(String serviceId, [String? reason]) {
    if (currentWorkerId == null) return;

    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex != -1) {
      final service = _serviceRequests[serviceIndex];

      _serviceRequests[serviceIndex] = ServiceRequest(
        id: service.id,
        customerId: service.customerId,
        customerName: service.customerName,
        serviceId: service.serviceId,
        serviceName: service.serviceName,
        workerId: service.workerId,
        workerName: service.workerName,
        requestedDate: service.requestedDate,
        requestedTime: service.requestedTime,
        address: service.address,
        customerNotes: service.customerNotes,
        status: ServiceRequestStatus.postponed,
        basePrice: service.basePrice,
        commission: service.commission,
        vat: service.vat,
        extraItems: service.extraItems,
        postponeReason: reason ?? 'Worker postponed before accepting',
        createdAt: service.createdAt,
        updatedAt: DateTime.now(),
      );

      debugPrint('✅ Service $serviceId postponed before acceptance');
      notifyListeners();
    }
  }

  // ✅ UPDATE: Add payment method parameter to completeService method

  Future<void> completeService(String serviceId, {String paymentMethod = 'Cash'}) async {
    if (currentWorkerId == null) return;

    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex == -1) return;

    final service = _serviceRequests[serviceIndex];

    // ✅ Verify credit BEFORE completing service
    final requiredCredit = service.totalDeduction;

    if (_currentWorkerData.creditBalance < requiredCredit) {
      debugPrint('❌ Cannot complete service: Insufficient credit');
      debugPrint('   Required: SAR ${requiredCredit.toStringAsFixed(2)}');
      debugPrint('   Available: SAR ${_currentWorkerData.creditBalance.toStringAsFixed(2)}');
      throw Exception('Insufficient credit balance');
    }

    final totalPrice = service.totalPrice;

    _currentWorkerData.walletBalance += totalPrice;
    _currentWorkerData.creditBalance -= requiredCredit;

    // ✅ Use the payment method from parameter
    final paymentMethodEnum = paymentMethod == 'Cash'
        ? PaymentMethod.cash
        : PaymentMethod.online;

    // ✅ Create completed service with selected payment method
    final completedService = ServiceRequest(
      id: service.id,
      customerId: service.customerId,
      customerName: service.customerName,
      serviceId: service.serviceId,
      serviceName: service.serviceName,
      workerId: service.workerId,
      workerName: service.workerName,
      requestedDate: service.requestedDate,
      requestedTime: service.requestedTime,
      address: service.address,
      customerNotes: service.customerNotes,
      status: ServiceRequestStatus.completed,
      basePrice: service.basePrice,
      commission: service.commission,
      vat: service.vat,
      extraItems: service.extraItems,
      completedDate: DateTime.now(),
      paymentMethod: paymentMethodEnum, // ✅ Use selected payment method
      createdAt: service.createdAt,
      updatedAt: DateTime.now(),
    );

    _currentWorkerData.completedServices.insert(0, completedService);
    _serviceRequests.removeAt(serviceIndex);

    // ✅ Add transactions
    _currentWorkerData.transactions.insert(0, Transaction(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      workerId: currentWorkerId!,
      workerName: currentWorkerName!,
      type: TransactionType.walletEarning,
      amount: totalPrice,
      balanceBefore: _currentWorkerData.walletBalance - totalPrice,
      balanceAfter: _currentWorkerData.walletBalance,
      serviceRequestId: service.id,
      description: '${service.serviceName} - ${service.customerName}',
      createdAt: DateTime.now(),
    ));

    _currentWorkerData.transactions.insert(0, Transaction(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch + 1}',
      workerId: currentWorkerId!,
      workerName: currentWorkerName!,
      type: TransactionType.creditDeduction,
      amount: -requiredCredit,
      balanceBefore: _currentWorkerData.creditBalance + requiredCredit,
      balanceAfter: _currentWorkerData.creditBalance,
      serviceRequestId: service.id,
      description: 'Commission & VAT deducted',
      createdAt: DateTime.now(),
    ));

    _currentWorkerData.lastWalletCreditDate = DateTime.now();

    // ✅ Pass payment method to financial service
    await _financialService.processCompletedService(
      serviceId: service.id,
      serviceName: service.serviceName,
      workerName: service.workerName ?? 'Worker',
      workerId: currentWorkerId!,
      customerName: service.customerName,
      basePrice: service.basePrice,
      extraCharges: service.totalExtraPrice,
      completionDate: DateTime.now(),
      paymentMethod: paymentMethod, // ✅ Pass selected payment method
    );

    // ✅ Create invoice from ServiceRequest model with payment method
    final invoice = ServiceInvoice.fromServiceRequest(completedService);
    await _invoiceService.saveInvoice(invoice);

    _currentWorkerData.calculatePendingAmount(activeServices);
    debugPrint('✅ Service $serviceId completed with payment method: $paymentMethod');
    notifyListeners();
  }

  void postponeService(String serviceId, [String? reason]) {
    if (currentWorkerId == null) return;

    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex != -1) {
      final service = _serviceRequests[serviceIndex];

      _serviceRequests[serviceIndex] = ServiceRequest(
        id: service.id,
        customerId: service.customerId,
        customerName: service.customerName,
        serviceId: service.serviceId,
        serviceName: service.serviceName,
        workerId: service.workerId,
        workerName: service.workerName,
        requestedDate: service.requestedDate,
        requestedTime: service.requestedTime,
        address: service.address,
        customerNotes: service.customerNotes,
        status: ServiceRequestStatus.postponed,
        basePrice: service.basePrice,
        commission: service.commission,
        vat: service.vat,
        extraItems: service.extraItems,
        postponeReason: reason ?? 'Worker postponed the service',
        createdAt: service.createdAt,
        updatedAt: DateTime.now(),
      );

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
    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);

    if (serviceIndex != -1) {
      final service = _serviceRequests[serviceIndex];

      _serviceRequests[serviceIndex] = ServiceRequest(
        id: service.id,
        customerId: service.customerId,
        customerName: service.customerName,
        serviceId: service.serviceId,
        serviceName: service.serviceName,
        workerId: newWorkerId,
        workerName: newWorkerName,
        requestedDate: newScheduledDate,
        requestedTime: service.requestedTime,
        address: service.address,
        customerNotes: service.customerNotes,
        status: ServiceRequestStatus.assigned,
        basePrice: service.basePrice,
        commission: service.commission,
        vat: service.vat,
        extraItems: service.extraItems,
        createdAt: service.createdAt,
        updatedAt: DateTime.now(),
      );

      debugPrint('✅ Service $serviceId rescheduled');
      notifyListeners();
    }
  }

  void addServiceRequest(ServiceRequest serviceData) {
    _serviceRequests.insert(0, serviceData);
    debugPrint('✅ New service request added');
    notifyListeners();
  }

  ServiceRequest? getServiceById(String serviceId) {
    try {
      return _serviceRequests.firstWhere((s) => s.id == serviceId);
    } catch (e) {
      try {
        return _currentWorkerData.completedServices.firstWhere((s) => s.id == serviceId);
      } catch (e) {
        return null;
      }
    }
  }

  double getRequiredCredit(ServiceRequest service) {
    return service.totalDeduction;
  }

  bool hasEnoughCredit(ServiceRequest service) {
    return creditBalance >= getRequiredCredit(service);
  }

  // ✅ NEW: Add extra items to service
  void addExtraItems(String serviceId, List<ExtraItem> items) {
    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex != -1) {
      final service = _serviceRequests[serviceIndex];
      final updatedItems = [...service.extraItems, ...items];

      _serviceRequests[serviceIndex] = ServiceRequest(
        id: service.id,
        customerId: service.customerId,
        customerName: service.customerName,
        serviceId: service.serviceId,
        serviceName: service.serviceName,
        workerId: service.workerId,
        workerName: service.workerName,
        requestedDate: service.requestedDate,
        requestedTime: service.requestedTime,
        address: service.address,
        customerNotes: service.customerNotes,
        status: service.status,
        basePrice: service.basePrice,
        commission: service.commission,
        vat: service.vat,
        extraItems: updatedItems,
        createdAt: service.createdAt,
        updatedAt: DateTime.now(),
      );

      if (service.status == ServiceRequestStatus.inProgress) {
        _currentWorkerData.calculatePendingAmount(activeServices);
      }
      notifyListeners();
    }
  }

  void topUpCreditWallet(double amount, String method) {
    if (currentWorkerId == null) return;

    final balanceBefore = _currentWorkerData.creditBalance;
    _currentWorkerData.creditBalance += amount;

    _currentWorkerData.transactions.insert(0, Transaction(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      workerId: currentWorkerId!,
      workerName: currentWorkerName!,
      type: TransactionType.creditTopup,
      amount: amount,
      balanceBefore: balanceBefore,
      balanceAfter: _currentWorkerData.creditBalance,
      description: 'Credit top-up via $method',
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  void transferWalletToCredit(double amount) {
    if (currentWorkerId == null) return;

    if (_currentWorkerData.walletBalance >= amount) {
      final walletBefore = _currentWorkerData.walletBalance;
      final creditBefore = _currentWorkerData.creditBalance;

      _currentWorkerData.walletBalance -= amount;
      _currentWorkerData.creditBalance += amount;

      _currentWorkerData.transactions.insert(0, Transaction(
        id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        workerId: currentWorkerId!,
        workerName: currentWorkerName!,
        type: TransactionType.creditTopup,
        amount: amount,
        balanceBefore: creditBefore,
        balanceAfter: _currentWorkerData.creditBalance,
        description: 'Transferred from Wallet to Credit',
        createdAt: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  void updateCreditBalance(double amount) {
    if (currentWorkerId == null) return;

    final balanceBefore = _currentWorkerData.creditBalance;
    _currentWorkerData.creditBalance += amount;

    _currentWorkerData.transactions.insert(0, Transaction(
      id: 'STC${DateTime.now().millisecondsSinceEpoch}',
      workerId: currentWorkerId!,
      workerName: currentWorkerName!,
      type: TransactionType.creditTopup,
      amount: amount,
      balanceBefore: balanceBefore,
      balanceAfter: _currentWorkerData.creditBalance,
      reference: 'STC${DateTime.now().millisecondsSinceEpoch}',
      description: 'Credit top-up via STC Pay',
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  void updateWalletBalance(double amount) {
    if (currentWorkerId == null) return;

    _currentWorkerData.walletBalance += amount;
    notifyListeners();
  }

  void addTransaction(Transaction transaction) {
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

  List<ServiceRequest> completedServices = [];
  List<Transaction> transactions = []; // ✅ Now Transaction objects

  WorkerFinancialData({
    required this.workerId,
    required this.creditBalance,
    required this.walletBalance,
    this.lastWalletCreditDate,
  }) {
    // ✅ Initialize with Transaction object
    transactions = [
      Transaction(
        id: 'TXN1001',
        workerId: workerId,
        workerName: 'Worker',
        type: TransactionType.creditTopup,
        amount: 100.0,
        balanceBefore: 0.0,
        balanceAfter: 100.0,
        description: 'Initial credit top-up via STC Pay',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
    _calculateBalances();
  }

  void _calculateBalances() {
    final now = DateTime.now();
    pendingClearance = 0.0;

    for (var txn in transactions) {
      if (txn.type == TransactionType.walletEarning) {
        final daysSince = now.difference(txn.createdAt).inDays;
        if (daysSince < 7) {
          pendingClearance += txn.amount;
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
      totalEarnings += service.totalPrice;
    }

    averagePerService = totalServicesCompleted > 0 ? totalEarnings / totalServicesCompleted : 0.0;
  }

  void calculatePendingAmount(List<ServiceRequest> activeServices) {
    pendingAmount = 0.0;

    for (var service in activeServices) {
      pendingAmount += service.totalDeduction;
    }

    _calculateBalances();
    _calculateEarnings();
  }
}