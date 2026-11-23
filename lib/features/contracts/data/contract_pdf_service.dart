// LEGAL NOTE
// ----------------------------------------------------------------------------
// The generated lease contract is a CUSTOMIZABLE TEMPLATE. It is not legal
// advice and does not claim to be valid in every country. The governing law,
// jurisdiction, dispute resolution and all clauses are entered by the owner
// per contract. Have the final wording reviewed by a qualified lawyer under
// the applicable local law before use.
// ----------------------------------------------------------------------------
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/crud/generic_repository.dart';
import '../../../core/locale/labels.dart';
import '../../../core/services/pdf_support.dart';
import '../../../core/utils/formatters.dart';
import 'contract_repository.dart';

class ContractPdfService {
  static const _optionKeys = {
    'contract_type',
    'language',
    'late_fee_type',
    'payment_cycle',
    'payment_method',
    'electricity_resp',
    'water_resp',
    'internet_resp',
    'maintenance_resp',
    'id_type',
  };
  static const _toggleKeys = {
    'renewal_option',
    'sublet_allowed',
    'pets_allowed',
    'smoking_allowed',
    'alterations_allowed',
  };
  static const _moneyKeys = {
    'rent_amount',
    'deposit_amount',
    'advance_payment',
    'service_charges',
    'commission',
  };

