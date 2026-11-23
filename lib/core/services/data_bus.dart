import 'package:get/get.dart';

/// Global change notifier. Any module that mutates data calls [bump];
/// listeners (dashboard, lists) refresh through a Worker (`ever`).
class DataBus extends GetxService {
  final tick = 0.obs;
  void bump() => tick.value++;
}
