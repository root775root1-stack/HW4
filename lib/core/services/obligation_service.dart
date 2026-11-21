import 'dart:math';

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import 'database_service.dart';

/// Creates monthly rent obligations for active contracts.
/// Runs on every app start and catches up on all missed months.
/// Safe to run repeatedly: a UNIQUE index (contract, period, type) plus
/// INSERT OR IGNORE prevents duplicates.
class ObligationService extends GetxService {
  DatabaseService get _db => Get.find<DatabaseService>();

  static String periodOf(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  static String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Returns the number of obligations created.
  Future<int> runCatchUp({DateTime? now}) async {
    now ??= DateTime.now();
    final db = _db.db;
    var created = 0;

    await db.transaction((txn) async {
      final contracts = await txn.query('contracts',
          where: 'status = ?', whereArgs: [ContractStatus.active]);

      for (final c in contracts) {
        final start = DateTime.parse(c['start_date'] as String);
        final end = DateTime.parse(c['end_date'] as String);
        final dueDay = (c['due_day'] as int?) ?? 1;
        final unit = (await txn.query('units',
                where: 'id = ?', whereArgs: [c['unit_id']], limit: 1))
            .first;

        var cursor = DateTime(start.year, start.month);
        final last = DateTime(now!.year, now.month);
        final lastForContract = DateTime(end.year, end.month);

        while (!cursor.isAfter(last) && !cursor.isAfter(lastForContract)) {
          final daysInMonth = DateTime(cursor.year, cursor.month + 1, 0).day;
          final due =
              DateTime(cursor.year, cursor.month, min(dueDay, daysInMonth));

          // TODO(v1.1): prorate first/last month if the owner chooses to.
          final id = await txn.insert(
            'obligations',
            {
              'tenant_id': c['tenant_id'],
              'contract_id': c['id'],
              'property_id': unit['property_id'],
              'unit_id': c['unit_id'],
              'type': ObligationType.rent,
              'period': periodOf(cursor),
              'due_date': _iso(due),
              'amount': c['rent_amount'],
              'status': ObligationStatus.unpaid,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
          if (id > 0) created++;

          cursor = DateTime(cursor.year, cursor.month + 1);
        }

        // TODO: add fixed-monthly and consumption service obligations here
        // (type = ObligationType.service(serviceId)).
      }

      // Expire contracts whose end date has passed (after generating).
      await txn.update(
        'contracts',
        {'status': ContractStatus.expired},
        where: 'status = ? AND end_date < ?',
        whereArgs: [ContractStatus.active, _iso(now!)],
      );

      // Flag late obligations.
      await txn.rawUpdate(
        'UPDATE obligations SET status = ? '
        'WHERE status IN (?, ?) AND due_date < ?',
        [
          ObligationStatus.overdue,
          ObligationStatus.unpaid,
          ObligationStatus.partial,
          _iso(now),
        ],
      );
    });

    return created;
  }
}