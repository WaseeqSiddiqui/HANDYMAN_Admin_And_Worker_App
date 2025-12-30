import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_message_model.dart';
import 'notification_service.dart';

class ChatMonitorService {
  static final ChatMonitorService _instance = ChatMonitorService._internal();
  factory ChatMonitorService() => _instance;
  ChatMonitorService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _servicesSubscription;
  final Map<String, StreamSubscription> _chatSubscriptions = {};

  void startMonitoring(String workerId) {
    stopMonitoring(); // Clear existing
    debugPrint("🚀 [ChatMonitor] Starting monitor for worker: $workerId");

    // Listen to services where this worker is assigned and status is active
    // We filter statuses client-side or assume the query covers relevant ones if simplified
    // Using a broader query and filtering helps avoid index issues if composite indexes are missing
    _servicesSubscription = _firestore
        .collection('service_requests')
        .where('workerId', isEqualTo: workerId)
        .where('status', whereIn: ['assigned', 'accepted', 'inProgress'])
        .snapshots()
        .listen(
          (snapshot) {
            final activeServiceIds = snapshot.docs.map((doc) => doc.id).toSet();
            _syncChatListeners(activeServiceIds);
          },
          onError: (e) {
            debugPrint("❌ [ChatMonitor] Error monitoring services: $e");
          },
        );
  }

  void _syncChatListeners(Set<String> activeServiceIds) {
    // 1. Remove subscriptions for services that are no longer active
    final currentMonitoredIds = _chatSubscriptions.keys.toList();
    for (var id in currentMonitoredIds) {
      if (!activeServiceIds.contains(id)) {
        _chatSubscriptions[id]?.cancel();
        _chatSubscriptions.remove(id);
        debugPrint("Stopped monitoring chat: $id");
      }
    }

    // 2. Add subscriptions for new active services
    for (var id in activeServiceIds) {
      if (!_chatSubscriptions.containsKey(id)) {
        _chatSubscriptions[id] = _monitorChat(id);
        debugPrint("Started monitoring chat: $id");
      }
    }
  }

  StreamSubscription _monitorChat(String serviceRequestId) {
    bool isFirstSnapshot = true;

    return _firestore
        .collection('chats')
        .doc(serviceRequestId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen(
          (snapshot) {
            // Ignore the initial state (existing last message)
            if (isFirstSnapshot) {
              isFirstSnapshot = false;
              return;
            }

            if (snapshot.docs.isNotEmpty) {
              // Evaluate the new message
              try {
                // Handle document change types if needed, but since we limit(1) and order desc,
                // any new message will appear as the first doc.
                // However, snapshot includes docChanges.

                for (var change in snapshot.docChanges) {
                  if (change.type == DocumentChangeType.added) {
                    final data = change.doc.data();
                    if (data == null) continue;
                    final message = ChatMessage.fromMap(data);

                    // Alert ONLY if sender is customer
                    if (message.role == 'customer') {
                      debugPrint(
                        "🔔 [ChatMonitor] New Message from Customer: ${message.message}",
                      );
                      NotificationService().showLocalNotification(
                        title: 'New Message • رسالة جديدة',
                        body: '${message.senderName}: ${message.message}',
                        payload:
                            'chat_$serviceRequestId', // Potential Payload for navigation
                      );
                    }
                  }
                }
              } catch (e) {
                debugPrint("❌ [ChatMonitor] Error processing message: $e");
              }
            }
          },
          onError: (e) {
            debugPrint(
              "❌ [ChatMonitor] Error listening to chat $serviceRequestId: $e",
            );
          },
        );
  }

  void stopMonitoring() {
    _servicesSubscription?.cancel();
    _servicesSubscription = null;

    for (var sub in _chatSubscriptions.values) {
      sub.cancel();
    }
    _chatSubscriptions.clear();
    debugPrint("🛑 [ChatMonitor] Stopped all monitoring");
  }
}
