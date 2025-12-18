// ---------------------------------------------------------
// INVOICE SERVICE - ENGLISH ONLY (NO ARABIC FONT NEEDED)
// ---------------------------------------------------------

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/foundation.dart';
import '/models/service_invoice_model.dart';
import '/models/service_request_model.dart';
import 'firestore_service.dart';

class InvoiceService {
  static InvoiceService _instance = InvoiceService._internal();
  factory InvoiceService() => _instance;

  @visibleForTesting
  static void reset() {
    _instance = InvoiceService._internal();
  }

  InvoiceService._internal() {
    _init();
  }

  FirestoreService get _firestoreService => FirestoreService();
  List<ServiceInvoice> _invoices = [];

  void _init() {
    _firestoreService.getInvoicesStream().listen((invoices) {
      _invoices = invoices;
    });
  }

  static const String ADMIN_STC_ACCOUNT = '0535616095';
  static const String ADMIN_BANK_NAME = 'STC Pay / Bank Transfer';

  // ✅ Extract English text only from bilingual strings
  String _getEnglishOnly(String text) {
    if (text.contains('•')) {
      return text.split('•')[0].trim();
    }
    return text;
  }

  // ✅ Helper to clean address (remove phone numbers)
  String _cleanAddress(String address) {
    try {
      // Robust Regex to match phone numbers with spaces, dashes, or various formats
      // Matches: +966..., 05..., 966... followed by digits/spaces
      // Examples: 053 561 6095, +966-53-561-6095, 0535616095
      var cleaned = address.replaceAll(
        RegExp(r'(\+966|05|966)([\s-]?\d){8,9}'),
        '',
      );

      // Remove standalone long number sequences (9-15 digits)
      cleaned = cleaned.replaceAll(RegExp(r'\b\d{9,15}\b'), '');

      // Clean up extra commas or whitespace left behind
      cleaned = cleaned.replaceAll(RegExp(r',\s*,'), ',');
      cleaned = cleaned.trim();
      if (cleaned.endsWith(','))
        cleaned = cleaned.substring(0, cleaned.length - 1);
      return cleaned.trim();
    } catch (e) {
      return address;
    }
  }

