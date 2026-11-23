import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/crud/generic_repository.dart';
import '../../../core/services/file_service.dart';
import '../../../core/widgets/attachments_section.dart';
import '../../../core/widgets/common_widgets.dart';
import '../data/attachment_repository.dart';

class DocumentsController extends GetxController with StateMixin<List<DbRow>> {
  final repo = AttachmentRepository();
  final query = ''.obs;
  List<DbRow> _all = [];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    change(null, status: RxStatus.loading());
    try {
      _all = await repo.listAll();
      _apply();
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  void onSearch(String q) {
    query.value = q;
    _apply();
  }

  void _apply() {
    final q = query.value.trim().toLowerCase();
    final list = q.isEmpty
        ? _all
        : _all
            .where((r) =>
                '${r['name']}'.toLowerCase().contains(q) ||
                '${r['owner_name']}'.toLowerCase().contains(q))
            .toList();
    change(list, status: list.isEmpty ? RxStatus.empty() : RxStatus.success());
  }
}

class DocumentsView extends StatelessWidget {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DocumentsController());
    return Scaffold(
      appBar: AppBar(title: Text('documents'.tr)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            onChanged: controller.onSearch,
            decoration: InputDecoration(
                hintText: 'search'.tr,
                prefixIcon: const Icon(Icons.search),
                isDense: true),
          ),
        ),
        Expanded(
          child: controller.obx(
            (list) => RefreshIndicator(
              onRefresh: controller.load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: list!.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (c, i) => AttachmentTile(
                  row: list[i],
                  showOwner: true,
                  onChanged: controller.load,
                ),
              ),
            ),
            onEmpty: const EmptyState(
                icon: Icons.folder_outlined,
                titleKey: 'no_documents',
                subtitleKey: 'no_documents_hint'),
            onLoading: const LoadingState(),
            onError: (e) => ErrorState(message: e, onRetry: controller.load),
          ),
        ),
      ]),
    );
  }
}
