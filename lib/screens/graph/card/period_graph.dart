import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controller/chart.dart';
import '/models/sensors.dart';
import '../../../theme/app_theme.dart';

class PeriodGraph extends StatelessWidget {
  const PeriodGraph({super.key, this.sensor});
  final SensorModel? sensor;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(ChartController.periods.length, (i) {
          final active = chartController.periodIndex.value == i;
          return Expanded(
            child: GestureDetector(
              onTap: () async {
                if (i == 2) {
                  var results = await showCalendarDatePicker2Dialog(
                    context: context,
                    config: CalendarDatePicker2WithActionButtonsConfig(
                      calendarType: CalendarDatePicker2Type.single,
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
                    value: chartController.date,
                    borderRadius: BorderRadius.circular(16),
                  );
                  if (results != null) {
                    chartController.onDate(results, sensor?.mac);
                  }
                } else {
                  chartController.changePeriod(i, sensor?.mac);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppTheme.primary : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child:
                      i == 2
                          ? Icon(
                            Icons.calendar_today_outlined,
                            color: active ? Colors.white : AppTheme.textMuted,
                            size: 18,
                          )
                          : Text(
                            ChartController.periods[i],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: active ? Colors.white : AppTheme.textMuted,
                            ),
                          ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
