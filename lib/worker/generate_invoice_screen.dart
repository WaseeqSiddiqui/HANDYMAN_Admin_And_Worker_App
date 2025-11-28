import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/app_state_provider.dart';
import '/models/service_request_model.dart';
import '/services/invoice_service.dart';
import '/models/service_invoice_model.dart';
import '/utils/worker_translations.dart';

class GenerateInvoiceScreen extends StatefulWidget {
  final String serviceId;

  const GenerateInvoiceScreen({super.key, required this.serviceId});

  @override
  State<GenerateInvoiceScreen> createState() => _GenerateInvoiceScreenState();
}

class _GenerateInvoiceScreenState extends State<GenerateInvoiceScreen> {
  String _paymentMethod = 'Cash';
  bool _isGenerating = false;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final service = appState.getServiceById(widget.serviceId);

        if (service == null) {
          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    WorkerTranslations.getEnglish(WorkerTranslations.generateInvoice),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    WorkerTranslations.getArabic(WorkerTranslations.generateInvoice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF005DFF),
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('Service not found'),
            ),
          );
        }

        final basePrice = service.basePrice;
        final extraCharges = service.totalExtraPrice;
        final total = service.totalServicePrice;
        final commission = service.totalCommission;
        final vat = service.totalVAT;
        final workerPayment = service.totalDeduction;
        final workerEarnings = total - workerPayment;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.generateInvoice),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.generateInvoice),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildServiceInfo(service),
                        const SizedBox(height: 16),
                        _buildCustomerInfo(service),
                        const SizedBox(height: 16),
                        _buildInvoiceSummary(
                            basePrice, extraCharges, total, service.extraItems),
                        const SizedBox(height: 16),
                        _buildWorkerPaymentInfo(
                            commission, vat, workerPayment, workerEarnings),
                        const SizedBox(height: 16),
                        _buildPaymentMethodSelection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Fixed bottom section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isGenerating
                              ? null
                              : () => _generateInvoice(appState, service),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005DFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isGenerating
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                WorkerTranslations.getEnglish(WorkerTranslations.generateInvoice),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                WorkerTranslations.getArabic(WorkerTranslations.generateInvoice),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                WorkerTranslations.afterGeneratingInvoice,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceInfo(ServiceRequest service) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.serviceDetails),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.serviceDetails),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(WorkerTranslations.serviceId, service.id),
            _buildInfoRow(WorkerTranslations.service, service.serviceName),
            _buildInfoRow(WorkerTranslations.status, service.status
                .toString()
                .split('.')
                .last),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(ServiceRequest service) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.customerInformation),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.customerInformation),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(WorkerTranslations.name, service.customerName),
            _buildInfoRow(WorkerTranslations.address, service.address),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WorkerTranslations.getEnglish(label),
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 12),
                ),
                Text(
                  WorkerTranslations.getArabic(label),
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSummary(double basePrice, double extraCharges,
      double total, List<ExtraItem> extraItems) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.customerInvoice),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.customerInvoice),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            _buildSummaryRow(
                WorkerTranslations.servicePrice,
                'SAR ${basePrice.toStringAsFixed(2)}'
            ),

            if (extraItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    WorkerTranslations.getEnglish(WorkerTranslations.extraItems),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    WorkerTranslations.getArabic(WorkerTranslations.extraItems),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...extraItems.map((item) =>
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: item.type == 'Service'
                                      ? Colors.blue.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  item.type == 'Service' ? Icons.build : Icons
                                      .inventory,
                                  size: 12,
                                  color: item.type == 'Service'
                                      ? Colors.blue
                                      : Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'SAR ${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            if (extraCharges > 0)
              _buildSummaryRow(
                WorkerTranslations.totalExtraCharges,
                'SAR ${extraCharges.toStringAsFixed(2)}',
                color: Colors.orange,
              ),
            const SizedBox(height: 8),
            const Divider(),
            _buildSummaryRow(
              WorkerTranslations.totalPrice,
              'SAR ${total.toStringAsFixed(2)}',
              isBold: true,
              color: const Color(0xFF005DFF),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          WorkerTranslations.getEnglish('Customer pays only the total amount'),
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                        Text(
                          WorkerTranslations.getArabic('Customer pays only the total amount'),
                          style: const TextStyle(fontSize: 10, color: Colors.blue),
                        ),
                      ],
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

  Widget _buildWorkerPaymentInfo(double commission,
      double vat, double workerPayment, double workerEarnings,) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.workerPaymentBreakdown),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.workerPaymentBreakdown),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            _buildSummaryRow(
                WorkerTranslations.commissionDeduction,
                'SAR ${commission.toStringAsFixed(2)}'
            ),
            _buildSummaryRow(
                WorkerTranslations.vatDeduction,
                'SAR ${vat.toStringAsFixed(2)}',
                color: Colors.orange
            ),
            const SizedBox(height: 8),
            const Divider(),
            _buildSummaryRow(
              WorkerTranslations.totalDeductions,
              'SAR ${workerPayment.toStringAsFixed(2)}',
              isBold: true,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WorkerTranslations.getEnglish(WorkerTranslations.yourPayment),
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      Text(
                        WorkerTranslations.getArabic(WorkerTranslations.yourPayment),
                        style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    'SAR ${workerEarnings.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WorkerTranslations.getEnglish(label),
                  style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    color: color,
                    fontSize: 12,
                  ),
                ),
                Text(
                  WorkerTranslations.getArabic(label),
                  style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    color: color,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.paymentMethod),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.paymentMethod),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Cash Payment Option
            InkWell(
              onTap: () => setState(() => _paymentMethod = 'Cash'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _paymentMethod == 'Cash'
                        ? Colors.green
                        : Colors.grey.shade300,
                    width: _paymentMethod == 'Cash' ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _paymentMethod == 'Cash'
                      ? Colors.green.withOpacity(0.05)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                          Icons.money, color: Colors.green, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WorkerTranslations.getEnglish(WorkerTranslations.cashPayment),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            WorkerTranslations.getArabic(WorkerTranslations.cashPayment),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            WorkerTranslations.getEnglish(WorkerTranslations.customerPaysCash),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: 'Cash',
                      groupValue: _paymentMethod,
                      onChanged: (value) =>
                          setState(() => _paymentMethod = value!),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // STC/Bank Payment Option
            InkWell(
              onTap: () => setState(() => _paymentMethod = 'STC/Bank'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _paymentMethod == 'STC/Bank'
                        ? const Color(0xFF005DFF)
                        : Colors.grey.shade300,
                    width: _paymentMethod == 'STC/Bank' ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _paymentMethod == 'STC/Bank'
                      ? const Color(0xFF005DFF).withOpacity(0.05)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF005DFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                          Icons.account_balance,
                          color: Color(0xFF005DFF),
                          size: 20
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WorkerTranslations.getEnglish(WorkerTranslations.stcPayBankTransfer),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            WorkerTranslations.getArabic(WorkerTranslations.stcPayBankTransfer),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Admin: ${InvoiceService.ADMIN_STC_ACCOUNT}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF005DFF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: 'STC/Bank',
                      groupValue: _paymentMethod,
                      onChanged: (value) =>
                          setState(() => _paymentMethod = value!),
                      activeColor: const Color(0xFF005DFF),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Selected Payment Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 18
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _paymentMethod == 'Cash'
                              ? WorkerTranslations.getEnglish(WorkerTranslations.invoiceWillShowCash)
                              : WorkerTranslations.getEnglish(WorkerTranslations.invoiceWillShowSTC),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _paymentMethod == 'Cash'
                              ? WorkerTranslations.getArabic(WorkerTranslations.invoiceWillShowCash)
                              : WorkerTranslations.getArabic(WorkerTranslations.invoiceWillShowSTC),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
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

  Future<void> _generateInvoice(AppStateProvider appState,
      ServiceRequest service,) async {
    setState(() => _isGenerating = true);

    try {
      final baseInvoice = ServiceInvoice.fromServiceRequest(service);

      final invoice = ServiceInvoice(
        invoiceNumber: baseInvoice.invoiceNumber,
        serviceRequestId: baseInvoice.serviceRequestId,
        serviceId: baseInvoice.serviceId,
        serviceName: baseInvoice.serviceName,
        customerId: baseInvoice.customerId,
        customerName: baseInvoice.customerName,
        customerAddress: baseInvoice.customerAddress,
        workerId: baseInvoice.workerId,
        workerName: baseInvoice.workerName,
        basePrice: baseInvoice.basePrice,
        extraCharges: baseInvoice.extraCharges,
        extraItems: baseInvoice.extraItems,
        totalAmount: baseInvoice.totalAmount,
        vat: baseInvoice.vat,
        commission: baseInvoice.commission,
        completionDate: baseInvoice.completionDate,
        paymentMethod: _paymentMethod,
        status: baseInvoice.status,
      );

      await InvoiceService().saveInvoice(invoice);

      if (!mounted) return;

      final paymentText = _paymentMethod == 'Cash'
          ? WorkerTranslations.paidByCash
          : WorkerTranslations.paidViaSTC;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            WorkerTranslations.getBilingual(
                '✅ Invoice generated successfully!\n'
                    'Invoice: ${invoice.invoiceNumber}\n'
                    'Payment: $paymentText',
                '✅ تم إنشاء الفاتورة بنجاح!\n'
                    'الفاتورة: ${invoice.invoiceNumber}\n'
                    'الدفع: $paymentText'
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            WorkerTranslations.getBilingual(
                '❌ Error generating invoice: $e',
                '❌ خطأ في إنشاء الفاتورة: $e'
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}