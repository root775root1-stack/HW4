import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/crud/generic_repository.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_details.dart';
import '../../../core/widgets/attachments_section.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../routes/app_routes.dart';
import '../data/unit_repository.dart';
import 'unit_form.dart';

class _UnitData {
  _UnitData(this.unit, this.contracts, this.obligations);
  final DbRow unit;
  final List<DbRow> contracts;
  final List<DbRow> obligations;
}

class UnitDetailsView extends StatelessWidget {
  const UnitDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = (Get.arguments as Map)['id'] as int;
    final repo = UnitRepository();
    return AsyncDetails<_UnitData>(
      loader: () async {
        final u = await repo.getJoined(id);
        if (u == null) throw 'not_found'.tr;
        return _UnitData(
            u, await repo.contractsOf(id), await repo.obligationsOf(id));
      },
      builder: (context, d, reload) {
        final u = d.unit;
        final balance = d.obligations
            .where((o) => o['status'] != 'paid' && o['status'] != 'cancelled')
            .fold<double>(
                0, (a, o) => a + toD(o['amount']) - toD(o['paid_amount']));
        return Scaffold(
          appBar: AppBar(
            title: Text('${'unit'.tr} ${txt(u['number'])}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  if (await openUnitForm(existing: u)) reload();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (await deleteUnit(u)) Get.back();
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionCard(
                titleKey: 'unit_info',
                icon: Icons.meeting_room_outlined,
                trailing: StatusChip(txt(u['status'])),
                child: Column(children: [
                  InfoRow('property', txt(u['property_name'])),
                  InfoRow('f_floor', txt(u['floor'])),
                  InfoRow('f_type',
                      txt(u['type']).isEmpty ? null : 'o_${u['type']}'.tr),
                  InfoRow('f_area',
                      txt(u['area']).isEmpty ? null : '${u['area']} m²'),
                  InfoRow('f_bedrooms', txt(u['bedrooms'])),
                  InfoRow('f_bathrooms', txt(u['bathrooms'])),
                  InfoRow(
                      'f_furnishing',
                      txt(u['furnishing']).isEmpty
                          ? null
                          : 'o_${u['furnishing']}'.tr),
                  InfoRow('f_base_rent', formatMoney(toD(u['base_rent']))),
                  InfoRow(
                      'f_deposit_amount',
                      txt(u['deposit_amount']).isEmpty
                          ? null
                          : formatMoney(toD(u['deposit_amount']))),
                  InfoRow('f_meter_electric', txt(u['meter_electric'])),
                  InfoRow('f_meter_water', txt(u['meter_water'])),
                  InfoRow('tenant', txt(u['tenant_name'])),
                  InfoRow('f_description', txt(u['description'])),
                  InfoRow('f_notes', txt(u['notes'])),
                ]),
              ),
              const SizedBox(height: 12),
              SectionCard(
                titleKey: 'financial_record',
                icon: Icons.account_balance_wallet_outlined,
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('outstanding'.tr),
                      Text(formatMoney(balance),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const Divider(),
                  if (d.obligations.isEmpty) Text('no_data'.tr),
                  for (final o in d.obligations.take(8))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                          '${txt(o['period'])}  •  ${txt(o['tenant_name'])}'),
                      subtitle: Text('${'due'.tr} ${txt(o['due_date'])}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatMoney(toD(o['amount']))),
                          StatusChip(txt(o['status'])),
                        ],
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 12),
              SectionCard(
                titleKey: 'contracts',
                icon: Icons.description_outlined,
                child: d.contracts.isEmpty
                    ? Text('no_contracts'.tr)
                    : Column(children: [
                        for (final c in d.contracts)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                                '${txt(c['contract_no'])}  ${txt(c['tenant_name'])}'),
                            subtitle: Text(
                                '${txt(c['start_date'])} → ${txt(c['end_date'])}'),
                            trailing: StatusChip(txt(c['status'])),
                            onTap: () => Get.toNamed(Routes.contractDetails,
                                arguments: {'id': c['id']}),
                          ),
                      ]),
              ),
              const SizedBox(height: 12),
              AttachmentsSection(ownerType: 'unit', ownerId: id),
            ],
          ),
        );
      },
    );
  }
}
