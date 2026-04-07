import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:siot_manager_pro/controller/home.dart';
import 'package:siot_manager_pro/services/chart.dart';
import '../../models/sensors.dart';

class ChartController extends GetxController {
  // ─── State ────────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxInt periodIndex = 0.obs;
  final RxList<SensorModel> raw = <SensorModel>[].obs;

  // ─── Chart spots ──────────────────────────────────────────────────────────
  final RxList<FlSpot> tempSpots = <FlSpot>[].obs;
  final RxList<FlSpot> humSpots = <FlSpot>[].obs;
  final RxList<FlSpot> luxSpots = <FlSpot>[].obs;
  final RxList<FlSpot> co2Spots = <FlSpot>[].obs;

  // ─── Averages ─────────────────────────────────────────────────────────────
  final RxDouble avgTemp = 0.0.obs;
  final RxDouble avgHum = 0.0.obs;
  final RxDouble avgLux = 0.0.obs;
  final RxDouble avgCo2 = 0.0.obs;

  // ─── Period map ───────────────────────────────────────────────────────────
  static const _periodDays = [1, 7, 30];
  static const periods = ['Jour', 'Semaine', 'Mois']; //['24h', '7j', '30j'];

  // ─── User ─────────────────────────────────────────────────────────────────
  String get _uuid =>
      Hive.box('login').getAt(0)['uuid_manager'] as String? ?? '';

  // ─── Actions ──────────────────────────────────────────────────────────────

  void changePeriod(int index, String? mac) {
    periodIndex.value = index;
    getChart(mac);
  }

  // ─── API ──────────────────────────────────────────────────────────────────

  Future<void> getChart(String? mac) async {
    await _run(() async {
      Map<String, dynamic> response;

      if (mac != null) {
        response = await chartService.chartTags({
          'uuid_manager': _uuid,
          'MacAddrs': mac,
          'nb_days': _periodDays[periodIndex.value].toString(),
        });
      } else {
        response = await chartService.chartAll({
          'uuid_manager': _uuid,
          'space_uuid':
              homeController.rooms
                  .firstWhere(
                    (e) => e.spaceName == homeController.selectedSpace.value,
                  )
                  .spaceUuid,
          'nb_days': _periodDays[periodIndex.value].toString(),
        });
      }

      // 🔥 unify source
      final data =
          mac != null
              ? response['DATA_TAGS_GRAPH']
              : response['DATA_SPACE_GRAPH'];

      final list = data?['LIST'];

      // ✅ SAFE CHECK
      if (list == null || list is! List || list.isEmpty) {
        print("⚠️ Chart LIST is empty");

        raw.clear();
        _clearSpots(); // 🔥 important (see below)

        return;
      }

      // ✅ parse safely
      final fetched =
          list.map((e) => SensorModel.fromJson(e)).toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

      raw.assignAll(fetched);

      _buildSpots();
    });
  }

  void _clearSpots() {
    tempSpots.clear();
    humSpots.clear();
    luxSpots.clear();
    co2Spots.clear();

    avgTemp.value = 0;
    avgHum.value = 0;
    avgLux.value = 0;
    avgCo2.value = 0;
  }

  // ─── Spot builder ─────────────────────────────────────────────────────────

  void _buildSpots() {
    final temps = <FlSpot>[];
    final hums = <FlSpot>[];
    final luxs = <FlSpot>[];
    final co2s = <FlSpot>[];

    // ✅ Single loop instead of 4 separate passes
    for (int i = 0; i < raw.length; i++) {
      final r = raw[i];
      final x = i.toDouble();
      temps.add(FlSpot(x, r.temperature));
      hums.add(FlSpot(x, r.humidity));
      luxs.add(FlSpot(x, r.illumination));
      co2s.add(FlSpot(x, r.pression.toDouble()));
    }

    tempSpots.assignAll(temps);
    humSpots.assignAll(hums);
    luxSpots.assignAll(luxs);
    co2Spots.assignAll(co2s);

    _calculateAverages();
  }

  // ─── Average calculator ───────────────────────────────────────────────────

  void _calculateAverages() {
    if (raw.isEmpty) return;
    final count = raw.length;

    // ✅ Single fold pass instead of 4 separate reduce calls
    double sumTemp = 0, sumHum = 0, sumLux = 0, sumCo2 = 0;
    for (final r in raw) {
      sumTemp += r.temperature;
      sumHum += r.humidity;
      sumLux += r.illumination;
      sumCo2 += r.pression;
    }

    avgTemp.value = sumTemp / count;
    avgHum.value = sumHum / count;
    avgLux.value = sumLux / count;
    avgCo2.value = sumCo2 / count;
  }

  // ─── Shared loader ────────────────────────────────────────────────────────

  Future<void> _run(Future<void> Function() action) async {
    isLoading.value = true;
    try {
      await action();
    } catch (e) {
      debugPrint('ChartController error: $e');
      Get.snackbar('Erreur', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}

final chartController = Get.put(ChartController());
