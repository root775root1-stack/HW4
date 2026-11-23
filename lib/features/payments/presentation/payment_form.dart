import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crud/dynamic_form.dart';
import '../../../core/crud/field_spec.dart';
import '../../../core/crud/form_model.dart';
import '../../../core/crud/generic_repository.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../data/payment_repository.dart';

final List<FieldSpec> paymentSpecs = [
  const FieldSpec('tenant_id', type: FieldType.dropdown, required: true),
  const FieldSpec('contract_id', type: FieldType.dropdown, required: true),
  const FieldSpec('obligation_id', type: FieldType.dropdown, required: true),
  const FieldSpec('paid_on', type: FieldType.date, required: true),
  const FieldSpec('amount', type: FieldType.money, required: true),
  FieldSpec('method',
      type: FieldType.dropdown,
      required: true,
      defaultValue: PaymentMethod.cash,
      options: opts(PaymentMethod.all)),
  const FieldSpec('reference'),
  const FieldSpec('bank_txn_no'),
  const FieldSpec('notes', type: FieldType.multiline),
];

/// Opens the record / edit payment sheet. Returns true when saved.
/// [obligationId] pre-selects an obligation (e.g. the "Pay" action).
Future<bool> openPaymentForm({DbRow? existing, int? obligationId}) async {
  final r = await Get.bottomSheet<bool>(
    _PaymentSheet(existing: existing, obligationId: obligationId),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    backgroundColor: Get.theme.colorScheme.surface,
  );
  return r == true;
}

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({this.existing, this.obligationId});
  final DbRow? existing;
  final int? obligationId;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final repo = PaymentRepository();
  late final FormModel model;
  bool _ready = false;
  bool _busy = false;
  bool _wiring = false;
  String? _tenant, _contract, _obligation;
  List<DbRow> _openObl = [];
  String? error;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    model = FormModel(paymentSpecs);
    _init();
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  String? _s(dynamic v) => (v == null || '$v'.isEmpty) ? null : '$v';

  Future<void> _init() async {
    int? oblId =
        widget.existing?['obligation_id'] as int? ?? widget.obligationId;
    DbRow? obl = oblId == null ? null : await repo.obligation(oblId);

    final tenants = await repo.tenantsWithOpenItems();
    var tenantRows = tenants;
    if (obl != null && !tenants.any((t) => t['id'] == obl!['tenant_id'])) {
      tenantRows = [
        ...tenants,
        ...await repo.raw('SELECT id, full_name FROM tenants WHERE id = ?',
            [obl['tenant_id']])
      ];
    }
    model.setOptions('tenant_id', [
      for (final t in tenantRows)
        FieldOption('${t['id']}', label: '${t['full_name']}', translate: false)
    ]);
    model.set('paid_on', formatDate(DateTime.now()), notify: false);

    if (obl != null) {
      await _loadContracts('${obl['tenant_id']}');
      await _loadObligations('${obl['contract_id']}', include: oblId);
      model.setAll({
        'tenant_id': obl['tenant_id'],
        'contract_id': obl['contract_id'],
        'obligation_id': obl['id'],
      });
      if (!_editing) {
        final remaining = toD(obl['amount']) - toD(obl['paid_amount']);
        model.set('amount', remaining > 0 ? remaining : null, notify: false);
      }
    }
    final e = widget.existing;
    if (e != null) {
      model.setAll({
        'paid_on': e['paid_on'],
        'amount': e['amount'],
        'method': e['method'],
        'reference': e['reference'],
        'bank_txn_no': e['bank_txn_no'],
        'notes': e['notes'],
      });
    }
    _tenant = _s(model.get('tenant_id'));
    _contract = _s(model.get('contract_id'));
    _obligation = _s(model.get('obligation_id'));
    model.addListener(_onChanged);
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _loadContracts(String tenantId) async {
    final cs = await repo.contractsOfTenant(int.parse(tenantId));
    model.setOptions('contract_id', [
      for (final c in cs)
        FieldOption('${c['id']}',
            label: '${c['contract_no']}  •  ${c['unit_number']}',
            translate: false)
    ]);
  }

  Future<void> _loadObligations(String contractId, {int? include}) async {
    _openObl =
        await repo.openObligations(int.parse(contractId), include: include);
    model.setOptions('obligation_id', [
      for (final o in _openObl)
        FieldOption('${o['id']}',
            label: '${o['period']} • ${obligationTypeLabel('${o['type']}')} • '
                '${formatMoney(toD(o['amount']) - toD(o['paid_amount']))}',
            translate: false)
    ]);
  }

  Future<void> _onChanged() async {
    if (_wiring) return;
    _wiring = true;
    try {
      final t = _s(model.get('tenant_id'));
      if (t != _tenant) {
        _tenant = t;
        _contract = null;
        _obligation = null;
        model.set('contract_id', null, notify: false);
        model.set('obligation_id', null, notify: false);
        model.setOptions('contract_id', []);
        model.setOptions('obligation_id', []);
        if (t != null) await _loadContracts(t);
      }
      final c = _s(model.get('contract_id'));
      if (c != _contract) {
        _contract = c;
        _obligation = null;
        model.set('obligation_id', null, notify: false);
        model.setOptions('obligation_id', []);
        if (c != null) await _loadObligations(c);
      }
      final o = _s(model.get('obligation_id'));
      if (o != _obligation) {
        _obligation = o;
        if (o != null && !_editing && model.text('amount').isEmpty) {
          final row = _openObl.where((e) => '${e['id']}' == o);
          if (row.isNotEmpty) {
            final rem =
                toD(row.first['amount']) - toD(row.first['paid_amount']);
            if (rem > 0) model.set('amount', rem);
          }
        }
      }
    } finally {
      _wiring = false;
    }
  }

  Future<void> _save() async {
    if (_busy || !model.validate()) return;
    final m = model.toMap();
    final amount = toD(m['amount']);
    if (amount <= 0) {
      setState(() => error = 'amount_positive'.tr);
      return;
    }
    final oblId = int.parse('${m['obligation_id']}');
    final obl = await repo.obligation(oblId);
    if (obl == null) return;
    final already = await repo.paidSum(oblId,
        excludePaymentId: widget.existing?['id'] as int?);
    if (already + amount > toD(obl['amount']) + 0.005) {
      if (!await confirmDialog(
          titleKey: 'overpay_title',
          messageKey: 'overpay_confirm',
          confirmKey: 'confirm',
          destructive: false)) {
        return;
      }
    }
    setState(() => _busy = true);
    try {
      await repo.savePayment(
        {
          'tenant_id': int.parse('${m['tenant_id']}'),
          'contract_id': int.parse('${m['contract_id']}'),
          'obligation_id': oblId,
          'paid_on': m['paid_on'],
          'amount': amount,
          'method': m['method'] ?? PaymentMethod.cash,
          'reference': m['reference'],
          'bank_txn_no': m['bank_txn_no'],
          'notes': m['notes'],
        },
        id: widget.existing?['id'] as int?,
        oldObligationId: widget.existing?['obligation_id'] as int?,
      );
      showOk('saved_ok');
      Get.back(result: true);
    } catch (_) {
      setState(() {
        _busy = false;
        error = 'save_failed'.tr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.92),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
            child: Row(children: [
              Expanded(
                child: Text(_editing ? 'edit_payment'.tr : 'record_payment'.tr,
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
            ]),
          ),
          Flexible(
            child: !_ready
                ? const Padding(
                    padding: EdgeInsets.all(40), child: LoadingState())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: DynamicForm(model: model),
                  ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: Get.back, child: Text('cancel'.tr))),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _ready && !_busy ? _save : null,
                  icon: const Icon(Icons.check),
                  label: Text('save'.tr),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
