import 'package:get/get.dart';

import '../../../core/services/database_service.dart';
import 'property_model.dart';

class PropertyRepository {
  DatabaseService get _db => Get.find<DatabaseService>();

  Future<List<PropertyModel>> getAll() async {
    final rows = await _db.db.query('properties', orderBy: 'name COLLATE NOCASE');
    return rows.map(PropertyModel.fromMap).toList();
  }

  Future<int> insert(PropertyModel p) => _db.db.insert('properties', p.toMap());

  Future<int> update(PropertyModel p) =>
      _db.db.update('properties', p.toMap(), where: 'id = ?', whereArgs: [p.id]);

  Future<int> unitCount(int propertyId) async {
    final r = await _db.db.rawQuery(
        'SELECT COUNT(*) AS c FROM units WHERE property_id = ?', [propertyId]);
    return (r.first['c'] as int?) ?? 0;
  }

  Future<int> delete(int id) =>
      _db.db.delete('properties', where: 'id = ?', whereArgs: [id]);
}