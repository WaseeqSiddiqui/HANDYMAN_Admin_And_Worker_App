import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/app_state_provider.dart';
import '/models/service_request_model.dart';

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
        // ✅ Get service from AppStateProvider (now returns ServiceRequest)
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

        // ✅ Use model properties directly
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
                _buildInvoiceSummary(basePrice, extraCharges, total),
                const SizedBox(height: 16),
                _buildWorkerPaymentInfo(commission, vat, workerPayment, workerEarnings),
                const SizedBox(height: 24),
                _buildPaymentMethod(),
                const SizedBox(height: 24),
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
                        : const Text('Generate & Complete Service'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Updated to use ServiceRequest model
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
            _buildInfoRow('Status', service.status.toString().split('.').last),
          ],
        ),
      ),
    );
  }

  // ✅ Updated to use ServiceRequest model
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
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
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

  Widget _buildInvoiceSummary(double basePrice, double extraCharges, double total) {
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
            _buildSummaryRow('Service Price', 'SAR ${basePrice.toStringAsFixed(2)}'),
            if (extraCharges > 0)
              _buildSummaryRow(
                'Extra Items',
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

  Widget _buildWorkerPaymentInfo(
      double commission,
      double vat,
      double workerPayment,
      double workerEarnings,
      ) {
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
            _buildSummaryRow('Commission (20%)', 'SAR ${commission.toStringAsFixed(2)}'),
            _buildSummaryRow('VAT (15%)', 'SAR ${vat.toStringAsFixed(2)}', color: Colors.orange),
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
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
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

  Widget _buildPaymentMethod() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RadioListTile(
              title: const Text('Cash'),
              value: 'Cash',
              groupValue: _paymentMethod,
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
            RadioListTile(
              title: const Text('Online Payment'),
              value: 'Online',
              groupValue: _paymentMethod,
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ UPDATED: Complete service through AppStateProvider
  Future<void> _generateInvoice(
      AppStateProvider appState,
      ServiceRequest service,
      ) async {
    setState(() => _isGenerating = true);

    try {
      // ✅ This will automatically:
      // 1. Update worker credit/wallet
      // 2. Generate invoice via InvoiceService using ServiceInvoice.fromServiceRequest()
      // 3. Update FinancialService records
      // 4. Add transaction to history
      await appState.completeService(service.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Service completed!\nInvoice generated for ${service.customerName}\nTotal: SAR ${service.totalPrice.toStringAsFixed(2)}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error completing service: $e'),
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