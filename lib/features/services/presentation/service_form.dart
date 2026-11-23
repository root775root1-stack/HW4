import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crud/dynamic_form.dart';
import '../../../core/crud/field_spec.dart';
import '../../../core/crud/generic_repository.dart';
import '../../../core/services/data_bus.dart';
import '../../../core/services/obligation_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../units/presentation/unit_form.dart';
import '../data/service_repository.dart';

final List<FieldSpec> serviceSpecs = [
  const FieldSpec('name', required: true),
  FieldSpec('billing_type',
      type: FieldType.dropdown,
      required: true,
      defaultValue: ServiceBilling.fixedMonthly,
      options: opts(ServiceBilling.all)),
  FieldSpec('split_method',
      type: FieldType.dropdown,
      defaultValue: ServiceSplit.direct,
      options: opts(ServiceSplit.all)),
  const FieldSpec('amount', type: FieldType.money),
  const FieldSpec('property_id', type: FieldType.dropdown),
  const FieldSpec('unit_id', type: FieldType.dropdown),
  const FieldSpec('is_active', type: FieldType.toggle, defaultValue: true),
  const FieldSpec('notes', type: FieldType.multiline),
];

Future<bool> openServiceForm({DbRow? existing}) async {
  final props =
      await propertyOptions(include: existing?['property_id'] as int?);
  final units = await GenericRepository('units').raw(
      'SELECT u.id, u.number, p.name FROM units u JOIN properties p ON p.id = u.property_id '
      'ORDER BY p.name COLLATE NOCASE, u.number');
  if (props.isEmpty) {
    showErr('add_property_first');
    return false;
  }
  final values = await showFormSheet(
    titleKey: existing == null ? 'add_service' : 'edit_service',
    specs: serviceSpecs,
    initial: existing == null
        ? null
        : {...existing, 'is_active': existing['is_active'] == 1},
    options: {
      'property_id': props,
      'unit_id': [
        for (final u in units)
          FieldOption('${u['id']}',
              label: '${u['name']} / ${u['number']}', translate: false)
      ],
    },
    validateExtra: (v) async =>
        (v['property_id'] == null && v['unit_id'] == null)
            ? 'service_target_required'
            : null,
  );
  if (values == null) return false;
  for (final k in ['property_id', 'unit_id']) {
    if (values[k] != null) values[k] = int.parse('${values[k]}');
  }
  values['amount'] = values['amount'] ?? 0;
  final repo = ServiceRepository();
  try {
    if (existing == null) {
      await repo.insert(values);
    } else {
      await repo.update(existing['id'] as int, values);
    }
    await Get.find<ObligationService>().runCatchUp();
    Get.find<DataBus>().bump();
    showOk('saved_ok');
    return true;
  } catch (_) {
    showErr('save_failed');
    return false;
  }
}

Future<bool> deleteService(DbRow row) async {
  final repo = ServiceRepository();
  final id = row['id'] as int;
  if (await repo.obligationCount(id) > 0) {
    // Financial history is never destroyed: stop the service instead.
    showErr('service_has_history');
    return false;
  }
  if (!await confirmDialog()) return false;
  await repo.delete(id);
  Get.find<DataBus>().bump();
  showOk('deleted_ok');
  return true;
}

/// Records consumption (e.g. water / electricity) for a unit and period.
Future<void> openReadingForm(DbRow service) async {
  final repo = ServiceRepository();
  final units = await repo.unitsFor(service);
  if (units.isEmpty) {
    showErr('no_units');
    return;
  }
  final now = DateTime.now();
  final values = await showFormSheet(
    titleKey: 'record_reading',
    specs: const [
      FieldSpec('unit_id', type: FieldType.dropdown, required: true),
      FieldSpec('period', required: true),
      FieldSpec('quantity', type: FieldType.number),
      FieldSpec('amount', type: FieldType.money, required: true),
    ],
    initial: {'period': ObligationMath.periodOf(now)},
    options: {
      'unit_id': [
        for (final u in units)
          FieldOption('${u['id']}', label: '${u['number']}', translate: false)
      ],
    },
    validateExtra: (v) async =>
        RegExp(r'^\d{4}-\d{2}$').hasMatch('${v['period']}')
            ? null
            : 'period_format',
  );
  if (values == null) return;
  await repo.saveReading({
    'service_id': service['id'],
    'unit_id': int.parse('${values['unit_id']}'),
    'period': values['period'],
    'quantity': toD(values['quantity']),
    'amount': toD(values['amount']),
  });
  await Get.find<ObligationService>().runCatchUp();
  Get.find<DataBus>().bump();
  showOk('saved_ok');
}
