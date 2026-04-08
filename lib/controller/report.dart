import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:siot_manager_pro/controller/home.dart';
import '/models/report.dart';
import '/services/report.dart';
import '../../models/rooms.dart';

class ReportController extends GetxController {
  // ─── State ────────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxString selectedSpace = ''.obs;
  final RxList<ReportModel> reports = <ReportModel>[].obs;

  // ─── Stats ─────────────────────────────────────────────────────────────
  final RxInt mesures = 0.obs, alerts = 0.obs, tags = 0.obs;
  final RxString uptime = DateTime.now().toString().obs;

  void setMouth(int year, mouth) {
    selectedYear.value = year;
    selectedMonth.value = mouth;
  }

  void selectRoom(RoomModel room) {
    selectedSpace.value = room.spaceName;
    getReports(room.spaceUuid);
    Get.back();
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    selectRoom(homeController.rooms.first);
  }

  // ─── API calls ────────────────────────────────────────────────────────────

  Future<void> getReports(String spaceId) async {
    isLoading.value = true;

    try {
      await Future.delayed(const Duration(seconds: 1));

      final response = await reportService.fetchReport({
        'uuid_manager': Hive.box('login').getAt(0)['uuid_manager'],
        'space_uuid': spaceId,
        'year': selectedYear.value,
        'mouth': selectedMonth.value,
      });

      final result = response['DATA_SPACE_REPORT'];

      if (result == null) {
        print("❌ DATA_SPACE_REPORT is null");

        // clear everything
        reports.clear();
        mesures.value = 0;
        alerts.value = 0;
        tags.value = 0;
        uptime.value = DateTime.now().toString();

        return;
      }

      print(result);

      final isSuccess =
          result['error'] == 'false' && result['connection_established'] == 1;

      if (!isSuccess) {
        Get.snackbar('Échec de connexion', result['message']);

        // 🔥 clear stale data
        reports.clear();
        mesures.value = 0;
        alerts.value = 0;
        tags.value = 0;
        uptime.value = DateTime.now().toString();

        return;
      }

      // ✅ SAFE LIST CHECK
      final list = result['LIST'];

      if (list == null || list is! List || list.isEmpty) {
        print("⚠️ Reports LIST is empty");

        reports.clear();

        // still keep stats if backend sends them
        mesures.value = result["total_mesures"] ?? 0;
        alerts.value = result["nb_alertes"] ?? 0;
        tags.value = result["actif_tags"] ?? 0;
        uptime.value = result["uptime"] ?? DateTime.now().toString();

        return;
      }

      final fetched = list.map((e) => ReportModel.fromJson(e)).toList();

      // ✅ assign data
      reports.assignAll(fetched);

      mesures.value = result["total_mesures"] ?? 0;
      alerts.value = result["nb_alertes"] ?? 0;
      tags.value = result["actif_tags"] ?? 0;
      uptime.value = result["uptime"] ?? 0;
    } catch (e) {
      Get.snackbar('Erreur', e.toString());

      // 🔥 safety reset
      reports.clear();
    } finally {
      isLoading.value = false;
    }
  }
}

final reportController = Get.put(ReportController());
