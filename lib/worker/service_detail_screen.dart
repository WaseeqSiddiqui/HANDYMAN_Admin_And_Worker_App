import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/providers/app_state_provider.dart';
import 'add_extra_items_screen.dart';
import 'generate_invoice_screen.dart';
import 'credit_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isLoading = false;

  String _formatDate(dynamic dateValue) {
    try {
      DateTime dateTime;
      if (dateValue is DateTime) {
        dateTime = dateValue;
      } else if (dateValue is String) {
        dateTime = DateTime.parse(dateValue);
      } else {
        return 'N/A';
      }
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        // Get live service data from provider
        final service = appState.getServiceById(widget.service['id']) ?? widget.service;

        // LIVE CALCULATION
        final totalPrice = (service['price'] as num).toDouble() +
            ((service['extraCharges'] ?? 0.0) as num).toDouble();
        final commission = totalPrice * 0.20;
        final vat = totalPrice * 0.15;
        final requiredCredit = commission + vat;
        final workerEarnings = totalPrice - requiredCredit;
        final hasEnoughCredit = appState.creditBalance >= requiredCredit;

        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, true);
            return false;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              title: Text(service['service']),
              backgroundColor: const Color(0xFF6B5B9A),
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, true),
              ),
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerInfo(service),
                  const SizedBox(height: 16),
                  _buildPriceBreakdown(service, totalPrice, commission, vat, workerEarnings),
                  const SizedBox(height: 16),
                  _buildCreditValidation(appState, requiredCredit, hasEnoughCredit),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, appState, service, hasEnoughCredit, requiredCredit),
                  const SizedBox(height: 100),  // ✅ Extra space for scrolling
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerInfo(Map<String, dynamic> service) {
    return Card(
      elevation: 3,
      color: Colors.grey.shade900, // Dark background
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF6B5B9A), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Customer',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        service['customer'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Light text on dark background
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Colors.grey),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Color(0xFF6B5B9A), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Address',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        service['address'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70, // Light text
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

  Widget _buildPriceBreakdown(Map<String, dynamic> service, double totalPrice,
      double commission, double vat, double workerEarnings) {
    final basePrice = (service['price'] as num).toDouble();
    final extraCharges = ((service['extraCharges'] ?? 0.0) as num).toDouble();
    final extraItems = (service['extraItems'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    return Card(
      elevation: 3,
      color: Colors.grey.shade900, // Dark background
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Price Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            const Divider(height: 24, color: Colors.grey),
            _buildRow('Base Price', basePrice),

            // Show detailed extra items
            if (extraItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Extra Items:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              ...extraItems.map((item) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            item['type'] == 'Service' ? Icons.build : Icons.inventory,
                            size: 16,
                            color: item['type'] == 'Service' ? Colors.blue : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item['name']} (${item['type']})',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
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
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 8),
              _buildRow('Total Extra', extraCharges, color: Colors.orange),
            ],

            const Divider(height: 24, color: Colors.grey),
            _buildRow('Total Amount', totalPrice, isBold: true, color: const Color(0xFF6B5B9A), fontSize: 20),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
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
                      const Text('Commission (20%)',
                          style: TextStyle(color: Colors.redAccent)),
                      Text('SAR ${commission.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('VAT (15%)',
                          style: TextStyle(color: Colors.redAccent)),
                      Text('SAR ${vat.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Your Earnings',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      )),
                  Text('SAR ${workerEarnings.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double value,
      {bool isBold = false, Color? color, double? fontSize}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.white70,
              fontSize: fontSize ?? 14,
            ),
          ),
          Text(
            'SAR ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.white,
              fontSize: fontSize ?? 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditValidation(AppStateProvider appState, double requiredCredit, bool hasEnoughCredit) {
    final hasInsufficientCredit = !hasEnoughCredit;

    return Card(
      elevation: 3,
      color: hasInsufficientCredit ? Colors.red.shade900 : Colors.green.shade900,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(hasInsufficientCredit ? Icons.warning : Icons.check_circle,
                    color: hasInsufficientCredit ? Colors.redAccent : Colors.greenAccent, size: 28),
                const SizedBox(width: 12),
                Text(hasInsufficientCredit ? 'Insufficient Credit' : 'Credit Validation',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hasInsufficientCredit ? Colors.redAccent : Colors.greenAccent)),
              ],
            ),
            const Divider(height: 24, color: Colors.white30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Required Credit:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    )),
                Text('SAR ${requiredCredit.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your Credit:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    )),
                Text('SAR ${appState.creditBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent)),
              ],
            ),
            if (hasInsufficientCredit) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          'Shortfall: SAR ${(requiredCredit - appState.creditBalance).toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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

  Widget _buildActionButtons(BuildContext context, AppStateProvider appState,
      Map<String, dynamic> service, bool hasEnoughCredit,
      double requiredCredit) {
    if (service['status'] == 'Pending') {
      return const SizedBox.shrink();
    } else if (service['status'] == 'In Progress') {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => _addExtraItems(context, appState, service),
            icon: const Icon(Icons.add_circle),
            label: const Text('Add Extra Items'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: hasEnoughCredit ? () => _generateInvoice(context, appState, service) : null,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5B9A),
                minimumSize: const Size(double.infinity, 50),
                disabledBackgroundColor: Colors.grey),
            child: Text(hasEnoughCredit
                ? 'Generate Invoice'
                : 'Insufficient Credit - Top-up Required'),
          ),
          if (!hasEnoughCredit) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const CreditScreen())),
              icon: const Icon(Icons.add_circle),
              label: const Text('Top-up Credit'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B5B9A),
                  minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _addExtraItems(BuildContext context, AppStateProvider appState, Map<String, dynamic> service) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExtraItemsScreen(
          service: service,
          onItemsAdded: (extraCharges, extraItems) {
            // Update service in provider with both charges and detailed items
            appState.addExtraCharges(service['id'], extraCharges);
            appState.addExtraItems(service['id'], extraItems);
          },
        ),
      ),
    );

    // Show updated info
    if (mounted) {
      final updatedService = appState.getServiceById(service['id']);
      if (updatedService != null) {
        final newTotal = (updatedService['price'] as num).toDouble() +
            ((updatedService['extraCharges'] ?? 0.0) as num).toDouble();
        final newRequired = newTotal * 0.35; // 20% + 15%

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✅ Extra items updated!',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('New Total: SAR ${newTotal.toStringAsFixed(2)}'),
                Text('Required Credit: SAR ${newRequired.toStringAsFixed(2)}'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _generateInvoice(BuildContext context, AppStateProvider appState, Map<String, dynamic> service) {
    final requiredCredit = appState.getRequiredCredit(service);

    if (!appState.hasEnoughCredit(service)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Cannot Generate Invoice')
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Insufficient credit to generate invoice.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Required: SAR ${requiredCredit.toStringAsFixed(2)}'),
              Text('Available: SAR ${appState.creditBalance.toStringAsFixed(2)}'),
              Text('Shortfall: SAR ${(requiredCredit - appState.creditBalance).toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Please top-up your credit to continue.',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const CreditScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B5B9A)),
              child: const Text('Top-up Credit'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GenerateInvoiceScreen(service: service)),
    );
  }
}