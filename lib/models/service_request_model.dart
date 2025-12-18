// models/service_request_model.dart - FIXED VERSION WITH BILINGUAL EXTRA ITEMS
import '/utils/admin_translations.dart';

enum ServiceRequestStatus {
  pending,
  assigned,
  accepted,
  inProgress,
  completed,
  postponed,
  cancelled,
}

enum PaymentMethod { cash, online }

class ServiceRequest {
  final String id;
  final String customerId;
  final String customerName; // ✅ صرف ایک language میں
  final String serviceId;
  final String serviceName;
  final String? workerId;
  final String? workerName;
  final String? workerNameArabic;
  final DateTime requestedDate;
  final String requestedTime;
  final String address; // ✅ صرف ایک language میں
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
  final String customerLanguage; // ✅ Customer کی language preference

  ServiceRequest({
    required this.id,
    required this.customerId,
    required this.customerName, // ✅ Single language name
    required this.serviceId,
    required this.serviceName,
    this.workerId,
    this.workerName,
    this.workerNameArabic,
    required this.requestedDate,
    required this.requestedTime,
    required this.address, // ✅ Single language address
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
    required this.customerLanguage, // ✅ Required field
  });

  // Check if customer prefers Arabic
  bool get customerPrefersArabic => customerLanguage == 'arabic';

  // Total extra items price
  double get totalExtraPrice =>
      extraItems.fold(0.0, (sum, item) => sum + item.price);

  // Total service price (what customer pays)
  double get totalServicePrice => basePrice + totalExtraPrice;

  // Commission is PERCENTAGE OF total, not added to it
  double get totalCommission => totalServicePrice * commission / 100;

  // VAT is PERCENTAGE OF total, not added to it
  double get totalVAT => totalServicePrice * vat / 100;

  // Customer pays ONLY this amount
  double get totalPrice => totalServicePrice;

  // Total deduction from worker credit (Commission + VAT)
  double get totalDeduction => totalCommission + totalVAT;

  // Worker earnings (what goes to worker wallet)
  double get workerEarnings => totalPrice - totalDeduction;

  // Admin receives (Commission + VAT)
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
    String? workerNameArabic, // ✅ ADDED
    DateTime? requestedDate,
    String? requestedTime,
    String? address,
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
    bool? invoiceGenerated, // ✅ Added
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      workerNameArabic: workerNameArabic ?? this.workerNameArabic,
      requestedDate: requestedDate ?? this.requestedDate,
      requestedTime: requestedTime ?? this.requestedTime,
      address: address ?? this.address,
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
      invoiceGenerated: invoiceGenerated ?? this.invoiceGenerated, // ✅ Added
      customerLanguage: customerLanguage ?? this.customerLanguage,
    );
  }

  // JSON Parsing
  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '', // ✅ Single language
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      workerId: json['workerId'],
      workerName: json['workerName'],
      workerNameArabic: json['workerNameArabic'],
      requestedDate:
          DateTime.tryParse(json['requestedDate'] ?? '') ?? DateTime.now(),
      requestedTime: json['requestedTime'] ?? '',
      address: json['address'] ?? '', // ✅ Single language
      customerNotes: json['customerNotes'],
      status: ServiceRequestStatus.values.firstWhere(
        (e) => e.toString() == 'ServiceRequestStatus.${json['status']}',
        orElse: () => ServiceRequestStatus.pending,
      ),
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 20.0).toDouble(),
      vat: (json['vat'] ?? 15.0).toDouble(),
      extraItems:
          (json['extraItems'] as List?)
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
      invoiceGenerated: json['invoiceGenerated'] ?? false, // ✅ Added
      customerLanguage: json['customerLanguage'] ?? 'english',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName, // ✅ Single language
      'serviceId': serviceId,
      'serviceName': serviceName,
      'workerId': workerId,
      'workerName': workerName,
      'workerNameArabic': workerNameArabic,
      'requestedDate': requestedDate.toIso8601String(),
      'requestedTime': requestedTime,
      'address': address, // ✅ Single language
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
      'invoiceGenerated': invoiceGenerated, // ✅ Added
      'customerLanguage': customerLanguage,
    };
  }
}

class ExtraItem {
  final String id;
  final String name; // ✅ NOW BILINGUAL: "Window Cleaning • تنظيف النوافذ"
  final String type; // 'service' or 'part'
  final double price;
  final String? description;

  ExtraItem({
    required this.id,
    required this.name, // ✅ BILINGUAL
    required this.type,
    required this.price,
    this.description,
  });

  // Get English name only
  String get nameEnglish => AdminTranslations.getEnglish(name);

  // Get Arabic name only
  String get nameArabic => AdminTranslations.getArabic(name);

  factory ExtraItem.fromJson(Map<String, dynamic> json) {
    return ExtraItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '', // ✅ BILINGUAL
      type: json['type'] ?? 'service',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name, // ✅ BILINGUAL
      'type': type,
      'price': price,
      'description': description,
    };
  }
}
