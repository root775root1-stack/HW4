import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crud/dynamic_form.dart';
import '../../../core/crud/field_spec.dart';
import '../../../core/crud/generic_repository.dart';
import '../../../core/services/data_bus.dart';
import '../../../core/widgets/common_widgets.dart';
import '../data/unit_repository.dart';

const unitTypes = [
  'apartment',
  'studio',
  'villa',
  'shop',
  'office',
  'warehouse',
  'parking',
  'other'
];

final List<FieldSpec> unitSpecs = [
  const FieldSpec('property_id', type: FieldType.dropdown, required: true),
  const FieldSpec('number', required: true),
  const FieldSpec('floor', type: FieldType.number),
  FieldSpec('type', type: FieldType.dropdown, options: opts(unitTypes)),
  const FieldSpec('area', type: FieldType.number),
  const FieldSpec('bedrooms', type: FieldType.number),
  const FieldSpec('bathrooms', type: FieldType.number),
  FieldSpec('furnishing',
      type: FieldType.dropdown,
      options: opts(['furnished', 'semi_furnished', 'unfurnished'])),
  const FieldSpec('base_rent', type: FieldType.money, required: true),
  const FieldSpec('deposit_amount', type: FieldType.money),
  FieldSpec('status',
      type: FieldType.dropdown,
      required: true,
      defaultValue: UnitStatus.available,
      options: opts(UnitStatus.all)),
  const FieldSpec('meter_electric'),
  const FieldSpec('meter_water'),
  const FieldSpec('description', type: FieldType.multiline),
  const FieldSpec('notes', type: FieldType.multiline),
];

/// Active properties as dropdown options (plus the current one when editing).
Future<List<FieldOption>> propertyOptions({int? include}) async {
  final rows = await GenericRepository('properties').raw(
      'SELECT id, name FROM properties WHERE is_active = 1 OR id = ? '
      'ORDER BY name COLLATE NOCASE',
      [include ?? 0]);
  return [
    for (final r in rows)
      FieldOption('${r['id']}', label: '${r['name']}', translate: false)
  ];
}

Future<bool> openUnitForm({DbRow? existing, int? propertyId}) async {
  final props =
      await propertyOptions(include: existing?['property_id'] as int?);
  if (props.isEmpty) {
    showErr('add_property_first');
    return false;
  }
  final values = await showFormSheet(
    titleKey: existing == null ? 'add_unit' : 'edit_unit',
    specs: unitSpecs,
    options: {'property_id': props},
    initial:
        existing ?? (propertyId == null ? null : {'property_id': propertyId}),
  );
  if (values == null) return false;
  values['property_id'] = int.parse('${values['property_id']}');
  final repo = UnitRepository();
  try {
    if (existing == null) {
      await repo.insert(values);
    } else {
      await repo.update(existing['id'] as int, values);
    }
    Get.find<DataBus>().bump();
    showOk('saved_ok');
    return true;
  } catch (e) {
    showErr(e.toString().contains('UNIQUE') ? 'unit_duplicate' : 'save_failed');
    return false;
  }
}

Future<bool> deleteUnit(DbRow row) async {
  final repo = UnitRepository();
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
