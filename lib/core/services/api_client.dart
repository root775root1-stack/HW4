import 'package:get/get.dart';

/// Placeholder for future server sync (v1 is fully offline).
class ApiClient extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://example.invalid';
    httpClient.timeout = const Duration(seconds: 20);
  }
}
