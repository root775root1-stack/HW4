import 'package:get/get.dart';

import '../../../core/crud/dynamic_form.dart';
import '../../../core/crud/field_spec.dart';
import '../../../core/crud/generic_repository.dart';
import '../../../core/services/data_bus.dart';
import '../../../core/widgets/common_widgets.dart';
import '../data/property_repository.dart';

const propertyTypes = [
  'apartment_building',
  'villa',
  'commercial_building',
  'mall',
  'compound',
  'land',
  'other'
];

final List<FieldSpec> propertySpecs = [
  const FieldSpec('name', required: true),
  FieldSpec('property_type',
      type: FieldType.dropdown, options: opts(propertyTypes)),
  const FieldSpec('address', wide: true),
  const FieldSpec('city'),
  const FieldSpec('country'),
  const FieldSpec('postal_code'),
  const FieldSpec('floors', type: FieldType.number, defaultValue: 1),
  const FieldSpec('units_count', type: FieldType.number),
  const FieldSpec('owner_name'),
  const FieldSpec('owner_phone', type: FieldType.phone),
  const FieldSpec('description', type: FieldType.multiline),
  const FieldSpec('notes', type: FieldType.multiline),
  const FieldSpec('is_active', type: FieldType.toggle, defaultValue: true),
];

/// Opens the add/edit sheet. Returns true when a record was saved.
Future<bool> openPropertyForm({DbRow? existing}) async {
  final values = await showFormSheet(
    titleKey: existing == null ? 'add_property' : 'edit_property',
    specs: propertySpecs,
    initial: existing == null
        ? null
        : {...existing, 'is_active': existing['is_active'] == 1},
  );
  if (values == null) return false;
  final repo = PropertyRepository();
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

/// Deletes a property unless it still owns units (history is preserved).
Future<bool> deleteProperty(DbRow row) async {
  final repo = PropertyRepository();
  final id = row['id'] as int;
  if (await repo.unitCount(id) > 0 || await repo.serviceCount(id) > 0) {
    showErr('cannot_delete_has_units');
    return false;
  }
  if (!await confirmDialog()) return false;
  await repo.delete(id);
  Get.find<DataBus>().bump();
  showOk('deleted_ok');
  return true;
}
