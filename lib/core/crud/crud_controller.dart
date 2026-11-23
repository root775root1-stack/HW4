import 'package:get/get.dart';

import '../services/data_bus.dart';
import 'generic_repository.dart';

/// Base controller for list screens: loading/empty/error states (StateMixin),
/// search, and automatic refresh when any module changes data (DataBus).
abstract class CrudController extends GetxController
    with StateMixin<List<DbRow>> {
  final query = ''.obs;
  List<DbRow> _all = [];
  Worker? _busWorker;

  DataBus get bus => Get.find<DataBus>();

  /// Subclasses return the rows (use joins to add display columns).
  Future<List<DbRow>> fetch();

  /// Columns searched by the search field.
  List<String> get searchColumns => const [];

  /// Optional extra filter (e.g. status chips).
  bool accept(DbRow row) => true;

  @override
  void onInit() {
    super.onInit();
    load();
    _busWorker = ever(bus.tick, (_) => load(silent: true));
  }

  @override
  void onClose() {
    _busWorker?.dispose();
    super.onClose();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) change(null, status: RxStatus.loading());
    try {
      _all = await fetch();
      _apply();
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  void onSearch(String q) {
    query.value = q;
    _apply();
  }

  void refilter() => _apply();

  void _apply() {
    final q = query.value.trim().toLowerCase();
    final list = _all.where((r) {
      if (!accept(r)) return false;
      if (q.isEmpty) return true;
      final cols = searchColumns.isEmpty ? r.keys.toList() : searchColumns;
      return cols.any((c) => '${r[c] ?? ''}'.toLowerCase().contains(q));
    }).toList();
    change(list,
        status: list.isEmpty
            ? (_all.isEmpty ? RxStatus.empty() : RxStatus.success())
            : RxStatus.success());
  }

  int get totalCount => _all.length;
  bool get filteredEmpty => _all.isNotEmpty && (state?.isEmpty ?? true);
}
