import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('about'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: s.primaryContainer, shape: BoxShape.circle),
              child: Icon(Icons.apartment_rounded,
                  size: 48, color: s.onPrimaryContainer),
            ),
          ),
          const SizedBox(height: 16),
          Center(
              child: Text('app_name'.tr,
                  style: Theme.of(context).textTheme.titleLarge)),
          Center(
              child: Text('${'app_version'.tr}: ${AppConstants.appVersion}',
                  style: TextStyle(color: s.onSurfaceVariant))),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('legal_note_title'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('legal_note_body'.tr),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
