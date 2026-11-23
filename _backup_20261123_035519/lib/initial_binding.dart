import 'package:get/get.dart';

import 'features/properties/data/property_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PropertyRepository>(() => PropertyRepository(), fenix: true);
  }
}