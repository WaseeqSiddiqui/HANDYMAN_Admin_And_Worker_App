import 'package:flutter/material.dart';
import '/services/financial_service.dart';
import 'package:flutter/scheduler.dart';
import '../services/worker_auth_service.dart';
import '../services/firestore_service.dart';
import '../models/worker_data_model.dart';
import '/services/invoice_service.dart';
import '/models/customer_model.dart';
import '/models/customer_service_model.dart';
import '../models/service_request_model.dart';
import '../models/service_model.dart'
    hide ServiceCategory; // ✅ Import Service model
import '../models/service_category_model.dart';

import '../models/transaction_model.dart';
import '/utils/admin_translations.dart';

class AppStateProvider with ChangeNotifier {
  final _firestoreService = FirestoreService();
  final _financialService = FinancialService();
  final _workerAuthService = WorkerAuthService();
  final _invoiceService = InvoiceService();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final Map<String, WorkerFinancialData> _workerData = {};
  String? currentWorkerId;
  String? currentWorkerName;
  List<ServiceRequest> _serviceRequests = [];
  List<ServiceCategory> _serviceCategories = [];
  List<ServiceCategory> get serviceCategories => _serviceCategories;

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
    debugPrint('🚀 Initializing AppStateProvider with Firestore...');

    // Listen to Service Requests
    _firestoreService.getServiceRequestsStream().listen((services) {
      _serviceRequests = services;
      notifyListeners();
      debugPrint(
        '🔄 AppStateProvider: Synced ${services.length} services from Firestore',
      );
    });

    // Listen to Service Categories
    _firestoreService.getServiceCategoriesStream().listen((categories) {
      _serviceCategories = categories;
      notifyListeners();
      debugPrint(
        '🔄 AppStateProvider: Synced ${categories.length} categories from Firestore',
      );
    });

    _isInitialized = true;
    notifyListeners();

