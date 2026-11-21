import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ContractPdfData {
  ContractPdfData({
    required this.ownerName,
    required this.ownerId,
    required this.ownerPhone,
    required this.tenantName,
    required this.tenantId,
    required this.tenantPhone,
    required this.propertyName,
    required this.propertyAddress,
    required this.unitNumber,
    required this.rent,
    required this.currency,
    required this.deposit,
    required this.startDate,
    required this.endDate,
    required this.paymentCycle,
    required this.termsText,
  });

  final String ownerName, ownerId, ownerPhone;
  final String tenantName, tenantId, tenantPhone;
  final String propertyName, propertyAddress, unitNumber;
  final double rent, deposit;
  final String currency, startDate, endDate, paymentCycle, termsText;
}

/// Builds a printable contract PDF. Signature, thumbprint and witness areas
/// are intentionally left blank for manual completion after printing.
class ContractPdfService {
  Future<pw.Font?> _font(String asset) async {
    try {
      return pw.Font.ttf(await rootBundle.load(asset));
    } catch (_) {
      return null; // font file missing -> Arabic will not render
    }
  }

  Future<Uint8List> build(ContractPdfData d, {bool rtl = true}) async {
    final regular = await _font('assets/fonts/Cairo-Regular.ttf');
    final bold = await _font('assets/fonts/Cairo-Bold.ttf');
    final doc = pw.Document(
      theme: (regular != null && bold != null)
          ? pw.ThemeData.withFont(base: regular, bold: bold)
          : null,
    );

    pw.Widget row(String k, String v) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(children: [
            pw.SizedBox(
                width: 120,
                child: pw.Text(k,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(child: pw.Text(v)),
          ]),
        );

    pw.Widget box(String label) => pw.Container(
          width: 160,
          height: 70,
          decoration: pw.BoxDecoration(border: pw.Border.all()),
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
        );

    pw.Widget sigRow(String who) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(who, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [box('Signature / التوقيع'), box('Thumbprint / البصمة')],
            ),
          ]),
        );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Center(
            child: pw.Text('عقد إيجار / Lease Agreement',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Owner / المالك', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          row('Name', d.ownerName),
          row('ID', d.ownerId),
          row('Phone', d.ownerPhone),
          pw.SizedBox(height: 8),
          pw.Text('Tenant / المستأجر', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          row('Name', d.tenantName),
          row('ID', d.tenantId),
          row('Phone', d.tenantPhone),
          pw.SizedBox(height: 8),
          pw.Text('Property / العقار', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          row('Property', d.propertyName),
          row('Address', d.propertyAddress),
          row('Unit', d.unitNumber),
          pw.SizedBox(height: 8),
          pw.Text('Financial & Term / المالية والمدة',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          row('Rent', '${d.rent.toStringAsFixed(2)} ${d.currency}'),
          row('Deposit', '${d.deposit.toStringAsFixed(2)} ${d.currency}'),
          row('Cycle', d.paymentCycle),
          row('Start', d.startDate),
          row('End', d.endDate),
          pw.SizedBox(height: 8),
          pw.Text('Terms / الشروط', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(d.termsText),
          pw.SizedBox(height: 16),
          sigRow('Owner / المالك'),
          sigRow('Tenant / المستأجر'),
          sigRow('Witness 1 / الشاهد الأول:  ____________________'),
          sigRow('Witness 2 / الشاهد الثاني:  ____________________'),
          pw.SizedBox(height: 12),
          pw.Text('Date / التاريخ: ____ / ____ / ________'),
        ],
      ),
    );
    return doc.save();
  }

  Future<File> saveTo(File target, ContractPdfData d) async {
    return target.writeAsBytes(await build(d));
  }
}