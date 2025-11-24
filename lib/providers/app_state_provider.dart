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
import '/utils/admin_translations.dart';

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
      // ✅ English customer service requests - صرف English میں customer details
      ServiceRequest(
        id: 'SR001',
        customerId: 'C001', // Ali Khan - English
        customerName: 'Ali Khan', // ✅ صرف English میں
        serviceId: 'SV001',
        serviceName: AdminTranslations.getServiceName('ac_repair'),
        requestedDate: DateTime.now().add(const Duration(days: 2)),
        requestedTime: '10:00 AM',
        address: 'Al Malqa, Riyadh 13521', // ✅ صرف English میں
        customerNotes: 'Air conditioning not cooling properly', // ✅ صرف English میں
        customerLanguage: 'english',
        status: ServiceRequestStatus.pending,
        basePrice: 250.0,
        commission: 20.0,
        vat: 15.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceRequest(
        id: 'SR002',
        customerId: 'C002', // Sarah Johnson - English
        customerName: 'Sarah Johnson', // ✅ صرف English میں
        serviceId: 'SV002',
        serviceName: AdminTranslations.getServiceName('plumbing'),
        requestedDate: DateTime.now().add(const Duration(days: 1)),
        requestedTime: '02:00 PM',
        address: 'Al Hamra District, Jeddah 23323', // ✅ صرف English میں
        customerNotes: 'Kitchen sink is leaking and needs repair', // ✅ صرف English میں
        customerLanguage: 'english',
        status: ServiceRequestStatus.pending,
        basePrice: 180.0,
        commission: 20.0,
        vat: 15.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // ✅ Arabic customer service requests - صرف Arabic میں customer details
      ServiceRequest(
        id: 'SR003',
        customerId: 'C003', // Fatima Hassan - Arabic
        customerName: 'فاطمة حسن', // ✅ صرف Arabic میں
        serviceId: 'SV003',
        serviceName: AdminTranslations.getServiceName('electrical'),
        requestedDate: DateTime.now().add(const Duration(days: 3)),
        requestedTime: '11:00 AM',
        address: 'النخيل، الرياض 13325', // ✅ صرف Arabic میں
        customerNotes: 'مشكلة في الأسلاك الكهربائية في غرفة المعيشة', // ✅ صرف Arabic میں
        customerLanguage: 'arabic',
        status: ServiceRequestStatus.assigned,
        workerId: 'W001',
        workerName: AdminTranslations.getWorkerName('ahmed'),
        workerNameArabic: AdminTranslations.getArabic(AdminTranslations.getWorkerName('ahmed')),
        basePrice: 300.0,
        commission: 25.0,
        vat: 18.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceRequest(
        id: 'SR004',
        customerId: 'C004', // Mohammed Ahmed - Arabic
        customerName: 'محمد أحمد', // ✅ صرف Arabic میں
        serviceId: 'SV004',
        serviceName: AdminTranslations.getServiceName('cleaning'),
        requestedDate: DateTime.now().add(const Duration(days: 4)),
        requestedTime: '09:00 AM',
        address: 'الروضة، جدة 23456', // ✅ صرف Arabic میں
        customerNotes: 'تنظيف عميق للشقة بالكامل قبل مناسبة خاصة', // ✅ صرف Arabic میں
        customerLanguage: 'arabic',
        status: ServiceRequestStatus.inProgress,
        workerId: 'W002',
        workerName: AdminTranslations.getWorkerName('fatima'),
        workerNameArabic: AdminTranslations.getArabic(AdminTranslations.getWorkerName('fatima')),
        basePrice: 200.0,
        commission: 15.0,
        vat: 12.0,
        extraItems: [
          ExtraItem(
              id: 'EXT001',
              name: 'Window Cleaning • تنظيف النوافذ', // ✅ Extra items bilingual
              type: 'service',
              price: 50.0
          ),
          ExtraItem(
              id: 'EXT002',
              name: 'Carpet Cleaning • تنظيف السجاد', // ✅ Extra items bilingual
              type: 'service',
              price: 80.0
          ),
        ],
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

  // ✅ ADD: Hardcoded customers list
  List<Customer> get hardcodedCustomers => Customer.sampleData();

  // ✅ ADD: Get customer by ID
  Customer? getCustomerById(String customerId) {
    return hardcodedCustomers.firstWhere(
          (customer) => customer.id == customerId,
      orElse: () => Customer(
        id: 'unknown',
        name: 'Unknown Customer',
        phone: 'N/A',
        registeredAt: DateTime.now(),
        languagePreference: 'english',
      ),
    );
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

  // ✅ UPDATED CUSTOMER MANAGEMENT - Single language customer details
  List<Customer> get registeredCustomers {
    final Map<String, Customer> customersMap = {};

    // Add customers from service requests
    for (var service in _serviceRequests) {
      final customerId = service.customerId;

      if (!customersMap.containsKey(customerId)) {
        final customer = getCustomerById(customerId);
        if (customer != null) {
          customersMap[customerId] = customer;
        }
      }
    }

    // Add customers from completed services
    for (var worker in _workerData.values) {
      for (var service in worker.completedServices) {
        final customerId = service.customerId;

        if (!customersMap.containsKey(customerId)) {
          final customer = getCustomerById(customerId);
          if (customer != null) {
            customersMap[customerId] = customer;
          }
        }
      }
    }

    // Add all hardcoded customers (for testing)
    if (customersMap.isEmpty) {
      for (var customer in hardcodedCustomers) {
        customersMap[customer.id] = customer;
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

    // ✅ FIXED: Preserve existing worker data if already exists
    if (!_workerData.containsKey(workerId)) {
      // First time login: Initialize with default/saved credit balance
      _workerData[workerId] = WorkerFinancialData(
        workerId: workerId,
        creditBalance: workerData.creditBalance,
        walletBalance: 0.0,
      );
      debugPrint('✅ Worker $workerId ($currentWorkerName) initialized with credit: SAR ${workerData.creditBalance.toStringAsFixed(2)}');
    } else {
      // Worker already exists: Keep existing balances (DON'T RESET)
      debugPrint('✅ Worker $workerId ($currentWorkerName) re-logged in');
      debugPrint('   Existing Credit: SAR ${_workerData[workerId]!.creditBalance.toStringAsFixed(2)}');
      debugPrint('   Existing Wallet: SAR ${_workerData[workerId]!.walletBalance.toStringAsFixed(2)}');
    }

    notifyListeners();
  }

  void assignServiceToWorker(String serviceId, String workerId, String workerName) {
    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);

    if (serviceIndex != -1) {
      final service = _serviceRequests[serviceIndex];

      // ✅ Get Arabic name from worker data
      final workers = _workerAuthService.getAllWorkers();
      final worker = workers.firstWhere((w) => w.id == workerId, orElse: () => WorkerData(
        id: workerId,
        name: workerName,
        nameArabic: AdminTranslations.getArabic(workerName),
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
      ));

      // ✅ FIXED: Preserve all fields including customer language
      _serviceRequests[serviceIndex] = ServiceRequest(
        id: service.id,
        customerId: service.customerId,
        customerName: service.customerName, // ✅ Customer کی entered language preserve
        serviceId: service.serviceId,
        serviceName: service.serviceName,
        workerId: workerId,
        workerName: workerName,
        workerNameArabic: worker.nameArabic,
        requestedDate: service.requestedDate,
        requestedTime: service.requestedTime,
        address: service.address, // ✅ Customer کی entered language preserve
        customerNotes: service.customerNotes, // ✅ Customer کی entered language preserve
        customerLanguage: service.customerLanguage, // ✅ Customer language preserve
        status: ServiceRequestStatus.assigned,
        basePrice: service.basePrice,
        commission: service.commission,
        vat: service.vat,
        extraItems: service.extraItems, // ✅ Preserve extra items
        createdAt: service.createdAt,
        updatedAt: DateTime.now(),
      );

      debugPrint('✅ Service $serviceId assigned to $workerName (${worker.nameArabic})');
      notifyListeners();
    }
  }

  // ✅ FIXED: Add validation that service belongs to current worker
  void acceptService(String serviceId) {
    if (currentWorkerId == null) return;

    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex == -1) {
      debugPrint('❌ Service $serviceId not found');
      return;
    }

    final service = _serviceRequests[serviceIndex];

    // ✅ Validate service belongs to current worker
    if (service.workerId != currentWorkerId) {
      debugPrint('❌ Service $serviceId does not belong to worker $currentWorkerId');
      return;
    }

    // ✅ Validate service status is assigned
    if (service.status != ServiceRequestStatus.assigned) {
      debugPrint('❌ Service $serviceId is not in assigned status');
      return;
    }

    _serviceRequests[serviceIndex] = ServiceRequest(
      id: service.id,
      customerId: service.customerId,
      customerName: service.customerName, // ✅ Customer کی entered language preserve
      serviceId: service.serviceId,
      serviceName: service.serviceName,
      workerId: service.workerId,
      workerName: service.workerName,
      workerNameArabic: service.workerNameArabic,
      requestedDate: service.requestedDate,
      requestedTime: service.requestedTime,
      address: service.address, // ✅ Customer کی entered language preserve
      customerNotes: service.customerNotes, // ✅ Customer کی entered language preserve
      customerLanguage: service.customerLanguage, // ✅ Customer language preserve
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

  void resumeService(String serviceId) {
    if (currentWorkerId == null) return;

    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex == -1) {
      debugPrint('❌ Service $serviceId not found');
      return;
    }

    final service = _serviceRequests[serviceIndex];

    // ✅ Validate service is postponed
    if (service.status != ServiceRequestStatus.postponed) {
      debugPrint('❌ Service $serviceId is not in postponed status (current: ${service.status})');
      return;
    }

    // ✅ Validate service belongs to current worker
    if (service.workerId != currentWorkerId) {
      debugPrint('❌ Service $serviceId does not belong to worker $currentWorkerId');
      return;
    }

    // ✅ Check if worker has enough credit
    final requiredCredit = service.totalDeduction;
    if (_currentWorkerData.creditBalance < requiredCredit) {
      debugPrint('❌ Insufficient credit to resume service. Required: $requiredCredit, Available: ${_currentWorkerData.creditBalance}');
      return;
    }

    // ✅ Resume service - move to inProgress
    _serviceRequests[serviceIndex] = ServiceRequest(
      id: service.id,
      customerId: service.customerId,
      customerName: service.customerName,
      serviceId: service.serviceId,
      serviceName: service.serviceName,
      workerId: service.workerId,
      workerName: service.workerName,
      workerNameArabic: service.workerNameArabic,
      requestedDate: service.requestedDate,
      requestedTime: service.requestedTime,
      address: service.address,
      customerNotes: service.customerNotes,
      customerLanguage: service.customerLanguage,
      status: ServiceRequestStatus.inProgress,
      basePrice: service.basePrice,
      commission: service.commission,
      vat: service.vat,
      extraItems: service.extraItems,
      postponeReason: null, // Clear postpone reason
      createdAt: service.createdAt,
      updatedAt: DateTime.now(),
    );

    _currentWorkerData.calculatePendingAmount(activeServices);
    debugPrint('✅ Service $serviceId resumed and moved to in-progress');
    notifyListeners();
  }

  // ✅ FIXED: Add validation for postponeAvailableService
  // ✅ FIXED: Add validation for postponeAvailableService
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
        workerNameArabic: service.workerNameArabic, // ✅ ADDED
        requestedDate: service.requestedDate,
        requestedTime: service.requestedTime,
        address: service.address,
        customerNotes: service.customerNotes,
        customerLanguage: service.customerLanguage, // ✅ ADDED
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
        workerNameArabic: service.workerNameArabic, // ✅ ADDED
        requestedDate: service.requestedDate,
        requestedTime: service.requestedTime,
        address: service.address,
        customerNotes: service.customerNotes,
        customerLanguage: service.customerLanguage, // ✅ ADDED
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


  Future<void> completeService(String serviceId, {String paymentMethod = 'Cash'}) async {
    if (currentWorkerId == null) return;

    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex == -1) {
      debugPrint('❌ Service $serviceId not found');
      return;
    }

    final service = _serviceRequests[serviceIndex];

    // ✅ Validate service belongs to current worker
    if (service.workerId != currentWorkerId) {
      debugPrint('❌ Service $serviceId does not belong to worker $currentWorkerId');
      return;
    }

    // ✅ Verify credit BEFORE completing service
    final requiredCredit = service.totalDeduction;

    if (_currentWorkerData.creditBalance < requiredCredit) {
      debugPrint('❌ Cannot complete service: Insufficient credit');
      debugPrint('   Required: SAR ${requiredCredit.toStringAsFixed(2)}');
      debugPrint('   Available: SAR ${_currentWorkerData.creditBalance.toStringAsFixed(2)}');
      throw Exception('Insufficient credit balance');
    }

    final totalPrice = service.totalPrice;

    // ✅ FIXED: Update wallet balance ONLY for ONLINE payments
    // Cash payments: Worker already received cash, no wallet update needed
    if (paymentMethod != 'Cash') {
      _currentWorkerData.walletBalance += totalPrice;
      debugPrint('💰 Worker wallet updated: +SAR ${totalPrice.toStringAsFixed(2)} (ONLINE payment)');
    } else {
      debugPrint('💵 CASH payment: Worker wallet NOT updated (already received cash)');
    }

    _currentWorkerData.creditBalance -= requiredCredit;

    // ✅ Use the payment method from parameter
    final paymentMethodEnum = paymentMethod == 'Cash'
        ? PaymentMethod.cash
        : PaymentMethod.online;

    // ✅ FIXED: Create completed service with all original fields preserved including customer language
    final completedService = ServiceRequest(
      id: service.id,
      customerId: service.customerId,
      customerName: service.customerName, // ✅ Customer کی entered language preserve
      serviceId: service.serviceId,
      serviceName: service.serviceName,
      workerId: service.workerId,
      workerName: service.workerName,
      workerNameArabic: service.workerNameArabic,
      requestedDate: service.requestedDate,
      requestedTime: service.requestedTime,
      address: service.address, // ✅ Customer کی entered language preserve
      customerNotes: service.customerNotes, // ✅ Customer کی entered language preserve
      customerLanguage: service.customerLanguage, // ✅ Customer language preserve
      status: ServiceRequestStatus.completed,
      basePrice: service.basePrice,
      commission: service.commission,
      vat: service.vat,
      extraItems: service.extraItems, // ✅ Preserve extra items
      completedDate: DateTime.now(),
      paymentMethod: paymentMethodEnum,
      createdAt: service.createdAt,
      updatedAt: DateTime.now(),
    );

    _currentWorkerData.completedServices.insert(0, completedService);
    _serviceRequests.removeAt(serviceIndex);

    // ✅ FIXED: Add wallet earning transaction ONLY for ONLINE payments
    if (paymentMethod != 'Cash') {
      _currentWorkerData.transactions.insert(0, Transaction(
        id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        workerId: currentWorkerId!,
        workerName: currentWorkerName!,
        type: TransactionType.walletEarning,
        amount: totalPrice,
        balanceBefore: _currentWorkerData.walletBalance - totalPrice,
        balanceAfter: _currentWorkerData.walletBalance,
        serviceRequestId: service.id,
        description: '${service.serviceName} - ${service.customerName} (ONLINE)',
        createdAt: DateTime.now(),
      ));
    } else {
      // CASH payment: Add transaction record showing cash was received directly
      _currentWorkerData.transactions.insert(0, Transaction(
        id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        workerId: currentWorkerId!,
        workerName: currentWorkerName!,
        type: TransactionType.walletEarning,
        amount: 0, // No wallet earning for cash
        balanceBefore: _currentWorkerData.walletBalance,
        balanceAfter: _currentWorkerData.walletBalance,
        serviceRequestId: service.id,
        description: '${service.serviceName} - ${service.customerName} (CASH - Received directly)',
        createdAt: DateTime.now(),
      ));
    }

    // ✅ Credit deduction happens for BOTH payment methods
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
      paymentMethod: paymentMethod,
    );

    // ✅ Create invoice from ServiceRequest model with payment method
    final invoice = ServiceInvoice.fromServiceRequest(completedService);
    await _invoiceService.saveInvoice(invoice);

    _currentWorkerData.calculatePendingAmount(activeServices);
    debugPrint('✅ Service $serviceId completed with payment method: $paymentMethod');
    notifyListeners();
  }

  // ✅ FIXED: Add validation for postponeService

  void reschedulePostponedService({
    required String serviceId,
    required String newWorkerId,
    required String newWorkerName,
    required DateTime newScheduledDate,
  }) {
    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);

    if (serviceIndex != -1) {
      final service = _serviceRequests[serviceIndex];

      // ✅ Get Arabic name from worker data
      final workers = _workerAuthService.getAllWorkers();
      final worker = workers.firstWhere((w) => w.id == newWorkerId, orElse: () => WorkerData(
        id: newWorkerId,
        name: newWorkerName,
        nameArabic: AdminTranslations.getArabic(newWorkerName),
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
      ));

      _serviceRequests[serviceIndex] = ServiceRequest(
        id: service.id,
        customerId: service.customerId,
        customerName: service.customerName, // ✅ Customer کی entered language preserve
        serviceId: service.serviceId,
        serviceName: service.serviceName,
        workerId: newWorkerId,
        workerName: newWorkerName,
        workerNameArabic: worker.nameArabic,
        requestedDate: newScheduledDate,
        requestedTime: service.requestedTime,
        address: service.address, // ✅ Customer کی entered language preserve
        customerNotes: service.customerNotes, // ✅ Customer کی entered language preserve
        customerLanguage: service.customerLanguage, // ✅ Customer language preserve
        status: ServiceRequestStatus.assigned,
        basePrice: service.basePrice,
        commission: service.commission,
        vat: service.vat,
        extraItems: service.extraItems, // ✅ Preserve extra items
        createdAt: service.createdAt,
        updatedAt: DateTime.now(),
      );

      debugPrint('✅ Service $serviceId rescheduled to $newWorkerName (${worker.nameArabic})');
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

  // ✅ Add extra items to service
  void addExtraItems(String serviceId, List<ExtraItem> items) {
    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex != -1) {
      final service = _serviceRequests[serviceIndex];
      final updatedItems = [...service.extraItems, ...items];

      _serviceRequests[serviceIndex] = ServiceRequest(
        id: service.id,
        customerId: service.customerId,
        customerName: service.customerName, // ✅ Customer کی entered language preserve
        serviceId: service.serviceId,
        serviceName: service.serviceName,
        workerId: service.workerId,
        workerName: service.workerName,
        workerNameArabic: service.workerNameArabic,
        requestedDate: service.requestedDate,
        requestedTime: service.requestedTime,
        address: service.address, // ✅ Customer کی entered language preserve
        customerNotes: service.customerNotes, // ✅ Customer کی entered language preserve
        customerLanguage: service.customerLanguage, // ✅ Customer language preserve
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

  // ✅ NEW: Sync worker credit when admin updates it
  void syncWorkerCredit(String workerId, double newCreditBalance) {
    // Update the specific worker's credit in _workerData
    if (_workerData.containsKey(workerId)) {
      _workerData[workerId]!.creditBalance = newCreditBalance;

      // If this is the currently logged-in worker, notify UI to update
      if (workerId == currentWorkerId) {
        debugPrint('✅ Synced credit for current worker $workerId: SAR ${newCreditBalance.toStringAsFixed(2)}');
        notifyListeners();
      } else {
        debugPrint('✅ Synced credit for worker $workerId: SAR ${newCreditBalance.toStringAsFixed(2)}');
      }
    } else {
      // Worker not yet initialized in AppState, create entry
      _workerData[workerId] = WorkerFinancialData(
        workerId: workerId,
        creditBalance: newCreditBalance,
        walletBalance: 0.0,
      );
      debugPrint('✅ Initialized and synced credit for worker $workerId: SAR ${newCreditBalance.toStringAsFixed(2)}');
    }
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
  List<Transaction> transactions = [];

  WorkerFinancialData({
    required this.workerId,
    required this.creditBalance,
    required this.walletBalance,
    this.lastWalletCreditDate,
  }) {
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