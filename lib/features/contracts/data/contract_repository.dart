import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crud/generic_repository.dart';
import '../../../core/services/data_bus.dart';
import '../../../core/services/file_service.dart';
import '../../../core/services/obligation_service.dart';
import 'contract_specs.dart';

/// Everything that makes up one lease contract.
class ContractBundle {
  ContractBundle({
    required this.contract,
    required this.landlord,
    required this.tenant,
    required this.clauses,
    required this.witnesses,
    required this.inventory,
    required this.readings,
    required this.attachments,
  });

  final DbRow contract; // joined with property / unit / tenant names
  final DbRow landlord;
  final DbRow tenant;
  final Map<String, Map<String, String>> clauses;
  final List<DbRow> witnesses;
  final List<DbRow> inventory;
  final List<DbRow> readings;
  final List<DbRow> attachments;

  String clause(String section, String key) => clauses[section]?[key] ?? '';
}

class ContractRepository extends GenericRepository {
  ContractRepository() : super('contracts');

  static String _iso(DateTime d) => ObligationMath.iso(d);

  Future<List<DbRow>> listJoined() => raw('''
    SELECT c.*, t.full_name AS tenant_name, u.number AS unit_number,
           p.name AS property_name
    FROM contracts c
    JOIN tenants t ON t.id = c.tenant_id
    JOIN units u ON u.id = c.unit_id
    JOIN properties p ON p.id = u.property_id
    ORDER BY c.id DESC''');

  /// Unique, human-friendly number: LC-2026-0001.
  Future<String> nextNumber() async {
    final year = DateTime.now().year;
    final r = await raw('SELECT COUNT(*) AS c FROM contracts');
    var n = ((r.first['c'] as int?) ?? 0) + 1;
    while (true) {
      final no = 'LC-$year-${n.toString().padLeft(4, '0')}';
      final e =
          await raw('SELECT 1 FROM contracts WHERE contract_no = ?', [no]);
      if (e.isEmpty) return no;
      n++;
    }
  }

  /// True when another active contract of the unit overlaps the dates.
  Future<bool> hasOverlap(int unitId, String start, String end,
      {int? excludeId}) async {
    final r = await raw(
        "SELECT COUNT(*) AS c FROM contracts WHERE unit_id = ? AND status = 'active' "
        'AND id != ? AND start_date <= ? AND end_date >= ?',
        [unitId, excludeId ?? 0, end, start]);
    return ((r.first['c'] as int?) ?? 0) > 0;
  }

  Future<ContractBundle?> loadBundle(int id) async {
    final rows = await raw('''
      SELECT c.*, t.full_name AS tenant_name, u.number AS unit_number,
             u.property_id AS property_id, p.name AS property_name,
             p.address AS property_address, p.city AS property_city
      FROM contracts c
      JOIN tenants t ON t.id = c.tenant_id
      JOIN units u ON u.id = c.unit_id
      JOIN properties p ON p.id = u.property_id
      WHERE c.id = ?''', [id]);
    if (rows.isEmpty) return null;
    final parties =
        await raw('SELECT * FROM contract_parties WHERE contract_id = ?', [id]);
    DbRow party(String role) => parties.firstWhere((p) => p['role'] == role,
        orElse: () => <String, Object?>{});
    final clauseRows = await raw(
        'SELECT * FROM contract_clauses WHERE contract_id = ? ORDER BY sort_order',
        [id]);
    final clauses = <String, Map<String, String>>{};
    for (final c in clauseRows) {
      clauses.putIfAbsent('${c['section']}', () => {})['${c['clause_key']}'] =
          '${c['body'] ?? ''}';
    }
    return ContractBundle(
      contract: rows.first,
      landlord: party('landlord'),
      tenant: party('tenant'),
      clauses: clauses,
      witnesses: await raw(
          'SELECT * FROM contract_witnesses WHERE contract_id = ? ORDER BY position',
          [id]),
      inventory: await raw(
          'SELECT * FROM contract_inventory WHERE contract_id = ? ORDER BY id',
          [id]),
      readings: await raw(
          'SELECT * FROM contract_meter_readings WHERE contract_id = ? ORDER BY id',
          [id]),
      attachments: await raw(
          'SELECT * FROM contract_attachments WHERE contract_id = ? ORDER BY id',
          [id]),
    );
  }

