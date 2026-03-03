import 'package:flutter/material.dart';
import '/services/financial_service.dart';
import 'package:flutter/scheduler.dart';
import '../services/worker_auth_service.dart';
import '../services/firestore_service.dart';
import '../models/worker_data_model.dart';
import '/models/customer_model.dart';
import '/models/customer_service_model.dart';
import '../models/service_request_model.dart';
// import '../models/service_model.dart'; // Removed unused import
import '../models/service_category_model.dart';

import '../models/transaction_model.dart';

import '/utils/admin_translations.dart';
import '/services/notification_service.dart';

class AppStateProvider with ChangeNotifier {
  final _firestoreService = FirestoreService();
  final _financialService = FinancialService();
  final _workerAuthService = WorkerAuthService();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final Map<String, WorkerFinancialData> _workerData = {};
  String? currentWorkerId;
  String? currentWorkerName;
  List<ServiceRequest> _serviceRequests = [];
  List<ServiceCategory> _serviceCategories = [];
  List<ServiceCategory> get serviceCategories => _serviceCategories;

  // ✅ ADDED: Real Firestore customers list
  List<Customer> _firestoreCustomers = [];

  // ✅ Processing Lock
  final Set<String> _processingServiceIds = {};

  // ✅ WATCHDOG STATE
  Set<String> _previousServiceIds = {};
  Map<String, ServiceRequestStatus> _previousServiceStatuses = {};
  bool _firstLoad = true;
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

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
      // LISTEN TO SERVICE REQUESTS
      // Identify changes for notifications
      if (_firstLoad) {
        _firstLoad = false;
        _previousServiceIds = services.map((s) => s.id).toSet();
        _previousServiceStatuses = {for (var s in services) s.id: s.status};
      } else {
        for (var service in services) {
          // 1. Check for NEW Service
          if (!_previousServiceIds.contains(service.id)) {
            NotificationService().showLocalNotification(
              title: 'New Service Request',
              body:
                  'New request from ${service.customerName}: ${service.serviceName}',
            );
          }
          // 2. Check for STATUS Change (Cancellation)
          else if (_previousServiceStatuses.containsKey(service.id)) {
            final oldStatus = _previousServiceStatuses[service.id];
            if (oldStatus != ServiceRequestStatus.cancelled &&
                service.status == ServiceRequestStatus.cancelled) {
              NotificationService().showLocalNotification(
                title: 'Service Cancelled',
                body:
                    '${service.customerName} cancelled ${service.serviceName}',
              );
            }
          }
        }

        // Update state
        _previousServiceIds = services.map((s) => s.id).toSet();
        _previousServiceStatuses = {for (var s in services) s.id: s.status};
      }

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

    // ✅ ADDED: Listen to Customers
    _firestoreService.getCustomersStream().listen((customers) {
      _firestoreCustomers = customers;
      notifyListeners();
      debugPrint(
        '🔄 AppStateProvider: Synced ${customers.length} customers from Firestore',
      );
    });

    _isInitialized = true;
    notifyListeners();

