import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Shared PDF helpers: Arabic-capable font loading and common widgets.
///
/// Arabic text needs a font that contains Arabic glyphs. Put these files in
/// assets/fonts/ (and declare the folder in pubspec.yaml):
///   Cairo-Regular.ttf, Cairo-Bold.ttf   (free, OFL license, Google Fonts)
/// Without them the PDF still builds but Arabic letters will not render.
class PdfSupport {
  static pw.Font? _regular;
  static pw.Font? _bold;
  static bool _tried = false;

  static Future<void> _load() async {
    if (_tried) return;
    _tried = true;
    try {
      _regular =
          pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Regular.ttf'));
      _bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
    } catch (_) {
      _regular = null;
      _bold = null;
    }
  }

  static Future<bool> hasArabicFont() async {
    await _load();
    return _regular != null && _bold != null;
  }

  static Future<pw.ThemeData?> theme() async {
    await _load();
    if (_regular == null || _bold == null) return null;
    return pw.ThemeData.withFont(base: _regular!, bold: _bold!);
  }

  static const accent = PdfColor.fromInt(0xFF0F6E5C);
  static const light = PdfColor.fromInt(0xFFE8F1EF);

  static pw.Widget heading(String text) => pw.Container(
        width: double.infinity,
        margin: const pw.EdgeInsets.only(top: 12, bottom: 4),
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: const pw.BoxDecoration(color: light),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 12, color: accent)),
      );

  static pw.Widget kv(String k, String v) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        decoration: const pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
                flex: 2,
                child: pw.Text(k,
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(
                flex: 3,
                child: pw.Text(v, style: const pw.TextStyle(fontSize: 10))),
          ],
        ),
      );

  /// Section: heading + key/value rows. Empty values are skipped; a section
  /// with no rows is omitted entirely.
  static List<pw.Widget> section(
      String title, List<MapEntry<String, String>> rows) {
    final shown = rows.where((e) => e.value.trim().isNotEmpty).toList();
    if (shown.isEmpty) return const [];
    return [heading(title), for (final r in shown) kv(r.key, r.value)];
  }
}
