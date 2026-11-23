import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/property_model.dart';
import 'properties_controller.dart';

class PropertiesView extends GetView<PropertiesController> {
  const PropertiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('properties'.tr)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: controller.obx(
        (list) => ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: list!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final p = list[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.apartment),
                title: Text(p.name),
                subtitle: Text(p.address ?? ''),
                onTap: () => _openForm(existing: p),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(p),
                ),
              ),
            );
          },
        ),
        onEmpty: Center(child: Text('no_data'.tr)),
        onLoading: const Center(child: CircularProgressIndicator()),
        onError: (e) => Center(child: Text(e ?? '')),
      ),
    );
  }

  void _confirmDelete(PropertyModel p) {
    Get.defaultDialog(
      title: 'confirm'.tr,
      middleText: 'delete_confirm'.tr,
      textConfirm: 'delete'.tr,
      textCancel: 'cancel'.tr,
      onConfirm: () {
        Get.back();
        controller.remove(p);
      },
    );
  }

  void _openForm({PropertyModel? existing}) {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: existing?.name);
    final address = TextEditingController(text: existing?.address);
    final desc = TextEditingController(text: existing?.description);
    final floors =
        TextEditingController(text: (existing?.floors ?? 1).toString());
    final notes = TextEditingController(text: existing?.notes);

    Get.bottomSheet(
      Container(
        color: Get.theme.colorScheme.surface,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(labelText: 'name'.tr),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'required'.tr : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                    controller: address,
                    decoration: InputDecoration(labelText: 'address'.tr)),
                const SizedBox(height: 10),
                TextFormField(
                    controller: desc,
                    decoration: InputDecoration(labelText: 'description'.tr)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: floors,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'floors'.tr),
                ),
                const SizedBox(height: 10),
                TextFormField(
                    controller: notes,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: 'notes'.tr)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                          onPressed: Get.back, child: Text('cancel'.tr)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          await controller.save(PropertyModel(
                            id: existing?.id,
                            name: name.text.trim(),
                            address: address.text.trim(),
                            description: desc.text.trim(),
                            floors: int.tryParse(floors.text) ?? 1,
                            notes: notes.text.trim(),
                            isActive: existing?.isActive ?? true,
                          ));
                          Get.back();
                        },
                        child: Text('save'.tr),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}