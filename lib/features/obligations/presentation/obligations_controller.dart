import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crud/crud_controller.dart';
import '../../../core/crud/generic_repository.dart';
import '../data/obligation_repository.dart';

class ObligationsController extends CrudController {
  final ObligationRepository repo = ObligationRepository();
  final statusFilter = 'all'.obs;

  @override
  void onInit() {
    final a = Get.arguments;
    if (a is String && ObligationStatus.all.contains(a)) statusFilter.value = a;
    super.onInit();
  }

  @override
  List<String> get searchColumns =>
      const ['tenant_name', 'contract_no', 'unit_number', 'period'];

  @override
  Future<List<DbRow>> fetch() => repo.listJoined();

  @override
  bool accept(DbRow row) =>
      statusFilter.value == 'all' || row['status'] == statusFilter.value;

  void setFilter(String v) {
    statusFilter.value = v;
    refilter();
  }
}
