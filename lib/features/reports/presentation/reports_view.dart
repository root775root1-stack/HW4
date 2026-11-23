import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/crud/generic_repository.dart';
import '../../../core/services/database_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';

class ReportDef {
  const ReportDef(this.key, this.icon, this.sql);
  final String key;
  final IconData icon;
  final String sql;
}

final reportDefs = <ReportDef>[
  const ReportDef('report_properties', Icons.apartment_outlined, '''
    SELECT p.name, p.city,
      (SELECT COUNT(*) FROM units u WHERE u.property_id = p.id) AS units,
      (SELECT COUNT(*) FROM units u WHERE u.property_id = p.id AND u.status='rented') AS rented
    FROM properties p ORDER BY p.name'''),
  const ReportDef('report_tenants', Icons.people_outline, '''
    SELECT t.full_name, t.phone,
      (SELECT COUNT(*) FROM contracts c WHERE c.tenant_id = t.id AND c.status='active') AS active_contracts
    FROM tenants t ORDER BY t.full_name'''),
  const ReportDef('report_contracts', Icons.description_outlined, '''
    SELECT c.contract_no, c.status, t.full_name AS tenant, u.number AS unit, c.start_date, c.end_date
    FROM contracts c JOIN tenants t ON t.id=c.tenant_id JOIN units u ON u.id=c.unit_id
    ORDER BY c.id DESC'''),
  const ReportDef('report_obligations', Icons.request_quote_outlined, '''
    SELECT o.period, t.full_name AS tenant, o.type, o.amount, o.paid_amount, o.status
    FROM obligations o JOIN tenants t ON t.id=o.tenant_id
    ORDER BY o.due_date DESC LIMIT 200'''),
  const ReportDef('report_payments', Icons.payments_outlined, '''
    SELECT pay.paid_on, t.full_name AS tenant, pay.amount, pay.method
    FROM payments pay JOIN tenants t ON t.id=pay.tenant_id
    ORDER BY pay.paid_on DESC LIMIT 200'''),
  const ReportDef('report_overdue', Icons.warning_amber_outlined, '''
    SELECT o.due_date, t.full_name AS tenant, u.number AS unit, (o.amount - o.paid_amount) AS balance
    FROM obligations o JOIN tenants t ON t.id=o.tenant_id LEFT JOIN units u ON u.id=o.unit_id
    WHERE o.status='overdue' ORDER BY o.due_date'''),
  const ReportDef('report_services', Icons.build_outlined, '''
    SELECT s.name, s.billing_type, s.amount,
      COALESCE(p.name, (SELECT pr.name FROM units un JOIN properties pr ON pr.id=un.property_id WHERE un.id=s.unit_id)) AS target
    FROM services s LEFT JOIN properties p ON p.id = s.property_id ORDER BY s.name'''),
];

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('reports'.tr)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reportDefs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (c, i) {
          final r = reportDefs[i];
          return Card(
            child: ListTile(
              leading:
                  Icon(r.icon, color: Theme.of(context).colorScheme.primary),
              title: Text(r.key.tr),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed('/report-view', arguments: r),
            ),
          );
        },
      ),
    );
  }
}

class ReportViewScreen extends StatelessWidget {
  const ReportViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final def = Get.arguments as ReportDef;
    return Scaffold(
      appBar: AppBar(title: Text(def.key.tr)),
      body: FutureBuilder<List<DbRow>>(
        future: Get.find<DatabaseService>().db.rawQuery(def.sql),
        builder: (context, snap) {
          if (!snap.hasData) return const LoadingState();
          final rows = snap.data!;
          if (rows.isEmpty) {
            return EmptyState(icon: def.icon, titleKey: 'no_data');
          }
          final cols = rows.first.keys.toList();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                for (final c in cols) DataColumn(label: Text('f_$c'.tr))
              ],
              rows: [
                for (final r in rows)
                  DataRow(cells: [
                    for (final c in cols) DataCell(Text(_cell(c, r[c]))),
                  ]),
              ],
            ),
          );
        },
      ),
    );
  }

  String _cell(String col, Object? v) {
    if (v == null) return '';
    if (col == 'amount' || col == 'paid_amount' || col == 'balance') {
      return formatMoney(toD(v));
    }
    if (col == 'status') return 'o_$v'.tr;
    if (col == 'type')
      return '$v'.startsWith('service:') ? 'service_charge'.tr : 'rent'.tr;
    if (col == 'billing_type') return 'o_$v'.tr;
    return '$v';
  }
}
