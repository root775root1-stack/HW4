import 'package:get/get.dart';

import '../data/property_model.dart';
import '../data/property_repository.dart';

class PropertiesController extends GetxController
    with StateMixin<List<PropertyModel>> {
  final PropertyRepository _repo = Get.find<PropertyRepository>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    change(null, status: RxStatus.loading());
    try {
      final list = await _repo.getAll();
      change(list,
          status: list.isEmpty ? RxStatus.empty() : RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<void> save(PropertyModel p) async {
    if (p.id == null) {
      await _repo.insert(p);
    } else {
      await _repo.update(p);
    }
    await load();
  }

  Future<void> remove(PropertyModel p) async {
    // Business rule: never orphan units / contracts / financial history.
    if (await _repo.unitCount(p.id!) > 0) {
      Get.snackbar('delete'.tr, 'cannot_delete_has_units'.tr);
      return;
    }
    await _repo.delete(p.id!);
    await load();
  }
}