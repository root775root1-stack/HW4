import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/crud/dynamic_form.dart';
import '../../../core/widgets/common_widgets.dart';
import 'contract_form_controller.dart';

class ContractFormView extends GetView<ContractFormController> {
  const ContractFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirmDialog(
            titleKey: 'discard_title',
            messageKey: 'discard_message',
            confirmKey: 'discard',
            destructive: true)) {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(controller.editId == null
              ? 'create_contract'.tr
              : 'edit_contract'.tr),
          actions: [
            Obx(() => controller.saving.value
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5)),
                  )
                : IconButton(
                    tooltip: 'save_draft'.tr,
                    icon: const Icon(Icons.save_outlined),
                    onPressed: () => controller.save(forceDraft: true),
                  )),
          ],
        ),
        body: Obx(() {
          if (controller.loading.value) return const LoadingState();
          final i = controller.current.value;
          return Column(
            children: [
              _stepsBar(context, i),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: SingleChildScrollView(
                      key: ValueKey('scroll_$i'),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(controller.steps[i].titleKey.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('${i + 1} / ${controller.steps.length}',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant)),
                          const SizedBox(height: 14),
                          ..._notes(context, controller.steps[i].id),
                          if (controller.steps[i].id == 'unit')
                            _unitActions(context),
                          KeyedSubtree(
                            key: ValueKey('form_$i'),
                            child: DynamicForm(model: controller.models[i]),
                          ),
                          ..._extras(context, controller.steps[i].id),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _bottomBar(context, i),
            ],
          );
        }),
      ),
    );
  }

  Widget _stepsBar(BuildContext context, int current) {
    final s = Theme.of(context).colorScheme;
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: controller.steps.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final step = controller.steps[i];
          final bad = controller.invalidSteps.contains(i);
          return ChoiceChip(
            avatar: Icon(bad ? Icons.error_outline : step.icon,
                size: 18, color: bad ? s.error : null),
            label: Text(step.titleKey.tr),
            selected: i == current,
            onSelected: (_) => controller.goTo(i),
          );
        },
      ),
    );
  }

  List<Widget> _notes(BuildContext context, String id) {
    String? key;
    if (id == 'tenant') key = 'note_tenant_select';
    if (id == 'handover') key = 'note_handover';
    if (id == 'witnesses') key = 'note_signatures';
    if (id == 'conditions') key = 'legal_note';
    if (key == null) return const [];
    final s = Theme.of(context).colorScheme;
    return [
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: s.secondaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline, size: 18, color: s.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
              child: Text(key.tr,
                  style: TextStyle(color: s.onSecondaryContainer))),
        ]),
      ),
    ];
  }

  /// Lets the owner add a property/unit inline instead of getting stuck
  /// when none exist yet.
  Widget _unitActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        OutlinedButton.icon(
          onPressed: controller.addProperty,
          icon: const Icon(Icons.add_home_work_outlined, size: 18),
          label: Text('add_property'.tr),
        ),
        OutlinedButton.icon(
          onPressed: controller.addUnit,
          icon: const Icon(Icons.add_business_outlined, size: 18),
          label: Text('add_unit'.tr),
        ),
      ]),
    );
  }

  List<Widget> _extras(BuildContext context, String id) {
    if (id == 'financial') {
      return [
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            onPressed: controller.suggestRentWords,
            icon: const Icon(Icons.spellcheck),
            label: Text('suggest_words'.tr),
          ),
        ),
      ];
    }
    return const [];
  }

  Widget _bottomBar(BuildContext context, int i) {
    final last = i == controller.steps.length - 1;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
        ),
        child: Row(children: [
          if (i > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.back,
                icon: const Icon(Icons.arrow_back),
                label: Text('previous'.tr),
              ),
            ),
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: last
                ? FilledButton.icon(
                    onPressed: controller.saving.value
                        ? null
                        : () => controller.save(),
                    icon: const Icon(Icons.check),
                    label: Text('save_contract'.tr),
                  )
                : FilledButton.icon(
                    onPressed: controller.next,
                    icon: const Icon(Icons.arrow_forward),
                    iconAlignment: IconAlignment.end,
                    label: Text('next'.tr),
                  ),
          ),
        ]),
      ),
    );
  }
}

extension on Color {
  withValues({required double alpha}) {}
}

class ContractFormBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => ContractFormController());
}
