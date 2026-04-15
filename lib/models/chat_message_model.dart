import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String role; // 'customer' or 'worker'
  final String message;
  final String type; // 'text' or 'location'
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.role,
    required this.message,
    this.type = 'text',
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    // Try multiple possible field names for timestamp
    final timestamp =
        map['timestamp'] ?? map['createdAt'] ?? map['time'] ?? map['date'];

    // Try multiple possible field names for message content
    final content =
        map['message'] ?? map['text'] ?? map['content'] ?? map['msg'] ?? '';

    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      role: map['role'] ?? '', // Expect 'customer' or 'worker'
      message: content,
      type: map['type'] ?? 'text',
      timestamp: parseDate(timestamp),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'role': role,
      'message': message,
      'type': type,
      'text': message, // Redundant field for compatibility
      'content': message, // Redundant field for compatibility
      'msg': message, // Redundant field for compatibility
      'timestamp': Timestamp.fromDate(timestamp),
      'createdAt': Timestamp.fromDate(timestamp), // Redundant timestamp
      'date': Timestamp.fromDate(timestamp), // Redundant timestamp
    };
  }
}
