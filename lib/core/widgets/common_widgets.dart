import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.titleKey,
    this.subtitleKey,
    this.actionKey,
    this.onAction,
  });
  final IconData icon;
  final String titleKey;
  final String? subtitleKey;
  final String? actionKey;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                  color: s.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle),
              child: Icon(icon, size: 44, color: s.primary),
            ),
            const SizedBox(height: 18),
            Text(titleKey.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            if (subtitleKey != null) ...[
              const SizedBox(height: 6),
              Text(subtitleKey!.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: s.onSurfaceVariant)),
            ],
            if (onAction != null && actionKey != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionKey!.tr),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension on Color {
  withValues({required double alpha}) {}
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, this.message, required this.onRetry});
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: s.error),
            const SizedBox(height: 12),
            Text('error_generic'.tr,
                style: Theme.of(context).textTheme.titleMedium),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(message!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: s.onSurfaceVariant)),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text('retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// Chip showing a translated status (`o_<status>`).
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.statusColor(status, Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('o_$status'.tr,
          style:
              TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

/// Card with a titled header, used on details screens.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.titleKey,
    required this.child,
    this.trailing,
    this.icon,
  });
  final String titleKey;
  final Widget child;
  final Widget? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(titleKey.tr,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              if (trailing != null) trailing!,
            ]),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Label / value row.
class InfoRow extends StatelessWidget {
  const InfoRow(this.labelKey, this.value, {super.key, this.rawLabel = false});
  final String labelKey;
  final String? value;
  final bool rawLabel;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty || value == 'null') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(rawLabel ? labelKey : labelKey.tr,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value!,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

/// Square-ish statistic card; tappable.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: c),
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 2),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> confirmDialog({
  String titleKey = 'confirm',
  String messageKey = 'delete_confirm',
  String confirmKey = 'delete',
  bool destructive = true,
}) async {
  final r = await Get.dialog<bool>(
    AlertDialog(
      title: Text(titleKey.tr),
      content: Text(messageKey.tr),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false), child: Text('cancel'.tr)),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Get.theme.colorScheme.error,
                  foregroundColor: Get.theme.colorScheme.onError)
              : null,
          onPressed: () => Get.back(result: true),
          child: Text(confirmKey.tr),
        ),
      ],
    ),
  );
  return r == true;
}

void showOk(String messageKey) => Get.rawSnackbar(
      message: messageKey.tr,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      backgroundColor: Colors.green.shade700,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );

void showErr(String messageKey) => Get.rawSnackbar(
      message: messageKey.tr,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      backgroundColor: Colors.red.shade700,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
