import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crud/generic_repository.dart';
import '../../../core/crud/module_list_view.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../routes/app_routes.dart';
import 'units_controller.dart';

/// Shared unit card (also used inside property details).
Widget unitCard(BuildContext context, DbRow r,
    {VoidCallback? onEdit, VoidCallback? onDelete, bool showProperty = true}) {
  final s = Theme.of(context).colorScheme;
  return Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Get.toNamed(Routes.unitDetails, arguments: {'id': r['id']}),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: s.secondaryContainer,
                borderRadius: BorderRadius.circular(14)),
            child: Text(txt(r['number']),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: s.onSecondaryContainer)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    if (txt(r['type']).isNotEmpty) 'o_${txt(r['type'])}'.tr,
                    if (showProperty) txt(r['property_name']),
                  ].where((e) => e.isNotEmpty).join(' • '),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    formatMoney(toD(r['base_rent'])),
                    if (txt(r['area']).isNotEmpty) '${txt(r['area'])} m²',
                  ].join('  •  '),
                  style: TextStyle(color: s.onSurfaceVariant),
                ),
                if (txt(r['tenant_name']).isNotEmpty)
                  Text(txt(r['tenant_name']),
                      style: TextStyle(color: s.primary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusChip(txt(r['status'])),
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  onSelected: (v) {
                    if (v == 'edit') onEdit?.call();
                    if (v == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text('edit'.tr)),
                    PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
                  ],
                ),
            ],
          ),
        ]),
      ),
    ),
  );
}

class UnitsView extends GetView<UnitsController> {
  const UnitsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleListView(
      controller: controller,
      titleKey: 'units',
      addKey: 'add_unit',
      emptyIcon: Icons.meeting_room_outlined,
      emptyTitleKey: 'no_units',
      onAdd: () => controller.openForm(),
      filters: FilterChips(
        values: UnitStatus.all,
        selected: controller.statusFilter,
        onSelected: controller.setFilter,
      ),
      itemBuilder: (c, r) => unitCard(c, r,
          onEdit: () => controller.openForm(existing: r),
          onDelete: () => controller.remove(r)),
    );
  }
}
