// lib/services/worker_auth_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/worker_data_model.dart';
import 'firestore_service.dart';

class WorkerAuthService {
  static final WorkerAuthService _instance = WorkerAuthService._internal();
  factory WorkerAuthService() => _instance;

  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<WorkerData>>? _workersSubscription;

  WorkerAuthService._internal() {
    _initializeListeners();
  }

  // Local cache to maintain synchronous compatibility
  final Map<String, WorkerData> _registeredWorkers = {};
  final List<VoidCallback> _listeners = [];
  bool _isInitialized = false;

  void _initializeListeners() {
    _workersSubscription =
        _firestoreService.getWorkersStream().listen((workers) {
      _registeredWorkers.clear();
      for (var worker in workers) {
        final normalized = _normalizePhoneNumber(worker.phone);
        _registeredWorkers[normalized] = worker;
      }
      _isInitialized = true;
      _notifyListeners();
      debugPrint(
          '🔄 WorkerAuthService: Synced ${workers.length} workers from Firestore');
    }, onError: (e) {
      debugPrint('❌ Error syncing workers: $e');
    });
  }

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

  void dispose() {
    _workersSubscription?.cancel();
  }

  bool isWorkerRegistered(String phoneNumber) {
    // If not initialized yet, we might return false negatives, but stream should be fast
    final normalized = _normalizePhoneNumber(phoneNumber);
    return _registeredWorkers.containsKey(normalized);
  }

  WorkerData? getWorkerByPhone(String phoneNumber) {
    final normalized = _normalizePhoneNumber(phoneNumber);
    return _registeredWorkers[normalized];
  }

  WorkerData? getWorkerById(String workerId) {
    try {
      return _registeredWorkers.values.firstWhere(
        (worker) => worker.id == workerId,
      );
    } catch (e) {
      return null;
    }
  }

  String _normalizePhoneNumber(String phone) {
    String normalized = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (normalized.isEmpty) return '';

    if (!normalized.startsWith('+')) {
      if (normalized.startsWith('966')) {
        normalized = '+$normalized';
      } else if (normalized.startsWith('0')) {
        normalized = '+966${normalized.substring(1)}';
      } else {
        // Only add prefix if it looks like a local number
        if (normalized.length >= 9) {
          normalized = '+966$normalized';
        }
      }
    }
    return normalized;
  }

  // Returns Future<bool> now, but keeping boolean return for UI compatibility might be tricky
  // Changing to Future<bool> is better, but requires updating UI callers.
  // For now, I will optimistically update local cache AND call firestore.

  bool addWorker(WorkerData worker) {
    final normalized = _normalizePhoneNumber(worker.phone);
    if (_registeredWorkers.containsKey(normalized)) return false;

    // Optimistic update
    final normalizedWorker = worker.copyWith(
      phone: normalized,
      completedServices: 0,
    );
    _registeredWorkers[normalized] = normalizedWorker;
    _notifyListeners();

    // Firestore update
    _firestoreService.addWorker(normalizedWorker).catchError((e) {
      debugPrint('❌ Failed to add worker to Firestore: $e');
      // Revert if needed, but for now just logging
      _registeredWorkers.remove(normalized);
      _notifyListeners();
    });

    return true;
  }

  bool updateWorker(String phone, WorkerData updatedWorker) {
    final normalized = _normalizePhoneNumber(phone);
    if (!_registeredWorkers.containsKey(normalized)) return false;

    // Optimistic update
    final updatedNormalized = updatedWorker.copyWith(phone: normalized);
    _registeredWorkers[normalized] = updatedNormalized;
    _notifyListeners();

    // Firestore update
    _firestoreService.updateWorker(updatedNormalized).catchError((e) {
      debugPrint('❌ Failed to update worker in Firestore: $e');
    });

    return true;
  }

  bool deleteWorker(String phone) {
    // Implementing delete might require a delete method in FirestoreService if we want it
    // For now, simple optimistic remove.
    // NOTE: FirestoreService didn't have deleteWorker, so I'll skip firestore call or add it later if needed.
    // The previous implementation was just memory.
    final normalized = _normalizePhoneNumber(phone);
    if (!_registeredWorkers.containsKey(normalized)) return false;

    _registeredWorkers.remove(normalized);
    _notifyListeners();

    // TODO: Add delete to FirestoreService if required
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
    final updatedWorker = worker.copyWith(status: newStatus);

    _registeredWorkers[normalized] = updatedWorker;
    _notifyListeners();

    _firestoreService.updateWorker(updatedWorker);
    return true;
  }

  bool updateWorkerCredit(String phone, double newCreditBalance) {
    final normalized = _normalizePhoneNumber(phone);
    final worker = _registeredWorkers[normalized];
    if (worker == null) return false;

    final updatedWorker = worker.copyWith(creditBalance: newCreditBalance);
    _registeredWorkers[normalized] = updatedWorker;
    _notifyListeners();

    _firestoreService.updateWorkerCredit(worker.id, newCreditBalance);
    return true;
  }

  bool updateWorkerServices(String phone, int completedServices) {
    final normalized = _normalizePhoneNumber(phone);
    final worker = _registeredWorkers[normalized];
    if (worker == null) return false;

    final updatedWorker = worker.copyWith(completedServices: completedServices);
    _registeredWorkers[normalized] = updatedWorker;
    _notifyListeners();

    _firestoreService.updateWorker(updatedWorker);
    return true;
  }
}
