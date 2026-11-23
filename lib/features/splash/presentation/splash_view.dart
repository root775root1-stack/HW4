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
    // Catch up on monthly obligations missed while the app was closed.
    try {
      await Get.find<ObligationService>().runCatchUp();
    } catch (e) {
      debugPrint('Obligation catch-up failed: $e');
    }
    await Future.delayed(const Duration(milliseconds: 700));
    // PinMiddleware redirects to the PIN screen when a PIN is set.
    Get.offAllNamed(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: s.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                  color: s.onPrimary.withValues(alpha: 0.15),
                  shape: BoxShape.circle),
              child:
                  Icon(Icons.apartment_rounded, size: 72, color: s.onPrimary),
            ),
            const SizedBox(height: 20),
            Text('app_name'.tr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: s.onPrimary, fontWeight: FontWeight.w800)),
            const SizedBox(height: 28),
            SizedBox(
              width: 26,
              height: 26,
              child:
                  CircularProgressIndicator(strokeWidth: 3, color: s.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

extension on Color {
  withValues({required double alpha}) {}
}
