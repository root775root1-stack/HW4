import '../../../core/crud/generic_repository.dart';

class PropertyRepository extends GenericRepository {
  PropertyRepository() : super('properties');

  /// Properties with unit / occupancy counters for list cards.
  Future<List<DbRow>> listWithStats() => raw('''
    SELECT p.*,
      (SELECT COUNT(*) FROM units u WHERE u.property_id = p.id) AS units_total,
      (SELECT COUNT(*) FROM units u WHERE u.property_id = p.id
         AND u.status = 'rented') AS units_rented
    FROM properties p
    ORDER BY p.name COLLATE NOCASE''');

  Future<int> unitCount(int propertyId) async {
    final r = await raw(
        'SELECT COUNT(*) AS c FROM units WHERE property_id = ?', [propertyId]);
    return (r.first['c'] as int?) ?? 0;
  }

  Future<int> serviceCount(int propertyId) async {
    final r = await raw(
        'SELECT COUNT(*) AS c FROM services WHERE property_id = ?',
        [propertyId]);
    return (r.first['c'] as int?) ?? 0;
  }

  Future<int> setImage(int id, String? path) =>
      update(id, {'image_path': path});
}
