import 'dart:math';

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import 'database_service.dart';

class ObligationMath {
  static String iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String periodOf(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  static double _r(double v) => (v * 100).round() / 100;

  /// Single source of truth for obligation status.
  static String statusFor(double amount, double paid, String dueDate,
      {DateTime? now}) {
    if (paid >= amount - 0.004) return ObligationStatus.paid;
    final today = iso(now ?? DateTime.now());
    if (dueDate.compareTo(today) < 0) return ObligationStatus.overdue;
    if (paid > 0) return ObligationStatus.partial;
    return ObligationStatus.unpaid;
  }

  /// Recomputes paid amount + status of an obligation from its payments.
  static Future<void> recalc(DatabaseExecutor tx, int obligationId) async {
    final o = await tx.query('obligations',
        where: 'id = ?', whereArgs: [obligationId], limit: 1);
    if (o.isEmpty) return;
    if (o.first['status'] == ObligationStatus.cancelled) return;
    final s = await tx.rawQuery(
        'SELECT COALESCE(SUM(amount),0) AS s FROM payments WHERE obligation_id = ?',
        [obligationId]);
    final paid = _r(((s.first['s'] as num?) ?? 0).toDouble());
    final amount = (o.first['amount'] as num).toDouble();
    await tx.update(
      'obligations',
      {
        'paid_amount': paid,
        'status': statusFor(amount, paid, o.first['due_date'] as String),
      },
      where: 'id = ?',
      whereArgs: [obligationId],
    );
  }
}

/// Creates rent and service obligations for active contracts.
/// Runs on app start and after contract activation; catches up all missed
/// periods. Idempotent through UNIQUE(contract_id, period, type).
class ObligationService extends GetxService {
  DatabaseService get _db => Get.find<DatabaseService>();

  static String periodOf(DateTime d) => ObligationMath.periodOf(d);

  /// Returns the number of obligations created.
  Future<int> runCatchUp({DateTime? now}) async {
    final clock = now ?? DateTime.now();
    var created = 0;
    await _db.db.transaction((txn) async {
      final contracts = await txn.query('contracts',
          where: 'status = ?', whereArgs: [ContractStatus.active]);
      for (final c in contracts) {
        created += await _forContract(txn, c, clock);
      }
      await _housekeeping(txn, clock);
    });
    return created;
  }

  Future<int> _forContract(
      Transaction txn, Map<String, Object?> c, DateTime now) async {
    var created = 0;
    final start = DateTime.parse(c['start_date'] as String);
    final end = DateTime.parse(c['end_date'] as String);
    final dueDay = (c['due_day'] as int?) ?? 1;
    final months = cycleMonths(c['payment_cycle'] as String?);
    final rent = (c['rent_amount'] as num).toDouble();
    final unitRows = await txn.query('units',
        where: 'id = ?', whereArgs: [c['unit_id']], limit: 1);
    if (unitRows.isEmpty) return 0;
    final unit = unitRows.first;

    DateTime dueFor(DateTime m) => DateTime(
        m.year, m.month, min(dueDay, DateTime(m.year, m.month + 1, 0).day));

    final lastMonth = DateTime(now.year, now.month);
    final endMonth = DateTime(end.year, end.month);

    // ---- rent, stepping by the payment cycle
    var cursor = DateTime(start.year, start.month);
    while (!cursor.isAfter(lastMonth) && !cursor.isAfter(endMonth)) {
      final id = await txn.insert(
        'obligations',
        {
          'tenant_id': c['tenant_id'],
          'contract_id': c['id'],
          'property_id': unit['property_id'],
          'unit_id': c['unit_id'],
          'type': ObligationType.rent,
          'period': periodOf(cursor),
          'due_date': ObligationMath.iso(dueFor(cursor)),
          'amount': rent * months,
          'status': ObligationStatus.unpaid,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      if (id > 0) created++;
      cursor = DateTime(cursor.year, cursor.month + months);
    }

    // ---- services, monthly
    final services = await txn.query('services',
        where:
            'is_active = 1 AND (unit_id = ? OR (unit_id IS NULL AND property_id = ?))',
        whereArgs: [c['unit_id'], unit['property_id']]);
    if (services.isEmpty) return created;

    cursor = DateTime(start.year, start.month);
    while (!cursor.isAfter(lastMonth) && !cursor.isAfter(endMonth)) {
      final period = periodOf(cursor);
      for (final s in services) {
        final amount = await _serviceAmount(txn, s, unit, period);
        if (amount == null || amount <= 0) continue;
        final id = await txn.insert(
          'obligations',
          {
            'tenant_id': c['tenant_id'],
            'contract_id': c['id'],
            'property_id': unit['property_id'],
            'unit_id': c['unit_id'],
            'type': ObligationType.service(s['id'] as int),
            'period': period,
            'due_date': ObligationMath.iso(dueFor(cursor)),
            'amount': amount,
            'status': ObligationStatus.unpaid,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        if (id > 0) created++;
      }
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return created;
  }

  /// Unit's share of a service for [period]; null when nothing is due.
  Future<double?> _serviceAmount(Transaction txn, Map<String, Object?> s,
      Map<String, Object?> unit, String period) async {
    final billing = s['billing_type'] as String;
    final total = (s['amount'] as num?)?.toDouble() ?? 0;

    if (billing == ServiceBilling.consumption) {
      final r = await txn.query('service_readings',
          where: 'service_id = ? AND unit_id = ? AND period = ?',
          whereArgs: [s['id'], unit['id'], period],
          limit: 1);
      return r.isEmpty ? null : (r.first['amount'] as num).toDouble();
    }
    if (billing == ServiceBilling.oneTime) {
      final created = (s['created_at'] as String?) ?? '';
      if (created.length < 7 || created.substring(0, 7) != period) return null;
    }
    // Directly attached to this unit: the unit pays the full amount.
    if (s['unit_id'] != null) return total;

    // Shared property service: split among units with active contracts.
    final method = s['split_method'] as String? ?? ServiceSplit.direct;
    if (method == ServiceSplit.direct) return total;
    final shared = await txn.rawQuery(
        'SELECT u.id AS id, COALESCE(u.area,0) AS area FROM units u '
        'JOIN contracts c ON c.unit_id = u.id AND c.status = ? '
        'WHERE u.property_id = ? GROUP BY u.id',
        [ContractStatus.active, unit['property_id']]);
    if (shared.isEmpty) return null;
    if (method == ServiceSplit.area) {
      final sum =
          shared.fold<double>(0, (a, e) => a + (e['area'] as num).toDouble());
      final mine = (unit['area'] as num?)?.toDouble() ?? 0;
      if (sum <= 0 || mine <= 0) return total / shared.length;
      return (total * mine / sum * 100).round() / 100;
    }
    return (total / shared.length * 100).round() / 100;
  }

  Future<void> _housekeeping(Transaction txn, DateTime now) async {
    final today = ObligationMath.iso(now);
    await txn.update(
      'contracts',
      {'status': ContractStatus.expired},
      where: 'status = ? AND end_date < ?',
      whereArgs: [ContractStatus.active, today],
    );
    // Free units whose rented status no longer has an active contract.
    await txn.rawUpdate(
        "UPDATE units SET status = 'available' WHERE status = 'rented' "
        "AND id NOT IN (SELECT unit_id FROM contracts WHERE status = 'active')");
    await txn.rawUpdate(
      'UPDATE obligations SET status = ? '
      'WHERE status IN (?, ?) AND due_date < ?',
      [
        ObligationStatus.overdue,
        ObligationStatus.unpaid,
        ObligationStatus.partial,
        today,
      ],
    );
  }
}
