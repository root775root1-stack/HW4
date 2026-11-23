import '../../../core/crud/generic_repository.dart';

class TenantRepository extends GenericRepository {
  TenantRepository() : super('tenants');

  Future<List<DbRow>> listWithStats() => raw('''
    SELECT t.*,
      (SELECT COUNT(*) FROM contracts c WHERE c.tenant_id = t.id
         AND c.status = 'active') AS active_contracts,
      (SELECT COALESCE(SUM(o.amount - o.paid_amount),0) FROM obligations o
         WHERE o.tenant_id = t.id AND o.status NOT IN ('paid','cancelled'))
         AS balance
    FROM tenants t ORDER BY t.full_name COLLATE NOCASE''');

  Future<int> contractCount(int tenantId) async {
    final r = await raw(
        'SELECT COUNT(*) AS c FROM contracts WHERE tenant_id = ?', [tenantId]);
    return (r.first['c'] as int?) ?? 0;
  }

  Future<List<DbRow>> contractsOf(int tenantId) => raw('''
    SELECT c.id, c.contract_no, c.status, c.start_date, c.end_date,
           c.rent_amount, u.number AS unit_number, p.name AS property_name
    FROM contracts c JOIN units u ON u.id = c.unit_id
    JOIN properties p ON p.id = u.property_id
    WHERE c.tenant_id = ? ORDER BY c.id DESC''', [tenantId]);

  Future<List<DbRow>> paymentsOf(int tenantId) => raw('''
    SELECT pay.*, o.period, o.type FROM payments pay
    JOIN obligations o ON o.id = pay.obligation_id
    WHERE pay.tenant_id = ? ORDER BY pay.paid_on DESC, pay.id DESC LIMIT 100''',
      [tenantId]);

  Future<List<DbRow>> openObligationsOf(int tenantId) => raw('''
    SELECT o.*, u.number AS unit_number FROM obligations o
    LEFT JOIN units u ON u.id = o.unit_id
    WHERE o.tenant_id = ? AND o.status NOT IN ('paid','cancelled')
    ORDER BY o.due_date''', [tenantId]);
}
