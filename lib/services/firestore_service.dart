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
      throw e;
    }
  }

  Future<void> addWorker(WorkerData worker) async {
    try {
      await _workersCollection.doc(worker.id).set(worker.toMap());
    } catch (e) {
      debugPrint('Error adding worker: $e');
      throw e;
    }
  }

  Future<void> updateWorker(WorkerData worker) async {
    try {
      await _workersCollection.doc(worker.id).update(worker.toMap());
    } catch (e) {
      debugPrint('Error updating worker: $e');
      throw e;
    }
  }

  Future<void> updateWorkerCredit(String workerId, double newCredit) async {
    try {
      await _workersCollection.doc(workerId).update({
        'creditBalance': newCredit,
      });
    } catch (e) {
      debugPrint('Error updating worker credit: $e');
      throw e;
    }
  }

  Future<void> updateWorkerWallet(String workerId, double newBalance) async {
    try {
      await _workersCollection.doc(workerId).update({
        'walletBalance': newBalance,
      });
    } catch (e) {
      debugPrint('Error updating worker wallet: $e');
      throw e;
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
      throw e;
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
      throw e;
    }
  }

  Future<void> addServiceRequest(ServiceRequest service) async {
    try {
      await _servicesCollection.doc(service.id).set(service.toJson());
    } catch (e) {
      debugPrint('Error adding service request: $e');
      throw e;
    }
  }

  Future<void> updateServiceRequest(ServiceRequest service) async {
    try {
      await _servicesCollection.doc(service.id).update(service.toJson());
    } catch (e) {
      debugPrint('Error updating service request: $e');
      throw e;
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
      throw e;
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _transactionsCollection
          .doc(transaction.id)
          .set(transaction.toJson());
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      throw e;
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
      throw e;
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
      throw e;
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
      throw e;
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
    } catch (e) {
      debugPrint('Error adding withdrawal request: $e');
      throw e;
    }
  }

  Future<void> updateWithdrawalRequest(WithdrawalRequest request) async {
    try {
      await _withdrawalCollection.doc(request.id).update(request.toMap());
    } catch (e) {
      debugPrint('Error updating withdrawal request: $e');
      throw e;
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
      throw e;
    }
  }

  Future<void> updateServiceCategory(ServiceCategory category) async {
    try {
      await _categoriesCollection.doc(category.id).update(category.toMap());
    } catch (e) {
      debugPrint('Error updating service category: $e');
      throw e;
    }
  }

  Future<void> deleteServiceCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      debugPrint('Error deleting service category: $e');
      throw e;
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
      throw e;
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
      throw e;
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
    } catch (e) {
      debugPrint('Error adding offered service: $e');
      throw e;
    }
  }

  Future<void> updateOfferedService(Service service) async {
    try {
      await _offeredServicesCollection.doc(service.id).update(service.toMap());
    } catch (e) {
      debugPrint('Error updating offered service: $e');
      throw e;
    }
  }

  Future<void> deleteOfferedService(String serviceId) async {
    try {
      await _offeredServicesCollection.doc(serviceId).delete();
    } catch (e) {
      debugPrint('Error deleting offered service: $e');
      throw e;
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
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw e;
    }
  }

  // ---------------------------------------------------------------------------
  // DATA SEEDING (One-time use)
  // ---------------------------------------------------------------------------

  Future<void> seedInitialData({
    required List<WorkerData> workers,
    required List<ServiceRequest> services,
    required List<Transaction> transactions,
    required List<ServiceCategory> categories,
    required List<Customer> customers,
    required List<Service> offeredServices,
  }) async {
    // Seeding disabled
    debugPrint('Seeding disabled.');
  }
}
