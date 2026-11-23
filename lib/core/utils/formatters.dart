import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../services/storage_service.dart';

String formatMoney(num? v, {String? currency}) {
  final cur = currency ?? Get.find<StorageService>().currency;
  return '${NumberFormat('#,##0.00', 'en').format(v ?? 0)} $cur';
}

String formatNumber(num? v) => NumberFormat('#,##0.##', 'en').format(v ?? 0);

String formatDate(DateTime d) => DateFormat('yyyy-MM-dd', 'en').format(d);

DateTime? parseDate(Object? s) {
  if (s == null) return null;
  final t = s.toString();
  if (t.isEmpty) return null;
  return DateTime.tryParse(t);
}

double toD(Object? v) => (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0;

/// Short text for a database value (null-safe).
String txt(Object? v) => (v == null || '$v' == 'null') ? '' : '$v';

// ---------------------------------------------------------------- number words
const _enOnes = [
  '',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
  'eleven',
  'twelve',
  'thirteen',
  'fourteen',
  'fifteen',
  'sixteen',
  'seventeen',
  'eighteen',
  'nineteen'
];
const _enTens = [
  '',
  '',
  'twenty',
  'thirty',
  'forty',
  'fifty',
  'sixty',
  'seventy',
  'eighty',
  'ninety'
];

String _en999(int n) {
  final parts = <String>[];
  if (n >= 100) {
    parts.add('${_enOnes[n ~/ 100]} hundred');
    n %= 100;
  }
  if (n >= 20) {
    parts.add(_enTens[n ~/ 10] + (n % 10 > 0 ? '-${_enOnes[n % 10]}' : ''));
  } else if (n > 0) {
    parts.add(_enOnes[n]);
  }
  return parts.join(' ');
}

const _arOnes = [
  '',
  'واحد',
  'اثنان',
  'ثلاثة',
  'أربعة',
  'خمسة',
  'ستة',
  'سبعة',
  'ثمانية',
  'تسعة',
  'عشرة',
  'أحد عشر',
  'اثنا عشر',
  'ثلاثة عشر',
  'أربعة عشر',
  'خمسة عشر',
  'ستة عشر',
  'سبعة عشر',
  'ثمانية عشر',
  'تسعة عشر'
];
const _arTens = [
  '',
  '',
  'عشرون',
  'ثلاثون',
  'أربعون',
  'خمسون',
  'ستون',
  'سبعون',
  'ثمانون',
  'تسعون'
];
const _arHundreds = [
  '',
  'مائة',
  'مائتان',
  'ثلاثمائة',
  'أربعمائة',
  'خمسمائة',
  'ستمائة',
  'سبعمائة',
  'ثمانمائة',
  'تسعمائة'
];

String _ar999(int n) {
  final parts = <String>[];
  if (n >= 100) {
    parts.add(_arHundreds[n ~/ 100]);
    n %= 100;
  }
  if (n >= 20) {
    final o = n % 10;
    parts.add(o > 0 ? '${_arOnes[o]} و${_arTens[n ~/ 10]}' : _arTens[n ~/ 10]);
  } else if (n > 0) {
    parts.add(_arOnes[n]);
  }
  return parts.join(' و');
}

/// Converts a whole amount to words ('ar' or 'en'). Decimals are ignored.
/// The result is only a suggestion: the contract field stays editable.
String numberToWords(num value, String lang) {
  var n = value.floor();
  if (n <= 0) return lang == 'ar' ? 'صفر' : 'zero';
  final ar = lang == 'ar';
  const enScale = ['', ' thousand', ' million', ' billion'];
  final groups = <int>[];
  while (n > 0) {
    groups.add(n % 1000);
    n ~/= 1000;
  }
  final out = <String>[];
  for (var i = groups.length - 1; i >= 0; i--) {
    final g = groups[i];
    if (g == 0) continue;
    if (!ar) {
      out.add(_en999(g) + enScale[i]);
      continue;
    }
    if (i == 0) {
      out.add(_ar999(g));
    } else if (i == 1) {
      out.add(g == 1
          ? 'ألف'
          : g == 2
              ? 'ألفان'
              : g <= 10
                  ? '${_ar999(g)} آلاف'
                  : '${_ar999(g)} ألف');
    } else {
      final name = i == 2 ? 'مليون' : 'مليار';
      final plural = i == 2 ? 'ملايين' : 'مليارات';
      out.add(g == 1
          ? name
          : g == 2
              ? '$name' 'ان'
              : g <= 10
                  ? '${_ar999(g)} $plural'
                  : '${_ar999(g)} $name');
    }
  }
  return out.join(ar ? ' و' : ' ');
}
