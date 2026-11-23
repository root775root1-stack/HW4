import '../../../core/crud/generic_repository.dart';

class UnitRepository extends GenericRepository {
  UnitRepository() : super('units');

  static const _select = '''
    SELECT u.*, p.name AS property_name,
      (SELECT t.full_name FROM contracts c JOIN tenants t ON t.id = c.tenant_id
        WHERE c.unit_id = u.id AND c.status = 'active' LIMIT 1) AS tenant_name,
      (SELECT c.id FROM contracts c
        WHERE c.unit_id = u.id AND c.status = 'active' LIMIT 1) AS active_contract_id
    FROM units u JOIN properties p ON p.id = u.property_id''';

  Future<List<DbRow>> listAllJoined() =>
      raw('$_select ORDER BY p.name COLLATE NOCASE, u.number COLLATE NOCASE');

  Future<List<DbRow>> listForProperty(int propertyId) => raw(
      '$_select WHERE u.property_id = ? ORDER BY u.number COLLATE NOCASE',
      [propertyId]);

  Future<DbRow?> getJoined(int id) async {
    final r = await raw('$_select WHERE u.id = ?', [id]);
    return r.isEmpty ? null : r.first;
  }

  Future<int> contractCount(int unitId) async {
    final r = await raw(
        'SELECT COUNT(*) AS c FROM contracts WHERE unit_id = ?', [unitId]);
    return (r.first['c'] as int?) ?? 0;
  }

  Future<List<DbRow>> contractsOf(int unitId) => raw('''
    SELECT c.id, c.contract_no, c.status, c.start_date, c.end_date,
           c.rent_amount, t.full_name AS tenant_name
    FROM contracts c JOIN tenants t ON t.id = c.tenant_id
    WHERE c.unit_id = ? ORDER BY c.id DESC''', [unitId]);

  Future<List<DbRow>> obligationsOf(int unitId) => raw('''
    SELECT o.*, t.full_name AS tenant_name FROM obligations o
    JOIN tenants t ON t.id = o.tenant_id
    WHERE o.unit_id = ? ORDER BY o.due_date DESC LIMIT 60''', [unitId]);
}
