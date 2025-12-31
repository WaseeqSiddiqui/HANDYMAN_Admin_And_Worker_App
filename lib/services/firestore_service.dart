import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/foundation.dart';
import '../models/worker_data_model.dart';
import '../models/service_request_model.dart';
import '../models/transaction_model.dart';
import '../models/admin_wallet_transaction.dart';
import '../models/commission_record_model.dart';
import '../models/vat_model.dart';
import '../models/withdrawl_requests_model.dart';
import '../models/service_category_model.dart';
import '../models/customer_model.dart';
import '../models/service_invoice_model.dart';
import '../models/service_model.dart';
import '../models/review_model.dart';
import '../models/chat_message_model.dart';
import '../models/credit_request_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  // Collection References
  CollectionReference get _workersCollection =>
      _firestore.collection('workers');
  CollectionReference get _servicesCollection =>
      _firestore.collection('service_requests');
  CollectionReference get _transactionsCollection =>
      _firestore.collection('transactions');
  CollectionReference get _adminWalletCollection =>
      _firestore.collection('admin_wallet');
  CollectionReference get _commissionCollection =>
      _firestore.collection('commissions');
  CollectionReference get _vatCollection =>
      _firestore.collection('vat_records');
  CollectionReference get _withdrawalCollection =>
      _firestore.collection('withdrawal_requests');
  CollectionReference get _categoriesCollection =>
      _firestore.collection('service_categories');
  CollectionReference get _customersCollection =>
      _firestore.collection('customers');
  CollectionReference get _invoicesCollection =>
      _firestore.collection('invoices');
  CollectionReference get _offeredServicesCollection =>
      _firestore.collection('services_offered');
  CollectionReference get _reviewsCollection =>
      _firestore.collection('reviews');
  CollectionReference get _creditRequestsCollection =>
      _firestore.collection('credit_requests');

  // Singleton pattern
  static FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal() : _firestore = FirebaseFirestore.instance;

  @visibleForTesting
  FirestoreService.withFirestore(this._firestore);

  @visibleForTesting
  static void setInstance(FirestoreService instance) {
    _instance = instance;
  }

  // ✅ Save FCM Token
  Future<void> saveFcmToken(String userId, String token, String role) async {
    try {
      if (role == 'worker') {
        await _workersCollection.doc(userId).update({'fcmToken': token});
      } else if (role == 'admin') {
        // Assuming 'admins' collection or similar. If not, maybe just log.
        // await _adminsCollection.doc(userId).update({'fcmToken': token});
      } else if (role == 'customer') {
        await _customersCollection.doc(userId).update({'fcmToken': token});
      }
    } catch (e) {
      debugPrint("Error saving FCM token: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // WORKERS
  // ---------------------------------------------------------------------------

  Stream<List<WorkerData>> getWorkersStream() {
    return _workersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure ID is set from doc ID if missing, though it should be in data
        if (data['id'] == null || data['id'].isEmpty) {
          data['id'] = doc.id;
        }
        return WorkerData.fromMap(data);
      }).toList();
    });
  }

  Future<List<WorkerData>> getAllWorkers() async {
    try {
      final snapshot = await _workersCollection.get();
      return snapshot.docs.map((doc) {
        return WorkerData.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching workers: $e');
      rethrow;
    }
  }

  Future<void> addWorker(WorkerData worker) async {
    try {
      await _workersCollection.doc(worker.id).set(worker.toMap());
    } catch (e) {
      debugPrint('Error adding worker: $e');
      rethrow;
    }
  }

  Future<void> updateWorker(WorkerData worker) async {
    try {
      await _workersCollection.doc(worker.id).update(worker.toMap());
    } catch (e) {
      debugPrint('Error updating worker: $e');
      rethrow;
    }
  }

  Future<void> updateWorkerCredit(String workerId, double newCredit) async {
    try {
      await _workersCollection.doc(workerId).update({
        'creditBalance': newCredit,
      });
    } catch (e) {
      debugPrint('Error updating worker credit: $e');
      rethrow;
    }
  }

  Future<void> deleteWorker(String workerId) async {
    try {
      await _workersCollection.doc(workerId).delete();
      debugPrint('✅ Worker deleted from Firestore: $workerId');
    } catch (e) {
      debugPrint('❌ Error deleting worker: $e');
      rethrow;
    }
  }

  Future<void> updateReview(Review review) async {
    try {
      await _reviewsCollection.doc(review.id).update(review.toMap());
      debugPrint('✅ Review updated: ${review.id}');
    } catch (e) {
      debugPrint('❌ Error updating review: $e');
      rethrow;
    }
  }

  Future<void> updateWorkerWallet(String workerId, double newBalance) async {
    try {
      await _workersCollection.doc(workerId).update({
        'walletBalance': newBalance,
      });
    } catch (e) {
      debugPrint('Error updating worker wallet: $e');
      rethrow;
    }
  }

  Future<void> incrementWorkerCompletedServices(String workerId) async {
    try {
      debugPrint('🔄 Incrementing completed services for worker: $workerId');
      await _workersCollection.doc(workerId).update({
        'completedServices': FieldValue.increment(1),
      });
      debugPrint(
        '✅ Successfully incremented completed services for worker: $workerId',
      );
    } catch (e) {
      debugPrint('❌ Error incrementing worker completed services: $e');
      rethrow;
    }
  }

  Future<WorkerData?> getWorkerById(String workerId) async {
    try {
      final doc = await _workersCollection.doc(workerId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure ID is set
        if (data['id'] == null || data['id'].isEmpty) {
          data['id'] = doc.id;
        }
        return WorkerData.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching worker by ID: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // SERVICE REQUESTS
  // ---------------------------------------------------------------------------

  Stream<List<ServiceRequest>> getServiceRequestsStream() {
    return _servicesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceRequest.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<List<ServiceRequest>> getAllServiceRequests() async {
    try {
      final snapshot = await _servicesCollection.get();
      return snapshot.docs.map((doc) {
        return ServiceRequest.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching services: $e');
      rethrow;
    }
  }

  Future<void> addServiceRequest(ServiceRequest service) async {
    try {
      await _servicesCollection.doc(service.id).set(service.toJson());

      // ✅ NOTIFICATION: Notify Admin AND Worker of New Assignment
      final targetIds = ['admin'];
      if (service.workerId != null) {
        targetIds.add(service.workerId!);
      }

      await _notificationsCollection.add({
        'title': 'New Service Request',
        'message': 'New service request created: ${service.serviceName}',
        'type': 'service',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'targetUserIds': targetIds,
        'relatedId': service.id,
      });
    } catch (e) {
      debugPrint('Error adding service request: $e');
      rethrow;
    }
  }

  Future<void> updateServiceRequest(ServiceRequest service) async {
    try {
      // Fetch old status to check for changes
      final doc = await _servicesCollection.doc(service.id).get();
      final oldData = doc.data() as Map<String, dynamic>?;
      final oldStatus = oldData?['status'];

      await _servicesCollection.doc(service.id).update(service.toJson());

      // ✅ NOTIFICATION: Status Change
      if (oldStatus != service.status.name) {
        // SERVICE COMPLETED -> Notify Admin
        if (service.status == ServiceRequestStatus.completed) {
          await _notificationsCollection.add({
            'title': 'Service Completed',
            'message': 'Service ${service.serviceName} marked as completed.',
            'type': 'service',
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'targetUserIds': ['admin'], // Admin always needs to know
            'relatedId': service.id,
          });
        }
        // SERVICE POSTPONED -> Notify Admin (User requirement: Worker does it, so only Admin needs to know)
        else if (service.status.name == 'postponed') {
          await _notificationsCollection.add({
            'title': 'Service Postponed',
            'message':
                'Service ${service.serviceName} has been postponed. Reason: ${service.postponeReason ?? "No reason provided"}',
            'type': 'warning',
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'targetUserIds': ['admin'],
            'relatedId': service.id,
          });
        }
      }

      // ✅ NOTIFICATION: Worker Re-assignment
      // Check if workerId changed
      final oldWorkerId = oldData?['workerId'];
      if (service.workerId != null && service.workerId != oldWorkerId) {
        await _notificationsCollection.add({
          'title': 'New Assignment',
          'message':
              'You have been assigned to service: ${service.serviceName}',
          'type': 'service',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'targetUserIds': [service.workerId!],
          'relatedId': service.id,
        });
      }
    } catch (e) {
      debugPrint('Error updating service request: $e');
      rethrow;
    }
  }

  // ✅ New Method for Customer App usage (or Admin cancellation)
  Future<void> cancelServiceRequest(
    String serviceId,
    String reason,
    String cancelledBy,
  ) async {
    try {
      // 1. Update Service Status
      await _servicesCollection.doc(serviceId).update({
        'status': 'cancelled',
        'postponeReason': reason, // Reusing reason field/adding cancel reason
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Fetch service to get names for notification
      // (Optimized: In a real app, pass names to this method to save a read)
      final doc = await _servicesCollection.doc(serviceId).get();
      final data = doc.data() as Map<String, dynamic>;
      final serviceName = data['serviceName'] ?? 'Service';
      // final workerId = data['workerId']; -> Not used anymore in this scope

      // 2. Create Notification
      // Notify Admin
      await _notificationsCollection.add({
        'title': 'Service Cancelled',
        'message':
            'Service $serviceName was cancelled by $cancelledBy. Reason: $reason',
        'type': 'warning',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'targetUserIds': ['admin'],
        'relatedId': serviceId,
      });

      // ✅ LOGIC CHANGE: Release reserved credit if service was in progress
      // We need to fetch the service to know if it was in a state where credit was reserved
      // Optimization: We already fetched 'data' above (line 306).
      // Check if status was 'inProgress' (or 'accepted' if that status existed, but here it's inProgress)
      final oldStatus = data['status'];
      final workerId = data['workerId'];

      if (workerId != null && oldStatus == 'inProgress') {
        // Calculate amount to release (Total Deduction)
        // We need to recalculate or fetch total deduction.
        // ServiceRequest model has totalDeduction getter, but here we have raw map.
        // Let's instantiate model or calculate.
        final serviceReq = ServiceRequest.fromJson(data);
        final amountToRelease = serviceReq.totalDeduction;

        if (amountToRelease > 0) {
          debugPrint(
            '🔄 Releasing reserved credit for cancelled service: $amountToRelease',
          );
          await _workersCollection.doc(workerId).update({
            'reservedCredit': FieldValue.increment(-amountToRelease),
          });
        }
      }
    } catch (e) {
      debugPrint('Error cancelling service: $e');
      rethrow;
    }
  }

  Future<void> updateWorkerReservedCredit(
    String workerId,
    double newReservedCredit,
  ) async {
    try {
      await _workersCollection.doc(workerId).update({
        'reservedCredit': newReservedCredit,
      });
    } catch (e) {
      debugPrint('Error updating worker reserved credit: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // TRANSACTIONS
  // ---------------------------------------------------------------------------

  Stream<List<Transaction>> getTransactionsStream(String workerId) {
    return _transactionsCollection
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Transaction.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  Future<List<Transaction>> getTransactions(String workerId) async {
    try {
      final snapshot = await _transactionsCollection
          .where('workerId', isEqualTo: workerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        return Transaction.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      rethrow;
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _transactionsCollection
          .doc(transaction.id)
          .set(transaction.toJson());
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // ADMIN WALLET & FINANCIALS
  // ---------------------------------------------------------------------------

  // Admin Wallet Transactions
  Stream<List<WalletTransaction>> getAdminWalletTransactionsStream() {
    return _adminWalletCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return WalletTransaction.fromMap(
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  Future<void> addAdminWalletTransaction(WalletTransaction transaction) async {
    try {
      await _adminWalletCollection.doc(transaction.id).set(transaction.toMap());
    } catch (e) {
      debugPrint('Error adding admin wallet transaction: $e');
      rethrow;
    }
  }

  // Commission Records
  Stream<List<CommissionRecord>> getCommissionRecordsStream() {
    return _commissionCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CommissionRecord.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  Future<void> addCommissionRecord(CommissionRecord record) async {
    try {
      await _commissionCollection.doc(record.id).set(record.toMap());
    } catch (e) {
      debugPrint('Error adding commission record: $e');
      rethrow;
    }
  }

  // VAT Records
  Stream<List<VATRecord>> getVATRecordsStream() {
    return _vatCollection.orderBy('date', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return VATRecord.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addVATRecord(VATRecord record) async {
    try {
      await _vatCollection.doc(record.id).set(record.toMap());
    } catch (e) {
      debugPrint('Error adding VAT record: $e');
      rethrow;
    }
  }

  // Withdrawal Requests
  Stream<List<WithdrawalRequest>> getWithdrawalRequestsStream() {
    return _withdrawalCollection
        .orderBy('requestDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return WithdrawalRequest.fromMap(
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  Future<void> addWithdrawalRequest(WithdrawalRequest request) async {
    try {
      await _withdrawalCollection.doc(request.id).set(request.toMap());

      // ✅ NOTIFICATION: Notify Admin of New Withdrawal Request
      await _notificationsCollection.add({
        'title': 'New Withdrawal Request',
        'message':
            '${request.workerName} requested withdrawal of SAR ${request.amount.toStringAsFixed(2)}',
        'type': 'finance',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'targetUserIds': ['admin'],
        'relatedId': request.id,
      });
    } catch (e) {
      debugPrint('Error adding withdrawal request: $e');
      rethrow;
    }
  }

  Future<void> updateWithdrawalRequest(WithdrawalRequest request) async {
    try {
      await _withdrawalCollection.doc(request.id).update(request.toMap());
    } catch (e) {
      debugPrint('Error updating withdrawal request: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // CREDIT REQUESTS (Top-up)
  // ---------------------------------------------------------------------------

  Stream<List<CreditRequest>> getCreditRequestsStream({String? status}) {
    Query query = _creditRequestsCollection.orderBy(
      'requestDate',
      descending: true,
    );
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure ID is set
        if (data['id'] == null || data['id'].isEmpty) {
          data['id'] = doc.id;
        }
        return CreditRequest.fromJson(data);
      }).toList();
    });
  }

  Future<void> createCreditRequest(CreditRequest request) async {
    try {
      await _creditRequestsCollection.doc(request.id).set(request.toJson());

      // Notify Admin
      await _notificationsCollection.add({
        'title': 'New Credit Request',
        'message':
            '${request.workerName} requested credit of SAR ${request.amount}',
        'type': 'finance',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'targetUserIds': ['admin'],
        'relatedId': request.id,
      });
    } catch (e) {
      debugPrint('Error creating credit request: $e');
      rethrow;
    }
  }

  Future<void> updateCreditRequestStatus(
    String requestId,
    String status, {
    String? notes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'processedDate': DateTime.now().toIso8601String(),
      };
      if (notes != null) {
        updates['adminNotes'] = notes;
      }
      await _creditRequestsCollection.doc(requestId).update(updates);
    } catch (e) {
      debugPrint('Error updating credit request status: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // SERVICE CATEGORIES
  // ---------------------------------------------------------------------------

  Stream<List<ServiceCategory>> getServiceCategoriesStream() {
    return _categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceCategory.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addServiceCategory(ServiceCategory category) async {
    try {
      await _categoriesCollection.doc(category.id).set(category.toMap());
    } catch (e) {
      debugPrint('Error adding service category: $e');
      rethrow;
    }
  }

  Future<void> updateServiceCategory(ServiceCategory category) async {
    try {
      await _categoriesCollection.doc(category.id).update(category.toMap());
    } catch (e) {
      debugPrint('Error updating service category: $e');
      rethrow;
    }
  }

  Future<void> deleteServiceCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      debugPrint('Error deleting service category: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // CUSTOMERS
  // ---------------------------------------------------------------------------

  Stream<List<Customer>> getCustomersStream() {
    return _customersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Customer.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      await _customersCollection.doc(customer.id).set(customer.toMap());
    } catch (e) {
      debugPrint('Error adding customer: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // INVOICES
  // ---------------------------------------------------------------------------

  Stream<List<ServiceInvoice>> getInvoicesStream() {
    return _invoicesCollection
        .orderBy('completionDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ServiceInvoice.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  Future<void> addInvoice(ServiceInvoice invoice) async {
    try {
      await _invoicesCollection.doc(invoice.invoiceNumber).set(invoice.toMap());
    } catch (e) {
      debugPrint('Error adding invoice: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // OFFERED SERVICES (CATALOGUE)
  // ---------------------------------------------------------------------------

  Stream<List<Service>> getOfferedServicesStream() {
    return _offeredServicesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Service.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addOfferedService(Service service) async {
    try {
      await _offeredServicesCollection.doc(service.id).set(service.toMap());

      // ✅ NOTIFICATION: Notify Admin of New Offered Service Addition
      await _notificationsCollection.add({
        'title': 'New Service Added to Catalog',
        'message':
            'New service "${service.name}" has been added to the offered services.',
        'type': 'system',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'targetUserIds': ['admin'],
        'relatedId': service.id,
      });
    } catch (e) {
      debugPrint('Error adding offered service: $e');
      rethrow;
    }
  }

  Future<void> updateOfferedService(Service service) async {
    try {
      await _offeredServicesCollection.doc(service.id).update(service.toMap());
    } catch (e) {
      debugPrint('Error updating offered service: $e');
      rethrow;
    }
  }

  Future<void> deleteOfferedService(String serviceId) async {
    try {
      await _offeredServicesCollection.doc(serviceId).delete();
    } catch (e) {
      debugPrint('Error deleting offered service: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // REVIEWS
  // ---------------------------------------------------------------------------

  Stream<List<Review>> getReviewsStream() {
    return _reviewsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Ensure ID is set
            if (data['id'] == null || data['id'].isEmpty) {
              data['id'] = doc.id;
            }
            return Review.fromMap(data);
          }).toList();
        });
  }

  Future<void> addReview(Review review) async {
    try {
      await _reviewsCollection.doc(review.id).set(review.toMap());

      // ✅ NOTIFICATION: Notify Admin and Worker
      // This technically belongs in a service layer, but for simplicity we add it here
      // or rely on a Cloud Function. Since we are doing "In-App", we call NotificationService.
      // However, FirestoreService shouldn't depend on NotificationService to avoid circular deps if possible.
      // But typically NotificationService depends on FirestoreService.
      // CHECK DEPENDENCY: NotificationService imports FirestoreService.
      // FirestoreService importing NotificationService -> Circular.

      // SOLUTION: We should NOT add the notification trigger HERE if it causes circular dependency.
      // We should add it in the Service/Provider that CALLS addReview.
      // But we don't have the caller (Customer App).

      // ALTERNATIVE: Use a callback or simply rely on the user adding this code to Customer App.
      // Or, since Dart allows circular imports sometimes if carefully managed? No, bad practice.

      // Let's check imports. NotificationService uses FirestoreService.
      // So FirestoreService CANNOT import NotificationService.

      // I will ADD the method, but I cannot add the NotificationService call here directly without refactoring.
      // Actually, I can use a mixin or just duplicate the "add notification" firestore write here?
      // "In-App" notification is just writing to 'notifications' collection.
      // FirestoreService HAS access to firestore.

      await _notificationsCollection.add({
        'title': 'New Review Received',
        'message':
            'New review for ${review.serviceName}: ${review.rating} stars',
        'type': 'review',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'targetUserIds': [
          'admin',
        ], // Notify Admin Only (User Request: Worker only gets Assignment/Withdrawal)
        'relatedId': review.id,
      });
    } catch (e) {
      debugPrint('Error adding review: $e');
      rethrow;
    }
  }

  // Need to expose notifications collection getter if not exists
  CollectionReference get _notificationsCollection =>
      _firestore.collection('notifications');

  // ---------------------------------------------------------------------------
  // CHAT
  // ---------------------------------------------------------------------------

  CollectionReference get _chatsCollection => _firestore.collection('chats');

  // ---------------------------------------------------------------------------
  // CHAT
  // ---------------------------------------------------------------------------

  Stream<List<ChatMessage>> getChatMessagesStream(String serviceRequestId) {
    debugPrint(
      'Fetching messages for service: $serviceRequestId from chats collection',
    );
    return _chatsCollection
        .doc(serviceRequestId)
        .collection('messages')
        // Removed server-side orderBy to avoid index issues and field name mismatches
        .snapshots()
        .map((snapshot) {
          debugPrint('Transactions found: ${snapshot.docs.length}');
          final messages = snapshot.docs.map((doc) {
            final data = doc.data();
            debugPrint('Message data: $data');
            if (data['id'] == null || data['id'].isEmpty) {
              data['id'] = doc.id;
            }
            return ChatMessage.fromMap(data);
          }).toList();

          // Sort client-side
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return messages;
        });
  }

  Future<void> sendMessage(String serviceRequestId, ChatMessage message) async {
    try {
      debugPrint(
        'Attempting to send message to chats/$serviceRequestId/messages/${message.id}',
      );
      debugPrint('Message content: ${message.toMap()}');

      await _chatsCollection
          .doc(serviceRequestId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      debugPrint('Message sent successfully!');

      debugPrint('Message sent successfully!');

      // ✅ Notification Logic: Notify the recipient(s)
      try {
        final serviceDoc = await _servicesCollection
            .doc(serviceRequestId)
            .get();

        if (serviceDoc.exists) {
          final data = serviceDoc.data() as Map<String, dynamic>;
          final workerId = data['workerId'];
          final customerId = data['customerId'];

          // 1. Notify Worker (if sender is NOT worker)
          if (message.role != 'worker' && workerId != null) {
            await _notificationsCollection.add({
              'title': 'New Message • رسالة جديدة',
              'message': '${message.senderName}: ${message.message}',
              'type': 'chat',
              'timestamp': FieldValue.serverTimestamp(),
              'isRead': false,
              'targetUserIds': [workerId],
              'relatedId': serviceRequestId,
            });
            debugPrint('✅ Chat notification sent to worker: $workerId');
          }

          // 2. Notify Customer (if sender is NOT customer)
          if (message.role != 'customer' && customerId != null) {
            await _notificationsCollection.add({
              'title': 'New Message • رسالة جديدة',
              'message': '${message.senderName}: ${message.message}',
              'type': 'chat',
              'timestamp': FieldValue.serverTimestamp(),
              'isRead': false,
              'targetUserIds': [customerId],
              'relatedId': serviceRequestId,
            });
            debugPrint('✅ Chat notification sent to customer: $customerId');
          }
        }
      } catch (nError) {
        debugPrint('⚠️ Error sending chat notification: $nError');
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // DATA SEEDING (One-time use)
  // ---------------------------------------------------------------------------

  // ✅ New Method: wipe clean
  Future<void> clearServiceCatalogue() async {
    try {
      // Delete all categories
      final catSnapshot = await _categoriesCollection.get();
      for (var doc in catSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all services
      final srvSnapshot = await _offeredServicesCollection.get();
      for (var doc in srvSnapshot.docs) {
        await doc.reference.delete();
      }
      debugPrint('✅ Service Catalogue Cleared');
    } catch (e) {
      debugPrint('Error clearing catalogue: $e');
      rethrow;
    }
  }
}