    // Attempt to seed data if empty (happens one time only)
    seedInitialData();
  }

  Future<void> seedInitialData() async {
    final hardcodedServices = [
      // ✅ English customer service requests
      ServiceRequest(
        id: 'SR001',
        customerId: 'C001', // Ali Khan - English
        customerName: 'Ali Khan',
        serviceId: 'SV001',
        serviceName: AdminTranslations.getServiceName('ac_repair'),
        requestedDate: DateTime.now().add(const Duration(days: 2)),
        requestedTime: '10:00 AM',
        address: 'Al Malqa, Riyadh 13521',
        customerNotes: 'Air conditioning not cooling properly',
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
        customerName: 'Sarah Johnson',
        serviceId: 'SV002',
        serviceName: AdminTranslations.getServiceName('plumbing'),
        requestedDate: DateTime.now().add(const Duration(days: 1)),
        requestedTime: '02:00 PM',
        address: 'Al Hamra District, Jeddah 23323',
        customerNotes: 'Kitchen sink is leaking and needs repair',
        customerLanguage: 'english',
        status: ServiceRequestStatus.pending,
        basePrice: 180.0,
        commission: 20.0,
        vat: 15.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      // Arabic requests
      ServiceRequest(
        id: 'SR003',
        customerId: 'C003',
        customerName: 'فاطمة حسن',
        serviceId: 'SV003',
        serviceName: AdminTranslations.getServiceName('electrical'),
        requestedDate: DateTime.now().add(const Duration(days: 3)),
        requestedTime: '11:00 AM',
        address: 'النخيل، الرياض 13325',
        customerNotes: 'مشكلة في الأسلاك الكهربائية في غرفة المعيشة',
        customerLanguage: 'arabic',
        status: ServiceRequestStatus.assigned,
        workerId: 'W001',
        workerName: AdminTranslations.getWorkerName('ahmed'),
        workerNameArabic: AdminTranslations.getArabic(
          AdminTranslations.getWorkerName('ahmed'),
        ),
        basePrice: 300.0,
        commission: 25.0,
        vat: 18.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceRequest(
        id: 'SR004',
        customerId: 'C004',
        customerName: 'محمد أحمد',
        serviceId: 'SV004',
        serviceName: AdminTranslations.getServiceName('cleaning'),
        requestedDate: DateTime.now().add(const Duration(days: 4)),
        requestedTime: '09:00 AM',
        address: 'الروضة، جدة 23456',
        customerNotes: 'تنظيف عميق للشقة بالكامل قبل مناسبة خاصة',
        customerLanguage: 'arabic',
        status: ServiceRequestStatus.inProgress,
        workerId: 'W002',
        workerName: AdminTranslations.getWorkerName('fatima'),
        workerNameArabic: AdminTranslations.getArabic(
          AdminTranslations.getWorkerName('fatima'),
        ),
        basePrice: 200.0,
        commission: 15.0,
        vat: 12.0,
        extraItems: [
          ExtraItem(
            id: 'EXT001',
            name: 'Window Cleaning • تنظيف النوافذ',
            type: 'service',
            price: 50.0,
          ),
          ExtraItem(
            id: 'EXT002',
            name: 'Carpet Cleaning • تنظيف السجاد',
            type: 'service',
            price: 80.0,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    // Assuming we have workers from Auth Service, but easier to just mock one here for seeding
    // In a real scenario, we'd fetch them or have them passed in.
    // For now, let's just seed services.

    // We also need some dummy workers if they don't exist
    final workers = [
      WorkerData(
        id: 'W001',
        name: 'Ahmed Ali',
        nameArabic: 'أحمد علي',
        phone: '+966500000001',
        email: 'ahmed@example.com',
        nationalId: '1000000001',
        stcPayId: 'STC001',
        address: 'Riyadh',
        addressArabic: 'الرياض',
        status: 'Active',
        joinedDate: DateTime.now(),
        creditBalance: 100.0,
      ),
      WorkerData(
        id: 'W002',
        name: 'Fatima Noor',
        nameArabic: 'فاطمة نور',
        phone: '+966500000002',
        email: 'fatima@example.com',
        nationalId: '1000000002',
        stcPayId: 'STC002',
        address: 'Jeddah',
        addressArabic: 'جدة',
        status: 'Active',
        joinedDate: DateTime.now(),
        creditBalance: 150.0,
      ),
    ];

    // Seed categories
    final categories = [
      ServiceCategory(
        id: 'CAT001',
        nameEnglish: 'AC Repair',
        nameArabic: 'تصليح مكيف',
        descriptionEnglish: 'Air conditioning repair and maintenance',
        descriptionArabic: 'صيانة وإصلاح المكيفات',
        basePrice: 150.0,
      ),
      ServiceCategory(
        id: 'CAT002',
        nameEnglish: 'Plumbing',
        nameArabic: 'سباكة',
        descriptionEnglish: 'All plumbing services',
        descriptionArabic: 'جميع خدمات السباكة',
        basePrice: 100.0,
      ),
      ServiceCategory(
        id: 'CAT003',
        nameEnglish: 'Electrical',
        nameArabic: 'كهرباء',
        descriptionEnglish: 'Electrical wiring and repair',
        descriptionArabic: 'التمديدات الكهربائية والإصلاح',
        basePrice: 120.0,
      ),
      ServiceCategory(
        id: 'CAT004',
        nameEnglish: 'Cleaning',
        nameArabic: 'تنظيف',
        descriptionEnglish: 'Home and office cleaning',
        descriptionArabic: 'تنظيف المنازل والمكاتب',
        basePrice: 80.0,
      ),
    ];

    // Access Service Management for offered services
    // Create a temporary instance just to get the initial data if needed,
    // or better, manually define them here to avoid circular dependency issues during init.
    // However, ServiceManagementService is a singleton so it should be fine.

    // We already have hardcodedCustomers getter below.

    // For Offered Services (Catalogue):
    // We need to define them here or get them from ServiceManagementService.
    // Let's define the initial catalogue here for valid seeding.
    final offeredServices = [
      Service(
        id: 'srv1',
        name: 'AC Repair',
        nameArabic: 'إصلاح التكييف',
        categoryId: 'CAT001',
        category: 'AC Repair',
        categoryArabic: 'تصليح مكيف',
        subcategoryId: 'cat1_0',
        subcategory: 'Repair',
        subcategoryArabic: 'إصلاح',
        basePrice: 450.0,
        commission: 10.0,
        vat: 5.0,
        isActive: true,
      ),
      Service(
        id: 'srv2',
        name: 'Washing Machine Service',
        nameArabic: 'صيانة الغسالة',
        categoryId: 'CAT002',
        category:
            'Plumbing', // Using Plumbing category for demo purposes based on ID match
        categoryArabic: 'سباكة',
        subcategoryId: 'cat2_0',
        subcategory: 'Installation',
        subcategoryArabic: 'تركيب',
        basePrice: 300.0,
        commission: 10.0,
        vat: 5.0,
        isActive: true,
      ),
    ];

    await _firestoreService.seedInitialData(
      workers: workers,
      services: hardcodedServices,
      transactions: [],
      categories: categories,
      customers: hardcodedCustomers,
      offeredServices: offeredServices,
    );
  }

  void loadMockData() {
    seedInitialData();
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
          .where(
            (s) =>
                s.workerId == currentWorkerId &&
                s.status == ServiceRequestStatus.inProgress,
          )
          .toList(),
    );
    return _currentWorkerData.pendingAmount;
  }

  double get availableForWithdrawal =>
      _currentWorkerData.availableForWithdrawal;
  double get pendingClearance => _currentWorkerData.pendingClearance;

  int get totalServicesCompleted => _currentWorkerData.totalServicesCompleted;
  double get totalEarnings => _currentWorkerData.totalEarnings;
  double get averagePerService => _currentWorkerData.averagePerService;

  bool canWithdraw() {
    if (currentWorkerId == null) return false;

    final lastCreditDate = _currentWorkerData.lastWalletCreditDate;
    if (lastCreditDate == null) return true;

    final daysSinceLastCredit = DateTime.now()
        .difference(lastCreditDate)
        .inDays;
    return daysSinceLastCredit >= 7;
  }

  int getDaysUntilWithdrawal() {
    if (currentWorkerId == null) return 0;

    final lastCreditDate = _currentWorkerData.lastWalletCreditDate;
    if (lastCreditDate == null) return 0;

    final daysSinceLastCredit = DateTime.now()
        .difference(lastCreditDate)
        .inDays;
    final remaining = 7 - daysSinceLastCredit;
    return remaining > 0 ? remaining : 0;
  }

  // ✅ Return ServiceRequest objects (not Maps)
  List<ServiceRequest> get availableServices => currentWorkerId == null
      ? []
      : _serviceRequests
            .where(
              (s) =>
                  s.workerId == currentWorkerId &&
                  s.status == ServiceRequestStatus.assigned,
            )
            .toList();

  List<ServiceRequest> get activeServices => currentWorkerId == null
      ? []
      : _serviceRequests
            .where(
              (s) =>
                  s.workerId == currentWorkerId &&
                  s.status == ServiceRequestStatus.inProgress,
            )
            .toList();

  // ✅ FIXED: Derive from _serviceRequests to always reflect Firestore state
  List<ServiceRequest> get completedServices => currentWorkerId == null
      ? []
      : _serviceRequests
            .where(
              (s) =>
                  s.workerId == currentWorkerId &&
                  s.status == ServiceRequestStatus.completed,
            )
            .toList();

  List<ServiceRequest> get postponedServices => currentWorkerId == null
      ? []
      : _serviceRequests
            .where(
              (s) =>
                  s.workerId == currentWorkerId &&
                  s.status == ServiceRequestStatus.postponed,
            )
            .toList();

  // ✅ Return Transaction objects (not Maps)
  List<Transaction> get transactions {
    if (currentWorkerId == null) return [];
    return _currentWorkerData.transactions;
  }

  List<ServiceRequest> get adminRequestedServices {
    return _serviceRequests
        .where(
          (s) =>
              s.status == ServiceRequestStatus.pending ||
              s.status == ServiceRequestStatus.assigned,
        )
        .toList();
  }

  List<ServiceRequest> get adminAssignedServices {
    return _serviceRequests
        .where((s) => s.status == ServiceRequestStatus.assigned)
        .toList();
  }

  List<ServiceRequest> get adminInProgressServices {
    return _serviceRequests
        .where((s) => s.status == ServiceRequestStatus.inProgress)
        .toList();
  }

  List<ServiceRequest> get adminPostponedServices {
    return _serviceRequests
        .where((s) => s.status == ServiceRequestStatus.postponed)
        .toList();
  }

  List<ServiceRequest> get adminAllActiveServices {
    return _serviceRequests;
  }

  // ✅ FIXED: Admin should see ALL completed services from Firestore
  List<ServiceRequest> get adminCompletedServices {
    return _serviceRequests
        .where((s) => s.status == ServiceRequestStatus.completed)
        .toList();
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
        services.add(
          CustomerService(
            id: service.id,
            service: service.serviceName,
            status: service.status.toString().split('.').last,
            price: service.totalPrice,
          ),
        );
      }
    }

    for (var worker in _workerData.values) {
      for (var service in worker.completedServices) {
        if (service.customerId == customerId) {
          services.add(
            CustomerService(
              id: service.id,
              service: service.serviceName,
              status: 'Completed',
              price: service.totalPrice,
            ),
          );
        }
      }
    }

    return services;
  }

  Future<void> setCurrentWorker(String workerId) async {
    currentWorkerId = workerId;

    final workerData = _workerAuthService.getWorkerById(workerId);

    if (workerData == null) {
      debugPrint('❌ Worker $workerId not found in auth service');
      return;
    }

    currentWorkerName = workerData.name;

    // Fetch transactions from Firestore
    final List<Transaction> transactions = List<Transaction>.from(
      await _firestoreService.getTransactions(workerId),
    );

    // Initialize or Update WorkerFinancialData
    _workerData[workerId] = WorkerFinancialData(
      workerId: workerId,
      creditBalance: workerData.creditBalance,
      walletBalance:
          0.0, // This should probably be persisted too if we want wallet balance to persist?
      // ACTUALLY: Wallet balance usually is calculated from transactions or persisted in WorkerData.
      // In WorkerData model there is no walletBalance, only creditBalance.
      // Transactions have balanceAfter.
      // Let's assume for now we calculate it or just start fresh/from last transaction.
      // But for creditBalance we have it in WorkerData.
    );
    _workerData[workerId]!.transactions.clear();
    _workerData[workerId]!.transactions.addAll(transactions);

    // Update wallet balance based on last transaction if available?
    // Or just rely on what we have.
    // If we want complete persistence, we might need walletBalance in WorkerData.
    // For now, let's keep it as is, but populate transactions.

    debugPrint('✅ Worker $workerId ($currentWorkerName) initialized');
    notifyListeners();

    // Subscribe to transactions stream for real-time updates
    _firestoreService.getTransactionsStream(workerId).listen((
      List<dynamic> incoming,
    ) {
      final transactions = List<Transaction>.from(incoming);
      if (_workerData.containsKey(workerId)) {
        _workerData[workerId]!.transactions.clear();
        _workerData[workerId]!.transactions.addAll(transactions);
        notifyListeners();
      }
    });
  }

  Future<void> assignServiceToWorker(
    String serviceId,
    String workerId,
    String workerName,
  ) async {
    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);

    if (serviceIndex != -1) {
      final service = _serviceRequests[serviceIndex];
      final worker = _workerAuthService.getWorkerById(workerId);
      final workerNameArabic = worker?.nameArabic ?? '';

      final updatedService = service.copyWith(
        workerId: workerId,
        workerName: workerName,
        workerNameArabic: workerNameArabic,
        status: ServiceRequestStatus.assigned,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateServiceRequest(updatedService);

      debugPrint('✅ Service $serviceId assigned to $workerName');
      // No need to notifyListeners() manually as stream will handle it
    }
  }

  // ✅ FIXED: Add validation that service belongs to current worker
  Future<void> acceptService(String serviceId) async {
    if (currentWorkerId == null) return;

    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex == -1) return;

    final service = _serviceRequests[serviceIndex];

    if (service.workerId != currentWorkerId) return;
    if (service.status != ServiceRequestStatus.assigned) return;

    final updatedService = service.copyWith(
      status: ServiceRequestStatus.inProgress,
      postponeReason:
          null, // Ensure to clear if it was there (though this is not resume)
      updatedAt: DateTime.now(),
    );

    await _firestoreService.updateServiceRequest(updatedService);

    debugPrint('✅ Service $serviceId accepted');
  }

  Future<void> resumeService(String serviceId) async {
    if (currentWorkerId == null) return;

    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex == -1) return;

    final service = _serviceRequests[serviceIndex];

    if (service.status != ServiceRequestStatus.postponed) return;
    if (service.workerId != currentWorkerId) return;

    final requiredCredit = service.totalDeduction;
    if (_currentWorkerData.creditBalance < requiredCredit) {
      debugPrint('❌ Insufficient credit to resume service.');
      return;
    }

    final updatedService = service.copyWith(
      status: ServiceRequestStatus.inProgress,
      postponeReason: null,
      updatedAt: DateTime.now(),
    );

    await _firestoreService.updateServiceRequest(updatedService);

    debugPrint('✅ Service $serviceId resumed');
  }

  // ✅ FIXED: Add validation for postponeAvailableService
  // ✅ FIXED: Add validation for postponeAvailableService
  Future<void> postponeAvailableService(
    String serviceId, [
    String? reason,
  ]) async {
    if (currentWorkerId == null) return;

    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex != -1) {
      final service = _serviceRequests[serviceIndex];

      final updatedService = service.copyWith(
        status: ServiceRequestStatus.postponed,
        postponeReason: reason ?? 'Worker postponed before accepting',
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateServiceRequest(updatedService);
      debugPrint('✅ Service $serviceId postponed before acceptance');
    }
  }

  Future<void> postponeService(String serviceId, [String? reason]) async {
    if (currentWorkerId == null) return;

    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex != -1) {
      final service = _serviceRequests[serviceIndex];

      final updatedService = service.copyWith(
        status: ServiceRequestStatus.postponed,
        postponeReason: reason ?? 'Worker postponed the service',
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateServiceRequest(updatedService);
      debugPrint('✅ Service $serviceId postponed');
    }
  }

  Future<void> completeService(
    String serviceId, {
    String paymentMethod = 'Cash',
  }) async {
    if (currentWorkerId == null) return;

    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex == -1) {
      debugPrint('❌ Service $serviceId not found');
      return;
    }

    final service = _serviceRequests[serviceIndex];

    // ✅ Validate service belongs to current worker
    if (service.workerId != currentWorkerId) {
      debugPrint(
        '❌ Service $serviceId does not belong to worker $currentWorkerId',
      );
      return;
    }

    // ✅ Verify credit BEFORE completing service
    final requiredCredit = service.totalDeduction;

    if (_currentWorkerData.creditBalance < requiredCredit) {
      debugPrint('❌ Cannot complete service: Insufficient credit');
      debugPrint('   Required: SAR ${requiredCredit.toStringAsFixed(2)}');
      debugPrint(
        '   Available: SAR ${_currentWorkerData.creditBalance.toStringAsFixed(2)}',
      );
      throw Exception('Insufficient credit balance');
    }

    final totalPrice = service.totalPrice;

    // Update local state temporarily/optimistically if needed, but here we just prepare data for Firestore

    final paymentMethodEnum = paymentMethod == 'Cash'
        ? PaymentMethod.cash
        : PaymentMethod.online;

    final completedService = service.copyWith(
      status: ServiceRequestStatus.completed,
      completedDate: DateTime.now(),
      paymentMethod: paymentMethodEnum,
      updatedAt: DateTime.now(),
    );

    // Create Transactions
    final transactionEarn = Transaction(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      workerId: currentWorkerId!,
      workerName: currentWorkerName!,
      type: TransactionType.walletEarning,
      amount: paymentMethod != 'Cash' ? totalPrice : 0,
      balanceBefore: _currentWorkerData.walletBalance, // Approximate
      balanceAfter:
          _currentWorkerData.walletBalance +
          (paymentMethod != 'Cash' ? totalPrice : 0),
      serviceRequestId: service.id,
      description:
          '${service.serviceName} - ${service.customerName} (${paymentMethod.toUpperCase()})',
      createdAt: DateTime.now(),
    );

    final transactionDeduct = Transaction(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch + 1}',
      workerId: currentWorkerId!,
      workerName: currentWorkerName!,
      type: TransactionType.creditDeduction,
      amount: -requiredCredit,
      balanceBefore: _currentWorkerData.creditBalance,
      balanceAfter: _currentWorkerData.creditBalance - requiredCredit,
      serviceRequestId: service.id,
      description: 'Commission & VAT deducted',
      createdAt: DateTime.now().add(const Duration(milliseconds: 100)),
    );

    // Batch update via helper methods or individually
    // Important: Update Credit in Firestore

    final newCredit = _currentWorkerData.creditBalance - requiredCredit;

    try {
      // 1. Update Service
      try {
        await _firestoreService.updateServiceRequest(completedService);
        debugPrint('✅ Service status updated to completed');
      } catch (e) {
        debugPrint('❌ Error updating service status: $e');
        throw e; // This is critical, must succeed
      }

      // 2. Add Transactions
      try {
        await _firestoreService.addTransaction(transactionEarn);
        await _firestoreService.addTransaction(transactionDeduct);
        debugPrint('✅ Worker transactions added');
      } catch (e) {
        debugPrint('❌ Error adding transactions: $e');
        // Don't throw - continue with other updates
      }

      // 3. Update Worker Credit
      try {
        await _firestoreService.updateWorkerCredit(currentWorkerId!, newCredit);
        debugPrint('✅ Worker credit updated');
      } catch (e) {
        debugPrint('❌ Error updating worker credit: $e');
        // Don't throw - continue with other updates
      }

      // 3.5. ✅ CRITICAL: Increment worker's completed services count
      try {
        await _firestoreService.incrementWorkerCompletedServices(
          currentWorkerId!,
        );
        debugPrint('✅ Worker completed services count incremented');
      } catch (e) {
        debugPrint('❌ Error incrementing completed services: $e');
        // Don't throw - continue with other updates
      }

      // 4. ✅ CRITICAL: Process Financial Records (Commission, VAT, Admin Wallet, Invoice)
      // This MUST be inside try block to ensure it runs
      try {
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
        debugPrint('✅ Financial records created successfully');
      } catch (e) {
        debugPrint('❌ Error creating financial records: $e');
        // Don't throw - allow service completion to succeed even if financial records fail
      }

      // Update local state for immediate feedback
      _currentWorkerData.creditBalance = newCredit;
      if (paymentMethod != 'Cash') {
        _currentWorkerData.walletBalance += totalPrice;
      }
      // ✅ REMOVED: No longer needed since completedServices derives from _serviceRequests
      // _currentWorkerData.completedServices.insert(0, completedService);

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error completing service: $e');
      throw e;
    }

    _currentWorkerData.calculatePendingAmount(activeServices);
    debugPrint(
      '✅ Service $serviceId completed with payment method: $paymentMethod',
    );
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
      final worker = workers.firstWhere(
        (w) => w.id == newWorkerId,
        orElse: () => WorkerData(
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
        ),
      );

      _serviceRequests[serviceIndex] = ServiceRequest(
        id: service.id,
        customerId: service.customerId,
        customerName:
            service.customerName, // ✅ Customer کی entered language preserve
        serviceId: service.serviceId,
        serviceName: service.serviceName,
        workerId: newWorkerId,
        workerName: newWorkerName,
        workerNameArabic: worker.nameArabic,
        requestedDate: newScheduledDate,
        requestedTime: service.requestedTime,
        address: service.address, // ✅ Customer کی entered language preserve
        customerNotes:
            service.customerNotes, // ✅ Customer کی entered language preserve
        customerLanguage:
            service.customerLanguage, // ✅ Customer language preserve
        status: ServiceRequestStatus.assigned,
        basePrice: service.basePrice,
        commission: service.commission,
        vat: service.vat,
        extraItems: service.extraItems, // ✅ Preserve extra items
        createdAt: service.createdAt,
        updatedAt: DateTime.now(),
      );

      debugPrint(
        '✅ Service $serviceId rescheduled to $newWorkerName (${worker.nameArabic})',
      );
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
        return _currentWorkerData.completedServices.firstWhere(
          (s) => s.id == serviceId,
        );
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
        customerName:
            service.customerName, // ✅ Customer کی entered language preserve
        serviceId: service.serviceId,
        serviceName: service.serviceName,
        workerId: service.workerId,
        workerName: service.workerName,
        workerNameArabic: service.workerNameArabic,
        requestedDate: service.requestedDate,
        requestedTime: service.requestedTime,
        address: service.address, // ✅ Customer کی entered language preserve
        customerNotes:
            service.customerNotes, // ✅ Customer کی entered language preserve
        customerLanguage:
            service.customerLanguage, // ✅ Customer language preserve
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

    _currentWorkerData.transactions.insert(
      0,
      Transaction(
        id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        workerId: currentWorkerId!,
        workerName: currentWorkerName!,
        type: TransactionType.creditTopup,
        amount: amount,
        balanceBefore: balanceBefore,
        balanceAfter: _currentWorkerData.creditBalance,
        description: 'Credit top-up via $method',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void transferWalletToCredit(double amount) {
    if (currentWorkerId == null) return;

    if (_currentWorkerData.walletBalance >= amount) {
      final walletBefore = _currentWorkerData.walletBalance;
      final creditBefore = _currentWorkerData.creditBalance;

      _currentWorkerData.walletBalance -= amount;
      _currentWorkerData.creditBalance += amount;

      _currentWorkerData.transactions.insert(
        0,
        Transaction(
          id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
          workerId: currentWorkerId!,
          workerName: currentWorkerName!,
          type: TransactionType.creditTopup,
          amount: amount,
          balanceBefore: creditBefore,
          balanceAfter: _currentWorkerData.creditBalance,
          description: 'Transferred from Wallet to Credit',
          createdAt: DateTime.now(),
        ),
      );
      notifyListeners();
    }
  }

  void updateCreditBalance(double amount) {
    if (currentWorkerId == null) return;

    final balanceBefore = _currentWorkerData.creditBalance;
    _currentWorkerData.creditBalance += amount;

    _currentWorkerData.transactions.insert(
      0,
      Transaction(
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
      ),
    );
    notifyListeners();
  }

  void updateWalletBalance(double amount) {
    if (currentWorkerId == null) return;

    _currentWorkerData.walletBalance += amount;
    notifyListeners();
  }

  // ✅ NEW: Sync worker credit when admin updates it
  // ✅ NEW: Sync worker credit when admin updates it
  void syncWorkerCredit(String workerId, double newCreditBalance) {
    // Update the specific worker's credit in _workerData
    if (_workerData.containsKey(workerId)) {
      _workerData[workerId]!.creditBalance = newCreditBalance;

      // If this is the currently logged-in worker, notify UI to update
      if (workerId == currentWorkerId) {
        debugPrint(
          '✅ Synced credit for current worker $workerId: SAR ${newCreditBalance.toStringAsFixed(2)}',
        );
        notifyListeners();
      } else {
        debugPrint(
          '✅ Synced credit for worker $workerId: SAR ${newCreditBalance.toStringAsFixed(2)}',
        );
      }
    } else {
      // Worker not yet initialized in AppState, create entry
      _workerData[workerId] = WorkerFinancialData(
        workerId: workerId,
        creditBalance: newCreditBalance,
        walletBalance: 0.0,
      );
      debugPrint(
        '✅ Initialized and synced credit for worker $workerId: SAR ${newCreditBalance.toStringAsFixed(2)}',
      );
    }
  }

  // ✅ NEW: Add credit with transaction record (for admin actions)
  void addCreditWithTransaction(
    String workerId,
    double amount,
    String description,
  ) {
    if (!_workerData.containsKey(workerId)) {
      debugPrint('❌ Worker $workerId not found in AppStateProvider');
      return;
    }

    final workerData = _workerData[workerId]!;

    // ✅ Calculate balanceBefore based on current balance and amount
    final balanceAfter = workerData.creditBalance;
    final balanceBefore = balanceAfter - amount;

    // ✅ Only add transaction record - DON'T modify credit balance!
    workerData.transactions.insert(
      0,
      Transaction(
        id: 'ADM${DateTime.now().millisecondsSinceEpoch}',
        workerId: workerId,
        workerName: _getWorkerName(workerId) ?? 'Worker',
        type: TransactionType.creditTopup,
        amount: amount,
        balanceBefore: balanceBefore,
        balanceAfter: balanceAfter,
        description: description,
        reference: 'ADMIN_ADDED',
        createdAt: DateTime.now(),
      ),
    );

    debugPrint(
      '✅ Transaction added for worker $workerId: +SAR ${amount.toStringAsFixed(2)}',
    );
    debugPrint(
      '   Balance: ${balanceBefore.toStringAsFixed(2)} → ${balanceAfter.toStringAsFixed(2)}',
    );

    // Notify if this is the current worker
    if (workerId == currentWorkerId) {
      notifyListeners();
    }
  }

  // Helper method to get worker name
  String? _getWorkerName(String workerId) {
    final worker = WorkerAuthService().getWorkerById(workerId);
    return worker?.name;
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
    // ✅ FIXED: Don't add any default transaction here
    // Transaction will be added in setCurrentWorker with correct amount
    transactions = [];
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

    averagePerService = totalServicesCompleted > 0
        ? totalEarnings / totalServicesCompleted
        : 0.0;
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
