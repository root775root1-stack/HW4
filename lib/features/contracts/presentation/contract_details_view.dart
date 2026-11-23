import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crud/generic_repository.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_details.dart';
import '../../../core/widgets/attachments_section.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../routes/app_routes.dart';
import '../data/contract_repository.dart';

class _Data {
  _Data(this.bundle, this.obligations);
  final ContractBundle bundle;
  final List<DbRow> obligations;
}

class ContractDetailsView extends StatelessWidget {
  const ContractDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = (Get.arguments as Map)['id'] as int;
    final repo = ContractRepository();
    return AsyncDetails<_Data>(
      loader: () async {
        final b = await repo.loadBundle(id);
        if (b == null) throw 'not_found'.tr;
        final obl = await repo.raw(
            'SELECT * FROM obligations WHERE contract_id = ? ORDER BY due_date DESC, id DESC',
            [id]);
        return _Data(b, obl);
      },
      builder: (context, d, reload) =>
          _Body(data: d, repo: repo, reload: reload),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data, required this.repo, required this.reload});
  final _Data data;
  final ContractRepository repo;
  final Future<void> Function() reload;

  ContractBundle get b => data.bundle;
  DbRow get c => b.contract;
  String get status => '${c['status']}';
  int get id => c['id'] as int;

  Future<void> _run(Future<String?> Function() op, String okKey) async {
    final err = await op();
    if (err != null) {
      showErr(err);
    } else {
      showOk(okKey);
    }
    await reload();
  }

  Future<void> _changeStatus(String s, String msgKey) async {
    if (!await confirmDialog(
        titleKey: 'confirm',
        messageKey: msgKey,
        confirmKey: 'confirm',
        destructive: false)) {
      return;
    }
    await _run(() => repo.changeStatus(id, s), 'status_changed');
  }

  @override
  Widget build(BuildContext context) {
    final cur = txt(c['currency']).isEmpty ? null : txt(c['currency']);
    String money(Object? v) => formatMoney(toD(v), currency: cur);
    String opt(Object? v) => txt(v).isEmpty ? '' : 'o_$v'.tr;
    String yn(String section, String key) {
      final v = b.clause(section, key);
      return v.isEmpty ? '' : (v == '1' ? 'yes'.tr : 'no'.tr);
    }

    Widget clauseRows(String section, List<String> keys) => Column(children: [
          for (final k in keys) InfoRow('f_$k', b.clause(section, k)),
        ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(txt(c['contract_no'])),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              switch (v) {
                case 'edit':
                  await Get.toNamed(Routes.contractForm, arguments: {'id': id});
                  await reload();
                case 'activate':
                  await _run(() => repo.activate(id), 'contract_activated');
                case 'terminate':
                  await _changeStatus(
                      ContractStatus.terminated, 'confirm_terminate');
                case 'cancel':
                  await _changeStatus(
                      ContractStatus.cancelled, 'confirm_cancel');
                case 'suspend':
                  await _changeStatus(
                      ContractStatus.suspended, 'confirm_suspend');
                case 'duplicate':
                  final n = await repo.duplicate(id);
                  if (n != null) {
                    showOk('contract_duplicated');
                    Get.offNamed(Routes.contractDetails, arguments: {'id': n});
                  }
                case 'delete':
                  if (!await confirmDialog()) return;
                  final err = await repo.deleteContract(id);
                  if (err != null) {
                    showErr(err);
                  } else {
                    showOk('deleted_ok');
                    Get.back();
                  }
              }
            },
            itemBuilder: (_) => [
              if (status == ContractStatus.draft)
                PopupMenuItem(value: 'edit', child: Text('edit'.tr)),
              if (status == ContractStatus.draft ||
                  status == ContractStatus.suspended)
                PopupMenuItem(
                    value: 'activate', child: Text('activate_contract'.tr)),
              if (status == ContractStatus.active)
                PopupMenuItem(
                    value: 'suspend', child: Text('suspend_contract'.tr)),
              if (status == ContractStatus.active)
                PopupMenuItem(
                    value: 'terminate', child: Text('terminate_contract'.tr)),
              if (status != ContractStatus.cancelled &&
                  status != ContractStatus.terminated &&
                  status != ContractStatus.expired)
                PopupMenuItem(
                    value: 'cancel', child: Text('cancel_contract'.tr)),
              PopupMenuItem(value: 'duplicate', child: Text('duplicate'.tr)),
              PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(txt(c['title']),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                    StatusChip(status),
                  ]),
                  const SizedBox(height: 10),
                  InfoRow('f_contract_type', opt(c['contract_type'])),
                  InfoRow('f_start_date', txt(c['start_date'])),
                  InfoRow('f_end_date', txt(c['end_date'])),
                  InfoRow('f_rent_amount', money(c['rent_amount'])),
                  InfoRow('f_payment_cycle', opt(c['payment_cycle'])),
                  InfoRow('f_created_date', txt(c['created_date'])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            titleKey: 'step_landlord',
            icon: Icons.account_balance_outlined,
            child: Column(children: [
              for (final k in [
                'full_name',
                'id_number',
                'phone',
                'phone2',
                'email',
                'address',
                'bank_name',
                'iban',
                'rep_name',
                'rep_id'
              ])
                InfoRow('f_$k', txt(b.landlord[k])),
            ]),
          ),
          const SizedBox(height: 12),
          SectionCard(
            titleKey: 'step_tenant',
            icon: Icons.person_outline,
            child: Column(children: [
              for (final k in [
                'full_name',
                'id_number',
                'nationality',
                'phone',
                'phone2',
                'email',
                'address',
                'employer',
                'emergency_name',
                'emergency_phone'
              ])
                InfoRow('f_$k', txt(b.tenant[k])),
            ]),
          ),
          const SizedBox(height: 12),
          SectionCard(
            titleKey: 'step_unit',
            icon: Icons.meeting_room_outlined,
            child: Column(children: [
              clauseRows('unit', [
                'property_name',
                'property_address',
                'unit_number',
                'floor',
                'unit_type',
                'area',
                'bedrooms',
                'bathrooms',
                'furnishing',
                'parking_space',
                'storage_room',
                'meter_electric',
                'meter_water',
                'facilities'
              ]),
              InfoRow(
                  'f_condition_at_handover', txt(c['condition_at_handover'])),
            ]),
          ),
          const SizedBox(height: 12),
          SectionCard(
            titleKey: 'step_financial',
            icon: Icons.payments_outlined,
            child: Column(children: [
              InfoRow('f_rent_words', txt(c['rent_words'])),
              InfoRow(
                  'f_deposit_amount',
                  txt(c['deposit_amount']).isEmpty ||
                          toD(c['deposit_amount']) == 0
                      ? ''
                      : money(c['deposit_amount'])),
              InfoRow(
                  'f_advance_payment',
                  txt(c['advance_payment']).isEmpty
                      ? ''
                      : money(c['advance_payment'])),
              InfoRow('f_due_day', txt(c['due_day'])),
              InfoRow('f_grace_period', txt(c['grace_period'])),
              InfoRow('f_late_fee', txt(c['late_fee'])),
              InfoRow('f_late_fee_type', opt(c['late_fee_type'])),
              InfoRow('f_payment_method', opt(c['payment_method'])),
              clauseRows('financial', [
                'utilities_included',
                'service_charges',
                'commission',
                'other_charges',
                'bank_details'
              ]),
              InfoRow('f_payment_notes', txt(c['payment_notes'])),
            ]),
          ),
          const SizedBox(height: 12),
          SectionCard(
            titleKey: 'step_conditions',
            icon: Icons.gavel_outlined,
            child: Column(children: [
              clauseRows('conditions', ['permitted_use', 'occupants_count']),
              InfoRow('f_sublet_allowed', yn('conditions', 'sublet_allowed')),
              InfoRow('f_pets_allowed', yn('conditions', 'pets_allowed')),
              InfoRow('f_smoking_allowed', yn('conditions', 'smoking_allowed')),
              InfoRow('f_alterations_allowed',
                  yn('conditions', 'alterations_allowed')),
              clauseRows('conditions', [
                'maintenance_terms',
                'early_termination',
                'breach_terms',
                'special_conditions',
                'additional_clauses'
              ]),
              InfoRow('f_dispute_resolution', txt(c['dispute_resolution'])),
              InfoRow('f_governing_law', txt(c['governing_law'])),
              InfoRow('f_jurisdiction', txt(c['jurisdiction'])),
            ]),
          ),
          const SizedBox(height: 12),
          SectionCard(
            titleKey: 'step_handover',
            icon: Icons.key_outlined,
            child: Column(children: [
              InfoRow('f_handover_date', txt(c['handover_date'])),
              InfoRow('f_keys_count', txt(c['keys_count'])),
              InfoRow('f_cards_count', txt(c['cards_count'])),
              for (final e in {
                'furniture': 'f_furniture_list',
                'appliance': 'f_appliances_list',
                'damage': 'f_damage_notes'
              }.entries)
                InfoRow(
                    e.value,
                    b.inventory
                        .where((r) => r['kind'] == e.key)
                        .map((r) => '• ${r['description']}')
                        .join('\n')),
              InfoRow('f_handover_notes', txt(c['handover_notes'])),
            ]),
          ),
          const SizedBox(height: 12),
          SectionCard(
            titleKey: 'obligations',
            icon: Icons.request_quote_outlined,
            child: data.obligations.isEmpty
                ? Text(status == ContractStatus.draft
                    ? 'obligations_after_activation'.tr
                    : 'no_data'.tr)
                : Column(children: [
                    for (final o in data.obligations.take(12))
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                            '${txt(o['period'])}  •  ${ObligationType.isService('${o['type']}') ? 'services'.tr : 'rent'.tr}'),
                        subtitle: Text('${'due'.tr} ${txt(o['due_date'])}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(money(o['amount'])),
                            StatusChip(txt(o['status'])),
                          ],
                        ),
                      ),
                  ]),
          ),
          const SizedBox(height: 12),
          AttachmentsSection(ownerType: 'contract', ownerId: id),
        ],
      ),
      // Prominent print button, always visible at the bottom.
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
          ),
          child: FilledButton.icon(
            onPressed: () =>
                Get.toNamed(Routes.contractPdf, arguments: {'id': id}),
            icon: const Icon(Icons.print),
            label: Text('print_contract'.tr,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
          ),
        ),
      ),
    );
  }
}
