import 'package:flutter/material.dart';

class GenerateInvoiceScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const GenerateInvoiceScreen({super.key, required this.service});

  @override
  State<GenerateInvoiceScreen> createState() => _GenerateInvoiceScreenState();
}

class _GenerateInvoiceScreenState extends State<GenerateInvoiceScreen> {
  // Calculate prices - Customer pays total only
  double get _basePrice => widget.service['price'].toDouble();
  double get _extraCharges => (widget.service['extraCharges'] ?? 0.0).toDouble();
  double get _total => _basePrice + _extraCharges;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvoiceHeader(),
            const SizedBox(height: 16),
            _buildServiceInfo(),
            const SizedBox(height: 16),
            _buildCustomerInfo(),
            const SizedBox(height: 16),
            _buildInvoiceSummary(),
            const SizedBox(height: 16),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateInvoice,
                icon: const Icon(Icons.receipt_long),
                label: const Text('Generate Invoice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B5B9A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt, color: Color(0xFF6B5B9A), size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TAX INVOICE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Aidea Services', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'PAID',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Invoice #: ${widget.service['id']}', style: const TextStyle(fontSize: 12)),
                Text('Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: const TextStyle(fontSize: 12)),
              ],
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
    final extraItems = (widget.service['extraItems'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Invoice Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildSummaryRow('Service Price', 'SAR ${_basePrice.toStringAsFixed(2)}'),

            // Show detailed extra items
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
              ...extraItems.map((item) => Padding(
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
                              color: item['type'] == 'Service'
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              item['type'] == 'Service' ? Icons.build : Icons.inventory,
                              size: 14,
                              color: item['type'] == 'Service' ? Colors.blue : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item['name'],
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'SAR ${(item['price'] as num).toDouble().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 8),
            ],

            if (_extraCharges > 0)
              _buildSummaryRow('Total Extra', 'SAR ${_extraCharges.toStringAsFixed(2)}', color: Colors.orange),
            const Divider(),
            _buildSummaryRow('TOTAL AMOUNT', 'SAR ${_total.toStringAsFixed(2)}',
                isBold: true, color: const Color(0xFF6B5B9A), fontSize: 20),
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

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color, double? fontSize}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: fontSize)),
          Text(value, style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: fontSize)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Methods', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPaymentMethodTile(
              icon: Icons.money,
              title: 'Cash Payment',
              subtitle: 'Pay with cash at service location',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodTile(
              icon: Icons.account_balance,
              title: 'STC Pay / Bank Transfer',
              subtitle: 'Admin STC: +966-50-123-4567',
              color: const Color(0xFF6B5B9A),
              showCopyButton: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool showCopyButton = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (showCopyButton)
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phone number copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              color: color,
            ),
        ],
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