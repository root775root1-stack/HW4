import 'package:get/get.dart';

import 'core/services/api_client.dart';

/// App-wide lazy dependencies. Core services are registered in main().
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
  }
}
