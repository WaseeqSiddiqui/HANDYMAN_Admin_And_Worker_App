import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Top-level function for background handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  await Firebase.initializeApp();

  // Show local notification for background messages if they are data-only
  if (message.notification == null) {
    debugPrint('Message is data-only. Showing local notification.');
    final FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await localNotifications.initialize(initializationSettings);

    await localNotifications.show(
      message.hashCode,
      message.data['title'] ?? 'New Notification',
      message.data['message'] ??
          message.data['body'] ??
          'You have a new message',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ NEW: Direct Firestore Listener (Bypasses Cloud Functions/FCM for active app)
  StreamSubscription? _notificationSubscription;

  Future<void> initialize() async {
    // 1. Request Permissions
    await _requestPermission();

    // 2. Setup Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Initialize Local Notifications (for foreground display)
    await _initLocalNotifications();

    // 4. Setup Message Handlers
    _setupMessageHandlers();

    // 5. Get and Save Token
    String? token = await _firebaseMessaging.getToken();
    debugPrint("FCM Token: $token");
    // Token is saved when user logs in via updateUserToken
  }

  // ✅ Call this after Login
  Future<void> updateUserToken(String userId, String role) async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      // Direct write to avoid circular dependency with FirestoreService if it exists
      await _saveTokenToFirestore(userId, token, role);
      debugPrint("FCM Token updated for $userId ($role)");
    }
  }

  Future<void> _saveTokenToFirestore(
    String userId,
    String token,
    String role,
  ) async {
    try {
      if (role == 'worker') {
        await _firestore.collection('workers').doc(userId).update({
          'fcmToken': token,
        });
      } else if (role == 'admin') {
        await _firestore.collection('admins').doc(userId).set({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else if (role == 'customer') {
        await _firestore.collection('customers').doc(userId).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      debugPrint("Error saving token: $e");
    }
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Local Notification Tapped: ${response.payload}");
        // Navigate to specific screen based on payload
      },
    );

    // Create channel for Android
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidImplementation?.createNotificationChannel(
        const AndroidNotificationChannel(
          'high_importance_channel', // id
          'High Importance Notifications', // title
          description: 'This channel is used for important notifications.',
          importance: Importance.max,
        ),
      );
    }
  }

  void _setupMessageHandlers() {
    // Foreground Message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');

      if (message.notification != null) {
        _showLocalNotification(message);
      } else {
        _showLocalNotification(message);
      }
      _saveNotificationToFirestore(message);
    });

    // Background/Terminated Tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
    });

    // App opened from terminated state
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state by notification');
      }
    });
  }

  // ✅ Manual Firestore Listener Logic
  void startListeningToNotifications(String userId) {
    if (_notificationSubscription != null) return;

    debugPrint(
      "🔥 [NotificationService] STARTING LISTENER for userId: $userId",
    );

    // Helper to ignore initial load
    bool isInitialSnapshot = true;
    debugPrint("📥 [NotificationService] Listener initialized for $userId");

    // ✅ Listen for Specific User, All users, or Role-based groups
    _notificationSubscription = _firestore
        .collection('notifications')
        .where(
          'targetUserIds',
          arrayContainsAny: [
            userId,
            'All',
            'Workers',
            'workers',
            'Customers', // In case we reuse for customers
            'customers',
          ],
        )
        // ✅ REMOVED orderBy/limit to avoid "Missing Index" errors
        .snapshots()
        .listen(
          (snapshot) {
            debugPrint(
              "🔥 [NotificationService] Snapshot received! Docs: ${snapshot.docs.length}",
            );

            // 1. Skip the first batch of documents (existing history)
            if (isInitialSnapshot) {
              isInitialSnapshot = false;
              debugPrint(
                "📥 [NotificationService] Initial snapshot ignored for $userId (${snapshot.docs.length} docs)",
              );
              return;
            }

            // 2. Process only new additions
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final data = change.doc.data();
                if (data == null) continue;

                debugPrint(
                  "🔔 [NotificationService] LIVE NOTIFICATION: ${data['title']} for $userId",
                );

                _showLocalNotificationPayload(
                  data['title'] ?? 'New Notification',
                  data['message'] ?? 'You have a new update',
                  data.toString(),
                );
              }
            }
          },
          onError: (e) {
            debugPrint("❌ [NotificationService] LISTENER ERROR: $e");
          },
        );
  }

  void stopListening() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showLocalNotificationPayload(title, body, payload ?? '');
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    String title =
        notification?.title ?? message.data['title'] ?? 'New Notification';
    String body =
        notification?.body ??
        message.data['message'] ??
        message.data['body'] ??
        '';

    if (title.isNotEmpty || body.isNotEmpty) {
      await _showLocalNotificationPayload(title, body, message.data.toString());
    }
  }

  Future<void> _showLocalNotificationPayload(
    String title,
    String body,
    String payload,
  ) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: payload,
    );
  }

  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      await _firestore.collection('notifications').add({
        'title':
            message.notification?.title ?? message.data['title'] ?? 'No Title',
        'message':
            message.notification?.body ?? message.data['message'] ?? 'No Body',
        'type': message.data['type'] ?? 'general',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': message.data,
      });
    } catch (e) {
      debugPrint("Error saving notification to Firestore: $e");
    }
  }

  // Helper to send notification
  Future<void> createNotificationInFirestore({
    required String title,
    required String body,
    required String type,
    List<String>? targetUserIds,
  }) async {
    await sendNotification(
      title: title,
      body: body,
      type: type,
      targetUserIds: targetUserIds,
    );
  }

  // Generalized method
  Future<void> sendNotification({
    required String title,
    required String body,
    required String type,
    List<String>? targetUserIds,
    String? relatedId,
  }) async {
    try {
      if (targetUserIds == null || targetUserIds.isEmpty) {
        return;
      }

      await _firestore.collection('notifications').add({
        'title': title,
        'message': body,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'targetUserIds': targetUserIds,
        'relatedId': relatedId,
      });

      debugPrint(
        "✅ Notification WRITTEN to Firestore: $title to $targetUserIds",
      );
    } catch (e) {
      debugPrint("❌ Error creating notification in Firestore: $e");
    }
  }

  // 🔥 TEST METHOD
  Future<void> showTestNotification() async {
    debugPrint("Showing test notification...");
    await _showLocalNotificationPayload(
      'Test Notification',
      'This is a test notification to verify system tray display.',
      'test_payload',
    );
  }
}
