import 'package:sqflite/sqflite.dart';

import '../../../core/crud/generic_repository.dart';

class ServiceRepository extends GenericRepository {
  ServiceRepository() : super('services');

  Future<List<DbRow>> listJoined() => raw('''
    SELECT s.*, p.name AS property_name, u.number AS unit_number,
           up.name AS unit_property_name
    FROM services s
    LEFT JOIN properties p ON p.id = s.property_id
    LEFT JOIN units u ON u.id = s.unit_id
    LEFT JOIN properties up ON up.id = u.property_id
    ORDER BY s.name COLLATE NOCASE''');

  Future<int> obligationCount(int serviceId) async {
    final r = await raw('SELECT COUNT(*) AS c FROM obligations WHERE type = ?',
        ['service:$serviceId']);
    return (r.first['c'] as int?) ?? 0;
  }

  /// Units a service applies to (own unit, or every unit of its property).
  Future<List<DbRow>> unitsFor(DbRow service) {
    if (service['unit_id'] != null) {
      return raw(
          'SELECT id, number FROM units WHERE id = ?', [service['unit_id']]);
    }
    return raw(
        'SELECT id, number FROM units WHERE property_id = ? ORDER BY number',
        [service['property_id']]);
  }

  Future<List<DbRow>> readingsOf(int serviceId) => raw('''
    SELECT r.*, u.number AS unit_number FROM service_readings r
    JOIN units u ON u.id = r.unit_id
    WHERE r.service_id = ? ORDER BY r.period DESC, u.number''', [serviceId]);

  Future<void> saveReading(Map<String, Object?> v) =>
      dbs.db.insert('service_readings', v,
          conflictAlgorithm: ConflictAlgorithm.replace);
}
