import 'package:get/get.dart';

import '../../../core/crud/dynamic_form.dart';
import '../../../core/crud/field_spec.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../contracts/data/contract_specs.dart' show idTypes;
import '../../tenants/presentation/tenant_form.dart';

final List<FieldSpec> ownerSpecs = [
  const FieldSpec('full_name', required: true),
  const FieldSpec('name_ar'),
  const FieldSpec('name_en'),
  FieldSpec('id_type', type: FieldType.dropdown, options: opts(idTypes)),
  const FieldSpec('id_number', label: 'f_id_number'),
  const FieldSpec('phone', type: FieldType.phone),
  const FieldSpec('phone2', type: FieldType.phone),
  const FieldSpec('email', type: FieldType.email),
  const FieldSpec('address', wide: true),
  const FieldSpec('city'),
  const FieldSpec('country'),
  const FieldSpec('bank_name'),
  const FieldSpec('iban'),
  const FieldSpec('notes', type: FieldType.multiline),
];

/// This profile pre-fills the landlord section of every new contract.
Future<void> openOwnerProfileForm() async {
  final storage = Get.find<StorageService>();
  final values = await showFormSheet(
    titleKey: 'owner_profile',
    specs: ownerSpecs,
    initial: storage.owner,
  );
  if (values == null) return;
  await storage.setOwner(values.map((k, v) => MapEntry(k, v)));
  showOk('saved_ok');
}
