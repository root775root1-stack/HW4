import 'package:get/get.dart';

import '../../../core/crud/generic_repository.dart';
import '../../../core/services/data_bus.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/obligation_service.dart';

class DashboardData {
  int properties = 0,
      units = 0,
      occupied = 0,
      available = 0,
      tenants = 0,
      activeContracts = 0,
      overdueCount = 0;
  double dueThisMonth = 0, paidThisMonth = 0, outstanding = 0, overdue = 0;
  List<DbRow> recentContracts = [];
  List<DbRow> recentPayments = [];
  List<DbRow> upcoming = [];
  List<DbRow> overdueList = [];
}

class HomeController extends GetxController with StateMixin<DashboardData> {
  DatabaseService get _db => Get.find<DatabaseService>();
  Worker? _worker;

  @override
  void onInit() {
    super.onInit();
    load();
    // Refresh whenever any module adds / edits / deletes data.
    _worker = ever(Get.find<DataBus>().tick, (_) => load(silent: true));
  }

  @override
  void onClose() {
    _worker?.dispose();
    super.onClose();
  }

  Future<num> _num(String sql, [List<Object?>? args]) async {
    final r = await _db.db.rawQuery(sql, args);
    return (r.first.values.first as num?) ?? 0;
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) change(null, status: RxStatus.loading());
    try {
      final now = DateTime.now();
      final today = ObligationMath.iso(now);
      final monthStart = ObligationMath.iso(DateTime(now.year, now.month, 1));
      final monthEnd = ObligationMath.iso(DateTime(now.year, now.month + 1, 0));
      final soon = ObligationMath.iso(now.add(const Duration(days: 14)));

      final d = DashboardData();
      d.properties = (await _num('SELECT COUNT(*) FROM properties')).toInt();
      d.units = (await _num('SELECT COUNT(*) FROM units')).toInt();
      d.occupied =
          (await _num("SELECT COUNT(*) FROM units WHERE status='rented'"))
              .toInt();
      d.available =
          (await _num("SELECT COUNT(*) FROM units WHERE status='available'"))
              .toInt();
      d.tenants = (await _num('SELECT COUNT(*) FROM tenants')).toInt();
      d.activeContracts =
          (await _num("SELECT COUNT(*) FROM contracts WHERE status='active'"))
              .toInt();

      d.dueThisMonth = (await _num(
              "SELECT SUM(amount) FROM obligations WHERE status!='cancelled' "
              'AND due_date BETWEEN ? AND ?',
              [monthStart, monthEnd]))
          .toDouble();
      d.paidThisMonth = (await _num(
              'SELECT SUM(amount) FROM payments WHERE paid_on BETWEEN ? AND ?',
              [monthStart, monthEnd]))
          .toDouble();
      d.outstanding =
          (await _num("SELECT SUM(amount - paid_amount) FROM obligations "
                  "WHERE status NOT IN ('paid','cancelled')"))
              .toDouble();
      d.overdue = (await _num(
              "SELECT SUM(amount - paid_amount) FROM obligations WHERE status='overdue'"))
          .toDouble();
      d.overdueCount = (await _num(
              "SELECT COUNT(*) FROM obligations WHERE status='overdue'"))
          .toInt();

      d.recentContracts = await _db.db.rawQuery('''
        SELECT c.id, c.contract_no, c.status, c.rent_amount, c.start_date,
               t.full_name AS tenant_name, u.number AS unit_number,
               p.name AS property_name
        FROM contracts c
        JOIN tenants t ON t.id = c.tenant_id
        JOIN units u ON u.id = c.unit_id
        JOIN properties p ON p.id = u.property_id
        ORDER BY c.id DESC LIMIT 5''');

      d.recentPayments = await _db.db.rawQuery('''
        SELECT pay.id, pay.amount, pay.paid_on, t.full_name AS tenant_name,
               u.number AS unit_number
        FROM payments pay
        JOIN tenants t ON t.id = pay.tenant_id
        JOIN obligations o ON o.id = pay.obligation_id
        LEFT JOIN units u ON u.id = o.unit_id
        ORDER BY pay.paid_on DESC, pay.id DESC LIMIT 5''');

      const obl = '''
        SELECT o.id, o.type, o.period, o.due_date, o.amount, o.paid_amount,
               o.status, t.full_name AS tenant_name, u.number AS unit_number
        FROM obligations o
        JOIN tenants t ON t.id = o.tenant_id
        LEFT JOIN units u ON u.id = o.unit_id''';
      d.upcoming = await _db.db.rawQuery(
          "$obl WHERE o.status IN ('unpaid','partial') AND o.due_date >= ? AND o.due_date <= ? "
          'ORDER BY o.due_date LIMIT 5',
          [today, soon]);
      d.overdueList = await _db.db.rawQuery(
          "$obl WHERE o.status = 'overdue' ORDER BY o.due_date LIMIT 5");

      change(d, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}
