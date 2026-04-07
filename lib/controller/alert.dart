import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:siot_manager_pro/models/alert.dart';
import 'package:siot_manager_pro/services/alert.dart';

class AlertController extends GetxController {
  // ─── State ────────────────────────────────────────────────────────────────
  final RxInt offset = 0.obs;
  final RxInt total = 0.obs;
  final RxBool isLoading = false.obs;
  final RxInt type = 0.obs;
  final RxList<AlertModel> alerts = <AlertModel>[].obs;
  final ScrollController paginateCtrl = ScrollController();

  // ─── User ─────────────────────────────────────────────────────────────────
  String get _uuid =>
      Hive.box('login').getAt(0)['uuid_manager'] as String? ?? '';

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    getAlerts();
    paginateCtrl.addListener(() {
      if (paginateCtrl.position.pixels >=
              paginateCtrl.position.maxScrollExtent &&
          !isLoading.value &&
          offset.value < total.value) {
        getAlerts(clear: false);
      }
    });
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void changePeriod(int index) {
    type.value = index;
    getAlerts();
  }

  // ─── API calls ────────────────────────────────────────────────────────────

  Future<void> getAlerts({bool clear = true}) async {
    if (clear) offset.value = 1;
    if (clear) alerts.clear();

    await _run(() async {
      final response = await alertService.fetchAlert(
        type: type.value,
        page: offset.value,
        {'uuid_manager': _uuid},
      );

      dynamic result;
      if (type.value == 0) {
        result = response['DATA_ALERTES_TEMPERATUR'];
      } else {
        result = response['DATA_ALERTES_HUMIDITY'];
      }

      final isSuccess =
          result['error'] == 'false' && result['connection_established'] == 1;

      if (!isSuccess) {
        Get.snackbar(
          'Échec',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 🔥 SAFE LIST CHECK
      final list = result['LIST'];

      if (list == null || list is! List || list.isEmpty) {
        print("⚠️ Empty alerts list");

        // stop pagination
        total.value = offset.value;

        return;
      }

      final fetched = list.map((e) => AlertModel.fromJson(e)).toList();

      alerts.addAll(fetched);

      total.value = result['total_pages'] ?? 0;
      offset.value++;
    });
  }

  // ─── Shared loading wrapper ───────────────────────────────────────────────

  Future<void> _run(Future<void> Function() action) async {
    isLoading.value = true;
    try {
      await action();
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

final alertController = Get.put(AlertController());
