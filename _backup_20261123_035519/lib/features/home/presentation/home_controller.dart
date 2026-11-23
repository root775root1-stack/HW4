import 'package:get/get.dart';

import '../../../core/services/database_service.dart';
import '../../../core/services/obligation_service.dart';

class DashboardStats {
  int properties = 0,
      units = 0,
      rented = 0,
      available = 0,
      tenants = 0,
      activeContracts = 0;
  double dueThisMonth = 0, paid = 0, remaining = 0, overdue = 0;
}

class HomeController extends GetxController with StateMixin<DashboardStats> {
  DatabaseService get _db => Get.find<DatabaseService>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<int> _count(String sql, [List<Object?>? args]) async {
    final r = await _db.db.rawQuery(sql, args);
    return (r.first.values.first as int?) ?? 0;
  }

  Future<double> _sum(String sql, [List<Object?>? args]) async {
    final r = await _db.db.rawQuery(sql, args);
    return ((r.first.values.first as num?) ?? 0).toDouble();
  }

  Future<void> load() async {
    change(null, status: RxStatus.loading());
    try {
      final s = DashboardStats();
      final period = ObligationService.periodOf(DateTime.now());

      s.properties = await _count('SELECT COUNT(*) FROM properties');
      s.units = await _count('SELECT COUNT(*) FROM units');
      s.rented = await _count("SELECT COUNT(*) FROM units WHERE status='rented'");
      s.available =
          await _count("SELECT COUNT(*) FROM units WHERE status='available'");
      s.tenants = await _count('SELECT COUNT(*) FROM tenants');
      s.activeContracts =
          await _count("SELECT COUNT(*) FROM contracts WHERE status='active'");

      s.dueThisMonth = await _sum(
          "SELECT SUM(amount) FROM obligations WHERE period=? AND status!='cancelled'",
          [period]);
      s.paid = await _sum(
          "SELECT SUM(paid_amount) FROM obligations WHERE period=? AND status!='cancelled'",
          [period]);
      s.remaining = s.dueThisMonth - s.paid;
      s.overdue = await _sum(
          "SELECT SUM(amount - paid_amount) FROM obligations WHERE status='overdue'");

      change(s, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}