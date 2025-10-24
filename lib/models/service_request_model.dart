enum ServiceRequestStatus {
  pending,
  assigned,
  accepted,
  inProgress,
  completed,
  postponed,
  cancelled
}

enum PaymentMethod { cash, online }

class ServiceRequest {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String serviceId;
  final String serviceName;
  final String? workerId;
  final String? workerName;
  final DateTime requestedDate;
  final String requestedTime;
  final String address;
  final String? customerNotes;
  final ServiceRequestStatus status;
  final double basePrice;
  final double commission;
  final double vat;
  final List<ExtraItem> extraItems;
  final String? postponeReason;
  final DateTime? completedDate;
  final PaymentMethod? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.serviceId,
    required this.serviceName,
    this.workerId,
    this.workerName,
    required this.requestedDate,
    required this.requestedTime,
    required this.address,
    this.customerNotes,
    required this.status,
    required this.basePrice,
    required this.commission,
    required this.vat,
    this.extraItems = const [],
    this.postponeReason,
    this.completedDate,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalExtraPrice =>
      extraItems.fold(0, (sum, item) => sum + item.price);

  double get totalServicePrice => basePrice + totalExtraPrice;

  double get totalCommission =>
      (totalServicePrice * commission / 100);

  double get totalVAT => (totalServicePrice * vat / 100);

  double get totalPrice => totalServicePrice + totalVAT;

  double get totalDeduction => totalCommission + totalVAT;

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      workerId: json['workerId'],
      workerName: json['workerName'],
      requestedDate: DateTime.parse(json['requestedDate']),
      requestedTime: json['requestedTime'],
      address: json['address'],
      customerNotes: json['customerNotes'],
      status: ServiceRequestStatus.values.firstWhere(
            (e) => e.toString() == 'ServiceRequestStatus.${json['status']}',
      ),
      basePrice: json['basePrice'].toDouble(),
      commission: json['commission'].toDouble(),
      vat: json['vat'].toDouble(),
      extraItems: (json['extraItems'] as List?)
          ?.map((e) => ExtraItem.fromJson(e))
          .toList() ??
          [],
      postponeReason: json['postponeReason'],
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
            (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
      )
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'workerId': workerId,
      'workerName': workerName,
      'requestedDate': requestedDate.toIso8601String(),
      'requestedTime': requestedTime,
      'address': address,
      'customerNotes': customerNotes,
      'status': status.toString().split('.').last,
      'basePrice': basePrice,
      'commission': commission,
      'vat': vat,
      'extraItems': extraItems.map((e) => e.toJson()).toList(),
      'postponeReason': postponeReason,
      'completedDate': completedDate?.toIso8601String(),
      'paymentMethod': paymentMethod?.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ExtraItem {
  final String id;
  final String name;
  final String type; // 'service' or 'part'
  final double price;
  final String? description;

  ExtraItem({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.description,
  });

  factory ExtraItem.fromJson(Map<String, dynamic> json) {
    return ExtraItem(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      price: json['price'].toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'price': price,
      'description': description,
    };
  }
}