import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../controller/history.dart';
import '../../controller/home.dart';
import '../../models/sensors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // ─── Date formatters ──────────────────────────────────────────────────────
  static final _dateFmt = DateFormat('dd-MM-yyyy');
  static final _timeFmt = DateFormat('HH:mm:ss');

  static const _periods = ['Jour', 'Semaine' /*, 'Mois'*/];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              _buildHeader(context),
              _buildPeriodTabs(context),
              Expanded(
                child:
                    historyController.isLoading.value &&
                            historyController.history.isEmpty
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        )
                        : _buildList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historique',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                // ✅ Sensor selector dropdown
                GestureDetector(
                  onTap: _openTagPicker,
                  child: Obx(
                    () => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          historyController.selectedTag.value.isEmpty
                              ? 'Sélectionner un capteur'
                              : historyController.selectedTag.value,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            onTap: historyController.getAllTags,
            icon: Image.asset(
              'assets/images/home/refresh.png',
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          AppIconButton(
            onTap: () => _openDelayDialog(context),
            icon: const Icon(Icons.timer_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ─── Tag picker bottom sheet ──────────────────────────────────────────────

  void _openTagPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(
          () => ListView.separated(
            shrinkWrap: true,
            itemCount: historyController.allTags.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final tag = historyController.allTags[index];
              return ListTile(
                title: Text(tag.name),
                trailing:
                    historyController.selectedTag.value == tag.name
                        ? const Icon(Icons.check, color: AppTheme.primary)
                        : null,
                onTap: () => historyController.selectTag(tag),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openDelayDialog(BuildContext context) {
    final box = Hive.box('login');
    final data = Map<String, dynamic>.from(box.getAt(0));

    final controller = TextEditingController(
      text: data['manager_delay_recordings']?.toString() ?? '',
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Handle ─────────────────────────────
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const Icon(Icons.timer, size: 40, color: Colors.black87),
              const SizedBox(height: 10),
              // ─── Title ──────────────────────────────
              const Text(
                'Délai d’enregistrement',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 16),

              // ─── Input ──────────────────────────────
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Entrer le délai',
                  suffixText: 'sec',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // ─── Actions ────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final value = int.tryParse(controller.text);
                        if (value == null || value <= 0) {
                          Get.snackbar('Erreur', 'Valeur invalide');
                          return;
                        }
                        data['manager_delay_recordings'] = value;
                        box.putAt(0, data);
                        final tag =
                            historyController.allTags
                                .where(
                                  (t) =>
                                      t.name ==
                                      historyController.selectedTag.value,
                                )
                                .firstOrNull;
                        if (tag != null) historyController.getHistory(tag.mac);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ─── Period tabs ──────────────────────────────────────────────────────────

  Widget _buildPeriodTabs(BuildContext ctx) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: List.generate(_periods.length, (i) {
                  final active = historyController.periodIndex.value == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => historyController.changePeriod(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(
                          right: i < _periods.length - 1 ? 8 : 0,
                        ),
                        height: 40,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              active
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _periods[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                active
                                    ? AppTheme.primary
                                    : Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: AppIconButton(
                onTap: () async {
                  var results = await showCalendarDatePicker2Dialog(
                    context: ctx,
                    config: CalendarDatePicker2WithActionButtonsConfig(
                      calendarType: CalendarDatePicker2Type.range,
                      firstDate: DateTime.now().subtract(Duration(days: 30)),
                      lastDate: DateTime.now(),
                      selectedDayHighlightColor: AppTheme.primary,
                      daySplashColor: AppTheme.primary.withValues(alpha: 0),
                      okButton: Text(
                        'Enregistrer',
                        style: TextStyle(color: AppTheme.primary),
                      ),
                      cancelButton: Text('Annuler'),
                    ),
                    dialogSize: const Size(300, 300),
                    value: historyController.range,
                    borderRadius: BorderRadius.circular(16),
                  );
                  if (results != null) historyController.onDate(results);
                },
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── History list ─────────────────────────────────────────────────────────

  Widget _buildList() {
    return Obx(() {
      if (historyController.history.isEmpty) {
        return const Center(
          child: Text(
            'Aucun historique disponible',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(14),
        controller: historyController.paginateCtrl,
        itemCount: historyController.history.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          if (i < historyController.history.length) {
            final r =
                historyController.history[historyController.history.length -
                    1 -
                    i];
            return _buildHistoryItem(r);
          } else {
            if (historyController.history.length <
                historyController.total.value) {
              return Center(child: CupertinoActivityIndicator(radius: 12));
            }
            return SizedBox();
          }
        },
      );
    });
  }

  Widget _buildHistoryItem(SensorModel r) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // ─── Date & time ────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateFmt.format(r.dateTime),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_timeFmt.format(r.dateTime)} · Mobile',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // ─── Sensor values ───────────────────────────────────────────────
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (homeController.access.value!.temperature == 1)
                  _valueChip(
                    '${r.temperature.toStringAsFixed(1)} °C',
                    AppTheme.primary,
                    Icons.thermostat,
                  ),
                if (homeController.access.value!.humidity == 1)
                  _valueChip(
                    '${r.humidity.toStringAsFixed(1)} %',
                    AppTheme.blue,
                    Icons.water_drop_outlined,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueChip(String value, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
