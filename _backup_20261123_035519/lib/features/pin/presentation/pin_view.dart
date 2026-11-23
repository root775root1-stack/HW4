import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'pin_controller.dart';

class PinView extends GetView<PinController> {
  const PinView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 64),
                  const SizedBox(height: 16),
                  Text('enter_pin'.tr,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.input,
                    obscureText: true,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (_) => controller.submit(),
                  ),
                  Obx(() => controller.error.value.isEmpty
                      ? const SizedBox.shrink()
                      : Text(controller.error.value,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error))),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: controller.submit,
                    child: Text('unlock'.tr),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}