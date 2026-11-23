import 'package:get/get.dart';

import 'pin_controller.dart';

class PinBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => PinController());
}
