import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import '../../../core/crud/generic_repository.dart';
import '../../../core/services/data_bus.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/file_service.dart';

/// Attachments for properties, units, tenants and contracts.
/// Contracts use `contract_attachments`; everything else uses `documents`.
class AttachmentRepository {
  DatabaseService get _db => Get.find<DatabaseService>();

  static const ownerTypes = ['property', 'unit', 'tenant', 'contract'];

  Future<List<DbRow>> list(String ownerType, int ownerId) {
    if (ownerType == 'contract') {
      return _db.db.rawQuery(
          "SELECT id, 'contract' AS owner_type, contract_id AS owner_id, name, kind, "
          'file_path, size_bytes, created_at FROM contract_attachments '
          'WHERE contract_id = ? ORDER BY id DESC',
          [ownerId]);
    }
    return _db.db.rawQuery(
        'SELECT id, owner_type, owner_id, name, kind, file_path, size_bytes, created_at '
        'FROM documents WHERE owner_type = ? AND owner_id = ? ORDER BY id DESC',
        [ownerType, ownerId]);
  }

  /// All attachments of every type, newest first (Documents screen).
  Future<List<DbRow>> listAll() => _db.db.rawQuery('''
    SELECT d.id, d.owner_type, d.owner_id, d.name, d.kind, d.file_path,
           d.size_bytes, d.created_at,
           CASE d.owner_type
             WHEN 'property' THEN (SELECT name FROM properties WHERE id = d.owner_id)
             WHEN 'unit' THEN (SELECT number FROM units WHERE id = d.owner_id)
             WHEN 'tenant' THEN (SELECT full_name FROM tenants WHERE id = d.owner_id)
           END AS owner_name
    FROM documents d
    UNION ALL
    SELECT a.id, 'contract', a.contract_id, a.name, a.kind, a.file_path,
           a.size_bytes, a.created_at,
           (SELECT contract_no FROM contracts WHERE id = a.contract_id)
    FROM contract_attachments a
    ORDER BY created_at DESC''');

  Future<void> add(String ownerType, int ownerId, StoredFile f) async {
    final ext = p.extension(f.name).replaceFirst('.', '').toLowerCase();
    if (ownerType == 'contract') {
      await _db.db.insert('contract_attachments', {
        'contract_id': ownerId,
        'name': f.name,
        'kind': ext,
        'file_path': f.path,
        'size_bytes': f.size,
      });
    } else {
      await _db.db.insert('documents', {
        'owner_type': ownerType,
        'owner_id': ownerId,
        'name': f.name,
        'kind': ext,
        'file_path': f.path,
        'size_bytes': f.size,
      });
    }
    Get.find<DataBus>().bump();
  }

  Future<void> delete(String ownerType, int id, String? path) async {
    await _db.db.delete(
        ownerType == 'contract' ? 'contract_attachments' : 'documents',
        where: 'id = ?',
        whereArgs: [id]);
    await Get.find<FileService>().deleteFile(path);
    Get.find<DataBus>().bump();
  }
}
