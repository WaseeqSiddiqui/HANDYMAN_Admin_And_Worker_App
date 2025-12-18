import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String customerName;
  final String customerId;
  final String workerName;
  final String workerId;
  final String serviceName;
  final String serviceId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String status;

  Review({
    required this.id,
    required this.customerName,
    required this.customerId,
    required this.workerName,
    required this.workerId,
    required this.serviceName,
    required this.serviceId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.status,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    return Review(
      id: map['id'] ?? '',
      customerName:
          map['customerName'] ??
          map['customer'] ??
          map['userName'] ??
          'Anonymous',
      customerId: map['customerId'] ?? '',
      workerName: map['workerName'] ?? map['worker'] ?? 'Unknown Worker',
      workerId: map['workerId'] ?? '',
      serviceName: map['serviceName'] ?? map['service'] ?? '',
      serviceId: map['serviceId'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: parseDate(map['createdAt']),
      status: map['status'] ?? 'Published',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerId': customerId,
      'workerName': workerName,
      'workerId': workerId,
      'serviceName': serviceName,
      'serviceId': serviceId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }
}
