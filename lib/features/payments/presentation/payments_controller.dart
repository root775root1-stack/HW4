import 'package:get/get.dart';

import '../../../core/crud/crud_controller.dart';
import '../../../core/crud/generic_repository.dart';
import '../../../core/widgets/common_widgets.dart';
import '../data/payment_repository.dart';
import 'payment_form.dart';

class PaymentsController extends CrudController {
  final PaymentRepository repo = PaymentRepository();

  @override
  List<String> get searchColumns =>
      const ['tenant_name', 'contract_no', 'reference', 'unit_number'];

  @override
  Future<List<DbRow>> fetch() => repo.listJoined();

  Future<void> add() async {
    if (await openPaymentForm()) await load(silent: true);
  }

  Future<void> edit(DbRow row) async {
    if (await openPaymentForm(existing: row)) await load(silent: true);
  }

  Future<void> remove(DbRow row) async {
    if (!await confirmDialog()) return;
    await repo.deletePayment(row['id'] as int, row['obligation_id'] as int);
    showOk('deleted_ok');
    await load(silent: true);
  }
}
