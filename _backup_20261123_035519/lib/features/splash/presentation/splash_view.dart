import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/obligation_service.dart';
import '../../../routes/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // Catch up on any monthly obligations missed while the app was closed.
    try {
      await Get.find<ObligationService>().runCatchUp();
    } catch (e) {
      debugPrint('Obligation catch-up failed: $e');
    }
    await Future.delayed(const Duration(milliseconds: 600));
    // PinMiddleware redirects to the PIN screen when needed.
    Get.offAllNamed(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apartment,
                size: 88, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('app_name'.tr,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}