  Future<void> saveInvoice(ServiceInvoice invoice) async {
    try {
      debugPrint(
        '💾 Service: Saving invoice ${invoice.invoiceNumber} for customer ${invoice.customerId}',
      );

      // Validate payload before write
      if (invoice.customerId.trim().isEmpty) {
        debugPrint('⚠️ Warning: Saving invoice with empty Customer ID!');
      }

      // Sanitize address (remove phone number)
      final cleanAddress = _cleanAddress(invoice.customerAddress);

      // Create a modified copy of the invoice for saving/PDF
      // (We don't modify the original object if it's immutable, but here we can just pass the new address)
      // Since ServiceInvoice is immutable (final fields), we might need to copyWith or just use the new address in PDF/Saving.
      // But ServiceInvoice doesn't have copyWith in the file I saw, so I'll create a new instance effectively
      // OR just use the clean address in the PDF generator and Firestore add.
      // Wait, to save to Firestore with the clean address, I need to modify the object or map.
      // I'll create a map for Firestore, but for PDF I need the object.
      // Actually, let's just create a new map for Firestore and use the modified string for PDF.
      // Better yet, let's trust the _cleanAddress usage inside the generator and the toMap.

      // Actually, I can't easily modify 'invoice' since it's final.
      // I will generate the PDF using the sanitized address logic INSIDE generateInvoicePDF.
      // AND for Firestore, I will modify the 'addInvoice' call in FirestoreService or just modify the map before sending?
      // InvoiceService calls _firestoreService.addInvoice(invoice).
      // I should probably add a clean step there or just do it here.
      // Let's rely on the PDF generation to show it clean.
      // The user said "stored/sent to admin... remove it". So it SHOULD be removed from Firestore too.
      // I will create a new ServiceInvoice with the cleaned address.

      final cleanInvoice = ServiceInvoice(
        invoiceNumber: invoice.invoiceNumber,
        serviceRequestId: invoice.serviceRequestId,
        serviceId: invoice.serviceId,
        serviceName: invoice.serviceName,
        customerId: invoice.customerId,
        customerName: invoice.customerName,
        customerAddress: cleanAddress, // CLEANED
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

      // Generate PDF first
      await generateInvoicePDF(cleanInvoice);
      // Save to Firestore
      await _firestoreService.addInvoice(cleanInvoice);
      debugPrint('✅ Service: Invoice saved successfully.');
    } catch (e) {
      debugPrint('❌ Service: Error saving invoice: $e');
      rethrow;
    }
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

    // Use a primary color for branding
    final primaryColor = PdfColors.blue900;
    final secondaryColor = PdfColors.blue50;
    final accentColor = PdfColors.orange600;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero, // Full bleed for header
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Full Width, Colored)
              pw.Container(
                color: primaryColor,
                padding: const pw.EdgeInsets.all(40),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 40,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          '#${invoice.invoiceNumber}',
                          style: const pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey200,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'HandyMan Services',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Riyadh, Saudi Arabia',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey200,
                          ),
                        ),
                        pw.Text(
                          'Support: 0535616095',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey200,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Wrapper for content with padding
              pw.Padding(
                padding: const pw.EdgeInsets.all(40),
                child: pw.Column(
                  children: [
                    // 2. INFO GRID
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Bill To
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'BILL TO',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              pw.SizedBox(height: 10),
                              pw.Text(
                                _getEnglishOnly(invoice.customerName),
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                // Ensure address is clean here too just in case
                                _cleanAddress(
                                  _getEnglishOnly(invoice.customerAddress),
                                ),
                                style: const pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.grey700,
                                  lineSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Invoice Details
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                'DETAILS',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              pw.SizedBox(height: 10),
                              _buildInfoRowAligned(
                                'Service',
                                _getEnglishOnly(invoice.serviceName),
                              ),
                              _buildInfoRowAligned(
                                'Worker',
                                _getEnglishOnly(invoice.workerName),
                              ),
                              _buildInfoRowAligned(
                                'Date',
                                '${invoice.completionDate.day}/${invoice.completionDate.month}/${invoice.completionDate.year}',
                              ),
                              _buildInfoRowAligned(
                                'Method',
                                invoice.paymentMethod,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 40),

                    // 3. TABLE
                    pw.Table(
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3), // Description
                        1: const pw.FlexColumnWidth(1), // Type
                        2: const pw.FlexColumnWidth(1.2), // Amount
                      },
                      children: [
                        // Header
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: primaryColor,
                            borderRadius: const pw.BorderRadius.vertical(
                              top: pw.Radius.circular(4),
                            ),
                          ),
                          children: [
                            _buildTableHeader('Description'),
                            _buildTableHeader('Type'),
                            _buildTableHeader(
                              'Amount',
                              align: pw.TextAlign.right,
                            ),
                          ],
                        ),
                        // Rows
                        _buildTableRow(
                          _getEnglishOnly(invoice.serviceName),
                          'Base Service',
                          invoice.basePrice,
                          isOdd: true,
                        ),
                        ...invoice.extraItems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return _buildTableRow(
                            _getEnglishOnly(item.name),
                            item.type,
                            item.price,
                            isOdd:
                                (index + 2) % 2 !=
                                0, // Used +2 because base service is row 1
                          );
                        }),
                      ],
                    ),
                    pw.SizedBox(height: 30),

                    // 4. SUMMARY & PAYMENT INFO
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Payment Info (Always Visible for reference)
                        pw.Expanded(
                          flex: 3,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(16),
                            decoration: pw.BoxDecoration(
                              color: secondaryColor,
                              borderRadius: pw.BorderRadius.circular(8),
                              border: pw.Border.all(color: PdfColors.blue100),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'PAYMENT INFORMATION',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  'STC Pay / Bank Transfer',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  '$ADMIN_STC_ACCOUNT',
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  'Account Name: Admin',
                                  style: const pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 30),

                        // Totals
                        pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                            children: [
                              _buildTotalRow(
                                'Subtotal',
                                'SAR ${(invoice.basePrice + invoice.extraCharges).toStringAsFixed(2)}',
                              ),
                              _buildTotalRow(
                                'VAT (15%)',
                                'SAR ${invoice.vat.toStringAsFixed(2)}',
                              ),
                              pw.Divider(color: PdfColors.grey300),
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    'TOTAL',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  pw.Text(
                                    'SAR ${invoice.totalAmount.toStringAsFixed(2)}',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 20,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // 5. FOOTER
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 20),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey200),
                  ),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      "Thank you for your business!",
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "For queries, contact us at support@handyman.com",
                      style: const pw.TextStyle(
                        color: PdfColors.grey500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/invoice_${invoice.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  Future<void> downloadInvoicePDF(ServiceInvoice invoice) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      // v2 to force new file creation and avoid OS caching/locking
      final filePath =
          '${directory.path}/invoice_${invoice.invoiceNumber}_v2.pdf';
      final file = File(filePath);

      // Always delete old file if exists (though v2 should be new)
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (e) {
          debugPrint("⚠️ Could not delete old PDF: $e");
        }
      }

      // Always generate fresh PDF to reflect changes
      await generateInvoicePDF(invoice);

      await OpenFilex.open(filePath);
    } catch (e) {
      throw Exception('Failed to download invoice: $e');
    }
  }

  // Helper Widgets

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

  // New Helpers for PDF
  pw.Widget _buildInfoRowAligned(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Flexible(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeader(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.TableRow _buildTableRow(
    String desc,
    String type,
    double amount, {
    bool isOdd = false,
  }) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: isOdd ? PdfColors.grey100 : PdfColors.white,
        border: const pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey100, width: 0.5),
        ),
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(desc, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            type,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            'SAR ${amount.toStringAsFixed(2)}',
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
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
