// ---------------------------------------------------------
// INVOICE SERVICE - ENHANCED WITH STC ACCOUNT DISPLAY
// ---------------------------------------------------------

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '/models/service_invoice_model.dart';
import '/models/service_request_model.dart';

class InvoiceService {
  static final InvoiceService _instance = InvoiceService._internal();
  factory InvoiceService() => _instance;
  InvoiceService._internal();

  final List<ServiceInvoice> _invoices = [];

  // ✅ ADMIN STC BANK ACCOUNT - Configure this as needed
  static const String ADMIN_STC_ACCOUNT = '+966-50-123-4567';
  static const String ADMIN_BANK_NAME = 'STC Pay / Bank Transfer';

  Future<void> saveInvoice(ServiceInvoice invoice) async {
    _invoices.insert(0, invoice);
    await generateInvoicePDF(invoice);
  }

  List<ServiceInvoice> getAllInvoices() => List.unmodifiable(_invoices);

  ServiceInvoice? getInvoiceByServiceId(String serviceId) {
    try {
      return _invoices.firstWhere((inv) => inv.serviceRequestId == serviceId);
    } catch (e) {
      return null;
    }
  }

  ServiceInvoice? getInvoiceByNumber(String invoiceNumber) {
    try {
      return _invoices.firstWhere((inv) => inv.invoiceNumber == invoiceNumber);
    } catch (e) {
      return null;
    }
  }

  Future<void> generateInvoicePDF(ServiceInvoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        invoice.invoiceNumber,
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Your Company Name',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Address Line 1',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Address Line 2',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Phone: +966 XXX XXX XXX',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // CUSTOMER + SERVICE INFO
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BILL TO:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        invoice.customerName,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        invoice.customerAddress,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'SERVICE INFO:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      _buildInfoRow('Service:', invoice.serviceName),
                      _buildInfoRow('Worker:', invoice.workerName),
                      _buildInfoRow(
                        'Date:',
                        '${invoice.completionDate.day}/${invoice.completionDate.month}/${invoice.completionDate.year}',
                      ),
                      _buildInfoRow(
                        'Payment:',
                        invoice.paymentMethod.toLowerCase() == 'cash'
                            ? 'Paid by Cash'
                            : 'Paid via STC Account',
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // ITEMS TABLE
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableHeader('Description'),
                      _buildTableHeader('Type'),
                      _buildTableHeader('Amount'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildTableCell(invoice.serviceName),
                      _buildTableCell('Service'),
                      _buildTableCell('SAR ${invoice.basePrice.toStringAsFixed(2)}'),
                    ],
                  ),
                  ...invoice.extraItems.map((item) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(item.name),
                        _buildTableCell(item.type),
                        _buildTableCell('SAR ${item.price.toStringAsFixed(2)}'),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 20),

              // TOTALS SECTION
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 250,
                  child: pw.Column(
                    children: [
                      _buildTotalRow(
                        'Subtotal:',
                        'SAR ${(invoice.basePrice + invoice.extraCharges).toStringAsFixed(2)}',
                      ),
                      _buildTotalRow(
                        'VAT (15%):',
                        'SAR ${invoice.vat.toStringAsFixed(2)}',
                      ),
                      pw.Divider(),
                      _buildTotalRow(
                        'TOTAL:',
                        'SAR ${invoice.totalAmount.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 30),

              // ✅ ENHANCED PAYMENT SECTION WITH STC ACCOUNT
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  color: PdfColors.grey100,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'PAYMENT METHOD',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              invoice.paymentMethod.toLowerCase() == 'cash'
                                  ? 'Paid by Cash at Service Location'
                                  : 'Paid via STC Pay / Bank Transfer',
                              style: const pw.TextStyle(fontSize: 12),
                            ),

                            // ✅ SHOW STC ACCOUNT FOR ONLINE PAYMENTS
                            if (invoice.paymentMethod.toLowerCase() != 'cash') ...[
                              pw.SizedBox(height: 12),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.blue50,
                                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                                  border: pw.Border.all(color: PdfColors.blue200),
                                ),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      'Transfer Details:',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.blue800,
                                      ),
                                    ),
                                    pw.SizedBox(height: 4),
                                    pw.Text(
                                      'Account: $ADMIN_STC_ACCOUNT',
                                      style: pw.TextStyle(
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.blue900,
                                      ),
                                    ),
                                    pw.Text(
                                      'Name: Admin Account',
                                      style: const pw.TextStyle(
                                        fontSize: 9,
                                        color: PdfColors.blue700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.green100,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            'PAID',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              pw.Divider(),
              pw.SizedBox(height: 10),

              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
              ),

              pw.Center(
                child: pw.Text(
                  'For support, contact us at support@example.com',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // SAVE FILE
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/invoice_${invoice.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  Future<void> downloadInvoicePDF(ServiceInvoice invoice) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/invoice_${invoice.invoiceNumber}.pdf';
      final file = File(filePath);

      if (!await file.exists()) {
        await generateInvoicePDF(invoice);
      }

      await OpenFilex.open(filePath);
    } catch (e) {
      throw Exception('Failed to download invoice: $e');
    }
  }

  // Helper Widgets
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(width: 10),
        pw.Text(value,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  pw.Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Legacy Method
  Future<void> generateInvoiceForCompletedService({
    required String serviceId,
    required String serviceName,
    required String customerName,
    required String customerAddress,
    required String workerName,
    required double basePrice,
    required double extraCharges,
    required List<Map<String, dynamic>> extraItems,
    required DateTime completionDate,
    required String paymentMethod,
  }) async {
    final extraItemModels = extraItems.map((item) {
      return ExtraItem(
        id: item['id'] ?? '',
        name: item['name'] ?? '',
        type: item['type'] ?? 'service',
        price: (item['price'] ?? 0.0).toDouble(),
        description: item['description'],
      );
    }).toList();

    final total = basePrice + extraCharges;
    final vat = total * 0.15;
    final commission = total * 0.20;

    final invoice = ServiceInvoice(
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      serviceRequestId: serviceId,
      serviceId: serviceId,
      serviceName: serviceName,
      customerId: 'N/A',
      customerName: customerName,
      customerAddress: customerAddress,
      workerName: workerName,
      basePrice: basePrice,
      extraCharges: extraCharges,
      extraItems: extraItemModels,
      totalAmount: total + vat,
      vat: vat,
      commission: commission,
      completionDate: completionDate,
      paymentMethod: paymentMethod,
      status: 'Paid',
    );

    await saveInvoice(invoice);
  }
}