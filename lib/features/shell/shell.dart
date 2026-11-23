import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/crud/generic_repository.dart';
import '../../routes/app_routes.dart';
import '../contracts/presentation/contracts_controller.dart';
import '../contracts/presentation/contracts_view.dart';
import '../home/presentation/home_controller.dart';
import '../home/presentation/home_view.dart';
import '../properties/presentation/properties_controller.dart';
import '../properties/presentation/properties_view.dart';
import '../tenants/presentation/tenants_controller.dart';
import '../tenants/presentation/tenants_view.dart';

class ShellController extends GetxController {
  final index = 0.obs;

  void select(int i) => index.value = i;

  /// Jumps to a tab from anywhere (closes pushed pages first).
  void open(int i) {
    Get.until((r) => r.settings.name == Routes.home || r.isFirst);
    index.value = i;
  }
}

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ShellController(), permanent: true);
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => PropertiesController(), fenix: true);
    Get.lazyPut(() => TenantsController(), fenix: true);
    Get.lazyPut(() => ContractsController(), fenix: true);
  }
}

class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final i = controller.index.value;
      return PopScope(
        canPop: i == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.select(0);
        },
        child: Scaffold(
          body: IndexedStack(
            index: i,
            children: const [
              HomeView(),
              PropertiesView(),
              TenantsView(),
              ContractsView(),
              MoreView(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: i,
            onDestinationSelected: controller.select,
            destinations: [
              NavigationDestination(
                  icon: const Icon(Icons.dashboard_outlined),
                  selectedIcon: const Icon(Icons.dashboard),
                  label: 'dashboard'.tr),
              NavigationDestination(
                  icon: const Icon(Icons.apartment_outlined),
                  selectedIcon: const Icon(Icons.apartment),
                  label: 'properties'.tr),
              NavigationDestination(
                  icon: const Icon(Icons.people_outline),
                  selectedIcon: const Icon(Icons.people),
                  label: 'tenants'.tr),
              NavigationDestination(
                  icon: const Icon(Icons.description_outlined),
                  selectedIcon: const Icon(Icons.description),
                  label: 'contracts'.tr),
              NavigationDestination(
                  icon: const Icon(Icons.grid_view_outlined),
                  selectedIcon: const Icon(Icons.grid_view_rounded),
                  label: 'more'.tr),
            ],
          ),
        ),
      );
    });
  }
}

/// Secondary modules: every section is reachable from here.
class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_MoreItem>[
      _MoreItem('units', Icons.meeting_room_outlined, Routes.units),
      _MoreItem(
          'obligations', Icons.request_quote_outlined, Routes.obligations),
      _MoreItem('payments', Icons.payments_outlined, Routes.payments),
      _MoreItem('services', Icons.build_outlined, Routes.services),
      _MoreItem('documents', Icons.folder_outlined, Routes.documents),
      _MoreItem('reports', Icons.bar_chart_outlined, Routes.reports),
      _MoreItem('settings', Icons.settings_outlined, Routes.settings),
      _MoreItem('about', Icons.info_outline, Routes.about),
    ];
    return Scaffold(
      appBar: AppBar(title: Text('more'.tr)),
      body: LayoutBuilder(builder: (context, c) {
        final cols = c.maxWidth >= 900 ? 4 : (c.maxWidth >= 600 ? 3 : 2);
        return GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: cols,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            for (final it in items)
              Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Get.toNamed(it.route),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(it.icon,
                          size: 34,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 10),
                      Text(it.key.tr,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _MoreItem {
  _MoreItem(this.key, this.icon, this.route);
  final String key;
  final IconData icon;
  final String route;
}

/// Convenience used by pushed pages that need a [DbRow] argument.
DbRow? rowArg() {
  final a = Get.arguments;
  return a is Map<String, Object?> ? a : null;
}