  /// Builds the PDF for [b] in language [lang] ('ar' = RTL layout).
  Future<Uint8List> build(ContractBundle b, {required String lang}) async {
    final rtl = lang == 'ar';
    final t = (String k) => labelFor(k, lang);
    final c = b.contract;
    final currency = txt(c['currency']);

    String val(String key, Object? raw) {
      final s = txt(raw);
      if (s.isEmpty) return '';
      if (_toggleKeys.contains(key))
        return (s == '1' || s == 'true') ? t('yes') : t('no');
      if (_optionKeys.contains(key)) return t('o_$s');
      if (_moneyKeys.contains(key)) {
        final n = num.tryParse(s);
        if (n != null) return '${formatNumber(n)} $currency'.trim();
      }
      if (key == 'late_fee') {
        final n = num.tryParse(s);
        if (n != null) {
          final pct = txt(c['late_fee_type']) == 'percentage';
          return pct
              ? '${formatNumber(n)} %'
              : '${formatNumber(n)} $currency'.trim();
        }
      }
      return s;
    }

    MapEntry<String, String> row(String key, Object? raw) =>
        MapEntry(t('f_$key'), val(key, raw));

    List<MapEntry<String, String>> fromMap(List<String> keys, DbRow m) =>
        [for (final k in keys) row(k, m[k])];

    List<MapEntry<String, String>> fromClauses(
            String section, List<String> keys) =>
        [for (final k in keys) row(k, b.clause(section, k))];

    final body = <pw.Widget>[
      ...PdfSupport.section(t('step_info'), [
        row('contract_no', c['contract_no']),
        row('contract_type', c['contract_type']),
        row('created_date', c['created_date']),
        row('start_date', c['start_date']),
        row('end_date', c['end_date']),
        row('renewal_option', c['renewal_option']),
        row('renewal_period', c['renewal_period']),
        row('notice_period', c['notice_period']),
        row('language', c['language']),
        row('currency', c['currency']),
      ]),
      ...PdfSupport.section(
          t('step_landlord'),
          fromMap([
            'full_name',
            'name_ar',
            'name_en',
            'id_type',
            'id_number',
            'phone',
            'phone2',
            'email',
            'address',
            'city',
            'country',
            'bank_name',
            'iban',
            'rep_name',
            'rep_id',
            'notes'
          ], b.landlord)),
      ...PdfSupport.section(
          t('step_tenant'),
          fromMap([
            'full_name',
            'name_ar',
            'name_en',
            'id_type',
            'id_number',
            'nationality',
            'birth_date',
            'phone',
            'phone2',
            'email',
            'address',
            'employer',
            'emergency_name',
            'emergency_phone',
            'notes'
          ], b.tenant)),
      ...PdfSupport.section(t('step_unit'), [
        ...fromClauses('unit', [
          'property_name',
          'property_address',
          'unit_number',
          'floor',
          'unit_type',
          'area',
          'bedrooms',
          'bathrooms',
          'furnishing',
          'parking_space',
          'storage_room',
          'meter_electric',
          'meter_water',
          'facilities'
        ]),
        row('condition_at_handover', c['condition_at_handover']),
      ]),
      ...PdfSupport.section(t('step_financial'), [
        row('rent_amount', c['rent_amount']),
        row('rent_words', c['rent_words']),
        row('deposit_amount', c['deposit_amount']),
        row('advance_payment', c['advance_payment']),
        row('payment_cycle', c['payment_cycle']),
        row('due_day', c['due_day']),
        row('grace_period', c['grace_period']),
        row('late_fee', c['late_fee']),
        row('late_fee_type', c['late_fee_type']),
        ...fromClauses('financial', [
          'utilities_included',
          'electricity_resp',
          'water_resp',
          'internet_resp',
          'maintenance_resp',
          'service_charges',
          'commission',
          'other_charges',
          'bank_details'
        ]),
        row('payment_method', c['payment_method']),
        row('payment_notes', c['payment_notes']),
      ]),
      ...PdfSupport.section(t('step_conditions'), [
        ...fromClauses('conditions', [
          'permitted_use',
          'occupants_count',
          'sublet_allowed',
          'pets_allowed',
          'smoking_allowed',
          'alterations_allowed',
          'maintenance_terms',
          'repairs_resp',
          'inspection_rights',
          'access_notice',
          'noise_rules',
          'parking_rules',
          'common_area_rules',
          'insurance_req',
          'early_termination',
          'breach_terms'
        ]),
        row('dispute_resolution', c['dispute_resolution']),
        row('governing_law', c['governing_law']),
        row('jurisdiction', c['jurisdiction']),
        ...fromClauses(
            'conditions', ['special_conditions', 'additional_clauses']),
      ]),
      ...PdfSupport.section(t('step_handover'), [
        row('handover_date', c['handover_date']),
        row('keys_count', c['keys_count']),
        row('cards_count', c['cards_count']),
        MapEntry(t('f_furniture_list'), _inv(b, 'furniture')),
        MapEntry(t('f_appliances_list'), _inv(b, 'appliance')),
        MapEntry(t('f_damage_notes'), _inv(b, 'damage')),
        for (final r in b.readings)
          MapEntry(
              '${t('f_reading_${r['meter_type']}')}'
              '${txt(r['meter_no']).isEmpty ? '' : ' (${txt(r['meter_no'])})'}',
              txt(r['reading'])),
        row('handover_notes', c['handover_notes']),
      ]),
    ];

    final w1 = _witness(b, 1);
    final w2 = _witness(b, 2);
    final generated =
        DateFormat('yyyy-MM-dd HH:mm', 'en').format(DateTime.now());
    final no = txt(c['contract_no']);

    final theme = await PdfSupport.theme();
    final doc = pw.Document(theme: theme, title: no, author: 'PTMS');
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 40),
        footer: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 6),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.grey500, width: 0.5))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('${t('f_contract_no')}: $no   •   $generated',
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey700)),
              pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}',
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey700)),
            ],
          ),
        ),
        build: (ctx) => [
          pw.Center(
            child: pw.Text(t('lease_agreement'),
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(txt(c['title']),
                style: const pw.TextStyle(fontSize: 13)),
          ),
          pw.SizedBox(height: 4),
          ...body,
          pw.NewPage(),
          ..._signatures(t, b, w1, w2),
        ],
      ),
    );
    return doc.save();
  }

  String _inv(ContractBundle b, String kind) => b.inventory
      .where((r) => r['kind'] == kind)
      .map((r) => '• ${r['description']}')
      .join('\n');

  DbRow? _witness(ContractBundle b, int pos) {
    for (final w in b.witnesses) {
      if (w['position'] == pos) return w;
    }
    return null;
  }

  /// Signature page. Signature and fingerprint boxes are intentionally EMPTY:
  /// they are completed by hand after printing. Nothing is drawn inside them.
  List<pw.Widget> _signatures(
      String Function(String) t, ContractBundle b, DbRow? w1, DbRow? w2) {
    final c = b.contract;
    pw.Widget box(String label, {double w = 200, double h = 85}) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 3),
            pw.Container(
              width: w,
              height: h,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey800, width: 0.8),
              ),
            ),
          ],
        );

    pw.Widget party(String role, String? name, String? id) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 18),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(role,
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
              if ((name ?? '').isNotEmpty)
                pw.Text(name!, style: const pw.TextStyle(fontSize: 10)),
              if ((id ?? '').isNotEmpty)
                pw.Text(id!, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 6),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  box(t('signature')),
                  pw.SizedBox(width: 24),
                  box(t('fingerprint'), w: 85),
                ],
              ),
            ],
          ),
        );

    return [
      PdfSupport.heading(t('step_witnesses')),
      if (txt(c['signed_date']).isNotEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text('${t('f_signed_date')}: ${txt(c['signed_date'])}'),
        )
      else
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text('${t('f_signed_date')}: ____ / ____ / ________'),
        ),
      pw.SizedBox(height: 10),
      party(t('landlord'), txt(b.landlord['full_name']),
          txt(b.landlord['id_number'])),
      party(
          t('tenant'), txt(b.tenant['full_name']), txt(b.tenant['id_number'])),
      party('${t('witness')} 1', txt(w1?['name']), txt(w1?['id_number'])),
      party('${t('witness')} 2', txt(w2?['name']), txt(w2?['id_number'])),
    ];
  }
}
