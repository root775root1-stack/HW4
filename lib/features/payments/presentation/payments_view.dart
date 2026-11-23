import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/crud/generic_repository.dart';
import '../../../core/crud/module_list_view.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../data/payment_repository.dart';
import 'payments_controller.dart';

class PaymentsView extends GetView<PaymentsController> {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return ModuleListView(
      controller: controller,
      titleKey: 'payments',
      addKey: 'record_payment',
      emptyIcon: Icons.payments_outlined,
      emptyTitleKey: 'no_payments',
      onAdd: controller.add,
      itemBuilder: (context, r) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.payments, color: Colors.green.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(txt(r['tenant_name']),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(
                      [
                        txt(r['contract_no']),
                        if (txt(r['unit_number']).isNotEmpty)
                          txt(r['unit_number']),
                        obligationTypeLabel(txt(r['obl_type'])),
                        txt(r['period']),
                      ].where((e) => e.isNotEmpty).join(' • '),
                      style: TextStyle(fontSize: 12, color: s.onSurfaceVariant),
                    ),
                    Text(
                        '${txt(r['paid_on'])}  •  ${'o_${txt(r['method'])}'.tr}',
                        style:
                            TextStyle(fontSize: 12, color: s.onSurfaceVariant)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatMoney(toD(r['amount'])),
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade700)),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    onSelected: (v) {
                      if (v == 'edit') controller.edit(r);
                      if (v == 'delete') controller.remove(r);
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
        );
      },
    );
  }
}

extension on MaterialColor {
  withValues({required double alpha}) {}
}
