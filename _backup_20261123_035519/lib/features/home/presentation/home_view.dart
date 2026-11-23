import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(Routes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: controller.obx(
          (s) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _grid([
                _Stat('properties'.tr, '${s!.properties}', Icons.apartment),
                _Stat('units'.tr, '${s.units}', Icons.meeting_room),
                _Stat('rented_units'.tr, '${s.rented}', Icons.key),
                _Stat('available_units'.tr, '${s.available}', Icons.door_front_door),
                _Stat('tenants'.tr, '${s.tenants}', Icons.people),
                _Stat('active_contracts'.tr, '${s.activeContracts}', Icons.description),
                _Stat('due_this_month'.tr, formatMoney(s.dueThisMonth), Icons.request_quote),
                _Stat('paid'.tr, formatMoney(s.paid), Icons.payments),
                _Stat('remaining'.tr, formatMoney(s.remaining), Icons.hourglass_bottom),
                _Stat('overdue'.tr, formatMoney(s.overdue), Icons.warning_amber),
              ]),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('properties'.tr, Icons.apartment, Routes.properties),
                  _chip('units'.tr, Icons.meeting_room, Routes.units),
                  _chip('tenants'.tr, Icons.people, Routes.tenants),
                  _chip('services'.tr, Icons.build, Routes.services),
                  _chip('contracts'.tr, Icons.description, Routes.contracts),
                  _chip('obligations'.tr, Icons.request_quote, Routes.obligations),
                  _chip('payments'.tr, Icons.payments, Routes.payments),
                  _chip('documents'.tr, Icons.folder, Routes.documents),
                  _chip('reports'.tr, Icons.bar_chart, Routes.reports),
                ],
              ),
            ],
          ),
          onLoading: const Center(child: CircularProgressIndicator()),
          onError: (e) => Center(child: Text(e ?? '')),
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon, String route) => ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: () => Get.toNamed(route),
      );

  Widget _grid(List<_Stat> stats) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.7,
        children: stats.map((e) => e.build()).toList(),
      );
}

class _Stat {
  _Stat(this.label, this.value, this.icon);
  final String label, value;
  final IconData icon;

  Widget build() => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [Icon(icon, size: 18), const SizedBox(width: 6), Flexible(child: Text(label, overflow: TextOverflow.ellipsis))]),
              const SizedBox(height: 6),
              FittedBox(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
}