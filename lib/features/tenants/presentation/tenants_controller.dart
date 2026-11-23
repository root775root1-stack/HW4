import 'package:get/get.dart';

import '../../../core/crud/crud_controller.dart';
import '../../../core/crud/generic_repository.dart';
import '../data/tenant_repository.dart';
import 'tenant_form.dart';

class TenantsController extends CrudController {
  final TenantRepository repo = TenantRepository();
  final filter = 'all'.obs; // all | with_balance

  @override
  List<String> get searchColumns => const [
        'full_name',
        'name_ar',
        'name_en',
        'phone',
        'national_id',
        'email'
      ];

  @override
  Future<List<DbRow>> fetch() => repo.listWithStats();

  @override
  bool accept(DbRow row) =>
      filter.value == 'all' || (row['balance'] as num? ?? 0) > 0;

  void setFilter(String v) {
    filter.value = v;
    refilter();
  }

  Future<void> openForm({DbRow? existing}) async {
    if (await openTenantForm(existing: existing)) await load(silent: true);
  }

  Future<void> remove(DbRow row) async {
    if (await deleteTenant(row)) await load(silent: true);
  }
}
