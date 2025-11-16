import 'package:flutter/material.dart';

class GenerateInvoiceScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const GenerateInvoiceScreen({super.key, required this.service});

  @override
  State<GenerateInvoiceScreen> createState() => _GenerateInvoiceScreenState();
}

class _GenerateInvoiceScreenState extends State<GenerateInvoiceScreen> {
  String _paymentMethod = 'Cash';

  // CORRECTED: Calculate prices
  // Customer pays: Total only (base + extra)
  // Commission: 20% of total
  // VAT: 15% of total

  double get _basePrice => widget.service['price'].toDouble();
  double get _extraCharges => (widget.service['extraCharges'] ?? 0.0).toDouble();
  double get _total => _basePrice + _extraCharges;
  double get _commission => _total * 0.20; // 20% of total
  double get _vat => _total * 0.15; // 15% of total
  double get _workerPayment => _commission + _vat;
  double get _workerEarnings => _total - _workerPayment;

  @override
  Widget build(BuildContext context) {
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
            _buildServiceInfo(),
            const SizedBox(height: 16),
            _buildCustomerInfo(),
            const SizedBox(height: 16),
            _buildInvoiceSummary(),
            const SizedBox(height: 16),
            _buildWorkerPaymentInfo(),
            const SizedBox(height: 24),
            _buildPaymentMethod(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generateInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B5B9A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Generate & Send Invoice'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Service Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInfoRow('Service ID', widget.service['id']),
            _buildInfoRow('Service', widget.service['service']),
            _buildInfoRow('Status', widget.service['status']),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInfoRow('Name', widget.service['customer']),
            _buildInfoRow('Phone', widget.service['phone']),
            _buildInfoRow('Address', widget.service['address']),
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
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildInvoiceSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer Invoice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildSummaryRow('Service Price', 'SAR ${_basePrice.toStringAsFixed(2)}'),
            if (_extraCharges > 0)
              _buildSummaryRow('Extra Items', 'SAR ${_extraCharges.toStringAsFixed(2)}', color: Colors.orange),
            const Divider(),
            _buildSummaryRow('TOTAL AMOUNT', 'SAR ${_total.toStringAsFixed(2)}', isBold: true, color: const Color(0xFF6B5B9A)),
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
                    child: Text('Customer pays only the total amount',
                        style: TextStyle(fontSize: 12, color: Colors.blue)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerPaymentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Worker Payment Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildSummaryRow('Commission (20%)', 'SAR ${_commission.toStringAsFixed(2)}'),
            _buildSummaryRow('VAT (15%)', 'SAR ${_vat.toStringAsFixed(2)}', color: Colors.orange),
            const Divider(),
            _buildSummaryRow('Deducted from Credit', 'SAR ${_workerPayment.toStringAsFixed(2)}', isBold: true, color: Colors.red),
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
                  const Text('Your Earnings:', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  Text('SAR ${_workerEarnings.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
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
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
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
            const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _generateInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Invoice generated for ${widget.service['customer']} - Total: SAR ${_total.toStringAsFixed(2)}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    Navigator.pop(context);
  }
}