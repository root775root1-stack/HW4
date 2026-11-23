import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crud/crud_controller.dart';
import '../../../core/crud/generic_repository.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../routes/app_routes.dart';
import '../data/contract_repository.dart';

class ContractsController extends CrudController {
  final ContractRepository repo = ContractRepository();
  final statusFilter = 'all'.obs;

  @override
  List<String> get searchColumns => const [
        'contract_no',
        'title',
        'tenant_name',
        'unit_number',
        'property_name'
      ];

  @override
  Future<List<DbRow>> fetch() => repo.listJoined();

  @override
  bool accept(DbRow row) =>
      statusFilter.value == 'all' || row['status'] == statusFilter.value;

  void setFilter(String v) {
    statusFilter.value = v;
    refilter();
  }

  void createNew({int? unitId}) =>
      Get.toNamed(Routes.contractForm, arguments: {'unit_id': unitId});

  void open(DbRow r) =>
      Get.toNamed(Routes.contractDetails, arguments: {'id': r['id']});

  Future<void> edit(DbRow r) async {
    if (r['status'] != ContractStatus.draft) {
      showErr('only_draft_editable');
      return;
    }
    await Get.toNamed(Routes.contractForm, arguments: {'id': r['id']});
  }

  Future<void> duplicate(DbRow r) async {
    final id = await repo.duplicate(r['id'] as int);
    if (id != null) {
      showOk('contract_duplicated');
      Get.toNamed(Routes.contractDetails, arguments: {'id': id});
    }
  }

  Future<void> remove(DbRow r) async {
    if (!await confirmDialog()) return;
    final err = await repo.deleteContract(r['id'] as int);
    if (err != null) {
      showErr(err);
    } else {
      showOk('deleted_ok');
    }
  }
}
