import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/services/history.dart';
import '../../models/sensors.dart';

class HistoryController extends GetxController {
  // ─── State ────────────────────────────────────────────────────────────────
  final RxInt offset = 0.obs;
  final RxInt total = 0.obs;
  final RxBool isLoading = false.obs;
  final RxInt periodIndex = 0.obs;
  final RxString selectedTag = ''.obs;
  final RxList<SensorModel> allTags = <SensorModel>[].obs;
  final RxList<SensorModel> history = <SensorModel>[].obs;
  final ScrollController paginateCtrl = ScrollController();

  // ─── User ─────────────────────────────────────────────────────────────────
  String get _uuid =>
      Hive.box('login').getAt(0)['uuid_manager'] as String? ?? '';

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    getAllTags();
    paginateCtrl.addListener(() {
      if (paginateCtrl.position.pixels >=
              paginateCtrl.position.maxScrollExtent &&
          !isLoading.value &&
          history.length < total.value) {
        final tag =
            allTags.where((t) => t.name == selectedTag.value).firstOrNull;
        if (tag != null) getHistory(tag.mac, clear: false);
      }
    });
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void changePeriod(int index) {
    periodIndex.value = index;
    final tag = allTags.where((t) => t.name == selectedTag.value).firstOrNull;
    if (tag != null) getHistory(tag.mac);
  }

  void selectTag(SensorModel tag) {
    selectedTag.value = tag.name;
    getHistory(tag.mac);
    Get.back();
  }

  var range = <DateTime?>[].obs;
  void onDate(List<DateTime?>? input) {
    range.clear();
    if (input == null || input.length < 2) return;
    range.value = input;
    periodIndex.value = 2;
    final tag = allTags.where((t) => t.name == selectedTag.value).firstOrNull;
    if (tag != null) getHistory(tag.mac);
  }

  // ─── API calls ────────────────────────────────────────────────────────────

  Future<void> getAllTags() async {
    await _run(() async {
      final response = await historyService.fetchTags({'uuid_manager': _uuid});
      final result = response['LIST_CAPTEURS'];

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

      allTags.assignAll(
        (result['LIST'] as List).map((e) => SensorModel.fromJson(e)).toList(),
      );

      if (allTags.isNotEmpty) {
        selectedTag.value = allTags.first.name;
        await getHistory(allTags.first.mac);
      }
    });
  }

  Future<void> getHistory(String mac, {bool clear = true}) async {
    if (clear) offset.value = 1;
    if (clear) history.clear();
    await _run(() async {
      final response = await historyService.fetchHistory(
        type: periodIndex.value,
        page: offset.value,
        {
          'uuid_manager': _uuid,
          'MacAddrs': mac,
          if (range.isNotEmpty) 'start_date': '${range.first}'.split(' ').first,
          if (range.isNotEmpty) 'end_date': '${range.last}'.split(' ').first,
          'manager_delay_recordings':
              Hive.box('login').getAt(0)['manager_delay_recordings'],
        },
      );
      final result = response['DATA_TAGS_DAY'];
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

      print(result);

      final fetched =
          (result['LIST'] as List).map((e) => SensorModel.fromJson(e)).toList();

      history.value += fetched;
      total.value = result['Nbr_registration'];
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

final historyController = Get.put(HistoryController());
