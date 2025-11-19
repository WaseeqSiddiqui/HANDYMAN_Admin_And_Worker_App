// models/service_request_model.dart - FIXED VERSION
// ✅ VAT and Commission are NOW INCLUDED in total, not added
// ✅ All existing parameters preserved

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
  final bool invoiceGenerated;

  ServiceRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
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
    this.invoiceGenerated = false,
  });

  // ✅ FIXED CALCULATIONS - Commission and VAT are INCLUDED in total, not added

  // Total extra items price
  double get totalExtraPrice =>
      extraItems.fold(0.0, (sum, item) => sum + item.price);

  // Total service price (what customer pays)
  double get totalServicePrice => basePrice + totalExtraPrice;

  // Commission is PERCENTAGE OF total, not added to it
  double get totalCommission => totalServicePrice * commission / 100;

  // VAT is PERCENTAGE OF total, not added to it
  double get totalVAT => totalServicePrice * vat / 100;

  // ✅ Customer pays ONLY this amount
  double get totalPrice => totalServicePrice;

  // ✅ Total deduction from worker credit (Commission + VAT)
  double get totalDeduction => totalCommission + totalVAT;

  // ✅ Worker earnings (what goes to worker wallet)
  double get workerEarnings => totalPrice - totalDeduction;

  // ✅ Admin receives (Commission + VAT)
  double get adminReceives => totalDeduction;

  // Copy with method for immutability
  ServiceRequest copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? serviceId,
    String? serviceName,
    String? workerId,
    String? workerName,
    DateTime? requestedDate,
    String? requestedTime,
    String? address,
    String? customerNotes,
    ServiceRequestStatus? status,
    double? basePrice,
    double? commission,
    double? vat,
    List<ExtraItem>? extraItems,
    String? postponeReason,
    DateTime? completedDate,
    PaymentMethod? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      requestedDate: requestedDate ?? this.requestedDate,
      requestedTime: requestedTime ?? this.requestedTime,
      address: address ?? this.address,
      customerNotes: customerNotes ?? this.customerNotes,
      status: status ?? this.status,
      basePrice: basePrice ?? this.basePrice,
      commission: commission ?? this.commission,
      vat: vat ?? this.vat,
      extraItems: extraItems ?? this.extraItems,
      postponeReason: postponeReason ?? this.postponeReason,
      completedDate: completedDate ?? this.completedDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // JSON Parsing
  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      workerId: json['workerId'],
      workerName: json['workerName'],
      requestedDate: DateTime.tryParse(json['requestedDate'] ?? '') ?? DateTime.now(),
      requestedTime: json['requestedTime'] ?? '',
      address: json['address'] ?? '',
      customerNotes: json['customerNotes'],
      status: ServiceRequestStatus.values.firstWhere(
            (e) => e.toString() == 'ServiceRequestStatus.${json['status']}',
        orElse: () => ServiceRequestStatus.pending,
      ),
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 20.0).toDouble(), // Default 20%
      vat: (json['vat'] ?? 15.0).toDouble(), // Default 15%
      extraItems: (json['extraItems'] as List?)
          ?.map((e) => ExtraItem.fromJson(e))
          .toList() ??
          [],
      postponeReason: json['postponeReason'],
      completedDate: json['completedDate'] != null
          ? DateTime.tryParse(json['completedDate'])
          : null,
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
            (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
        orElse: () => PaymentMethod.cash,
      )
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'service',
      price: (json['price'] ?? 0).toDouble(),
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