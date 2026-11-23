import 'translation_data.dart';

/// Looks up a translation outside the widget tree (used by PDF generation,
/// which must render in whichever language the contract was written in,
/// independent of the app's current UI locale).
String labelFor(String key, String lang) {
  final entry = kTranslations[key];
  if (entry == null) return key;
  return entry[lang] ?? entry['en'] ?? key;
}