    // Initialization complete
  }

  // ✅ ADD: Get customer by ID
  Customer? getCustomerById(String customerId) {
    // 1. Try to find in Firestore data first (Real data)
    try {
      return _firestoreCustomers.firstWhere((c) => c.id == customerId);
    } catch (_) {}

    // 2. Last resort: Unknown
    return Customer(
      id: customerId, // Use the ID passed, so we at least know WHICH ID is missing
      name: 'Unknown Customer',
      phone: 'N/A',
      registeredAt: DateTime.now(),
      languagePreference: 'english',
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
  double get reservedCredit =>
      _currentWorkerData.reservedCredit; // Added getter
  double get availableCredit =>
      creditBalance - reservedCredit; // Effective credit
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

  // ✅ ADDED: Cancelled Services Filter
  List<ServiceRequest> get adminCancelledServices {
    return _serviceRequests
        .where((s) => s.status == ServiceRequestStatus.cancelled)
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

    // 1. Add all real customers from Firestore FIRST
    for (var customer in _firestoreCustomers) {
      customersMap[customer.id] = customer;
    }

    // 2. Add customers from service requests (Fallback if not in customers collection yet)
    for (var service in _serviceRequests) {
      final customerId = service.customerId;

      if (!customersMap.containsKey(customerId)) {
        final customer = getCustomerById(customerId);
        if (customer != null) {
          customersMap[customerId] = customer;
        }
      }
    }

    // 3. Add customers from completed services
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

    // 4. Fallback removed.
    /*
    if (customersMap.isEmpty) {
      for (var customer in hardcodedCustomers) {
        customersMap[customer.id] = customer;
      }
    }
    */

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

    WorkerData? workerData = _workerAuthService.getWorkerById(workerId);

    // ✅ FIXED: Fallback to direct Firestore fetch if service not ready
    if (workerData == null) {
      debugPrint(
        '⚠️ Worker $workerId not found in auth service cache, fetching from Firestore...',
      );
      workerData = await _firestoreService.getWorkerById(workerId);
    }

    if (workerData == null) {
      debugPrint('❌ Worker $workerId not found in Firestore either');
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
      reservedCredit: workerData.reservedCredit, // Initialize reservedCredit
      walletBalance: workerData.walletBalance,
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

    // ✅ Start Notification Listener
    NotificationService().startListeningToNotifications(workerId);

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

      // ✅ NOTIFICATION: Notify Worker of Assignment
      await NotificationService().sendNotification(
        title: 'New Service Assigned',
        body: 'You have been assigned to service: ${service.serviceName}',
        type: 'service',
        targetUserIds: [workerId],
        relatedId: serviceId,
      );

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

    // ✅ CHECK Credit Reservation
    // We must ensure (Available Credit = Total - Reserved) >= Required
    final requiredCredit = service.totalDeduction;
    // Note: 'totalDeduction' usually means commission + VAT

    if ((_currentWorkerData.creditBalance - _currentWorkerData.reservedCredit) <
        requiredCredit) {
      debugPrint('❌ Insufficient available credit to accept service.');
      debugPrint('   Required: $requiredCredit');
      debugPrint(
        '   Available: ${_currentWorkerData.creditBalance - _currentWorkerData.reservedCredit}',
      );
      return; // Or throw/show error, but effectively blocks acceptance
    }

    final updatedService = service.copyWith(
      status: ServiceRequestStatus.inProgress,
      postponeReason:
          null, // Ensure to clear if it was there (though this is not resume)
      updatedAt: DateTime.now(),
    );

    // ✅ Update Worker Reserved Credit
    // Increase reserved credit
    final newReserved = _currentWorkerData.reservedCredit + requiredCredit;

    // Batch update via helper methods or manually ensuring both succeed
    // Ideally use a batch or transaction, but for now sequential updates with error handling
    try {
      await _firestoreService.updateWorkerReservedCredit(
        currentWorkerId!,
        newReserved,
      );
      _currentWorkerData.reservedCredit = newReserved; // Optimistic update
    } catch (e) {
      debugPrint('❌ Error updating reserved credit: $e');
      return; // Fail cleanly
    }

    await _firestoreService.updateServiceRequest(updatedService);

    debugPrint(
      '✅ Service $serviceId accepted (Reserved Credit: $requiredCredit)',
    );

    // ✅ NOTIFICATION: Notify Customer & Admin
    await NotificationService().sendNotification(
      title: 'Service Accepted',
      body:
          '$currentWorkerName has accepted your request for ${service.serviceName}',
      type: 'service',
      targetUserIds: [service.customerId, 'admin'], // ✅ Notify both
      relatedId: serviceId,
    );
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

    // ✅ NOTIFICATION: Notify Admin/Customer of Resumption
    await NotificationService().sendNotification(
      title: 'Service Resumed',
      body:
          '$currentWorkerName has resumed the service: ${service.serviceName}',
      type: 'service',
      targetUserIds: [service.customerId, 'admin'], // Notify both
      relatedId: serviceId,
    );

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

      // ✅ NOTIFICATION: Notify Admin/Customer of Postponement
      await NotificationService().sendNotification(
        title: 'Service Postponed',
        body: '$currentWorkerName postponed ${service.serviceName}: $reason',
        type: 'warning',
        targetUserIds: [service.customerId, 'admin'], // Notify both
        relatedId: serviceId,
      );
    }
  }

  Future<void> completeService(
    String serviceId, {
    String paymentMethod = 'Cash',
  }) async {
    if (currentWorkerId == null) return;

    // ✅ Prevent double execution
    if (_processingServiceIds.contains(serviceId)) {
      debugPrint('⚠️ Service $serviceId logic already in progress');
      return;
    }
    _processingServiceIds.add(serviceId);
    notifyListeners(); // Notify UI to disable button

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

    // Logic: We already reserved credit. So we expect (Total >= Deduction).
    // We don't check (Available >= Deduction) because we are CONSUMING the reservation.
    // We just check if Total Credit is enough (it should be, unless Admin deducted manually).

    if (_currentWorkerData.creditBalance < requiredCredit) {
      debugPrint(
        '❌ Cannot complete service: Insufficient TOTAL credit (Unexpected)',
      );
      debugPrint('   Required: SAR ${requiredCredit.toStringAsFixed(2)}');
      debugPrint(
        '   Total: SAR ${_currentWorkerData.creditBalance.toStringAsFixed(2)}',
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

    // ✅ Deterministic ID Generation to prevent duplicates
    final earnTxnId = 'TXN_EARN_${service.id}';
    final deductTxnId = 'TXN_DEDUCT_${service.id}';

    // Create Transactions
    final transactionEarn = Transaction(
      id: earnTxnId,
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
      id: deductTxnId,
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

    // ✅ LOGIC CHANGE:
    // New Credit Balance = Old Credit Balance - Deduction
    // New Reserved Credit = Old Reserved Credit - Deduction (Release reservation)

    final newCredit = _currentWorkerData.creditBalance - requiredCredit;
    final newReserved = (_currentWorkerData.reservedCredit - requiredCredit)
        .clamp(0.0, double.infinity);
    // Use clamp just in case of slight precision errors or manual admin edits

    try {
      // 1. Update Service
      try {
        await _firestoreService.updateServiceRequest(completedService);
        debugPrint('✅ Service status updated to completed');
      } catch (e) {
        debugPrint('❌ Error updating service status: $e');
        rethrow; // This is critical, must succeed
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

      // 3. Update Worker Credit & Release Reservation
      try {
        await _firestoreService.updateWorkerCredit(currentWorkerId!, newCredit);
        await _firestoreService.updateWorkerReservedCredit(
          currentWorkerId!,
          newReserved,
        );
        debugPrint('✅ Worker credit updated & reservation released');
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
          commissionAmount:
              service.totalCommission, // ✅ Pass correct commission
          vatAmount: service.totalVAT, // ✅ Pass correct VAT
        );
        debugPrint('✅ Financial records created successfully');
      } catch (e) {
        debugPrint('❌ Error creating financial records: $e');
        // Don't throw - allow service completion to succeed even if financial records fail
      }

      // Update local state for immediate feedback
      _currentWorkerData.creditBalance = newCredit;
      _currentWorkerData.reservedCredit =
          newReserved; // Update local reservation
      if (paymentMethod != 'Cash') {
        final newWalletBalance = _currentWorkerData.walletBalance + totalPrice;
        _currentWorkerData.walletBalance = newWalletBalance;

        try {
          await _firestoreService.updateWorkerWallet(
            currentWorkerId!,
            newWalletBalance,
          );
          debugPrint('✅ Worker wallet updated');
        } catch (e) {
          debugPrint('❌ Error updating worker wallet: $e');
        }
      }
      // ✅ REMOVED: No longer needed since completedServices derives from _serviceRequests
      // _currentWorkerData.completedServices.insert(0, completedService);

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error completing service: $e');
      rethrow;
    } finally {
      // ✅ Release lock
      _processingServiceIds.remove(serviceId);
      // notifyListeners() is called below or automatically by finally?
      // Safest to just ensure closure.
    }

    _currentWorkerData.calculatePendingAmount(activeServices);
    debugPrint(
      '✅ Service $serviceId completed with payment method: $paymentMethod',
    );
    notifyListeners();
  }
  // ✅ FIXED: Add validation for postponeService

  Future<void> reschedulePostponedService({
    required String serviceId,
    required String newWorkerId,
    required String newWorkerName,
    required DateTime newScheduledDate,
  }) async {
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

      final updatedService = ServiceRequest(
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

      // ✅ Persist to Firestore
      await _firestoreService.updateServiceRequest(updatedService);

      // ✅ NOTIFICATION: Notify Customer of Rescheduling
      await NotificationService().sendNotification(
        title: 'Service Rescheduled',
        body:
            'Your service "${service.serviceName}" has been rescheduled with a new worker.',
        type: 'service',
        targetUserIds: [service.customerId],
        relatedId: serviceId,
      );

      // ✅ NOTIFICATION: Notify New Worker of Assignment
      await NotificationService().sendNotification(
        title: 'New Service Assigned (Rescheduled)',
        body:
            'You have been assigned to a rescheduled service: ${service.serviceName}',
        type: 'service',
        targetUserIds: [newWorkerId],
        relatedId: serviceId,
      );

      debugPrint(
        '✅ Service $serviceId rescheduled to $newWorkerName (${worker.nameArabic})',
      );
      // Local state is updated by Firestore stream
    }
  }

  void addServiceRequest(ServiceRequest serviceData) {
    _serviceRequests.insert(0, serviceData);
    debugPrint('✅ New service request added');

    // ✅ NOTIFICATION: Notify All Workers (Broadcast) or specific if assigned logic existed here
    // For now, Notify Admin
    NotificationService().sendNotification(
      title: 'New Service Request',
      body:
          'New request for ${serviceData.serviceName} from ${serviceData.customerName}',
      type: 'service',
      targetUserIds: ['admin'], // Admin should see this
      relatedId: serviceData.id,
    );

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
    if (currentWorkerId == null) return false;
    // Check if we already reserved credit for THIS service (e.g. if it is in progress)
    // If we already accepted it, we don't need *more* credit, we just need to ensure we have enough TOTAL.
    // BUT the user scenario is: "accepted service A (reserved), accepted service B (reserved), completed B".
    // If complete B, it shouldn't affect A's reservation.
    // So "hasEnoughCredit" is usually called BEFORE accepting.
    // Or during "Complete Service" flow?

    // If status is 'assigned' (not yet accepted), we check against (Total - Reserved).
    if (service.status == ServiceRequestStatus.assigned) {
      return (creditBalance - reservedCredit) >= getRequiredCredit(service);
    }

    // If status is 'inProgress' (already accepted/reserved), we check against Total.
    // Because the credit for THIS service is already inside 'reservedCredit'.
    // So we just need to ensure Total Credit is still enough to cover this reservation.
    // (Total >= Required) is sufficient because Required IS part of Reserved (which is part of Total).
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

  void transferWalletToCredit(double amount) async {
    if (currentWorkerId == null || _isSubmitting) return;

    if (_currentWorkerData.walletBalance >= amount) {
      _isSubmitting = true;
      notifyListeners();

      try {
        final creditBefore = _currentWorkerData.creditBalance;

        // Perform Firestore update first
        final newWalletBalance = _currentWorkerData.walletBalance - amount;
        final newCreditBalance = _currentWorkerData.creditBalance + amount;

        await _firestoreService.updateWorkerWallet(
          currentWorkerId!,
          newWalletBalance,
        );
        await _firestoreService.updateWorkerCredit(
          currentWorkerId!,
          newCreditBalance,
        );

        // Add transaction
        final txn = Transaction(
          id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
          workerId: currentWorkerId!,
          workerName: currentWorkerName!,
          type: TransactionType.creditTopup,
          amount: amount,
          balanceBefore: creditBefore,
          balanceAfter: newCreditBalance,
          description: 'Transferred from Wallet to Credit',
          createdAt: DateTime.now(),
        );
        await _firestoreService.addTransaction(txn);

        // Update local state
        _currentWorkerData.walletBalance = newWalletBalance;
        _currentWorkerData.creditBalance = newCreditBalance;
        _currentWorkerData.transactions.insert(0, txn);
      } catch (e) {
        debugPrint('❌ Error in transferWalletToCredit: $e');
        rethrow;
      } finally {
        _isSubmitting = false;
        notifyListeners();
      }
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

    // ✅ NOTIFICATION: Notify Worker of Credit Addition
    NotificationService().sendNotification(
      title: 'Credit Added',
      body:
          'Admin added SAR ${amount.toStringAsFixed(2)} to your credit balance.',
      type: 'payment',
      targetUserIds: [workerId],
      relatedId: 'ADM${DateTime.now().millisecondsSinceEpoch}',
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

  Future<void> markInvoiceAsGenerated(String serviceId) async {
    final serviceIndex = _serviceRequests.indexWhere((s) => s.id == serviceId);
    if (serviceIndex != -1) {
      final service = _serviceRequests[serviceIndex];
      final updatedService = service.copyWith(
        invoiceGenerated: true,
        updatedAt: DateTime.now(),
      );

      // 1. Update Firestore (Sync with Customer App)
      await _firestoreService.updateServiceRequest(updatedService);

      // 2. Update Local State
      _serviceRequests[serviceIndex] = updatedService;
      notifyListeners();

      debugPrint('✅ Invoice marked as generated for service: $serviceId');
    }
  }

  // ✅ CREDIT REQUEST - delegates to FinancialService (includes pending check)
  Future<void> submitCreditRequest(
    double amount,
    String referenceNumber,
  ) async {
    if (currentWorkerId == null || _isSubmitting) return;

    _isSubmitting = true;
    notifyListeners();

    try {
      await _financialService.submitCreditRequest(
        workerId: currentWorkerId!,
        workerName: currentWorkerName ?? 'Worker',
        amount: amount,
        referenceNumber: referenceNumber,
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

class WorkerFinancialData {
  final String workerId;
  double creditBalance;
  double reservedCredit; // Added reservedCredit
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
    this.reservedCredit = 0.0, // Default to 0.0
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
