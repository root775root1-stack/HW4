import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Temporary page for modules that are not implemented yet.
class PlaceholderView extends StatelessWidget {
  const PlaceholderView({super.key, required this.titleKey});
  final String titleKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titleKey.tr)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction, size: 56),
            const SizedBox(height: 12),
            Text('coming_soon'.tr),
          ],
        ),
      ),
    );
  }
}
