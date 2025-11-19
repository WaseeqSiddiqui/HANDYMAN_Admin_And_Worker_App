// lib/services/worker_auth_service.dart
import 'package:flutter/foundation.dart';
import '../models/worker_data_model.dart';

class WorkerAuthService {
  static final WorkerAuthService _instance = WorkerAuthService._internal();
  factory WorkerAuthService() => _instance;
  WorkerAuthService._internal();

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

  bool isWorkerRegistered(String phoneNumber) {
    final normalized = _normalizePhoneNumber(phoneNumber);
    final isRegistered = _registeredWorkers.containsKey(normalized);
    debugPrint('🔍 Checking registration for $normalized: $isRegistered');
    return isRegistered;
  }

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

  bool addWorker(WorkerData worker) {
    final normalized = _normalizePhoneNumber(worker.phone);
    if (_registeredWorkers.containsKey(normalized)) return false;

    final normalizedWorker = worker.copyWith(
      phone: normalized,
      completedServices: 0,
    );
    _registeredWorkers[normalized] = normalizedWorker;
    _notifyListeners();
    return true;
  }

  bool updateWorker(String phone, WorkerData updatedWorker) {
    final normalized = _normalizePhoneNumber(phone);
    if (!_registeredWorkers.containsKey(normalized)) return false;

    final updatedNormalized = updatedWorker.copyWith(phone: normalized);
    _registeredWorkers[normalized] = updatedNormalized;
    _notifyListeners();
    return true;
  }

  bool deleteWorker(String phone) {
    final normalized = _normalizePhoneNumber(phone);
    if (!_registeredWorkers.containsKey(normalized)) return false;

    _registeredWorkers.remove(normalized);
    _notifyListeners();
    return true;
  }

  List<WorkerData> getAllWorkers() => _registeredWorkers.values.toList();

  List<WorkerData> getActiveWorkers() =>
      _registeredWorkers.values.where((w) => w.status == 'Active').toList();

  bool toggleWorkerStatus(String phone) {
    final normalized = _normalizePhoneNumber(phone);
    final worker = _registeredWorkers[normalized];
    if (worker == null) return false;

    final newStatus = worker.status == 'Active' ? 'Blocked' : 'Active';
    _registeredWorkers[normalized] = worker.copyWith(status: newStatus);
    _notifyListeners();
    return true;
  }

  bool updateWorkerCredit(String phone, double newCreditBalance) {
    final normalized = _normalizePhoneNumber(phone);
    final worker = _registeredWorkers[normalized];
    if (worker == null) return false;

    _registeredWorkers[normalized] =
        worker.copyWith(creditBalance: newCreditBalance);
    _notifyListeners();
    return true;
  }

  bool updateWorkerServices(String phone, int completedServices) {
    final normalized = _normalizePhoneNumber(phone);
    final worker = _registeredWorkers[normalized];
    if (worker == null) return false;

    _registeredWorkers[normalized] =
        worker.copyWith(completedServices: completedServices);
    _notifyListeners();
    return true;
  }
}
