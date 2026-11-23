import 'package:get/get.dart';

import '../../../core/crud/generic_repository.dart';
import '../../../core/services/data_bus.dart';
import '../../../core/services/obligation_service.dart';

/// Human label of an obligation type ('rent', 'service:3', 'other:Fine').
String obligationTypeLabel(String type) {
  if (type == 'rent') return 'rent'.tr;
  if (type.startsWith('service:')) return 'service_charge'.tr;
  if (type.startsWith('other:')) return type.substring(6);
  return type;
}

class PaymentRepository extends GenericRepository {
  PaymentRepository() : super('payments');

  Future<List<DbRow>> listJoined() => raw('''
    SELECT pay.*, t.full_name AS tenant_name, c.contract_no,
           o.period, o.type AS obl_type, o.amount AS obl_amount,
           o.paid_amount AS obl_paid, u.number AS unit_number
    FROM payments pay
    JOIN tenants t ON t.id = pay.tenant_id
    JOIN contracts c ON c.id = pay.contract_id
    JOIN obligations o ON o.id = pay.obligation_id
    LEFT JOIN units u ON u.id = o.unit_id
    ORDER BY pay.paid_on DESC, pay.id DESC''');

  Future<List<DbRow>> tenantsWithOpenItems() => raw('''
    SELECT DISTINCT t.id, t.full_name FROM tenants t
    JOIN obligations o ON o.tenant_id = t.id
    WHERE o.status NOT IN ('paid','cancelled')
    ORDER BY t.full_name COLLATE NOCASE''');

  Future<List<DbRow>> contractsOfTenant(int tenantId) => raw('''
    SELECT DISTINCT c.id, c.contract_no, u.number AS unit_number
    FROM contracts c JOIN units u ON u.id = c.unit_id
    JOIN obligations o ON o.contract_id = c.id
    WHERE c.tenant_id = ? ORDER BY c.id DESC''', [tenantId]);

  /// Open obligations of a contract (plus [include] when editing).
  Future<List<DbRow>> openObligations(int contractId, {int? include}) => raw('''
    SELECT * FROM obligations
    WHERE contract_id = ? AND (status NOT IN ('paid','cancelled') OR id = ?)
    ORDER BY due_date''', [contractId, include ?? 0]);

  Future<DbRow?> obligation(int id) async {
    final r = await raw('SELECT * FROM obligations WHERE id = ?', [id]);
    return r.isEmpty ? null : r.first;
  }

  /// Sum of payments of an obligation, optionally excluding one payment.
  Future<double> paidSum(int obligationId, {int? excludePaymentId}) async {
    final r = await raw(
        'SELECT COALESCE(SUM(amount),0) AS s FROM payments '
        'WHERE obligation_id = ? AND id != ?',
        [obligationId, excludePaymentId ?? 0]);
    return ((r.first['s'] as num?) ?? 0).toDouble();
  }

  /// Insert / update a payment and recompute the obligation(s) atomically.
  Future<void> savePayment(DbRow values,
      {int? id, int? oldObligationId}) async {
    await dbs.db.transaction((txn) async {
      if (id == null) {
        await txn.insert('payments', values);
      } else {
        await txn.update('payments', values, where: 'id = ?', whereArgs: [id]);
      }
      await ObligationMath.recalc(txn, values['obligation_id'] as int);
      if (oldObligationId != null &&
          oldObligationId != values['obligation_id']) {
        await ObligationMath.recalc(txn, oldObligationId);
      }
    });
    Get.find<DataBus>().bump();
  }

  Future<void> deletePayment(int id, int obligationId) async {
    await dbs.db.transaction((txn) async {
      await txn.delete('payments', where: 'id = ?', whereArgs: [id]);
      await ObligationMath.recalc(txn, obligationId);
    });
    Get.find<DataBus>().bump();
  }
}
