import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crud/module_list_view.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import 'contracts_controller.dart';

class ContractsView extends GetView<ContractsController> {
  const ContractsView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return ModuleListView(
      controller: controller,
      titleKey: 'contracts',
      addKey: 'create_contract',
      emptyIcon: Icons.description_outlined,
      emptyTitleKey: 'no_contracts',
      onAdd: () => controller.createNew(),
      filters: FilterChips(
        values: ContractStatus.all,
        selected: controller.statusFilter,
        onSelected: controller.setFilter,
      ),
      itemBuilder: (context, r) {
        final draft = r['status'] == ContractStatus.draft;
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => controller.open(r),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(txt(r['contract_no']),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                    StatusChip(txt(r['status'])),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      onSelected: (v) {
                        switch (v) {
                          case 'edit':
                            controller.edit(r);
                          case 'duplicate':
                            controller.duplicate(r);
                          case 'delete':
                            controller.remove(r);
                        }
                      },
                      itemBuilder: (_) => [
                        if (draft)
                          PopupMenuItem(value: 'edit', child: Text('edit'.tr)),
                        PopupMenuItem(
                            value: 'duplicate', child: Text('duplicate'.tr)),
                        PopupMenuItem(
                            value: 'delete', child: Text('delete'.tr)),
                      ],
                    ),
                  ]),
                  Text(txt(r['title']),
                      style: TextStyle(color: s.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.person_outline, size: 16, color: s.primary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(txt(r['tenant_name']))),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.apartment, size: 16, color: s.primary),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(
                            '${txt(r['property_name'])} / ${txt(r['unit_number'])}')),
                  ]),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${txt(r['start_date'])} → ${txt(r['end_date'])}',
                          style: TextStyle(
                              fontSize: 12, color: s.onSurfaceVariant)),
                      Text(
                          formatMoney(toD(r['rent_amount']),
                              currency: txt(r['currency']).isEmpty
                                  ? null
                                  : txt(r['currency'])),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
