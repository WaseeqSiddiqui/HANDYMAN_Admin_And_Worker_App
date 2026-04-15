import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import '../models/commission_record_model.dart';
import '../models/vat_model.dart';

class ReportPdfService {
  static final ReportPdfService _instance = ReportPdfService._internal();
  factory ReportPdfService() => _instance;

  ReportPdfService._internal();

  static const String ADMIN_COMPANY_NAME = 'HandyMan Services';
  static const String ADMIN_COMPANY_ADDRESS = 'Riyadh, Saudi Arabia';
  static const String VAT_REGISTRATION_NUMBER = '312875789500003';
  static const String SUPPORT_PHONE = '0535616095';

  // ================= VAT REPORT =================

  Future<void> downloadVATReportPDF(List<VATRecord> records, String period) async {
    try {
      final file = await _generateVATReportPDF(records, period);
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      debugPrint('Error generating VAT Report: $e');
      throw Exception('Failed to download VAT report: $e');
    }
  }

  Future<File> _generateVATReportPDF(List<VATRecord> records, String period) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    final primaryColor = PdfColors.orange600;
    
    final totalServiceAmount = records.fold<double>(0.0, (sum, r) => sum + r.serviceAmount);
    final totalVAT = records.fold<double>(0.0, (sum, r) => sum + r.vatAmount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildReportHeader('VAT REPORT', period, primaryColor, fontBold),
        footer: (context) => _buildReportFooter(context, primaryColor),
        build: (context) {
          return [
            _buildReportSummaryGrid('Total Services Value', totalServiceAmount, 'Total VAT Collected', totalVAT, primaryColor, font, fontBold),
            pw.SizedBox(height: 30),
            _buildVATRecordsTable(records, primaryColor, font, fontBold),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final safePeriod = period.replaceAll(' ', '_').toLowerCase();
    final file = File('${directory.path}/VAT_Report_$safePeriod.pdf');
    if (await file.exists()) {
      try { await file.delete(); } catch (_) {}
    }
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildVATRecordsTable(List<VATRecord> records, PdfColor headerColor, pw.Font font, pw.Font fontBold) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(2), // Date
        1: const pw.FlexColumnWidth(3), // Service Name
        2: const pw.FlexColumnWidth(2), // Service Amount
        3: const pw.FlexColumnWidth(2), // VAT Amount
        4: const pw.FlexColumnWidth(1), // Status
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerColor, borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(4))),
          children: [
            _buildTableHeader('Date', fontBold),
            _buildTableHeader('Service', fontBold),
            _buildTableHeader('Amount (SAR)', fontBold, align: pw.TextAlign.right),
            _buildTableHeader('VAT (SAR)', fontBold, align: pw.TextAlign.right),
            _buildTableHeader('Status', fontBold, align: pw.TextAlign.center),
          ],
        ),
        ...records.asMap().entries.map((entry) {
          final index = entry.key;
          final record = entry.value;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index % 2 == 0 ? PdfColors.grey100 : PdfColors.white,
              border: const pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
            ),
            children: [
              _buildTableCell('${record.date.day}/${record.date.month}/${record.date.year}', font),
              _buildTableCell(record.serviceName, font),
              _buildTableCell(record.serviceAmount.toStringAsFixed(2), font, align: pw.TextAlign.right),
              _buildTableCell(record.vatAmount.toStringAsFixed(2), fontBold, align: pw.TextAlign.right),
              _buildTableCell(record.status.toUpperCase(), font, align: pw.TextAlign.center, color: PdfColors.green700),
            ],
          );
        }),
      ],
    );
  }

  // ================= COMMISSION REPORT =================

  Future<void> downloadCommissionReportPDF(List<CommissionRecord> records, String period) async {
    try {
      final file = await _generateCommissionReportPDF(records, period);
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      debugPrint('Error generating Commission Report: $e');
      throw Exception('Failed to download Commission report: $e');
    }
  }

  Future<File> _generateCommissionReportPDF(List<CommissionRecord> records, String period) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    final primaryColor = PdfColor.fromHex('#7B1FA2'); // Purple
    
    final totalServiceAmount = records.fold<double>(0.0, (sum, r) => sum + r.serviceAmount);
    final totalCommission = records.fold<double>(0.0, (sum, r) => sum + r.commissionAmount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildReportHeader('COMMISSION REPORT', period, primaryColor, fontBold),
        footer: (context) => _buildReportFooter(context, primaryColor),
        build: (context) {
          return [
            _buildReportSummaryGrid('Total Services Value', totalServiceAmount, 'Total Commission Collected', totalCommission, primaryColor, font, fontBold),
            pw.SizedBox(height: 30),
            _buildCommissionRecordsTable(records, primaryColor, font, fontBold),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final safePeriod = period.replaceAll(' ', '_').toLowerCase();
    final file = File('${directory.path}/Commission_Report_$safePeriod.pdf');
    if (await file.exists()) {
      try { await file.delete(); } catch (_) {}
    }
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildCommissionRecordsTable(List<CommissionRecord> records, PdfColor headerColor, pw.Font font, pw.Font fontBold) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(2), // Date
        1: const pw.FlexColumnWidth(2.5), // Worker
        2: const pw.FlexColumnWidth(2.5), // Service
        3: const pw.FlexColumnWidth(2), // Amount
        4: const pw.FlexColumnWidth(2), // Commission
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerColor, borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(4))),
          children: [
            _buildTableHeader('Date', fontBold),
            _buildTableHeader('Worker', fontBold),
            _buildTableHeader('Service', fontBold),
            _buildTableHeader('Amount (SAR)', fontBold, align: pw.TextAlign.right),
            _buildTableHeader('Comm. (SAR)', fontBold, align: pw.TextAlign.right),
          ],
        ),
        ...records.asMap().entries.map((entry) {
          final index = entry.key;
          final record = entry.value;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index % 2 == 0 ? PdfColors.grey100 : PdfColors.white,
              border: const pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
            ),
            children: [
              _buildTableCell('${record.date.day}/${record.date.month}/${record.date.year}', font),
              _buildTableCell(record.workerName, font),
              _buildTableCell(record.serviceName, font),
              _buildTableCell(record.serviceAmount.toStringAsFixed(2), font, align: pw.TextAlign.right),
              _buildTableCell(record.commissionAmount.toStringAsFixed(2), fontBold, align: pw.TextAlign.right, color: headerColor),
            ],
          );
        }),
      ],
    );
  }

  // ================= SHARED COMPONENTS =================

  pw.Widget _buildReportHeader(String title, String period, PdfColor color, pw.Font fontBold) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.only(bottom: 15),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: color, font: fontBold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Period: $period',
                style: const pw.TextStyle(fontSize: 14, color: PdfColors.black),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                ADMIN_COMPANY_NAME,
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: fontBold),
              ),
              pw.Text(ADMIN_COMPANY_ADDRESS, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
              pw.Text('Support: $SUPPORT_PHONE', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
              pw.Text('VAT: $VAT_REGISTRATION_NUMBER', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
            ],
          )
        ],
      )
    );
  }

  pw.Widget _buildReportSummaryGrid(String label1, double value1, String label2, double value2, PdfColor color, pw.Font font, pw.Font fontBold) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(label1, style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700, font: font)),
                pw.SizedBox(height: 5),
                pw.Text('SAR ${value1.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.black, font: fontBold)),
              ]
            ),
          )
        ),
        pw.SizedBox(width: 15),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: color.shade(0.1),
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: color.shade(0.3)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(label2, style: pw.TextStyle(fontSize: 12, color: color, font: font, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('SAR ${value2.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: color, font: fontBold)),
              ]
            ),
          )
        ),
      ]
    );
  }

  pw.Widget _buildTableHeader(String text, pw.Font fontBold, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold, font: fontBold),
      ),
    );
  }

  pw.Widget _buildTableCell(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left, PdfColor color = PdfColors.black}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontSize: 9, color: color, font: font),
      ),
    );
  }

  pw.Widget _buildReportFooter(pw.Context context, PdfColor color) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('End of Report', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        ],
      )
    );
  }
}
