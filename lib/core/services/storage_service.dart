import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/app_constants.dart';

/// Simple key/value settings (language, theme, PIN, currency, owner profile,
/// default contract settings). Relational data lives in SQLite.
class StorageService extends GetxService {
  late final GetStorage _box;

  Future<StorageService> init() async {
    _box = GetStorage();
    return this;
  }

  // ---- language (Arabic is the default / primary language)
  String get langCode => _box.read<String>('lang') ?? 'ar';
  bool get isArabic => langCode == 'ar';

  Locale get locale =>
      isArabic ? const Locale('ar', 'SA') : const Locale('en', 'US');

  Future<void> setLang(String code) async {
    await _box.write('lang', code);
    Get.updateLocale(locale);
  }

  // ---- theme
  ThemeMode get themeMode =>
      (_box.read<bool>('dark') ?? false) ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDark(bool v) async {
    await _box.write('dark', v);
    Get.changeThemeMode(themeMode);
  }

  // ---- PIN (salted SHA-256 hash, never the raw PIN)
  bool get hasPin => (_box.read<String>('pin_hash') ?? '').isNotEmpty;

  String _hash(String pin) =>
      sha256.convert(utf8.encode('ptms.v1.$pin')).toString();

  Future<void> setPin(String pin) => _box.write('pin_hash', _hash(pin));
  Future<void> removePin() => _box.remove('pin_hash');
  bool verifyPin(String pin) => _box.read<String>('pin_hash') == _hash(pin);

  // ---- currency
  String get currency =>
      _box.read<String>('currency') ?? AppConstants.defaultCurrency;
  Future<void> setCurrency(String v) => _box.write('currency', v);

  // ---- owner profile (pre-fills the landlord section of contracts)
  Map<String, dynamic> get owner =>
      Map<String, dynamic>.from(_box.read('owner') ?? {});
  Future<void> setOwner(Map<String, dynamic> v) => _box.write('owner', v);

  // ---- default contract settings
  Map<String, dynamic> get contractDefaults =>
      Map<String, dynamic>.from(_box.read('contract_defaults') ?? {});
  Future<void> setContractDefaults(Map<String, dynamic> v) =>
      _box.write('contract_defaults', v);
}
