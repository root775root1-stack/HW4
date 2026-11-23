import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pin_controller.dart';

class PinView extends GetView<PinController> {
  const PinView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: s.primaryContainer, shape: BoxShape.circle),
                      child: Icon(Icons.lock_rounded,
                          size: 40, color: s.onPrimaryContainer),
                    ),
                    const SizedBox(height: 16),
                    Text('enter_pin'.tr,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < PinController.maxLen; i++)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i < controller.digits.value.length
                                      ? (controller.error.value
                                          ? s.error
                                          : s.primary)
                                      : s.outlineVariant,
                                ),
                              ),
                          ],
                        )),
                    const SizedBox(height: 10),
                    Obx(() => SizedBox(
                          height: 22,
                          child: controller.error.value
                              ? Text('wrong_pin'.tr,
                                  style: TextStyle(color: s.error))
                              : null,
                        )),
                    const SizedBox(height: 16),
                    _keypad(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _keypad(BuildContext context) {
    Widget key(Widget child, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            width: 72,
            height: 62,
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18))),
              onPressed: onTap,
              child: child,
            ),
          ),
        );
    Widget num(String d) => key(Text(d, style: const TextStyle(fontSize: 22)),
        () => controller.press(d));
    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (final d in row) num(d)],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            key(const Icon(Icons.backspace_outlined), controller.backspace),
            num('0'),
            key(const Icon(Icons.check), controller.submit),
          ],
        ),
      ],
    );
  }
}
