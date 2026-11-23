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

/// Single-screen dashboard: a compact stats strip, quick actions, an
/// overdue banner when relevant, then the remaining space is split into
/// short tabbed sections — nothing here scrolls as a whole page.
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
      body: SafeArea(
        child: controller.obx(
          (d) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: RefreshIndicator(
                onRefresh: controller.load,
                child: Column(children: [
                  const SizedBox(height: 4),
                  _stats(context, d!),
                  const SizedBox(height: 10),
                  _quickActions(context),
                  if (d.overdueCount > 0) ...[
                    const SizedBox(height: 10),
                    _overdueBanner(context, d),
                  ],
                  const SizedBox(height: 6),
                  Expanded(child: _tabs(context, d)),
                ]),
              ),
            ),
          ),
          onLoading: const LoadingState(),
          onError: (e) => ErrorState(message: e, onRetry: controller.load),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- stats
  Widget _stats(BuildContext context, DashboardData d) {
    final items = <_Mini>[
      _Mini('properties'.tr, '${d.properties}', Icons.apartment,
          () => _shell.open(Tabs.properties)),
      _Mini('units'.tr, '${d.occupied}/${d.units}', Icons.meeting_room,
          () => Get.toNamed(Routes.units), Colors.indigo),
      _Mini('tenants'.tr, '${d.tenants}', Icons.people,
          () => _shell.open(Tabs.tenants), Colors.teal),
      _Mini('active_contracts'.tr, '${d.activeContracts}', Icons.description,
          () => _shell.open(Tabs.contracts), Colors.deepPurple),
      _Mini(
          'due_this_month'.tr,
          formatMoney(d.dueThisMonth),
          Icons.request_quote,
          () => Get.toNamed(Routes.obligations),
          Colors.orange.shade800),
      _Mini(
          'overdue'.tr,
          formatMoney(d.overdue),
          Icons.warning_amber_rounded,
          () => Get.toNamed(Routes.obligations, arguments: 'overdue'),
          Colors.red.shade700),
    ];
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (c, i) =>
            SizedBox(width: 116, child: items[i].build(context)),
      ),
    );
  }

  // ---------------------------------------------------------------- quick actions
  Widget _quickActions(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    Widget action(IconData icon, String label, VoidCallback onTap) => Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: ActionChip(
            avatar: Icon(icon, size: 17, color: s.primary),
            label: Text(label, style: const TextStyle(fontSize: 12.5)),
            onPressed: onTap,
          ),
        );
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          action(Icons.add_home_work_outlined, 'add_property'.tr,
              () => Get.find<PropertiesController>().openForm()),
          action(Icons.person_add_alt_1_outlined, 'add_tenant'.tr,
              () => Get.find<TenantsController>().openForm()),
          action(Icons.note_add_outlined, 'create_contract'.tr,
              () => Get.find<ContractsController>().createNew()),
          action(Icons.add_card, 'record_payment'.tr, () => openPaymentForm()),
        ],
      ),
    );
  }

  Widget _overdueBanner(BuildContext context, DashboardData d) {
    final red = Colors.red.shade700;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Get.toNamed(Routes.obligations, arguments: 'overdue'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded, color: red, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${'overdue_warning'.trParams({
                        'n': '${d.overdueCount}'
                      })}  •  ${formatMoney(d.overdue)}',
                  style: TextStyle(
                      color: red, fontWeight: FontWeight.w700, fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, color: red, size: 18),
            ]),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- tabs
  Widget _tabs(BuildContext context, DashboardData d) {
    final s = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 3,
      child: Column(children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: s.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: s.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: s.onPrimary,
            unselectedLabelColor: s.onSurfaceVariant,
            labelStyle:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            tabs: [
              Tab(text: 'upcoming_dues'.tr),
              Tab(text: 'recent_contracts'.tr),
              Tab(text: 'recent_payments'.tr),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: TabBarView(children: [
            _tabList(d.upcoming, _oblTile, 'no_upcoming'),
            _tabList(d.recentContracts, _contractTile, 'no_data',
                onMore: () => _shell.open(Tabs.contracts)),
            _tabList(d.recentPayments, _paymentTile, 'no_data',
                onMore: () => Get.toNamed(Routes.payments)),
          ]),
        ),
      ]),
    );
  }

  Widget _tabList(
      List<DbRow> rows, Widget Function(DbRow) tile, String emptyKey,
      {VoidCallback? onMore}) {
    if (rows.isEmpty) {
      return EmptyState(icon: Icons.inbox_outlined, titleKey: emptyKey);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      itemCount: rows.length + (onMore == null ? 0 : 1),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (c, i) {
        if (onMore != null && i == rows.length) {
          return TextButton(onPressed: onMore, child: Text('view_all'.tr));
        }
        return tile(rows[i]);
      },
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

/// Compact stat chip used in the top strip.
class _Mini {
  _Mini(this.label, this.value, this.icon, this.onTap, [this.color]);
  final String label, value;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: c),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
