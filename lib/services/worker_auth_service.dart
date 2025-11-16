// lib/services/worker_auth_service.dart
import 'package:flutter/foundation.dart';

class WorkerAuthService {
  static final WorkerAuthService _instance = WorkerAuthService._internal();
  factory WorkerAuthService() => _instance;
  WorkerAuthService._internal();

  // Registered workers database
  final Map<String, WorkerData> _registeredWorkers = {};
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notifyListeners() {
    Future.microtask(() {
      for (var listener in _listeners) {
        try {
          listener();
        } catch (e) {
          debugPrint('Error notifying listener: $e');
        }
      }
    });
  }

  // Check if worker can login
  bool isWorkerRegistered(String phoneNumber) {
    final normalized = _normalizePhoneNumber(phoneNumber);
    final isRegistered = _registeredWorkers.containsKey(normalized);
    debugPrint('🔍 Checking registration for $normalized: $isRegistered');
    return isRegistered;
  }

  // Get worker data
  WorkerData? getWorkerByPhone(String phoneNumber) {
    final normalized = _normalizePhoneNumber(phoneNumber);
    return _registeredWorkers[normalized];
  }

  String _normalizePhoneNumber(String phone) {
    String normalized = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!normalized.startsWith('+')) {
      if (normalized.startsWith('966')) {
        normalized = '+$normalized';
      } else if (normalized.startsWith('0')) {
        normalized = '+966${normalized.substring(1)}';
      } else {
        normalized = '+966$normalized';
      }
    }

    return normalized;
  }

  // Add new worker (Admin only)
  bool addWorker(WorkerData worker) {
    final normalized = _normalizePhoneNumber(worker.phone);

    if (_registeredWorkers.containsKey(normalized)) {
      debugPrint('❌ Worker already exists: $normalized');
      return false;
    }

    // ✅ Create worker with normalized phone and CUSTOM INITIAL CREDIT
    final normalizedWorker = worker.copyWith(
      phone: normalized,
      creditBalance: worker.creditBalance, // ✅ Use provided credit balance
      completedServices: 0,
    );
    _registeredWorkers[normalized] = normalizedWorker;

    debugPrint('✅ Worker added: $normalized - ${worker.name}');
    debugPrint('📊 Total workers: ${_registeredWorkers.length}');
    debugPrint('💰 Initial credit: SAR ${normalizedWorker.creditBalance.toStringAsFixed(2)}');

    _notifyListeners();
    return true;
  }

  // Update worker
  bool updateWorker(String phone, WorkerData updatedWorker) {
    final normalized = _normalizePhoneNumber(phone);

    if (!_registeredWorkers.containsKey(normalized)) {
      return false;
    }

    final updatedNormalized = updatedWorker.copyWith(phone: normalized);
    _registeredWorkers[normalized] = updatedNormalized;
    _notifyListeners();
    return true;
  }

  // Delete worker
  bool deleteWorker(String phone) {
    final normalized = _normalizePhoneNumber(phone);

    if (!_registeredWorkers.containsKey(normalized)) {
      return false;
    }

    _registeredWorkers.remove(normalized);
    _notifyListeners();
    return true;
  }

  // Get all workers
  List<WorkerData> getAllWorkers() {
    return _registeredWorkers.values.toList();
  }

  // Get active workers
  List<WorkerData> getActiveWorkers() {
    return _registeredWorkers.values
        .where((worker) => worker.status == 'Active')
        .toList();
  }

  // Toggle worker status
  bool toggleWorkerStatus(String phone) {
    final normalized = _normalizePhoneNumber(phone);
    final worker = _registeredWorkers[normalized];
    if (worker == null) return false;

    final newStatus = worker.status == 'Active' ? 'Blocked' : 'Active';
    _registeredWorkers[normalized] = worker.copyWith(status: newStatus);
    _notifyListeners();
    return true;
  }

  // Update worker credit balance
  bool updateWorkerCredit(String phone, double newCreditBalance) {
    final normalized = _normalizePhoneNumber(phone);
    final worker = _registeredWorkers[normalized];
    if (worker == null) {
      debugPrint('❌ Worker not found for credit update: $normalized');
      return false;
    }

    _registeredWorkers[normalized] = worker.copyWith(creditBalance: newCreditBalance);
    debugPrint('✅ Worker credit updated: $normalized → SAR ${newCreditBalance.toStringAsFixed(2)}');
    _notifyListeners();
    return true;
  }

  // Update worker completed services
  bool updateWorkerServices(String phone, int completedServices) {
    final normalized = _normalizePhoneNumber(phone);
    final worker = _registeredWorkers[normalized];
    if (worker == null) {
      debugPrint('❌ Worker not found for services update: $normalized');
      return false;
    }

    _registeredWorkers[normalized] = worker.copyWith(completedServices: completedServices);
    debugPrint('✅ Worker services updated: $normalized → $completedServices services');
    _notifyListeners();
    return true;
  }
}

// Worker Data Model with Arabic localization
class WorkerData {
  final String id;
  final String name;
  final String nameArabic;
  final String phone;
  final String email;
  final String nationalId;
  final String stcPayId;
  final String address;
  final String addressArabic;
  final String status;
  final DateTime joinedDate;
  final int completedServices;
  final double creditBalance;

  WorkerData({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.phone,
    required this.email,
    required this.nationalId,
    required this.stcPayId,
    required this.address,
    required this.addressArabic,
    required this.status,
    required this.joinedDate,
    this.completedServices = 0,
    this.creditBalance = 100.0,  // ✅ DEFAULT INITIAL CREDIT (will be overridden by admin input)
  });

  WorkerData copyWith({
    String? id,
    String? name,
    String? nameArabic,
    String? phone,
    String? email,
    String? nationalId,
    String? stcPayId,
    String? address,
    String? addressArabic,
    String? status,
    DateTime? joinedDate,
    int? completedServices,
    double? creditBalance,
  }) {
    return WorkerData(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      nationalId: nationalId ?? this.nationalId,
      stcPayId: stcPayId ?? this.stcPayId,
      address: address ?? this.address,
      addressArabic: addressArabic ?? this.addressArabic,
      status: status ?? this.status,
      joinedDate: joinedDate ?? this.joinedDate,
      completedServices: completedServices ?? this.completedServices,
      creditBalance: creditBalance ?? this.creditBalance,
    );
  }
}