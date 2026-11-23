import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/app_constants.dart';

/// Simple key/value settings (language, theme, PIN, currency, owner info).
/// Relational data lives in SQLite, never here.
class StorageService extends GetxService {
  late final GetStorage _box;

  Future<StorageService> init() async {
    _box = GetStorage();
    return this;
  }

  // ---- language
  Locale get locale => (_box.read<String>('lang') ?? 'ar') == 'ar'
      ? const Locale('ar', 'SA')
      : const Locale('en', 'US');

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

  String _hash(String pin) {
    const salt = 'ptms.v1.';
    return sha256.convert(utf8.encode('$salt$pin')).toString();
  }

  Future<void> setPin(String pin) => _box.write('pin_hash', _hash(pin));
  Future<void> removePin() => _box.remove('pin_hash');
  bool verifyPin(String pin) => _box.read<String>('pin_hash') == _hash(pin);

  // ---- currency & owner
  String get currency =>
      _box.read<String>('currency') ?? AppConstants.defaultCurrency;
  Future<void> setCurrency(String v) => _box.write('currency', v);

  Map<String, dynamic> get owner =>
      Map<String, dynamic>.from(_box.read('owner') ?? {});
  Future<void> setOwner(Map<String, dynamic> v) => _box.write('owner', v);
}