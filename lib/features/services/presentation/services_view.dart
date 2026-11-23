import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crud/module_list_view.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import 'service_form.dart';
import 'services_controller.dart';

class ServicesView extends GetView<ServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return ModuleListView(
      controller: controller,
      titleKey: 'services',
      addKey: 'add_service',
      emptyIcon: Icons.build_outlined,
      emptyTitleKey: 'no_services',
      onAdd: () => controller.openForm(),
      itemBuilder: (context, r) {
        final target = txt(r['unit_number']).isNotEmpty
            ? '${txt(r['unit_property_name'])} / ${txt(r['unit_number'])}'
            : txt(r['property_name']);
        final active = r['is_active'] == 1;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: s.tertiaryContainer,
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.bolt, color: s.onTertiaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(txt(r['name']),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(
                      [
                        'o_${txt(r['billing_type'])}'.tr,
                        if (r['unit_id'] == null)
                          'o_${txt(r['split_method'])}'.tr,
                        target,
                      ].where((e) => e.isNotEmpty).join(' • '),
                      style: TextStyle(color: s.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text(formatMoney(toD(r['amount'])),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      StatusChip(active ? 'active' : 'inactive'),
                    ]),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'edit':
                      controller.openForm(existing: r);
                    case 'delete':
                      controller.remove(r);
                    case 'toggle':
                      controller.toggleActive(r);
                    case 'reading':
                      openReadingForm(r);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text('edit'.tr)),
                  if (r['billing_type'] == ServiceBilling.consumption)
                    PopupMenuItem(
                        value: 'reading', child: Text('record_reading'.tr)),
                  PopupMenuItem(
                      value: 'toggle',
                      child: Text(active ? 'deactivate'.tr : 'activate'.tr)),
                  PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
                ],
              ),
            ]),
          ),
        );
      },
    );
  }
}
