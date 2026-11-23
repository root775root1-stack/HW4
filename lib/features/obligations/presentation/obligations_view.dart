import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/crud/generic_repository.dart';
import '../../../core/crud/module_list_view.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../payments/data/payment_repository.dart';
import '../../payments/presentation/payment_form.dart';
import 'obligations_controller.dart';

class ObligationsView extends StatelessWidget {
  const ObligationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ObligationsController());
    final s = Theme.of(context).colorScheme;
    return ModuleListView(
      controller: controller,
      titleKey: 'obligations',
      showSearch: true,
      emptyIcon: Icons.request_quote_outlined,
      emptyTitleKey: 'no_data',
      filters: FilterChips(
        values: ObligationStatus.all,
        selected: controller.statusFilter,
        onSelected: controller.setFilter,
      ),
      itemBuilder: (context, r) {
        final remaining = toD(r['amount']) - toD(r['paid_amount']);
        final canPay = r['status'] != 'paid' && r['status'] != 'cancelled';
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${txt(r['tenant_name'])}  •  ${obligationTypeLabel(txt(r['type']))}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${txt(r['contract_no'])}  •  ${txt(r['unit_number'])}  •  ${txt(r['period'])}',
                      style: TextStyle(fontSize: 12, color: s.onSurfaceVariant),
                    ),
                    Text('${'due'.tr}: ${txt(r['due_date'])}',
                        style:
                            TextStyle(fontSize: 12, color: s.onSurfaceVariant)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(txt(r['status'])),
                  const SizedBox(height: 4),
                  Text(formatMoney(toD(r['amount'])),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (remaining > 0 && remaining != toD(r['amount']))
                    Text('${'remaining'.tr}: ${formatMoney(remaining)}',
                        style: TextStyle(fontSize: 11, color: s.error)),
                ],
              ),
              if (canPay)
                IconButton(
                  tooltip: 'record_payment'.tr,
                  icon: const Icon(Icons.add_card_outlined),
                  onPressed: () async {
                    if (await openPaymentForm(obligationId: r['id'] as int)) {
                      controller.load(silent: true);
                    }
                  },
                ),
            ]),
          ),
        );
      },
    );
  }
}
