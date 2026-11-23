import '../../../core/crud/generic_repository.dart';

class ObligationRepository extends GenericRepository {
  ObligationRepository() : super('obligations');

  Future<List<DbRow>> listJoined() => raw('''
    SELECT o.*, t.full_name AS tenant_name, c.contract_no, u.number AS unit_number
    FROM obligations o
    JOIN tenants t ON t.id = o.tenant_id
    JOIN contracts c ON c.id = o.contract_id
    LEFT JOIN units u ON u.id = o.unit_id
    ORDER BY o.due_date DESC, o.id DESC''');

  Future<List<DbRow>> paymentsOf(int obligationId) => raw(
      'SELECT * FROM payments WHERE obligation_id = ? ORDER BY paid_on DESC',
      [obligationId]);
}
