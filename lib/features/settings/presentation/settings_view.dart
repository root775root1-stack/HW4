import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import 'contract_defaults_form.dart';
import 'owner_profile_form.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _section(context, 'appearance'),
          Obx(() => SwitchListTile(
                secondary: const Icon(Icons.translate),
                title: Text('language'.tr),
                subtitle:
                    Text(controller.isArabic.value ? 'العربية' : 'English'),
                value: controller.isArabic.value,
                onChanged: (v) => controller.isArabic.value = v,
              )),
          Obx(() => SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: Text('theme_dark'.tr),
                value: controller.isDark.value,
                onChanged: (v) => controller.isDark.value = v,
              )),
          const Divider(height: 24),
          _section(context, 'financial_settings'),
          Obx(() => ListTile(
                leading: const Icon(Icons.attach_money),
                title: Text('currency'.tr),
                subtitle: Text(controller.currency.value),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _editCurrency(context),
              )),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: Text('owner_profile'.tr),
            subtitle: Text('owner_profile_hint'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: openOwnerProfileForm,
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: Text('default_contract_settings'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: openContractDefaultsForm,
          ),
          const Divider(height: 24),
          _section(context, 'security'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text('set_pin'.tr),
            onTap: () => _pinDialog(context),
          ),
          Obx(() => controller.hasPin.value
              ? ListTile(
                  leading: const Icon(Icons.lock_open_outlined),
                  title: Text('remove_pin'.tr),
                  onTap: () async {
                    if (await confirmDialog(
                        messageKey: 'remove_pin_confirm',
                        confirmKey: 'remove_pin',
                        destructive: false)) {
                      controller.removePin();
                    }
                  },
                )
              : const SizedBox.shrink()),
          const Divider(height: 24),
          _section(context, 'data'),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text('backup'.tr),
            subtitle: Text('backup_hint'.tr),
            onTap: controller.backup,
          ),
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: Text('restore_database'.tr),
            subtitle: Text('restore_hint'.tr),
            onTap: controller.restore,
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('about'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed('/about'),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String key) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
        child: Text(key.tr,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary)),
      );

  void _editCurrency(BuildContext context) {
    final c = TextEditingController(text: controller.currency.value);
    Get.dialog(AlertDialog(
      title: Text('currency'.tr),
      content: TextField(controller: c, textAlign: TextAlign.center),
      actions: [
        TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
        FilledButton(
          onPressed: () {
            controller.setCurrency(c.text);
            Get.back();
          },
          child: Text('save'.tr),
        ),
      ],
    ));
  }

  void _pinDialog(BuildContext context) {
    final c = TextEditingController();
    Get.dialog(AlertDialog(
      title: Text('set_pin'.tr),
      content: TextField(
        controller: c,
        obscureText: true,
        maxLength: 6,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: 'new_pin'.tr),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
        FilledButton(
          onPressed: () {
            controller.setPin(c.text);
            Get.back();
          },
          child: Text('save'.tr),
        ),
      ],
    ));
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => SettingsController());
}
