import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/app_state_provider.dart';
import '/models/service_request_model.dart';
import '/utils/admin_translations.dart';
import '/widgets/bilingual_text.dart';

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
              title: Text(AdminTranslations.split(AdminTranslations.generateInvoice)[0]),
              backgroundColor: const Color(0xFF6B5B9A),
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: BilingualText(
                english: AdminTranslations.split(AdminTranslations.serviceNotFound)[0],
                arabic: AdminTranslations.split(AdminTranslations.serviceNotFound)[1],
                englishStyle: const TextStyle(fontSize: 16),
              ),
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
            title: Text(AdminTranslations.split(AdminTranslations.generateInvoice)[0]),
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
                        : Text(AdminTranslations.split(AdminTranslations.generateCompleteService)[0]),
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
            BilingualText(
              english: AdminTranslations.split(AdminTranslations.serviceDetails)[0],
              arabic: AdminTranslations.split(AdminTranslations.serviceDetails)[1],
              englishStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              AdminTranslations.split(AdminTranslations.serviceId)[0],
              AdminTranslations.split(AdminTranslations.serviceId)[1],
              service.id,
            ),
            _buildInfoRow(
              AdminTranslations.split(AdminTranslations.services)[0],
              AdminTranslations.split(AdminTranslations.services)[1],
              service.serviceName,
            ),
            _buildInfoRow(
              AdminTranslations.split(AdminTranslations.status)[0],
              AdminTranslations.split(AdminTranslations.status)[1],
              service.status.toString().split('.').last,
            ),
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
            BilingualText(
              english: AdminTranslations.split(AdminTranslations.customerInformation)[0],
              arabic: AdminTranslations.split(AdminTranslations.customerInformation)[1],
              englishStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              AdminTranslations.split(AdminTranslations.name)[0],
              AdminTranslations.split(AdminTranslations.name)[1],
              service.customerName,
            ),
            _buildInfoRow(
              AdminTranslations.split(AdminTranslations.address)[0],
              AdminTranslations.split(AdminTranslations.address)[1],
              service.address,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String labelEn, String labelAr, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: BilingualText(
              english: '$labelEn:',
              arabic: '$labelAr:',
              englishStyle: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
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
            BilingualText(
              english: AdminTranslations.split(AdminTranslations.customerInvoice)[0],
              arabic: AdminTranslations.split(AdminTranslations.customerInvoice)[1],
              englishStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildSummaryRow(
              AdminTranslations.split(AdminTranslations.servicePrice)[0],
              AdminTranslations.split(AdminTranslations.servicePrice)[1],
              'SAR ${basePrice.toStringAsFixed(2)}',
            ),
            if (extraCharges > 0)
              _buildSummaryRow(
                AdminTranslations.split(AdminTranslations.extraItems)[0],
                AdminTranslations.split(AdminTranslations.extraItems)[1],
                'SAR ${extraCharges.toStringAsFixed(2)}',
                color: Colors.orange,
              ),
            const Divider(),
            _buildSummaryRow(
              AdminTranslations.split(AdminTranslations.totalAmountUpper)[0],
              AdminTranslations.split(AdminTranslations.totalAmountUpper)[1],
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
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BilingualText(
                      english: AdminTranslations.split(AdminTranslations.customerPaysOnly)[0],
                      arabic: AdminTranslations.split(AdminTranslations.customerPaysOnly)[1],
                      englishStyle: const TextStyle(fontSize: 12, color: Colors.blue),
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
            BilingualText(
              english: AdminTranslations.split(AdminTranslations.workerPaymentBreakdown)[0],
              arabic: AdminTranslations.split(AdminTranslations.workerPaymentBreakdown)[1],
              englishStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildSummaryRow(
              AdminTranslations.split(AdminTranslations.commissionPercent)[0],
              AdminTranslations.split(AdminTranslations.commissionPercent)[1],
              'SAR ${commission.toStringAsFixed(2)}',
            ),
            _buildSummaryRow(
              AdminTranslations.split(AdminTranslations.vatPercent)[0],
              AdminTranslations.split(AdminTranslations.vatPercent)[1],
              'SAR ${vat.toStringAsFixed(2)}',
              color: Colors.orange,
            ),
            const Divider(),
            _buildSummaryRow(
              AdminTranslations.split(AdminTranslations.deductedFromCredit)[0],
              AdminTranslations.split(AdminTranslations.deductedFromCredit)[1],
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
                  BilingualText(
                    english: AdminTranslations.split(AdminTranslations.workerEarnings)[0],
                    arabic: AdminTranslations.split(AdminTranslations.workerEarnings)[1],
                    englishStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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

  Widget _buildSummaryRow(String labelEn, String labelAr, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BilingualText(
            english: labelEn,
            arabic: labelAr,
            englishStyle: TextStyle(
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
            BilingualText(
              english: AdminTranslations.split(AdminTranslations.paymentMethod)[0],
              arabic: AdminTranslations.split(AdminTranslations.paymentMethod)[1],
              englishStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RadioListTile(
              title: Text(AdminTranslations.split(AdminTranslations.cash)[0]),
              value: 'Cash',
              groupValue: _paymentMethod,
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
            RadioListTile(
              title: Text(AdminTranslations.split(AdminTranslations.onlinePayment)[0]),
              value: 'Online',
              groupValue: _paymentMethod,
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateInvoice(
      AppStateProvider appState,
      ServiceRequest service,
      ) async {
    setState(() => _isGenerating = true);

    try {
      await appState.completeService(service.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AdminTranslations.serviceCompletedSuccess} ${service.customerName}\nTotal: SAR ${service.totalPrice.toStringAsFixed(2)}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AdminTranslations.errorCompletingService} $e'),
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