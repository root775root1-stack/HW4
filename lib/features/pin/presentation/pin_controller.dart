import 'package:get/get.dart';

import '../../../core/services/session_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../routes/app_routes.dart';

class PinController extends GetxController {
  static const maxLen = 6;
  final digits = ''.obs;
  final error = false.obs;

  void press(String d) {
    if (digits.value.length >= maxLen) return;
    error.value = false;
    digits.value += d;
    final storage = Get.find<StorageService>();
    // Unlock as soon as the typed digits match (PIN length is 4-6).
    if (digits.value.length >= 4 && storage.verifyPin(digits.value)) {
      Get.find<SessionService>().unlocked = true;
      Get.offAllNamed(Routes.home);
    } else if (digits.value.length == maxLen) {
      _fail();
    }
  }

  void backspace() {
    if (digits.value.isEmpty) return;
    error.value = false;
    digits.value = digits.value.substring(0, digits.value.length - 1);
  }

  void submit() {
    if (digits.value.length >= 4) _fail();
  }

  void _fail() {
    error.value = true;
    digits.value = '';
  }
}
