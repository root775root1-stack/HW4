import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/session_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../routes/app_routes.dart';

class PinController extends GetxController {
  final input = TextEditingController();
  final error = ''.obs;

  void submit() {
    final storage = Get.find<StorageService>();
    if (storage.verifyPin(input.text)) {
      Get.find<SessionService>().unlocked = true;
      Get.offAllNamed(Routes.home);
    } else {
      error.value = 'wrong_pin'.tr;
      input.clear();
    }
  }

  @override
  void onClose() {
    input.dispose();
    super.onClose();
  }
}