import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/crud/module_list_view.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';
import 'tenants_controller.dart';

class TenantsView extends GetView<TenantsController> {
  const TenantsView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return ModuleListView(
      controller: controller,
      titleKey: 'tenants',
      addKey: 'add_tenant',
      emptyIcon: Icons.people_outline,
      emptyTitleKey: 'no_tenants',
      onAdd: () => controller.openForm(),
      filters: FilterChips(
        values: const ['with_balance'],
        selected: controller.filter,
        onSelected: controller.setFilter,
      ),
      itemBuilder: (context, r) {
        final balance = toD(r['balance']);
        final name = txt(r['full_name']);
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () =>
                Get.toNamed(Routes.tenantDetails, arguments: {'id': r['id']}),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: s.primaryContainer,
                  child: Text(name.isEmpty ? '?' : name.characters.first,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: s.onPrimaryContainer)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(txt(r['phone']),
                          style: TextStyle(color: s.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Wrap(spacing: 8, children: [
                        Chip(
                          visualDensity: VisualDensity.compact,
                          avatar:
                              const Icon(Icons.description_outlined, size: 16),
                          label: Text('${r['active_contracts'] ?? 0}'),
                        ),
                        if (balance > 0)
                          Chip(
                            visualDensity: VisualDensity.compact,
                            backgroundColor: Colors.red.withValues(alpha: 0.12),
                            label: Text(formatMoney(balance),
                                style: TextStyle(color: Colors.red.shade700)),
                          ),
                      ]),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') controller.openForm(existing: r);
                    if (v == 'delete') controller.remove(r);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text('edit'.tr)),
                    PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
                  ],
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

extension on MaterialColor {
  withValues({required double alpha}) {}
}
