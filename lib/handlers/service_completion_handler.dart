import 'package:flutter/material.dart';
import '../services/financial_service.dart';
import '../models/financial_transaction_model.dart';

/// Service Completion Handler
/// Jab worker "Complete Service" button press karta hai,
/// ye automatically sab kuch update kar deta hai
class ServiceCompletionHandler {
  static final _financialService = FinancialService();

  /// Complete service aur sab financial data update karo
  static Future<void> completeService({
    required BuildContext context,
    required Map<String, dynamic> serviceData,
  }) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing service completion...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Extract service data
      final serviceId = serviceData['id'] ?? 'SRV_${DateTime.now().millisecondsSinceEpoch}';
      final serviceName = serviceData['service'] ?? serviceData['serviceType'] ?? 'Service';
      final workerName = serviceData['worker'] ?? 'Worker';
      final workerId = serviceData['workerId'] ?? 'WKR_001';
      final customerName = serviceData['customer'] ?? 'Customer';
      final basePrice = (serviceData['baseAmount'] ?? serviceData['price'] ?? 0.0).toDouble();
      final extraCharges = (serviceData['extraCharges'] ?? 0.0).toDouble();
      final paymentMethod = serviceData['paymentMethod'] ?? 'Cash';

      // Process through Financial Service
      // Ye automatically update karega:
      // - Admin Wallet
      // - Commission Records
      // - VAT Records
      // - Financial Reports
      final result = await _financialService.processCompletedService(
        serviceId: serviceId,
        serviceName: serviceName,
        workerName: workerName,
        workerId: workerId,
        customerName: customerName,
        basePrice: basePrice,
        extraCharges: extraCharges,
        completionDate: DateTime.now(),
        paymentMethod: paymentMethod,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);

        if (result.success) {
          // Show success with detailed breakdown
          _showSuccessDialog(context, result.transaction!);
        } else {
          // Show error
          _showErrorDialog(context, result.message);
        }
      }
    } catch (e) {
      // Close loading and show error
      if (context.mounted) {
        Navigator.pop(context);
        _showErrorDialog(context, e.toString());
      }
    }
  }

  /// Show success dialog with financial breakdown
  static void _showSuccessDialog(
      BuildContext context, FinancialTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 32),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Service Completed!',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Financial Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(),
              _buildSummaryRow('Service', transaction.serviceName),
              _buildSummaryRow('Customer', transaction.customerName),
              const SizedBox(height: 8),
              _buildAmountRow('Total Amount', transaction.totalAmount, Colors.blue),
              _buildAmountRow('Commission (20%)', transaction.commission, Colors.purple),
              _buildAmountRow('VAT (15%)', transaction.vat, Colors.orange),
              const Divider(),
              _buildAmountRow('Your Earnings', transaction.workerEarnings, Colors.green, isBold: true),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All financial records have been updated automatically',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View Wallet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005DFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  static Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  static Widget _buildAmountRow(String label, double amount, Color color,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'SAR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}