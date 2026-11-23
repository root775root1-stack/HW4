import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: ListView(
        children: [
          Obx(() => SwitchListTile(
                title: Text('language'.tr),
                subtitle: Text(controller.isArabic.value ? 'العربية' : 'English'),
                value: controller.isArabic.value,
                onChanged: (v) => controller.isArabic.value = v,
              )),
          Obx(() => SwitchListTile(
                title: Text('theme_dark'.tr),
                value: controller.isDark.value,
                onChanged: (v) => controller.isDark.value = v,
              )),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text('set_pin'.tr),
            onTap: _pinDialog,
          ),
          Obx(() => controller.hasPin.value
              ? ListTile(
                  leading: const Icon(Icons.lock_open),
                  title: Text('remove_pin'.tr),
                  onTap: controller.removePin,
                )
              : const SizedBox.shrink()),
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text('backup'.tr),
            onTap: controller.backup,
          ),
        ],
      ),
    );
  }

  void _pinDialog() {
    final c = TextEditingController();
    Get.defaultDialog(
      title: 'set_pin'.tr,
      content: TextField(
        controller: c,
        obscureText: true,
        maxLength: 6,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: 'new_pin'.tr),
      ),
      textConfirm: 'save'.tr,
      textCancel: 'cancel'.tr,
      onConfirm: () async {
        await controller.setPin(c.text);
        Get.back();
      },
    );
  }
}