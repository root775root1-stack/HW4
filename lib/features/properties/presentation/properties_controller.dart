import 'package:get/get.dart';

import '../../../core/crud/crud_controller.dart';
import '../../../core/crud/generic_repository.dart';
import '../data/property_repository.dart';
import 'property_form.dart';

class PropertiesController extends CrudController {
  final PropertyRepository repo = PropertyRepository();
  final statusFilter = 'all'.obs;

  @override
  List<String> get searchColumns =>
      const ['name', 'city', 'address', 'owner_name', 'property_type'];

  @override
  Future<List<DbRow>> fetch() => repo.listWithStats();

  @override
  bool accept(DbRow row) {
    switch (statusFilter.value) {
      case 'active':
        return row['is_active'] == 1;
      case 'inactive':
        return row['is_active'] != 1;
      default:
        return true;
    }
  }

  void setFilter(String v) {
    statusFilter.value = v;
    refilter();
  }

  Future<void> openForm({DbRow? existing}) async {
    if (await openPropertyForm(existing: existing)) await load(silent: true);
  }

  Future<void> remove(DbRow row) async {
    if (await deleteProperty(row)) await load(silent: true);
  }
}
