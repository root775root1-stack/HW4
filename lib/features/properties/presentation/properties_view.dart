import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/crud/generic_repository.dart';
import '../../../core/crud/module_list_view.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../routes/app_routes.dart';
import 'properties_controller.dart';

/// Leading thumbnail: the property photo when available, else an icon.
Widget propertyThumb(BuildContext context, DbRow r, {double size = 56}) {
  final path = txt(r['image_path']);
  final s = Theme.of(context).colorScheme;
  Widget fallback() => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: s.primaryContainer, borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.apartment, color: s.onPrimaryContainer),
      );
  if (path.isEmpty) return fallback();
  return ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: Image.file(File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback()),
  );
}

class PropertiesView extends GetView<PropertiesController> {
  const PropertiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleListView(
      controller: controller,
      titleKey: 'properties',
      addKey: 'add_property',
      emptyIcon: Icons.apartment_outlined,
      emptyTitleKey: 'no_properties',
      onAdd: () => controller.openForm(),
      filters: FilterChips(
        values: const ['active', 'inactive'],
        selected: controller.statusFilter,
        onSelected: controller.setFilter,
      ),
      itemBuilder: (context, r) {
        final total = (r['units_total'] as int?) ?? 0;
        final rented = (r['units_rented'] as int?) ?? 0;
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () =>
                Get.toNamed(Routes.propertyDetails, arguments: {'id': r['id']}),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                propertyThumb(context, r),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(txt(r['name']),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (txt(r['property_type']).isNotEmpty)
                            'o_${txt(r['property_type'])}'.tr,
                          txt(r['city']),
                        ].where((e) => e.isNotEmpty).join(' • '),
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 6),
                      Wrap(spacing: 8, children: [
                        Chip(
                          visualDensity: VisualDensity.compact,
                          avatar: const Icon(Icons.meeting_room, size: 16),
                          label: Text('$rented / $total ${'rented_short'.tr}'),
                        ),
                        if (r['is_active'] != 1) const StatusChip('inactive'),
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
