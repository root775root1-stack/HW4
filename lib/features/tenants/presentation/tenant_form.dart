import 'package:get/get.dart';

import '../../../core/crud/dynamic_form.dart';
import '../../../core/crud/field_spec.dart';
import '../../../core/crud/generic_repository.dart';
import '../../../core/services/data_bus.dart';
import '../../../core/widgets/common_widgets.dart';
import '../data/tenant_repository.dart';

const idTypes = [
  'national_id',
  'passport',
  'residence_permit',
  'commercial_reg'
];

/// Shared by the tenant form and the contract form (landlord/tenant sections).
final List<FieldSpec> tenantSpecs = [
  const FieldSpec('full_name', required: true),
  const FieldSpec('name_ar'),
  const FieldSpec('name_en'),
  FieldSpec('id_type', type: FieldType.dropdown, options: opts(idTypes)),
  const FieldSpec('national_id', label: 'f_id_number', required: true),
  const FieldSpec('id_issue_date', type: FieldType.date),
  const FieldSpec('id_expiry_date', type: FieldType.date),
  const FieldSpec('nationality'),
  const FieldSpec('birth_date', type: FieldType.date),
  FieldSpec('gender',
      type: FieldType.dropdown, options: opts(['male', 'female'])),
  const FieldSpec('phone', type: FieldType.phone, required: true),
  const FieldSpec('phone2', type: FieldType.phone),
  const FieldSpec('email', type: FieldType.email),
  const FieldSpec('address', wide: true),
  const FieldSpec('employer'),
  const FieldSpec('job_title'),
  const FieldSpec('emergency_name'),
  const FieldSpec('emergency_phone', type: FieldType.phone),
  const FieldSpec('emergency_relation'),
  const FieldSpec('notes', type: FieldType.multiline),
];

Future<bool> openTenantForm({DbRow? existing}) async {
  final values = await showFormSheet(
    titleKey: existing == null ? 'add_tenant' : 'edit_tenant',
    specs: tenantSpecs,
    initial: existing,
  );
  if (values == null) return false;
  final repo = TenantRepository();
  try {
    if (existing == null) {
      await repo.insert(values);
    } else {
      await repo.update(existing['id'] as int, values);
    }
    Get.find<DataBus>().bump();
    showOk('saved_ok');
    return true;
  } catch (_) {
    showErr('save_failed');
    return false;
  }
}

Future<bool> deleteTenant(DbRow row) async {
  final repo = TenantRepository();
  final id = row['id'] as int;
  if (await repo.contractCount(id) > 0) {
    showErr('cannot_delete_has_contracts');
    return false;
  }
  if (!await confirmDialog()) return false;
  await repo.delete(id);
  Get.find<DataBus>().bump();
  showOk('deleted_ok');
  return true;
}
