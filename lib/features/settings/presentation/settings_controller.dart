import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/database_service.dart';
import '../../../core/services/storage_service.dart';

class SettingsController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final isArabic = false.obs;
  final isDark = false.obs;
  final hasPin = false.obs;

  @override
  void onInit() {
    super.onInit();
    isArabic.value = storage.locale.languageCode == 'ar';
    isDark.value = storage.themeMode == ThemeMode.dark;
    hasPin.value = storage.hasPin;

    // Workers: react to switches.
    ever(isArabic, (bool v) => storage.setLang(v ? 'ar' : 'en'));
    ever(isDark, (bool v) => storage.setDark(v));
  }

  Future<void> setPin(String pin) async {
    if (pin.length < 4 || pin.length > 6) return;
    await storage.setPin(pin);
    hasPin.value = true;
  }

  Future<void> removePin() async {
    await storage.removePin();
    hasPin.value = false;
  }

  Future<void> backup() async {
    final file = await Get.find<DatabaseService>().createBackupCopy();
    await Share.shareXFiles([XFile(file.path)]);
  }
}