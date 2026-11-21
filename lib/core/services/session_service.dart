import 'package:get/get.dart';

/// In-memory session state (resets each app launch).
class SessionService extends GetxService {
  bool unlocked = false;
}