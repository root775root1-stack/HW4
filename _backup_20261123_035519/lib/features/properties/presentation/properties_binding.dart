import 'package:get/get.dart';

import 'properties_controller.dart';

class PropertiesBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => PropertiesController());
}