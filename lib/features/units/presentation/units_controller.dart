import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crud/crud_controller.dart';
import '../../../core/crud/generic_repository.dart';
import '../data/unit_repository.dart';
import 'unit_form.dart';

class UnitsController extends CrudController {
  final UnitRepository repo = UnitRepository();
  final statusFilter = 'all'.obs;

  @override
  void onInit() {
    // The dashboard can open this list pre-filtered (rented / available).
    final a = Get.arguments;
    if (a is String && UnitStatus.all.contains(a)) statusFilter.value = a;
    super.onInit();
  }

  @override
  List<String> get searchColumns =>
      const ['number', 'property_name', 'type', 'tenant_name'];

  @override
  Future<List<DbRow>> fetch() => repo.listAllJoined();

  @override
  bool accept(DbRow row) =>
      statusFilter.value == 'all' || row['status'] == statusFilter.value;

  void setFilter(String v) {
    statusFilter.value = v;
    refilter();
  }

  Future<void> openForm({DbRow? existing}) async {
    if (await openUnitForm(existing: existing)) await load(silent: true);
  }

  Future<void> remove(DbRow row) async {
    if (await deleteUnit(row)) await load(silent: true);
  }
}
