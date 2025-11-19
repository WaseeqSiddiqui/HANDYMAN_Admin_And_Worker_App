import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/app_state_provider.dart';
import '/models/service_request_model.dart';
import '/services/invoice_service.dart';
import '/models/service_invoice_model.dart';

class GenerateInvoiceScreen extends StatefulWidget {
  final String serviceId;

  const GenerateInvoiceScreen({super.key, required this.serviceId});

  @override
  State<GenerateInvoiceScreen> createState() => _GenerateInvoiceScreenState();
}

class _GenerateInvoiceScreenState extends State<GenerateInvoiceScreen> {
  String _paymentMethod = 'Cash';
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final service = appState.getServiceById(widget.serviceId);

        if (service == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Generate Invoice'),
              backgroundColor: const Color(0xFF6B5B9A),
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
            title: const Text('Generate Invoice'),
            backgroundColor: const Color(0xFF6B5B9A),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
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
                const SizedBox(height: 24),
                _buildPaymentMethodSelection(),
                const SizedBox(height: 24),

                // ✅ SINGLE BUTTON: Generate Invoice
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isGenerating
                        ? null
                        : () => _generateInvoice(appState, service),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B5B9A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        : const Text(
                      'Generate Invoice',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ INFO: What happens after
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700,
                          size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'After generating the invoice, you can complete the service from the service details screen.',
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
        );
      },
    );
  }

  Widget _buildServiceInfo(ServiceRequest service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Service ID', service.id),
            _buildInfoRow('Service', service.serviceName),
            _buildInfoRow('Status', service.status
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', service.customerName),
            _buildInfoRow('Address', service.address),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSummary(double basePrice, double extraCharges,
      double total, List<ExtraItem> extraItems) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Invoice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildSummaryRow(
                'Service Price', 'SAR ${basePrice.toStringAsFixed(2)}'),

            if (extraItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Extra Items:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              ...extraItems.map((item) =>
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 6),
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
                                  size: 14,
                                  color: item.type == 'Service'
                                      ? Colors.blue
                                      : Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'SAR ${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            if (extraCharges > 0)
              _buildSummaryRow(
                'Total Extra',
                'SAR ${extraCharges.toStringAsFixed(2)}',
                color: Colors.orange,
              ),
            const Divider(),
            _buildSummaryRow(
              'TOTAL AMOUNT',
              'SAR ${total.toStringAsFixed(2)}',
              isBold: true,
              color: const Color(0xFF6B5B9A),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Customer pays only the total amount',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
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
      double vat,
      double workerPayment,
      double workerEarnings,) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Worker Payment Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildSummaryRow(
                'Commission (20%)', 'SAR ${commission.toStringAsFixed(2)}'),
            _buildSummaryRow('VAT (15%)', 'SAR ${vat.toStringAsFixed(2)}',
                color: Colors.orange),
            const Divider(),
            _buildSummaryRow(
              'Deducted from Credit',
              'SAR ${workerPayment.toStringAsFixed(2)}',
              isBold: true,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Worker Earnings:',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'SAR ${workerEarnings.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Cash Payment Option
            InkWell(
              onTap: () => setState(() => _paymentMethod = 'Cash'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                          Icons.money, color: Colors.green, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cash Payment',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Customer pays with cash',
                            style: TextStyle(
                              fontSize: 13,
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

            const SizedBox(height: 12),

            // STC/Bank Payment Option
            InkWell(
              onTap: () => setState(() => _paymentMethod = 'STC/Bank'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _paymentMethod == 'STC/Bank'
                        ? const Color(0xFF6B5B9A)
                        : Colors.grey.shade300,
                    width: _paymentMethod == 'STC/Bank' ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _paymentMethod == 'STC/Bank'
                      ? const Color(0xFF6B5B9A).withOpacity(0.05)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B5B9A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                          Icons.account_balance,
                          color: Color(0xFF6B5B9A),
                          size: 24
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'STC Pay / Bank Transfer',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // ✅ SHOW ADMIN STC ACCOUNT
                          Text(
                            'Admin: ${InvoiceService.ADMIN_STC_ACCOUNT}',
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF6B5B9A),
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
                      activeColor: const Color(0xFF6B5B9A),
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
                      size: 20
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _paymentMethod == 'Cash'
                          ? 'Invoice will show: Paid by Cash'
                          : 'Invoice will show: Paid via STC Account with transfer details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
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

  // ✅ GENERATE INVOICE ONLY (Not completing service)
  // ✅ FIXED: generate_invoice_screen.dart
// Updated to work with actual ServiceInvoice model structure

// Replace the _generateInvoice method with this corrected version:

  Future<void> _generateInvoice(AppStateProvider appState,
      ServiceRequest service,) async {
    setState(() => _isGenerating = true);

    try {
      // ✅ Create base invoice from ServiceRequest
      final baseInvoice = ServiceInvoice.fromServiceRequest(service);

      // ✅ Create updated invoice with selected payment method
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
        // ✅ Use selected payment method
        status: baseInvoice.status,
      );

      // ✅ Save invoice
      await InvoiceService().saveInvoice(invoice);

      if (!mounted) return;

      final paymentText = _paymentMethod == 'Cash'
          ? 'Paid by Cash'
          : 'Paid via STC Account (${InvoiceService.ADMIN_STC_ACCOUNT})';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Invoice generated successfully!\n'
                'Invoice: ${invoice.invoiceNumber}\n'
                'Payment: $paymentText\n\n'
                'Now you can complete the service from service details.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );

      // Navigate back to service details
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error generating invoice: $e'),
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
}