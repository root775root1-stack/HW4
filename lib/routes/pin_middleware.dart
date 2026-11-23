import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/session_service.dart';
import '../core/services/storage_service.dart';
import 'app_routes.dart';

class PinMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();
    final session = Get.find<SessionService>();
    if (storage.hasPin && !session.unlocked) {
      return const RouteSettings(name: Routes.pin);
    }
    return null;
  }
}
