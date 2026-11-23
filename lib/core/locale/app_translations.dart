import 'package:get/get.dart';

import 'translation_data.dart';

/// Wires [kTranslations] into GetX so every widget can call `'key'.tr`.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys {
    final en = <String, String>{};
    final ar = <String, String>{};
    kTranslations.forEach((k, v) {
      en[k] = v['en'] ?? k;
      ar[k] = v['ar'] ?? v['en'] ?? k;
    });
    return {'en_US': en, 'ar_SA': ar};
  }
}
