import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '/services/invoice_service.dart';
import '/models/service_invoice_model.dart';
import '/utils/admin_translations.dart';
import '/widgets/bilingual_text.dart';

class InvoiceManagementScreen extends StatefulWidget {
  const InvoiceManagementScreen({super.key});

  @override
  State<InvoiceManagementScreen> createState() =>
      _InvoiceManagementScreenState();
}

class _InvoiceManagementScreenState extends State<InvoiceManagementScreen> {
  final _invoiceService = InvoiceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AdminTranslations.split(AdminTranslations.invoiceManagement)[0],
        ),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ServiceInvoice>>(
        stream: _invoiceService.getInvoicesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final invoices = snapshot.data ?? [];

          return Column(
            children: [
              // Invoices Count Header (Moved from AppBar Actions to Body for cleaner stream handling)
              if (invoices.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${invoices.length} ${AdminTranslations.split(AdminTranslations.invoices)[0]}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: invoices.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: invoices.length,
                        itemBuilder: (context, index) {
                          final invoice = invoices[index];
                          return _buildInvoiceCard(invoice);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          BilingualText(
            english: AdminTranslations.split(
              AdminTranslations.noInvoicesYet,
            )[0],
            arabic: AdminTranslations.split(AdminTranslations.noInvoicesYet)[1],
            englishStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: BilingualText(
              english: AdminTranslations.split(
                AdminTranslations.invoicesWillAppear,
              )[0],
              arabic: AdminTranslations.split(
                AdminTranslations.invoicesWillAppear,
              )[1],
              englishStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(ServiceInvoice invoice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewInvoiceDetails(invoice),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B5B9A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF6B5B9A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                invoice.invoiceNumber,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                invoice.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AdminTranslations.split(AdminTranslations.services)[0]}: ${invoice.serviceId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.person,
                      AdminTranslations.split(AdminTranslations.customer)[0],
                      invoice.customerName,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.build,
                      AdminTranslations.split(AdminTranslations.services)[0],
                      invoice.serviceName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.person_outline,
                      AdminTranslations.split(AdminTranslations.worker)[0],
                      invoice.workerName,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.calendar_today,
                      AdminTranslations.split(AdminTranslations.date)[0],
                      '${invoice.completionDate.day}/${invoice.completionDate.month}/${invoice.completionDate.year}',
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BilingualText(
                    english: AdminTranslations.split(
                      AdminTranslations.totalAmount,
                    )[0],
                    arabic: AdminTranslations.split(
                      AdminTranslations.totalAmount,
                    )[1],
                    englishStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'SAR ${invoice.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B5B9A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _viewInvoiceDetails(invoice),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: Text(
                    AdminTranslations.split(AdminTranslations.viewDetails)[0],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B5B9A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _viewInvoiceDetails(ServiceInvoice invoice) {
    // FALLBACK ADDRESS LOGIC
    String displayAddress = invoice.customerAddress;
    if (displayAddress == 'NA' ||
        displayAddress.isEmpty ||
        displayAddress == 'N/A') {
      try {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        final serviceReq = appState.getServiceById(invoice.serviceId);
        if (serviceReq != null &&
            serviceReq.address.isNotEmpty &&
            serviceReq.address != 'NA') {
          displayAddress = serviceReq.address;
        }
      } catch (e) {
        debugPrint('Address fallback failed: $e');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF6B5B9A,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: Color(0xFF6B5B9A),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BilingualText(
                                  english: AdminTranslations.split(
                                    AdminTranslations.invoiceDetails,
                                  )[0],
                                  arabic: AdminTranslations.split(
                                    AdminTranslations.invoiceDetails,
                                  )[1],
                                  englishStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  invoice.invoiceNumber,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              invoice.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      _buildDetailSection(
                        AdminTranslations.split(
                          AdminTranslations.serviceInformation,
                        )[0],
                        AdminTranslations.split(
                          AdminTranslations.serviceInformation,
                        )[1],
                        [
                          _buildDetailRow(
                            AdminTranslations.split(
                              AdminTranslations.serviceId,
                            )[0],
                            AdminTranslations.split(
                              AdminTranslations.serviceId,
                            )[1],
                            invoice.serviceId,
                          ),
                          _buildDetailRow(
                            AdminTranslations.split(
                              AdminTranslations.serviceType,
                            )[0],
                            AdminTranslations.split(
                              AdminTranslations.serviceType,
                            )[1],
                            invoice.serviceName,
                          ),
                          _buildDetailRow(
                            AdminTranslations.split(
                              AdminTranslations.worker,
                            )[0],
                            AdminTranslations.split(
                              AdminTranslations.worker,
                            )[1],
                            invoice.workerName,
                          ),
                          _buildDetailRow(
                            AdminTranslations.split(AdminTranslations.date)[0],
                            AdminTranslations.split(AdminTranslations.date)[1],
                            '${invoice.completionDate.day}/${invoice.completionDate.month}/${invoice.completionDate.year}',
                          ),
                        ],
                      ),

                      _buildDetailSection(
                        AdminTranslations.split(
                          AdminTranslations.customerInformation,
                        )[0],
                        AdminTranslations.split(
                          AdminTranslations.customerInformation,
                        )[1],
                        [
                          // _buildDetailRow(
                          //   AdminTranslations.split(AdminTranslations.phone)[0],
                          //   AdminTranslations.split(AdminTranslations.phone)[1],
                          //   invoice.customerId,
                          // ),
                          _buildDetailRow(
                            AdminTranslations.split(AdminTranslations.name)[0],
                            AdminTranslations.split(AdminTranslations.name)[1],
                            invoice.customerName,
                          ),
                          _buildDetailRow(
                            AdminTranslations.split(
                              AdminTranslations.address,
                            )[0],
                            AdminTranslations.split(
                              AdminTranslations.address,
                            )[1],
                            displayAddress,
                          ),
                        ],
                      ),

                      _buildDetailSection(
                        AdminTranslations.split(
                          AdminTranslations.paymentBreakdown,
                        )[0],
                        AdminTranslations.split(
                          AdminTranslations.paymentBreakdown,
                        )[1],
                        [
                          _buildDetailRow(
                            AdminTranslations.split(
                              AdminTranslations.basePrice,
                            )[0],
                            AdminTranslations.split(
                              AdminTranslations.basePrice,
                            )[1],
                            'SAR ${invoice.basePrice.toStringAsFixed(2)}',
                          ),
                          if (invoice.extraCharges > 0)
                            _buildDetailRow(
                              AdminTranslations.split(
                                AdminTranslations.extraCharges,
                              )[0],
                              AdminTranslations.split(
                                AdminTranslations.extraCharges,
                              )[1],
                              'SAR ${invoice.extraCharges.toStringAsFixed(2)}',
                            ),
                          const Divider(),
                          _buildDetailRow(
                            AdminTranslations.split(
                              AdminTranslations.totalAmount,
                            )[0],
                            AdminTranslations.split(
                              AdminTranslations.totalAmount,
                            )[1],
                            'SAR ${invoice.totalAmount.toStringAsFixed(2)}',
                            isBold: true,
                          ),
                          const Divider(),
                          _buildDetailRow(
                            AdminTranslations.split(
                              AdminTranslations.vatPercent,
                            )[0],
                            AdminTranslations.split(
                              AdminTranslations.vatPercent,
                            )[1],
                            'SAR ${invoice.vat.toStringAsFixed(2)}',
                          ),
                          _buildDetailRow(
                            AdminTranslations.split(
                              AdminTranslations.commissionPercent,
                            )[0],
                            AdminTranslations.split(
                              AdminTranslations.commissionPercent,
                            )[1],
                            'SAR ${invoice.commission.toStringAsFixed(2)}',
                          ),
                        ],
                      ),

                      _buildDetailSection(
                        AdminTranslations.split(
                          AdminTranslations.paymentInformation,
                        )[0],
                        AdminTranslations.split(
                          AdminTranslations.paymentInformation,
                        )[1],
                        [
                          _buildDetailRow(
                            AdminTranslations.split(
                              AdminTranslations.method,
                            )[0],
                            AdminTranslations.split(
                              AdminTranslations.method,
                            )[1],
                            invoice.paymentMethod,
                          ),
                          _buildDetailRow(
                            AdminTranslations.split(
                              AdminTranslations.status,
                            )[0],
                            AdminTranslations.split(
                              AdminTranslations.status,
                            )[1],
                            invoice.status,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _downloadInvoice(invoice);
                        },
                        icon: const Icon(Icons.download),
                        label: Text(
                          AdminTranslations.split(
                            AdminTranslations.downloadPdf,
                          )[0],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(
    String titleEn,
    String titleAr,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BilingualText(
          english: titleEn,
          arabic: titleAr,
          englishStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B5B9A),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDetailRow(
    String labelEn,
    String labelAr,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: BilingualText(
              english: labelEn,
              arabic: labelAr,
              englishStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadInvoice(ServiceInvoice invoice) async {
    // FALLBACK ADDRESS LOGIC FOR PDF
    ServiceInvoice invoiceToPrint = invoice;
    String displayAddress = invoice.customerAddress;

    // Check various forms of 'NA' or empty
    if (displayAddress == 'NA' ||
        displayAddress.isEmpty ||
        displayAddress == 'N/A') {
      try {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        final serviceReq = appState.getServiceById(invoice.serviceId);
        if (serviceReq != null &&
            serviceReq.address.isNotEmpty &&
            serviceReq.address != 'NA') {
          // Create a new Service Invoice with the updated address
          invoiceToPrint = ServiceInvoice(
            invoiceNumber: invoice.invoiceNumber,
            serviceRequestId: invoice.serviceRequestId,
            serviceId: invoice.serviceId,
            serviceName: invoice.serviceName,
            customerId: invoice.customerId,
            customerName: invoice.customerName,
            customerAddress: serviceReq.address, // UPDATED
            workerId: invoice.workerId,
            workerName: invoice.workerName,
            basePrice: invoice.basePrice,
            extraCharges: invoice.extraCharges,
            extraItems: invoice.extraItems,
            totalAmount: invoice.totalAmount,
            vat: invoice.vat,
            commission: invoice.commission,
            completionDate: invoice.completionDate,
            paymentMethod: invoice.paymentMethod,
            status: invoice.status,
          );
        }
      } catch (e) {
        debugPrint('Address fallback for PDF failed: $e');
      }
    }

    try {
      await _invoiceService.downloadInvoicePDF(invoiceToPrint);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AdminTranslations.invoiceDownloaded} ${invoice.invoiceNumber}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AdminTranslations.errorDownloadingInvoice} $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
