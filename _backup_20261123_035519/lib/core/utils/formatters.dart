import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../services/storage_service.dart';

String formatMoney(num v) {
  final cur = Get.find<StorageService>().currency;
  return '${NumberFormat('#,##0.00').format(v)} $cur';
}

String formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);