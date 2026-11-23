import 'package:get/get.dart';

import '../../../core/crud/dynamic_form.dart';
import '../../../core/crud/field_spec.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../contracts/data/contract_specs.dart'
    show paymentCycles, lateFeeTypes;

final List<FieldSpec> contractDefaultSpecs = [
  FieldSpec('language', type: FieldType.dropdown, options: opts(['ar', 'en'])),
  const FieldSpec('currency'),
  FieldSpec('payment_cycle',
      type: FieldType.dropdown, options: opts(paymentCycles)),
  const FieldSpec('due_day', type: FieldType.number),
  const FieldSpec('grace_period', type: FieldType.number),
  const FieldSpec('late_fee', type: FieldType.money),
  FieldSpec('late_fee_type',
      type: FieldType.dropdown, options: opts(lateFeeTypes)),
  const FieldSpec('notice_period', type: FieldType.number),
  const FieldSpec('renewal_period'),
  const FieldSpec('governing_law', wide: true),
  const FieldSpec('jurisdiction', wide: true),
  const FieldSpec('dispute_resolution', type: FieldType.multiline),
];

/// Values pre-filled into every new contract (still fully editable per contract).
Future<void> openContractDefaultsForm() async {
  final storage = Get.find<StorageService>();
  final values = await showFormSheet(
    titleKey: 'default_contract_settings',
    specs: contractDefaultSpecs,
    initial: storage.contractDefaults,
  );
  if (values == null) return;
  await storage.setContractDefaults(values);
  showOk('saved_ok');
}
