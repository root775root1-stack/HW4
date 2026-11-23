import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/crud/generic_repository.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../routes/app_routes.dart';
import '../../contracts/presentation/contracts_controller.dart';
import '../../payments/presentation/payment_form.dart';
import '../../properties/presentation/properties_controller.dart';
import '../../shell/shell.dart';
import '../../tenants/presentation/tenants_controller.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  ShellController get _shell => Get.find<ShellController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(Routes.settings),
          ),
        ],
      ),
      body: controller.obx(
        (d) => RefreshIndicator(
          onRefresh: controller.load,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _stats(context, d!),
                  const SizedBox(height: 18),
                  _quickActions(),
                  if (d.overdueCount > 0) ...[
                    const SizedBox(height: 18),
                    _overdueBanner(context, d),
                  ],
                  const SizedBox(height: 18),
                  _listCard('upcoming_dues', Icons.event_outlined, d.upcoming,
                      _oblTile, 'no_upcoming'),
                  const SizedBox(height: 14),
                  _listCard('recent_contracts', Icons.description_outlined,
                      d.recentContracts, _contractTile, 'no_data',
                      onMore: () => _shell.open(Tabs.contracts)),
                  const SizedBox(height: 14),
                  _listCard('recent_payments', Icons.payments_outlined,
                      d.recentPayments, _paymentTile, 'no_data',
                      onMore: () => Get.toNamed(Routes.payments)),
                ],
              ),
            ),
          ),
        ),
        onLoading: const LoadingState(),
        onError: (e) => ErrorState(message: e, onRetry: controller.load),
      ),
    );
  }

  Widget _stats(BuildContext context, DashboardData d) {
    final cs = Theme.of(context).colorScheme;
    final items = <StatCard>[
      StatCard(
          label: 'properties'.tr,
          value: '${d.properties}',
          icon: Icons.apartment,
          onTap: () => _shell.open(Tabs.properties)),
      StatCard(
          label: 'units'.tr,
          value: '${d.units}',
          icon: Icons.meeting_room,
          color: Colors.indigo,
          onTap: () => Get.toNamed(Routes.units)),
      StatCard(
          label: 'occupied_units'.tr,
          value: '${d.occupied}',
          icon: Icons.key,
          color: Colors.green.shade700,
          onTap: () => Get.toNamed(Routes.units, arguments: 'rented')),
      StatCard(
          label: 'available_units'.tr,
          value: '${d.available}',
          icon: Icons.door_front_door_outlined,
          color: Colors.blue.shade700,
          onTap: () => Get.toNamed(Routes.units, arguments: 'available')),
      StatCard(
          label: 'tenants'.tr,
          value: '${d.tenants}',
          icon: Icons.people,
          color: Colors.teal,
          onTap: () => _shell.open(Tabs.tenants)),
      StatCard(
          label: 'active_contracts'.tr,
          value: '${d.activeContracts}',
          icon: Icons.description,
          color: Colors.deepPurple,
          onTap: () => _shell.open(Tabs.contracts)),
      StatCard(
          label: 'due_this_month'.tr,
          value: formatMoney(d.dueThisMonth),
          icon: Icons.request_quote,
          color: Colors.orange.shade800,
          onTap: () => Get.toNamed(Routes.obligations)),
      StatCard(
          label: 'paid_this_month'.tr,
          value: formatMoney(d.paidThisMonth),
          icon: Icons.payments,
          color: Colors.green.shade700,
          onTap: () => Get.toNamed(Routes.payments)),
      StatCard(
          label: 'outstanding'.tr,
          value: formatMoney(d.outstanding),
          icon: Icons.hourglass_bottom,
          color: cs.tertiary,
          onTap: () => Get.toNamed(Routes.obligations, arguments: 'unpaid')),
      StatCard(
          label: 'overdue'.tr,
          value: formatMoney(d.overdue),
          icon: Icons.warning_amber_rounded,
          color: Colors.red.shade700,
          onTap: () => Get.toNamed(Routes.obligations, arguments: 'overdue')),
    ];
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 900 ? 5 : (c.maxWidth >= 600 ? 4 : 2);
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: cols == 2 ? 1.35 : 1.15,
        children: items,
      );
    });
  }

  Widget _quickActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.tonalIcon(
          onPressed: () => Get.find<PropertiesController>().openForm(),
          icon: const Icon(Icons.add_home_work_outlined),
          label: Text('add_property'.tr),
        ),
        FilledButton.tonalIcon(
          onPressed: () => Get.find<TenantsController>().openForm(),
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: Text('add_tenant'.tr),
        ),
        FilledButton.icon(
          onPressed: () => Get.find<ContractsController>().createNew(),
          icon: const Icon(Icons.note_add_outlined),
          label: Text('create_contract'.tr),
        ),
        FilledButton.tonalIcon(
          onPressed: () => openPaymentForm(),
          icon: const Icon(Icons.add_card),
          label: Text('record_payment'.tr),
        ),
      ],
    );
  }

  Widget _overdueBanner(BuildContext context, DashboardData d) {
    final red = Colors.red.shade700;
    return Card(
      color: red.withValues(alpha: 0.10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.toNamed(Routes.obligations, arguments: 'overdue'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Icon(Icons.warning_amber_rounded, color: red, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('overdue_warning'.trParams({'n': '${d.overdueCount}'}),
                      style:
                          TextStyle(color: red, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(formatMoney(d.overdue)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
    );
  }

  Widget _listCard(String titleKey, IconData icon, List<DbRow> rows,
      Widget Function(DbRow) tile, String emptyKey,
      {VoidCallback? onMore}) {
    return SectionCard(
      titleKey: titleKey,
      icon: icon,
      trailing: onMore == null
          ? null
          : TextButton(onPressed: onMore, child: Text('view_all'.tr)),
      child: rows.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(emptyKey.tr),
            )
          : Column(children: rows.map(tile).toList()),
    );
  }

  Widget _oblTile(DbRow r) => ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(txt(r['tenant_name'])),
        subtitle: Text(
            '${txt(r['unit_number'])}  •  ${'due'.tr} ${txt(r['due_date'])}'),
        trailing: Text(formatMoney(toD(r['amount']) - toD(r['paid_amount'])),
            style: const TextStyle(fontWeight: FontWeight.w700)),
        onTap: () =>
            Get.toNamed(Routes.obligations, arguments: txt(r['status'])),
      );

  Widget _contractTile(DbRow r) => ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text('${txt(r['contract_no'])}  ${txt(r['tenant_name'])}'),
        subtitle: Text('${txt(r['property_name'])} / ${txt(r['unit_number'])}'),
        trailing: StatusChip(txt(r['status'])),
        onTap: () =>
            Get.toNamed(Routes.contractDetails, arguments: {'id': r['id']}),
      );

  Widget _paymentTile(DbRow r) => ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(txt(r['tenant_name'])),
        subtitle: Text('${txt(r['paid_on'])}  •  ${txt(r['unit_number'])}'),
        trailing: Text(formatMoney(r['amount'] as num?),
            style: TextStyle(
                fontWeight: FontWeight.w700, color: Colors.green.shade700)),
        onTap: () => Get.toNamed(Routes.payments),
      );
}

extension on Color {
  withValues({required double alpha}) {}
}
