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

  Review copyWith({
    String? id,
    String? customerName,
    String? customerId,
    String? workerName,
    String? workerId,
    String? serviceName,
    String? serviceId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? status,
  }) {
    return Review(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerId: customerId ?? this.customerId,
      workerName: workerName ?? this.workerName,
      workerId: workerId ?? this.workerId,
      serviceName: serviceName ?? this.serviceName,
      serviceId: serviceId ?? this.serviceId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
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
