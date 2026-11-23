import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/services/database_service.dart';
import '../../../core/services/data_bus.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/common_widgets.dart';

class SettingsController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final isArabic = false.obs;
  final isDark = false.obs;
  final hasPin = false.obs;
  final currency = ''.obs;

  @override
  void onInit() {
    super.onInit();
    isArabic.value = storage.isArabic;
    isDark.value = storage.themeMode == ThemeMode.dark;
    hasPin.value = storage.hasPin;
    currency.value = storage.currency;

    ever(isArabic, (bool v) => storage.setLang(v ? 'ar' : 'en'));
    ever(isDark, (bool v) => storage.setDark(v));
  }

  Future<void> setCurrency(String v) async {
    if (v.trim().isEmpty) return;
    currency.value = v.trim();
    await storage.setCurrency(v.trim());
    Get.find<DataBus>().bump();
  }

  Future<void> setPin(String pin) async {
    if (pin.length < 4 || pin.length > 6) {
      showErr('pin_length');
      return;
    }
    await storage.setPin(pin);
    hasPin.value = true;
    showOk('pin_set');
  }

  Future<void> removePin() async {
    await storage.removePin();
    hasPin.value = false;
    showOk('pin_removed');
  }

  /// Copies the live database to a file the owner picks with the system
  /// "save" dialog, so it can be kept outside the app (cloud drive, USB, …).
  Future<void> backup() async {
    try {
      final file = await Get.find<DatabaseService>().createBackupCopy();
      final saved = await FilePicker.platform.saveFile(
        fileName: file.path.split(Platform.pathSeparator).last,
        bytes: await file.readAsBytes(),
      );
      if (saved != null) showOk('backup_saved');
    } catch (_) {
      showErr('backup_failed');
    }
  }

  /// Replaces the live database with a previously saved backup file.
  /// A safety copy of the current database is kept automatically.
  Future<void> restore() async {
    if (!await confirmDialog(
        titleKey: 'restore_database',
        messageKey: 'restore_confirm',
        confirmKey: 'confirm',
        destructive: true)) {
      return;
    }
    try {
      final r = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['db']);
      final path = r?.files.single.path;
      if (path == null) return;
      final ok = await Get.find<DatabaseService>().restoreFrom(File(path));
      if (ok) {
        Get.find<DataBus>().bump();
        showOk('restore_ok');
      } else {
        showErr('restore_invalid');
      }
    } catch (_) {
      showErr('restore_failed');
    }
  }
}
