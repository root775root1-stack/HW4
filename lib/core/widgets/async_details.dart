import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/data_bus.dart';
import 'common_widgets.dart';

/// Loads data for a details screen, shows loading / error-with-retry, and
/// reloads automatically whenever any module changes data (DataBus).
class AsyncDetails<T> extends StatefulWidget {
  const AsyncDetails({
    super.key,
    required this.loader,
    required this.builder,
  });

  final Future<T> Function() loader;
  final Widget Function(
      BuildContext context, T data, Future<void> Function() reload) builder;

  @override
  State<AsyncDetails<T>> createState() => _AsyncDetailsState<T>();
}

class _AsyncDetailsState<T> extends State<AsyncDetails<T>> {
  T? _data;
  Object? _error;
  bool _loading = true;
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    _load();
    _worker = ever(Get.find<DataBus>().tick, (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = true);
    try {
      final d = await widget.loader();
      if (!mounted) return;
      setState(() {
        _data = d;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingState();
    if (_error != null || _data == null) {
      return ErrorState(message: _error?.toString(), onRetry: _load);
    }
    return widget.builder(context, _data as T, _load);
  }
}
