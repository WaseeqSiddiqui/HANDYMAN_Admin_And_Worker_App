import 'service_request_model.dart';

class ServiceInvoice {
  final String invoiceNumber;
  final String serviceRequestId;
  final String serviceId;
  final String serviceName;
  final String customerId;
  final String customerName;
  final String customerAddress;
  final String? workerId;
  final String workerName;
  final double basePrice;
  final double extraCharges;
  final List<ExtraItem> extraItems;
  final double totalAmount;
  final double vat;
  final double commission;
  final DateTime completionDate;
  final String paymentMethod;
  final String status;

  ServiceInvoice({
    required this.invoiceNumber,
    required this.serviceRequestId,
    required this.serviceId,
    required this.serviceName,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    this.workerId,
    required this.workerName,
    required this.basePrice,
    required this.extraCharges,
    required this.extraItems,
    required this.totalAmount,
    required this.vat,
    required this.commission,
    required this.completionDate,
    required this.paymentMethod,
    required this.status,
  });

  factory ServiceInvoice.fromServiceRequest(ServiceRequest req) {
    final totalExtra = req.extraItems.fold(0.0, (sum, e) => sum + e.price);
    final subtotal = req.basePrice + totalExtra;

    return ServiceInvoice(
      invoiceNumber: "INV-${DateTime.now().millisecondsSinceEpoch}",
      serviceRequestId: req.id,
      serviceId: req.serviceId,
      serviceName: req.serviceName,
      customerId: req.customerId,
      customerName: req.customerName,
      customerAddress: req.address,
      workerId: req.workerId,
      workerName: req.workerName ?? "--",
      basePrice: req.basePrice,
      extraCharges: totalExtra,
      extraItems: req.extraItems,
      vat: req.totalVAT,
      commission: req.totalCommission,
      totalAmount: req.totalPrice,
      completionDate: req.completedDate ?? DateTime.now(),
      paymentMethod: req.paymentMethod?.name ?? "unknown",
      status: "Paid",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'serviceRequestId': serviceRequestId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'customerId': customerId,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'workerId': workerId,
      'workerName': workerName,
      'basePrice': basePrice,
      'extraCharges': extraCharges,
      'extraItems': extraItems.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'vat': vat,
      'commission': commission,
      'completionDate': completionDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'status': status,
    };
  }

  factory ServiceInvoice.fromMap(Map<String, dynamic> map) {
    return ServiceInvoice(
      invoiceNumber: map['invoiceNumber'] ?? '',
      serviceRequestId: map['serviceRequestId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      workerId: map['workerId'],
      workerName: map['workerName'] ?? '',
      basePrice: (map['basePrice'] ?? 0.0).toDouble(),
      extraCharges: (map['extraCharges'] ?? 0.0).toDouble(),
      extraItems: List<ExtraItem>.from(
        (map['extraItems'] as List? ?? []).map((x) => ExtraItem.fromJson(x)),
      ),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      vat: (map['vat'] ?? 0.0).toDouble(),
      commission: (map['commission'] ?? 0.0).toDouble(),
      completionDate: DateTime.parse(map['completionDate']),
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? '',
    );
  }
}
