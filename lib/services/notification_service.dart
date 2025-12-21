import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firestore_service.dart';

// Top-level function for background handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // If you need to access other Firebase services here, you must initialize App again
  // await Firebase.initializeApp();
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    print("FCM Token: $token");
    // Token is saved when user logs in via updateUserToken
  }

  // ✅ Call this after Login
  Future<void> updateUserToken(String userId, String role) async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await FirestoreService().saveFcmToken(userId, token, role);
      print("FCM Token updated for $userId ($role)");
    }
  }

  // Need to use existing firestore reference but cast it if needed, or better, use FirestoreService singleton
  // But wait, _firestore is defined as `FirebaseFirestore.instance` in this class (line 24).
  // I need to use the `FirestoreService` class I just modified.

  // So I will change _firestore usage in this method to use FirestoreService()
  // OR add FirestoreService instance to this class.

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

    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings can be added here
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle local notification tap
        print("Local Notification Tapped: ${response.payload}");
        // Navigate to specific screen based on payload
      },
    );
  }

  void _setupMessageHandlers() {
    // Foreground Message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }

      // Save to Firestore so it appears in the In-App Notification Screen
      _saveNotificationToFirestore(message);
    });

    // Background/Terminated Tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Navigate to specific screen
    });

    // Check if app was opened from a terminated state
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state by notification');
        // Handle navigation
      }
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // id
            'High Importance Notifications', // title
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      // Assuming 'notifications' collection. You might want to restructure this
      // based on recipient (userID).
      await _firestore.collection('notifications').add({
        'title': message.notification?.title ?? 'No Title',
        'message': message.notification?.body ?? 'No Body',
        'type': message.data['type'] ?? 'general',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': message.data,
        // You might want to add 'userId' here if the message data contains it
      });
    } catch (e) {
      print("Error saving notification to Firestore: $e");
    }
  }

  // Helper to send notification (Data creation part - typically for Admin use or testing)
  // Real sending happens via Firebase Cloud Functions or backend
  Future<void> createNotificationInFirestore({
    required String title,
    required String body,
    required String type,
    List<String>? targetUserIds, // 'All' or specific IDs
  }) async {
    await sendNotification(
      title: title,
      body: body,
      type: type,
      targetUserIds: targetUserIds,
    );
  }

  // Generalized method for all parts of the app to use
  Future<void> sendNotification({
    required String title,
    required String body,
    required String
    type, // 'service', 'payment', 'system', 'reminder', 'warning', 'review'
    List<String>? targetUserIds, // List of IDs or ['All']
    String? relatedId, // ServiceRequestId, TransactionId, etc.
  }) async {
    try {
      if (targetUserIds == null || targetUserIds.isEmpty) {
        // If no target, maybe default to admin or log warning
        print("Warning: Notification has no target users: $title");
        return;
      }

      // For each target user (or once if 'All'), create a document
      // Current design: One doc per notification? Or one doc per user?
      // If 'All', we need a way for all users to see it.
      // Typically 'All' is a broadcast.
      // If specific ID, it's personal.

      // We will create ONE document, but with a 'targetUserIds' field.
      // The receiving end (Worker/Admin) must filter by this field.

      await _firestore.collection('notifications').add({
        'title': title,
        'message': body,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'targetUserIds': targetUserIds,
        'relatedId': relatedId,
      });

      print("Notification sent: $title to $targetUserIds");
    } catch (e) {
      print("Error creating notification: $e");
    }
  }
}
