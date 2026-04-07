import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:siot_manager_pro/models/access.dart';
import 'package:siot_manager_pro/services/sensor.dart';
import '../../models/rooms.dart';
import '../../models/sensors.dart';

class HomeController extends GetxController {
  // ─── State ────────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isListView = true.obs;
  final RxString selectedSpace = ''.obs;
  final RxString selectedCard = ''.obs;
  final Rxn<AccessModel> access = Rxn<AccessModel>();
  final RxList<RoomModel> rooms = <RoomModel>[].obs;
  final RxList<SensorModel> sensors = <SensorModel>[].obs;

  // ─── Search ───────────────────────────────────────────────────────────────
  final search = TextEditingController().obs;
  final RxString searchQuery = ''.obs;

  // ─── User info ────────────────────────────────────────────────────────────
  String get managerSurname =>
      Hive.box('login').getAt(0)['manager_surname'] as String? ?? '';

  // ─── Filtered sensors ─────────────────────────────────────────────────────
  List<SensorModel> get filteredSensors =>
      sensors
          .where(
            (s) =>
                s.name.toLowerCase().contains(searchQuery.value.toLowerCase()),
          )
          .toList();

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    getAccess();
  }

  @override
  void onClose() {
    search.value.dispose();
    super.onClose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void toggleView(bool listView) => isListView.value = listView;

  void toggleCard(String mac) {
    selectedCard.value = selectedCard.value == mac ? '' : mac;
  }

  void selectRoom(RoomModel room) {
    selectedSpace.value = room.spaceName;
    getSensors(room.spaceUuid);
    Get.back();
  }

  void onSearchChanged(String value) => searchQuery.value = value;

  // ─── API calls ────────────────────────────────────────────────────────────

  Future<void> getAccess() async {
    isLoading.value = true;
    try {
      final response = await sensorService.access({
        'uuid_manager': Hive.box('login').getAt(0)['uuid_manager'],
      });
      access.value = AccessModel.fromJson(response["VALUES_DISPLAY"]);
      await getRooms();
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getRooms() async {
    isLoading.value = true;
    try {
      final response = await sensorService.fetchRooms({
        'uuid_manager': Hive.box('login').getAt(0)['uuid_manager'],
      });

      final result = response['LIST_STORAGE_SPACE'];

      final isSuccess =
          result['error'] == 'false' && result['connection_established'] == 1;

      if (!isSuccess) {
        // ✅ Show failure and stop
        Get.snackbar('Échec de connexion', result['message']);
        return;
      }

      rooms.assignAll(
        (result["LIST"] as List).map((e) => RoomModel.fromJson(e)).toList(),
      );

      selectedSpace.value = rooms.first.spaceName;
      await getSensors(rooms.first.spaceUuid);
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getSensors(String spaceId) async {
    isLoading.value = true;

    try {
      await Future.delayed(const Duration(seconds: 1));

      final response = await sensorService.fetchSensors({
        'uuid_manager': Hive.box('login').getAt(0)['uuid_manager'],
        'space_uuid': spaceId,
      });

      final result = response['DATA_TAGS'];

      if (result == null) {
        print("❌ DATA_TAGS is null");
        sensors.clear();
        return;
      }

      final isSuccess =
          result['error'] == 'false' && result['connection_established'] == 1;

      if (!isSuccess) {
        Get.snackbar('Échec de connexion', result['message']);
        sensors.clear(); // 🔥 avoid showing old data
        return;
      }

      // 🔥 SAFE LIST CHECK
      final list = result['LIST'];

      if (list == null || list is! List || list.isEmpty) {
        print("⚠️ Sensors LIST is empty");

        sensors.clear(); // 🔥 important

        return;
      }

      final fetched = list.map((e) => SensorModel.fromJson(e)).toList();

      sensors.assignAll(fetched);
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
      sensors.clear(); // 🔥 safety
    } finally {
      isLoading.value = false;
    }
  }
}

final homeController = Get.put(HomeController());
