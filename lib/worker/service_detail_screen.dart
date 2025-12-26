import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/providers/app_state_provider.dart';
import '/models/service_request_model.dart';
import '/models/service_invoice_model.dart';
import '/services/invoice_service.dart';
import 'add_extra_items_screen.dart';
import 'generate_invoice_screen.dart';
import 'credit_screen.dart';
import '/utils/worker_translations.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceRequest service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  String _formatDateTime(DateTime dateTime, String time) {
    try {
      final date = DateFormat('MMM dd, yyyy').format(dateTime);
      return '$date • $time';
    } catch (e) {
      return WorkerTranslations.getBilingual('N/A', 'غير متوفر');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final service =
            appState.getServiceById(widget.service.id) ?? widget.service;

        final invoiceService = InvoiceService();
        final invoice = invoiceService.getInvoiceByServiceId(service.id);
        final hasInvoice = invoice != null;

        final totalPrice = service.totalPrice;
        final commission = service.totalCommission;
        final vat = service.totalVAT;
        final requiredCredit = service.totalDeduction;
        final workerEarnings = totalPrice - requiredCredit;
        final hasEnoughCredit = appState.hasEnoughCredit(service);

        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, true);
            return false;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service.serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    service.customerName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, true),
              ),
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCustomerInfo(service),
                                const SizedBox(height: 12),
                                _buildPriceBreakdown(
                                  service,
                                  totalPrice,
                                  commission,
                                  vat,
                                  workerEarnings,
                                ),

                                if (service.status !=
                                    ServiceRequestStatus.completed) ...[
                                  const SizedBox(height: 12),
                                  _buildCreditValidation(
                                    appState,
                                    requiredCredit,
                                    hasEnoughCredit,
                                  ),
                                ],

                                if (service.status ==
                                    ServiceRequestStatus.inProgress) ...[
                                  const SizedBox(height: 12),
                                  _buildInvoiceStatus(hasInvoice, invoice),
                                ],

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),

                        // Fixed bottom action buttons
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            child: _buildActionButtons(
                              context,
                              appState,
                              service,
                              hasEnoughCredit,
                              requiredCredit,
                              hasInvoice,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildInvoiceStatus(bool hasInvoice, ServiceInvoice? invoice) {
    return Card(
      elevation: 3,
      color: hasInvoice ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasInvoice ? Icons.check_circle : Icons.receipt_long,
                  color: hasInvoice ? Colors.green[700] : Colors.orange[800],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WorkerTranslations.getEnglish(
                          hasInvoice
                              ? WorkerTranslations.invoiceGenerated
                              : WorkerTranslations.invoiceRequired,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: hasInvoice
                              ? Colors.green[800]
                              : Colors.orange[900],
                        ),
                      ),
                      Text(
                        WorkerTranslations.getArabic(
                          hasInvoice
                              ? WorkerTranslations.invoiceGenerated
                              : WorkerTranslations.invoiceRequired,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: hasInvoice
                              ? Colors.green[800]
                              : Colors.orange[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (hasInvoice && invoice != null) ...[
              const SizedBox(height: 12),
              _buildInvoiceDetailRow(
                WorkerTranslations.invoiceNumber,
                invoice.invoiceNumber,
                Colors.green[700]!,
              ),
              const SizedBox(height: 6),
              _buildInvoiceDetailRow(
                WorkerTranslations.paymentMethodLabel,
                invoice.paymentMethod == 'unknown'
                    ? WorkerTranslations.notSet
                    : invoice.paymentMethod,
                invoice.paymentMethod == 'unknown'
                    ? Colors.orange[800]!
                    : Colors.green[700]!,
                icon: invoice.paymentMethod == 'Cash'
                    ? Icons.money
                    : Icons.account_balance,
              ),
              if (invoice.paymentMethod == 'STC/Bank') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.lightBlueAccent,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin STC Account: ${InvoiceService.ADMIN_STC_ACCOUNT}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.lightBlueAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'حساب STC الإداري: ${InvoiceService.ADMIN_STC_ACCOUNT}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 6),
              _buildInvoiceDetailRow(
                WorkerTranslations.totalAmount,
                'SAR ${invoice.totalAmount.toStringAsFixed(2)}',
                Colors.green[700]!,
              ),
            ] else ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[800],
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WorkerTranslations.getEnglish(
                              WorkerTranslations.mustGenerateInvoice,
                            ),
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            WorkerTranslations.getArabic(
                              WorkerTranslations.mustGenerateInvoice,
                            ),
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetailRow(
    String label,
    String value,
    Color color, {
    IconData? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              WorkerTranslations.getEnglish(label),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            Text(
              WorkerTranslations.getArabic(label),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(ServiceRequest service) {
    return Card(
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF005DFF), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WorkerTranslations.getEnglish(
                          WorkerTranslations.customer,
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        WorkerTranslations.getArabic(
                          WorkerTranslations.customer,
                        ),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16, color: Colors.grey),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF005DFF),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WorkerTranslations.getEnglish(
                          WorkerTranslations.address,
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        WorkerTranslations.getArabic(
                          WorkerTranslations.address,
                        ),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.address,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16, color: Colors.grey),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF005DFF),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WorkerTranslations.getEnglish(
                          WorkerTranslations.dateTime,
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        WorkerTranslations.getArabic(
                          WorkerTranslations.dateTime,
                        ),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(service.requestedDate, service.requestedTime),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(
    ServiceRequest service,
    double totalPrice,
    double commission,
    double vat,
    double workerEarnings,
  ) {
    final basePrice = service.basePrice;
    final extraCharges = service.totalExtraPrice;
    final extraItems = service.extraItems;

    return Card(
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WorkerTranslations.getEnglish(
                    WorkerTranslations.priceBreakdown,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  WorkerTranslations.getArabic(
                    WorkerTranslations.priceBreakdown,
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 12),
            _buildRow(WorkerTranslations.basePrice, basePrice),

            if (extraItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    WorkerTranslations.getEnglish(
                      WorkerTranslations.extraItems,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    WorkerTranslations.getArabic(WorkerTranslations.extraItems),
                    style: const TextStyle(fontSize: 11, color: Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...extraItems
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  item.type == 'Service'
                                      ? Icons.build
                                      : Icons.inventory,
                                  size: 14,
                                  color: item.type == 'Service'
                                      ? Colors.blue
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${item.name} (${item.type})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SAR ${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WorkerTranslations.getEnglish(
                              WorkerTranslations.totalExtraCharges,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.orange,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            WorkerTranslations.getArabic(
                              WorkerTranslations.totalExtraCharges,
                            ),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SAR ${extraCharges.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 12),
            _buildRow(
              WorkerTranslations.total,
              totalPrice,
              isBold: true,
              color: const Color(0xFF005DFF),
              fontSize: 16,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WorkerTranslations.getEnglish(
                              WorkerTranslations.commissionDeduction,
                            ),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            WorkerTranslations.getArabic(
                              WorkerTranslations.commissionDeduction,
                            ),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'SAR ${commission.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WorkerTranslations.getEnglish(
                              WorkerTranslations.vatDeduction,
                            ),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            WorkerTranslations.getArabic(
                              WorkerTranslations.vatDeduction,
                            ),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'SAR ${vat.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WorkerTranslations.getEnglish(
                          WorkerTranslations.workerEarnings,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        WorkerTranslations.getArabic(
                          WorkerTranslations.workerEarnings,
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'SAR ${workerEarnings.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    double value, {
    bool isBold = false,
    Color? color,
    double? fontSize,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                WorkerTranslations.getEnglish(label),
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? Colors.grey[700],
                  fontSize: fontSize != null ? fontSize - 2 : 12,
                ),
              ),
              Text(
                WorkerTranslations.getArabic(label),
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? Colors.grey[700],
                  fontSize: fontSize != null ? fontSize - 4 : 10,
                ),
              ),
            ],
          ),
          Text(
            'SAR ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.black,
              fontSize: fontSize ?? 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditValidation(
    AppStateProvider appState,
    double requiredCredit,
    bool hasEnoughCredit,
  ) {
    final hasInsufficientCredit = !hasEnoughCredit;

    return Card(
      elevation: 3,
      color: hasInsufficientCredit ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  hasInsufficientCredit ? Icons.warning : Icons.check_circle,
                  color: hasInsufficientCredit ? Colors.red : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WorkerTranslations.getEnglish(
                          hasInsufficientCredit
                              ? WorkerTranslations.insufficientCredit
                              : WorkerTranslations.creditValidation,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: hasInsufficientCredit
                              ? Colors.red
                              : Colors.green[800],
                        ),
                      ),
                      Text(
                        WorkerTranslations.getArabic(
                          hasInsufficientCredit
                              ? WorkerTranslations.insufficientCredit
                              : WorkerTranslations.creditValidation,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: hasInsufficientCredit
                              ? Colors.red
                              : Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      WorkerTranslations.getEnglish(
                        WorkerTranslations.requiredCredit,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      WorkerTranslations.getArabic(
                        WorkerTranslations.requiredCredit,
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  'SAR ${requiredCredit.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      WorkerTranslations.getEnglish(
                        WorkerTranslations.currentCredit,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      WorkerTranslations.getArabic(
                        WorkerTranslations.currentCredit,
                      ),
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
                Text(
                  'SAR ${appState.creditBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
            if (hasInsufficientCredit) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Shortfall• النقص: SAR ${(requiredCredit - appState.creditBalance).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppStateProvider appState,
    ServiceRequest service,
    bool hasEnoughCredit,
    double requiredCredit,
    bool hasInvoice,
  ) {
    if (service.status == ServiceRequestStatus.pending) {
      return const SizedBox.shrink();
    } else if (service.status == ServiceRequestStatus.inProgress) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addExtraItems(context, appState, service),
              icon: const Icon(Icons.add_circle, size: 18),
              label: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    WorkerTranslations.getEnglish(
                      WorkerTranslations.addExtraCharges,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    WorkerTranslations.getArabic(
                      WorkerTranslations.addExtraCharges,
                    ),
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          if (!hasInvoice) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasEnoughCredit
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GenerateInvoiceScreen(serviceId: service.id),
                        ),
                      ).then((_) => setState(() {}))
                    : null,
                icon: const Icon(Icons.receipt_long, size: 18),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      WorkerTranslations.getEnglish(
                        WorkerTranslations.generateInvoice,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      WorkerTranslations.getArabic(
                        WorkerTranslations.generateInvoice,
                      ),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005DFF),
                  minimumSize: const Size(double.infinity, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),
          ],

          if (hasInvoice) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasEnoughCredit
                    ? () => _completeService(context, appState, service)
                    : null,
                icon: const Icon(Icons.check_circle, size: 18),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      WorkerTranslations.getEnglish(
                        WorkerTranslations.markCompleted,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      WorkerTranslations.getArabic(
                        WorkerTranslations.markCompleted,
                      ),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),
          ],

          if (!hasEnoughCredit) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreditScreen()),
                ),
                icon: const Icon(Icons.add_circle, size: 18),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      WorkerTranslations.getEnglish(
                        WorkerTranslations.topUpNow,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      WorkerTranslations.getArabic(WorkerTranslations.topUpNow),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF005DFF),
                  minimumSize: const Size(double.infinity, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  side: const BorderSide(color: Color(0xFF005DFF)),
                ),
              ),
            ),
          ],
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _addExtraItems(
    BuildContext context,
    AppStateProvider appState,
    ServiceRequest service,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExtraItemsScreen(
          service: service,
          onItemsAdded: (extraCharges, extraItems) {
            appState.addExtraItems(service.id, extraItems);
          },
        ),
      ),
    );

    if (mounted) {
      setState(() {});
      final updatedService = appState.getServiceById(service.id);
      if (updatedService != null) {
        final newTotal = updatedService.totalPrice;
        final newRequired = updatedService.totalDeduction;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WorkerTranslations.getBilingual(
                    '✅ Extra items updated!',
                    '✅ تم تحديث العناصر الإضافية!',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  WorkerTranslations.getBilingual(
                    'New Total: SAR ${newTotal.toStringAsFixed(2)}',
                    'الإجمالي الجديد: ${newTotal.toStringAsFixed(2)} ريال',
                  ),
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  WorkerTranslations.getBilingual(
                    'Required Credit: SAR ${newRequired.toStringAsFixed(2)}',
                    'الرصيد المطلوب: ${newRequired.toStringAsFixed(2)} ريال',
                  ),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _completeService(
    BuildContext context,
    AppStateProvider appState,
    ServiceRequest service,
  ) async {
    final invoiceService = InvoiceService();
    final invoice = invoiceService.getInvoiceByServiceId(service.id);

    if (invoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            WorkerTranslations.getBilingual(
              '❌ Invoice not found. Please generate invoice first.',
              '❌ لم يتم العثور على الفاتورة. يرجى إنشاء الفاتورة أولاً.',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final requiredCredit = appState.getRequiredCredit(service);

    if (!appState.hasEnoughCredit(service)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      WorkerTranslations.getEnglish('Cannot Complete Service'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      WorkerTranslations.getArabic('Cannot Complete Service'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    WorkerTranslations.getEnglish(
                      'Insufficient credit to complete service.',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    WorkerTranslations.getArabic(
                      'Insufficient credit to complete service.',
                    ),
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                WorkerTranslations.getBilingual(
                  'Required: SAR ${requiredCredit.toStringAsFixed(2)}',
                  'المطلوب: ${requiredCredit.toStringAsFixed(2)} ريال',
                ),
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                WorkerTranslations.getBilingual(
                  'Available: SAR ${appState.creditBalance.toStringAsFixed(2)}',
                  'المتاح: ${appState.creditBalance.toStringAsFixed(2)} ريال',
                ),
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                'Shortfall: SAR ${(requiredCredit - appState.creditBalance).toStringAsFixed(2)} • النقص: ${(requiredCredit - appState.creditBalance).toStringAsFixed(2)} ريال',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    WorkerTranslations.getEnglish(
                      'Please top-up your credit to continue.',
                    ),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Text(
                    WorkerTranslations.getArabic(
                      'Please top-up your credit to continue.',
                    ),
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    WorkerTranslations.getEnglish(WorkerTranslations.cancelBtn),
                  ),
                  Text(
                    WorkerTranslations.getArabic(WorkerTranslations.cancelBtn),
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreditScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005DFF),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    WorkerTranslations.getEnglish(WorkerTranslations.topUpNow),
                  ),
                  Text(
                    WorkerTranslations.getArabic(WorkerTranslations.topUpNow),
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    WorkerTranslations.getEnglish('Complete Service'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    WorkerTranslations.getArabic('Complete Service'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WorkerTranslations.getEnglish(
                    'Complete service for ${service.customerName}?',
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  WorkerTranslations.getArabic(
                    'Complete service for ${service.customerName}?',
                  ),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WorkerTranslations.getEnglish('Invoice:'),
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            WorkerTranslations.getArabic('Invoice:'),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WorkerTranslations.getEnglish('Payment:'),
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            WorkerTranslations.getArabic('Payment:'),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      Text(
                        invoice.paymentMethod,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WorkerTranslations.getEnglish('Total Amount:'),
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            WorkerTranslations.getArabic('Total Amount:'),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      Text(
                        'SAR ${service.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WorkerTranslations.getEnglish('Credit Deduction:'),
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            WorkerTranslations.getArabic('Credit Deduction:'),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      Text(
                        'SAR ${requiredCredit.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.cancelBtn),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.cancelBtn),
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await appState.completeService(
                  service.id,
                  paymentMethod: invoice.paymentMethod,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WorkerTranslations.getBilingual(
                              '✅ Service completed!',
                              '✅ اكتملت الخدمة!',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            WorkerTranslations.getBilingual(
                              'Invoice: ${invoice.invoiceNumber}',
                              'الفاتورة: ${invoice.invoiceNumber}',
                            ),
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            WorkerTranslations.getBilingual(
                              'Total: SAR ${service.totalPrice.toStringAsFixed(2)}',
                              'الإجمالي: ${service.totalPrice.toStringAsFixed(2)} ريال',
                            ),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        WorkerTranslations.getBilingual(
                          '❌ Error: $e',
                          '❌ خطأ: $e',
                        ),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(WorkerTranslations.getEnglish('Complete Service')),
                Text(
                  WorkerTranslations.getArabic('Complete Service'),
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
