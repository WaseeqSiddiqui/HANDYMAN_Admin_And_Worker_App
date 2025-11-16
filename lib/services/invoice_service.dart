// lib/services/invoice_service.dart
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class InvoiceService {
  static final InvoiceService _instance = InvoiceService._internal();
  factory InvoiceService() => _instance;
  InvoiceService._internal();

  // Store all generated invoices
  final Map<String, InvoiceData> _invoices = {};

  // Generate and store invoice when service is completed
  Future<InvoiceData> generateInvoiceForCompletedService({
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
    final invoiceNumber = 'INV${DateTime.now().millisecondsSinceEpoch}';

    final invoice = InvoiceData(
      invoiceNumber: invoiceNumber,
      serviceId: serviceId,
      serviceName: serviceName,
      customerName: customerName,
      customerAddress: customerAddress,
      workerName: workerName,
      basePrice: basePrice,
      extraCharges: extraCharges,
      extraItems: extraItems,
      totalAmount: basePrice + extraCharges,
      vat: (basePrice + extraCharges) * 0.15,
      commission: (basePrice + extraCharges) * 0.20,
      completionDate: completionDate,
      paymentMethod: paymentMethod,
      status: 'Paid',
    );

    // Store invoice
    _invoices[invoiceNumber] = invoice;

    debugPrint('✅ Invoice generated: $invoiceNumber for service $serviceId');
    return invoice;
  }

  // Get invoice by invoice number
  InvoiceData? getInvoice(String invoiceNumber) {
    return _invoices[invoiceNumber];
  }

  // Get invoice by service ID
  InvoiceData? getInvoiceByServiceId(String serviceId) {
    return _invoices.values.firstWhere(
          (invoice) => invoice.serviceId == serviceId,
      orElse: () => InvoiceData(
        invoiceNumber: '',
        serviceId: '',
        serviceName: '',
        customerName: '',
        customerAddress: '',
        workerName: '',
        basePrice: 0,
        extraCharges: 0,
        extraItems: [],
        totalAmount: 0,
        vat: 0,
        commission: 0,
        completionDate: DateTime.now(),
        paymentMethod: '',
        status: '',
      ),
    );
  }

  // Get all invoices
  List<InvoiceData> getAllInvoices() {
    return _invoices.values.toList();
  }

  // Generate PDF for invoice
  Future<void> downloadInvoicePDF(InvoiceData invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TAX INVOICE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Aidea Services',
                        style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green100,
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Text(
                      invoice.status.toUpperCase(),
                      style: pw.TextStyle(
                        color: PdfColors.green700,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Invoice Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Invoice #: ${invoice.invoiceNumber}'),
                  pw.Text('Service #: ${invoice.serviceId}'),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text('Date: ${invoice.completionDate.day}/${invoice.completionDate.month}/${invoice.completionDate.year}'),
              pw.SizedBox(height: 30),

              // Customer Info
              pw.Text('BILL TO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(invoice.customerName, style: const pw.TextStyle(fontSize: 16)),
              pw.Text(invoice.customerAddress),
              pw.SizedBox(height: 30),

              // Service Details
              pw.Text('SERVICE DETAILS:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Service: ${invoice.serviceName}'),
              pw.Text('Worker: ${invoice.workerName}'),
              pw.SizedBox(height: 30),

              // Invoice Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Base Service
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(invoice.serviceName),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('SAR ${invoice.basePrice.toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                  // Extra Items
                  ...invoice.extraItems.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('  • ${item['name']} (${item['type']})'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('SAR ${(item['price'] as num).toDouble().toStringAsFixed(2)}'),
                      ),
                    ],
                  )).toList(),
                  // Subtotal
                  if (invoice.extraCharges > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Extra Charges Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('SAR ${invoice.extraCharges.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                  // Total
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('TOTAL AMOUNT', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('SAR ${invoice.totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Payment Info
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('PAYMENT INFORMATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text('Payment Method: ${invoice.paymentMethod}'),
                    pw.Text('Status: ${invoice.status}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      debugPrint('✅ Invoice PDF generated successfully');
    } catch (e) {
      debugPrint('❌ Error generating PDF: $e');
      rethrow;
    }
  }

  // Share invoice PDF
  Future<void> shareInvoicePDF(InvoiceData invoice) async {
    final pdf = pw.Document();
    // ... (same PDF generation code as above)

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'invoice_${invoice.invoiceNumber}.pdf',
    );
  }
}

// Invoice Data Model
class InvoiceData {
  final String invoiceNumber;
  final String serviceId;
  final String serviceName;
  final String customerName;
  final String customerAddress;
  final String workerName;
  final double basePrice;
  final double extraCharges;
  final List<Map<String, dynamic>> extraItems;
  final double totalAmount;
  final double vat;
  final double commission;
  final DateTime completionDate;
  final String paymentMethod;
  final String status;

  InvoiceData({
    required this.invoiceNumber,
    required this.serviceId,
    required this.serviceName,
    required this.customerName,
    required this.customerAddress,
    required this.workerName,
    required this.basePrice,
    required this.extraCharges,
    required this.extraItems,
    required this.totalAmount,
    required this.vat,
    required this.commission,
    required this.completionDate,
    required this.paymentMethod,
    required this.status,
  });
}