  /// Saves a contract with all of its child records atomically.
  /// New tenants (tenantId == null) are created from [tenantParty].
  Future<int> save({
    int? id,
    required DbRow contract,
    required DbRow landlord,
    required DbRow tenantParty,
    int? tenantId,
    required Map<String, Map<String, String>> clauses,
    required List<DbRow> witnesses,
    required List<DbRow> inventory,
    required List<DbRow> readings,
  }) {
    return dbs.db.transaction<int>((txn) async {
      var tId = tenantId;
      if (tId == null) {
        tId = await txn.insert('tenants', {
          'full_name': tenantParty['full_name'],
          'name_ar': tenantParty['name_ar'],
          'name_en': tenantParty['name_en'],
          'national_id': tenantParty['id_number'],
          'id_type': tenantParty['id_type'],
          'nationality': tenantParty['nationality'],
          'birth_date': tenantParty['birth_date'],
          'phone': tenantParty['phone'],
          'phone2': tenantParty['phone2'],
          'email': tenantParty['email'],
          'address': tenantParty['address'],
          'employer': tenantParty['employer'],
          'emergency_name': tenantParty['emergency_name'],
          'emergency_phone': tenantParty['emergency_phone'],
          'notes': tenantParty['notes'],
        });
      }
      final values = <String, Object?>{...contract, 'tenant_id': tId};
      values['deposit_amount'] ??= 0;
      values['payment_cycle'] ??= 'monthly';
      values['due_day'] ??= 1;
      final int cid;
      if (id == null) {
        values.removeWhere((k, v) => v == null);
        cid = await txn.insert('contracts', values);
      } else {
        await txn.update('contracts', values, where: 'id = ?', whereArgs: [id]);
        cid = id;
      }

      for (final e in {'landlord': landlord, 'tenant': tenantParty}.entries) {
        await txn.insert(
            'contract_parties', {'contract_id': cid, 'role': e.key, ...e.value},
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      for (final t in [
        'contract_clauses',
        'contract_witnesses',
        'contract_inventory',
        'contract_meter_readings'
      ]) {
        await txn.delete(t, where: 'contract_id = ?', whereArgs: [cid]);
      }
      var order = 0;
      for (final sec in clauses.entries) {
        for (final c in sec.value.entries) {
          await txn.insert('contract_clauses', {
            'contract_id': cid,
            'section': sec.key,
            'clause_key': c.key,
            'body': c.value,
            'sort_order': order++,
          });
        }
      }
      for (final w in witnesses) {
        await txn.insert('contract_witnesses', {'contract_id': cid, ...w});
      }
      for (final i in inventory) {
        await txn.insert('contract_inventory', {'contract_id': cid, ...i});
      }
      for (final r in readings) {
        await txn.insert('contract_meter_readings', {'contract_id': cid, ...r});
      }
      return cid;
    });
  }

  /// Draft -> Active. Returns an error key, or null on success.
  Future<String?> activate(int id) async {
    final c = await getById(id);
    if (c == null) return 'not_found';
    if (c['status'] == ContractStatus.active) return null;
    final end = '${c['end_date']}';
    if (end.compareTo(_iso(DateTime.now())) < 0)
      return 'contract_already_ended';
    final unitId = c['unit_id'] as int;
    final unit = await GenericRepository('units').getById(unitId);
    if (unit == null || unit['status'] == UnitStatus.inactive) {
      return 'unit_inactive';
    }
    if (c['allow_overlap'] != 1 &&
        await hasOverlap(unitId, '${c['start_date']}', end, excludeId: id)) {
      return 'unit_has_active_contract';
    }
    await dbs.db.transaction((txn) async {
      await txn.update('contracts', {'status': ContractStatus.active},
          where: 'id = ?', whereArgs: [id]);
      await txn.update('units', {'status': UnitStatus.rented},
          where: 'id = ?', whereArgs: [unitId]);
    });
    await Get.find<ObligationService>().runCatchUp();
    Get.find<DataBus>().bump();
    return null;
  }

  /// Terminate / cancel / suspend / expire. Frees the unit when appropriate.
  Future<String?> changeStatus(int id, String status) async {
    if (status == ContractStatus.active) return activate(id);
    final c = await getById(id);
    if (c == null) return 'not_found';
    final wasActive = c['status'] == ContractStatus.active;
    final today = _iso(DateTime.now());
    await dbs.db.transaction((txn) async {
      await txn.update('contracts', {'status': status},
          where: 'id = ?', whereArgs: [id]);
      if (status == ContractStatus.terminated ||
          status == ContractStatus.cancelled) {
        // Future, untouched obligations no longer apply.
        await txn.rawUpdate(
            "UPDATE obligations SET status = 'cancelled' WHERE contract_id = ? "
            "AND paid_amount = 0 AND status IN ('unpaid') AND due_date >= ?",
            [id, today]);
      }
      if (wasActive) {
        await txn.rawUpdate(
            "UPDATE units SET status = 'available' WHERE id = ? AND status = 'rented' "
            "AND NOT EXISTS (SELECT 1 FROM contracts WHERE unit_id = ? AND status = 'active')",
            [c['unit_id'], c['unit_id']]);
      }
    });
    Get.find<DataBus>().bump();
    return null;
  }

  /// Copies a contract (with all details) into a new draft. Returns new id.
  Future<int?> duplicate(int id) async {
    final b = await loadBundle(id);
    if (b == null) return null;
    final c = <String, Object?>{
      for (final k in contractColumnKeys) k: b.contract[k],
    };
    c['contract_no'] = await nextNumber();
    c['status'] = ContractStatus.draft;
    c['created_date'] = _iso(DateTime.now());
    c['signed_date'] = null;
    DbRow strip(DbRow r) => {
          for (final e in r.entries)
            if (!{'id', 'contract_id', 'role'}.contains(e.key)) e.key: e.value
        };
    final newId = await save(
      contract: c,
      landlord: strip(b.landlord),
      tenantParty: strip(b.tenant),
      tenantId: b.contract['tenant_id'] as int,
      clauses: b.clauses,
      witnesses: b.witnesses.map(strip).toList(),
      inventory: b.inventory.map(strip).toList(),
      readings: b.readings.map(strip).toList(),
    );
    Get.find<DataBus>().bump();
    return newId;
  }

  /// Deletes a contract that has no financial history. Returns an error key.
  Future<String?> deleteContract(int id) async {
    final r = await raw(
        'SELECT COUNT(*) AS c FROM obligations WHERE contract_id = ?', [id]);
    if (((r.first['c'] as int?) ?? 0) > 0)
      return 'cannot_delete_has_obligations';
    final c = await getById(id);
    if (c != null && c['status'] == ContractStatus.active) {
      return 'cannot_delete_active';
    }
    final atts = await raw(
        'SELECT file_path FROM contract_attachments WHERE contract_id = ?',
        [id]);
    final files = Get.find<FileService>();
    for (final a in atts) {
      await files.deleteFile('${a['file_path']}');
    }
    await files.deleteFile('${c?['pdf_path'] ?? ''}');
    await delete(id);
    Get.find<DataBus>().bump();
    return null;
  }
}
