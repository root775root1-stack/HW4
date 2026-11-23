import 'package:get/get.dart';

import '../../../core/crud/crud_controller.dart';
import '../../../core/crud/generic_repository.dart';
import '../data/service_repository.dart';
import 'service_form.dart';

class ServicesController extends CrudController {
  final ServiceRepository repo = ServiceRepository();

  @override
  List<String> get searchColumns =>
      const ['name', 'property_name', 'unit_number', 'billing_type'];

  @override
  Future<List<DbRow>> fetch() => repo.listJoined();

  Future<void> openForm({DbRow? existing}) async {
    if (await openServiceForm(existing: existing)) await load(silent: true);
  }

  Future<void> remove(DbRow row) async {
    if (await deleteService(row)) await load(silent: true);
  }

  Future<void> toggleActive(DbRow row) async {
    await repo
        .update(row['id'] as int, {'is_active': row['is_active'] == 1 ? 0 : 1});
    bus.bump();
  }
}
