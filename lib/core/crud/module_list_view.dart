import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/common_widgets.dart';
import 'crud_controller.dart';
import 'generic_repository.dart';

/// Shared list screen: search, filters, loading/empty/error states, FAB.
class ModuleListView extends StatelessWidget {
  const ModuleListView({
    super.key,
    required this.controller,
    required this.titleKey,
    required this.itemBuilder,
    this.onAdd,
    this.addKey = 'add',
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitleKey = 'no_data',
    this.emptySubtitleKey,
    this.filters,
    this.showSearch = true,
    this.actions,
  });

  final CrudController controller;
  final String titleKey;
  final Widget Function(BuildContext, DbRow) itemBuilder;
  final VoidCallback? onAdd;
  final String addKey;
  final IconData emptyIcon;
  final String emptyTitleKey;
  final String? emptySubtitleKey;
  final Widget? filters;
  final bool showSearch;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleKey.tr),
        actions: [
          ...?actions,
          IconButton(
            tooltip: 'retry'.tr,
            icon: const Icon(Icons.refresh),
            onPressed: controller.load,
          ),
        ],
      ),
      floatingActionButton: onAdd == null
          ? null
          : FloatingActionButton.extended(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(addKey.tr),
            ),
      body: Column(
        children: [
          if (showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                onChanged: controller.onSearch,
                decoration: InputDecoration(
                  hintText: 'search'.tr,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
          if (filters != null) filters!,
          Expanded(
            child: controller.obx(
              (list) {
                if (list == null || list.isEmpty) {
                  return EmptyState(
                      icon: Icons.search_off, titleKey: 'no_results');
                }
                return RefreshIndicator(
                  onRefresh: controller.load,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (c, i) => itemBuilder(c, list[i]),
                      ),
                    ),
                  ),
                );
              },
              onEmpty: EmptyState(
                icon: emptyIcon,
                titleKey: emptyTitleKey,
                subtitleKey: emptySubtitleKey ?? 'empty_hint',
                actionKey: onAdd == null ? null : addKey,
                onAction: onAdd,
              ),
              onLoading: const LoadingState(),
              onError: (e) => ErrorState(message: e, onRetry: controller.load),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal row of choice chips for status filtering.
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.values,
    required this.selected,
    required this.onSelected,
  });
  final List<String> values;
  final RxString selected;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(() => ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final v in ['all', ...values])
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(v == 'all' ? 'all'.tr : 'o_$v'.tr),
                    selected: selected.value == v,
                    onSelected: (_) => onSelected(v),
                  ),
                ),
            ],
          )),
    );
  }
}
