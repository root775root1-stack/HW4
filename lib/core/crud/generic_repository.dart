import 'package:get/get.dart';

import '../services/database_service.dart';

typedef DbRow = Map<String, Object?>;

/// Thin table gateway. Specific repositories extend it and add joins.
class GenericRepository {
  GenericRepository(this.table);
  final String table;

  DatabaseService get dbs => Get.find<DatabaseService>();

  Future<List<DbRow>> getAll(
          {String? where, List<Object?>? args, String? orderBy}) =>
      dbs.db.query(table,
          where: where, whereArgs: args, orderBy: orderBy ?? 'id DESC');

  Future<DbRow?> getById(int id) async {
    final r =
        await dbs.db.query(table, where: 'id = ?', whereArgs: [id], limit: 1);
    return r.isEmpty ? null : r.first;
  }

  Future<int> insert(DbRow values) => dbs.db.insert(table, values);

  Future<int> update(int id, DbRow values) =>
      dbs.db.update(table, values, where: 'id = ?', whereArgs: [id]);

  Future<int> delete(int id) =>
      dbs.db.delete(table, where: 'id = ?', whereArgs: [id]);

  Future<int> count(String where, List<Object?> args) async {
    final r = await dbs.db
        .rawQuery('SELECT COUNT(*) AS c FROM $table WHERE $where', args);
    return (r.first['c'] as int?) ?? 0;
  }

  /// Ready-made option list for dropdowns: id -> display label.
  Future<List<DbRow>> raw(String sql, [List<Object?>? args]) =>
      dbs.db.rawQuery(sql, args);
}
